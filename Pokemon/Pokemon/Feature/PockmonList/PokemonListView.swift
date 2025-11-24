//
//  PokemonListView.swift
//  Pokemon
//
//  Created by 莊羚羊 on 2025/11/24.
//

import SwiftUI

struct PokemonListView: View {
    @StateObject private var viewModel = PokemonListViewModel(
        pokeAPIClient: .init(),
        favoriteStorage: .shared
    )
    @EnvironmentObject private var router: MainRouter

    var body: some View {
        mainContent
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .navigationTitle("All Pokémon")
            .navigationBarTitleDisplayMode(.inline)
            .background(Color(.secondarySystemBackground))
            .task {
                // 使用 task ，避免阻塞 UI
                if viewModel.pokemons.isEmpty {
                    // 添加微小延遲，讓 navigation transition 完成
                    try? await Task.sleep(nanoseconds: 200_000_000)  // 0.1 秒
                    viewModel.loadInitialData()
                }
            }
    }
}
extension PokemonListView {
    @ViewBuilder
    fileprivate var mainContent: some View {
        if viewModel.isLoading && viewModel.pokemons.isEmpty {
            loadingView
        } else if let errorMessage = viewModel.errorMessage,
            viewModel.pokemons.isEmpty
        {
            errorView(errorMessage)
        } else {
            listView
        }
    }
    fileprivate func errorView(_ message: String) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 50))
                .foregroundColor(.orange)

            Text("Oops!")
                .font(.title2)
                .fontWeight(.bold)

            Text(message)
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
    }
    fileprivate var loadingView: some View {
        ProgressView()
            .scaleEffect(1.2)
    }
    fileprivate var listView: some View {
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
