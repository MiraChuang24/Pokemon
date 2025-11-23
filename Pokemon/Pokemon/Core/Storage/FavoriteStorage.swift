//
//  FavoriteStorage.swift
//  Pokemon
//
//  Created by 莊羚羊 on 2025/11/23.
//

import Combine
import Foundation

final class FavoriteStorage {
    private let userDefaultsKey: String = "favoritePokemons"
    private let userDefaults: UserDefaults

    private let queue: DispatchQueue = DispatchQueue(label: "com.pokemon.favoritePokemonsQueue")

    private let subject: CurrentValueSubject<Set<Int>, Never>

    var valuesPublisher: AnyPublisher<Set<Int>, Never> {
        subject.eraseToAnyPublisher()
    }

    fileprivate init(
        userDefaults: UserDefaults = .standard
    ) {
        self.userDefaults = userDefaults
        let storedIDs =
            userDefaults.array(forKey: userDefaultsKey) as? [Int] ?? []
        subject = .init(Set(storedIDs))
    }

    /// 添加收藏
    func add(_ pokemonID: Int) {
        queue.sync {
            var currentValue = self.subject.value
            currentValue.insert(pokemonID)
            subject.send(currentValue)
            saveToUserDefaults()
        }
    }

    /// 移除收藏
    func remove(_ pokemonID: Int) {
        queue.sync {
            var currentValue = self.subject.value
            currentValue.remove(pokemonID)
            subject.send(currentValue)
            saveToUserDefaults()
        }
    }

    /// 切換收藏狀態
    func toggle(_ pokemonID: Int) {
        queue.sync {
            var currentValue = self.subject.value
            if currentValue.contains(pokemonID) {
                currentValue.remove(pokemonID)
            } else {
                currentValue.insert(pokemonID)
            }
            subject.send(currentValue)
            saveToUserDefaults()
        }
    }

    /// 檢查是否為收藏
    func isFavorite(_ pokemonID: Int) -> Bool {
        return subject.value.contains(pokemonID)
    }

    /// 獲取所有收藏的 Pokemon ID
    func getAll() -> Set<Int> {
        return subject.value
    }

    // 儲存到 UserDefaults
    private func saveToUserDefaults() {
        let favoritesArray = Array(subject.value)
        userDefaults.set(favoritesArray, forKey: userDefaultsKey)
    }
}

extension FavoriteStorage {
    static let shared = FavoriteStorage()
    static let test = FavoriteStorage(userDefaults: .init(suiteName: "test")!)
}
