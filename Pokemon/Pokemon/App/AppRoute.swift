//
//  AppRoute.swift
//  Pokemon
//
//  Created by 莊羚羊 on 2025/11/24.
//

import Foundation

/// App 中會被「推進 NavigationStack」的頁面
/// - 首頁是 root，不放在 route 裡
enum AppRoute: Hashable {
    case pokemonList                       // 首頁 "See more" 進入的列表頁
    case pokemonDetail(pokemon: PokemonDetailResponse)            // 任一寶可夢的詳細頁
}
