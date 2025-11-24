//
//  HomeViewModel.swift
//  Pokemon
//
//  Created by 莊羚羊 on 2025/11/24.
//

import Combine
import Foundation

class HomeViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var pokemonItems: [HomeItem] = []
    @Published var typeItems: [HomeItem] = []
    @Published var regionItems: [HomeItem] = []
    @Published var errorMessage: String?

    // MARK: - Properties
    var pokemons: [Int: PokemonCareState] = [:]
    // 哪一隻 Pokémon 更新了
    let pokemonDidChange = PassthroughSubject<Int, Never>()

    var regions: [Int: RegionDetailResponse] = [:]
    let regionDidChange = PassthroughSubject<Int, Never>()

    private let pokeAPIClient: PokeAPIClientType
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Init

    init(pokeAPIClient: PokeAPIClientType = PokeAPIClient()) {
        self.pokeAPIClient = pokeAPIClient
    }
    
    @MainActor
    func fetchAllRegion() async {
        errorMessage = nil
        regionItems.removeAll()

        do {
            let response = try await pokeAPIClient.fetchRegionList()
            let ids = response.results.prefix(6).compactMap(\.id)

            // 一次塞好所有 regionItems
            regionItems = ids.map { HomeItem.region($0) }

            // 再去打每個 region 的 detail
            ids.forEach { id in
                regions[id] = nil
                fetchRegion(id: id)
            }
        } catch {
            errorMessage = "Failed to fetch regions: \(error.localizedDescription)"
        }
    }
    private func fetchRegion(id: Int) {
        regions[id] = nil
        regionDidChange.send(id)  // 通知 loading 狀態變了

        Task { [weak self] in
            guard let self else { return }

            do {
                let response = try await pokeAPIClient.fetchRegionDetail(id: id)
                await MainActor.run {
                    self.regions[id] = response
                    self.regionDidChange.send(id)
                }
            } catch {
                await MainActor.run {
                    self.regions[id] = nil
                    self.regionDidChange.send(id)
                }
            }
        }
    }
    @MainActor
    func fetchAllTypes() async {
        errorMessage = nil
        typeItems.removeAll()

        // 避免重複 type，用一個 Set 記錄
        var seenTypes = Set<PokemonType>()

        var nextParameters: APIParameters? = APIParameters(
            offset: 0,
            limit: 10
        )

        while let params = nextParameters {
            do {
                let response = try await pokeAPIClient.fetchTypeList(
                    limit: params.limit,
                    offset: params.offset
                )

                let pageItems: [HomeItem] = response.results.compactMap {
                    result in
                    guard let id = result.id,
                        let type = PokemonType(rawValue: id)
                    else { return nil }

                    // 過濾掉不想要的 type
                    guard type != .unknownType, type != .shadow else {
                        return nil
                    }

                    // 確保每個 type 只出現一次
                    guard seenTypes.insert(type).inserted else {
                        return nil
                    }

                    return .type(type)
                }

                typeItems.append(contentsOf: pageItems)

                nextParameters = response.nextParameters
            } catch {
                errorMessage =
                    "Failed to fetch types: \(error.localizedDescription)"
                break
            }
        }
    }

    @MainActor
    func fetchPokemons() async {
        errorMessage = nil

        do {
            let response = try await pokeAPIClient.fetchPokemonList(
                limit: 9,
                offset: 0
            )
            let ids = response.results.prefix(9).compactMap(\.id)
            pokemonItems = ids.map({ .pokemon($0) })
            ids.forEach { id in
                pokemons[id] = .noData
                fetchPokemon(id: id)
            }
        } catch {
            errorMessage =
                "Failed to fetch Pokémon: \(error.localizedDescription)"
        }
    }
    private func fetchPokemon(id: Int) {
        pokemons[id] = .loading
        pokemonDidChange.send(id)  // 通知 loading 狀態變了

        Task { [weak self] in
            guard let self else { return }

            do {
                let response = try await pokeAPIClient.fetchPokemonDetail(
                    id: id
                )
                await MainActor.run {
                    self.pokemons[id] = .loaded(pokemon: response)
                    self.pokemonDidChange.send(id)  // 再通知一次
                }
            } catch {
                await MainActor.run {
                    self.pokemons[id] = .error
                    self.pokemonDidChange.send(id)
                }
            }
        }
    }

}
