//
//  PokemonDetailViewModel.swift
//  Pokemon
//
//  Created by 莊羚羊 on 2025/11/24.
//

import Combine
import Foundation

/// Pokemon 詳情頁專用 ViewModel，用 FavoriteStorage 追蹤單一 Pokemon 的收藏狀態
final class PokemonDetailViewModel: ObservableObject {

    // MARK: - Input

    private let pokemonID: Int
    private let storage: FavoriteStorage

    // MARK: - Output

    /// 目前是否已收藏
    @Published private(set) var isFavorite: Bool = false

    // MARK: - Private

    private var cancellables = Set<AnyCancellable>()

    // MARK: - Init

    init(
        pokemonID: Int,
        storage: FavoriteStorage = .shared
    ) {
        self.pokemonID = pokemonID
        self.storage = storage

        // 初始化時先同步一次
        self.isFavorite = storage.isFavorite(pokemonID)

        // 監聽 FavoriteStorage 的變化，對應到 isFavorite
        storage.valuesPublisher
            .map { $0.contains(pokemonID) }
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .assign(to: &$isFavorite)
    }

    // MARK: - Public API

    /// 切換收藏狀態
    func toggleFavorite() {
        storage.toggle(pokemonID)
    }
}

