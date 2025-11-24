//
//  PokemonListViewModel.swift
//  Pokemon
//
//  Created by 莊羚羊 on 2025/11/24.
//

import Combine
import Foundation

@MainActor
class PokemonListViewModel: ObservableObject {

    // MARK: - Published Properties

    @Published var pokemons: [PokemonDetailResponse] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var favorites: Set<Int> = []

    // MARK: - Private Properties

    private let pokeAPIClient: PokeAPIClient
    private let favoriteStorage: FavoriteStorage
    private var cancellables = Set<AnyCancellable>()

    private var nextParameters: APIParameters?
    private var isFetchingMore = false

    // MARK: - Constants

    private let pageSize = 20

    // MARK: - Initialization

    init(
        pokeAPIClient: PokeAPIClient,
        favoriteStorage: FavoriteStorage
    ) {
        self.pokeAPIClient = pokeAPIClient
        self.favoriteStorage = favoriteStorage

        setupFavoritesObserver()
    }

    // MARK: - Public Methods

    func loadInitialData() {
        Task {
            await fetchPokemons(isInitial: true)
        }
    }

    func loadMoreIfNeeded(currentItem: PokemonDetailResponse) {
        // 當滾動到倒數第 5 個時開始載入
        guard
            let index = pokemons.firstIndex(where: { $0.id == currentItem.id }),
            index >= pokemons.count - 5
        else {
            return
        }

        loadMore()
    }

    func loadMore() {
        guard !isFetchingMore, nextParameters != nil else {
            return
        }

        Task {
            await fetchPokemons(isInitial: false)
        }
    }

    func toggleFavorite(pokemonID: Int) {
        favoriteStorage.toggle(pokemonID)
    }

    func refresh() async {
        nextParameters = nil
        pokemons.removeAll()
        await fetchPokemons(isInitial: true)
    }

    // MARK: - Private Methods

    private func setupFavoritesObserver() {
        favoriteStorage.valuesPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] favorites in
                self?.favorites = favorites
            }
            .store(in: &cancellables)
    }

    private func fetchPokemons(isInitial: Bool) async {
        guard !isFetchingMore else { return }

        isFetchingMore = true

        if isInitial {
            isLoading = true
        }

        do {
            let offset = isInitial ? 0 : (nextParameters?.offset ?? 0)
            let response = try await pokeAPIClient.fetchPokemonList(
                limit: pageSize,
                offset: offset
            )

            // 取得 Pokemon 的詳細資訊
            let items = try await fetchPokemonDetails(from: response.results)

            if isInitial {
                pokemons = items
            } else {
                pokemons.append(contentsOf: items)
            }

            nextParameters = response.nextParameters
            errorMessage = nil

        } catch {
            errorMessage =
                "Failed to load Pokémon: \(error.localizedDescription)"
            print("❌ Error loading Pokémon: \(error)")
        }

        isLoading = false
        isFetchingMore = false
    }

    private func fetchPokemonDetails(from results: [PokeListResult])
        async throws -> [PokemonDetailResponse]
    {
        // 使用 TaskGroup 並行載入，但限制並發數量以避免 UI 卡頓
        return try await withThrowingTaskGroup(
            of: (index: Int, pokemon: PokemonDetailResponse?).self
        ) { group in
            var items: [Int: PokemonDetailResponse] = [:]

            // 分批處理，每批最多 5 個並行請求
            for (index, result) in results.enumerated() {
                guard let id = result.id else { continue }

                // 當已經有 5 個任務在執行時，等待其中一個完成
                if index >= 5 {
                    if let completed = try await group.next() {
                        if let pokemon = completed.pokemon {
                            items[completed.index] = pokemon
                        }
                    }
                }

                group.addTask {
                    do {
                        let detail = try await self.pokeAPIClient
                            .fetchPokemonDetail(id: id)
                        return (index, detail)
                    } catch {
                        print("❌ Failed to fetch pokemon \(id): \(error)")
                        return (index, nil)
                    }
                }
            }

            // 收集剩餘的結果
            for try await completed in group {
                if let pokemon = completed.pokemon {
                    items[completed.index] = pokemon
                }
            }

            // 按原始順序返回（保持 ID 順序）
            return items.sorted { $0.key < $1.key }.compactMap { $0.value }
        }
    }
}
