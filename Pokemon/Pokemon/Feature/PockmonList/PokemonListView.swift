//
//  PokemonListView.swift
//  Pokemon
//
//  Created by 莊羚羊 on 2025/11/24.
//

import SwiftUI

struct PokemonListView: View {
    @StateObject private var viewModel = PokemonListViewModel()
    @EnvironmentObject private var router: MainRouter

    var body: some View {
        ZStack {
            if viewModel.isLoading && viewModel.pokemons.isEmpty {
                // 初次載入
                ProgressView("Loading Pokémon...")
                    .scaleEffect(1.2)
            } else if let errorMessage = viewModel.errorMessage,
                viewModel.pokemons.isEmpty
            {
                // 錯誤狀態
                VStack(spacing: 16) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.system(size: 50))
                        .foregroundColor(.orange)

                    Text("Oops!")
                        .font(.title2)
                        .fontWeight(.bold)

                    Text(errorMessage)
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)

                    Button(action: {
                        viewModel.loadInitialData()
                    }) {
                        Label("Retry", systemImage: "arrow.clockwise")
                            .font(.headline)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
            } else {
                // Pokemon 列表
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(viewModel.pokemons) { pokemon in
                            Button(action: {
                                router.push(.pokemonDetail(pokemon: pokemon))
                            }) {
                                PokemonListRowView(
                                    pokemon: pokemon,
                                    isFavorite: viewModel.favorites.contains(
                                        pokemon.id
                                    ),
                                    onFavoriteTap: {
                                        viewModel.toggleFavorite(
                                            pokemonID: pokemon.id
                                        )
                                    }
                                )
                            }
                            .buttonStyle(.plain)
                            .onAppear {
                                viewModel.loadMoreIfNeeded(currentItem: pokemon)
                            }
                        }

                        // 載入更多指示器
                        if viewModel.isLoading {
                            ProgressView()
                                .padding()
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)
                }
                .refreshable {
                    await viewModel.refresh()
                }
            }
        }
        .navigationTitle("All Pokémon")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            // 使用 task 替代 onAppear，避免阻塞 UI
            if viewModel.pokemons.isEmpty {
                // 添加微小延遲，讓 navigation transition 完成
                try? await Task.sleep(nanoseconds: 300_000_000) // 0.1 秒
                viewModel.loadInitialData()
            }
        }
    }
}
