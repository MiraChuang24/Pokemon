//
//  ContentView.swift
//  Pokemon
//
//  Created by 莊羚羊 on 2025/11/23.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var router: MainRouter

    var body: some View {
        NavigationStack(path: $router.path) {
            // UIKit 的 HomeViewController，用 SwiftUI 包起來
            HomeView()
                .navigationTitle("Pokédex")
                .navigationBarTitleDisplayMode(.inline)
                .background(Color(.secondarySystemBackground))
                .navigationDestination(for: AppRoute.self) { route in
                    switch route {
                    case .pokemonList:
                        PokemonListView()

                    case .pokemonDetail(let id):
                        EmptyView()
                    }
                }
        }
    }
}

#Preview {
    ContentView()
}
