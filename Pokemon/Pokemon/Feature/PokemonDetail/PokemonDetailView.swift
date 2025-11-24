//
//  PokemonDetailView.swift
//  Pokemon
//
//  Created by 莊羚羊 on 2025/11/24.
//

import SwiftUI

import SwiftUI

struct PokemonDetailView: View {

    // MARK: - Input

    let pokemon: PokemonDetailResponse

    // MARK: - ViewModel

    @StateObject private var viewModel: PokemonDetailViewModel

    // MARK: - Init

    init(
        pokemon: PokemonDetailResponse,
        storage: FavoriteStorage = .shared
    ) {
        self.pokemon = pokemon
        _viewModel = StateObject(
            wrappedValue: PokemonDetailViewModel(
                pokemonID: pokemon.id,
                storage: storage
            )
        )
    }

    // MARK: - 顏色與型別

    private var typeColors: [Color] {
        let types = pokemon.pokemonTypes
        if types.isEmpty {
            return [Color(.systemGreen), Color(.systemPurple)]
        } else if types.count == 1 {
            let c = Color(types[0].color)
            return [c, c.opacity(0.6)]
        } else {
            return [Color(types[0].color), Color(types[1].color)]
        }
    }

    // MARK: - Body

    var body: some View {
        ZStack(alignment: .top) {
            typeColorCare

            ScrollView {
                VStack(spacing: 24) {
                    pokemonImage
                        .padding(.top, 150)

                    VStack(spacing: 16) {
                        // 名稱
                        Text(pokemon.name.capitalized)
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(.primary)

                        // Type 標籤
                        typesRow

                        // 體重 / 身高
                        weightHeightRow

                        // Base Stats
                        statsSection
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 32)
                }
            }
        }
        .ignoresSafeArea()
        .background(Color(.systemBackground))
        .toolbar {
            // 中間的 ID 當作 title
            ToolbarItem(placement: .principal) {
                Text(pokemon.displayID)
                    .font(.headline)
                    .foregroundColor(.white)
            }

            // 右上角收藏按鈕
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    viewModel.toggleFavorite()
                } label: {
                    Image(
                        systemName: viewModel.isFavorite
                            ? "heart.fill" : "heart"
                    )
                    .foregroundColor(.white)
                    .font(.system(size: 20))
                }
            }
        }
    }

    // MARK: - Header（上方漸層）

    private var typeColorCare: some View {
        RoundedRectangle(cornerRadius: 32, style: .continuous)
            .fill(
                LinearGradient(
                    colors: typeColors,
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .frame(height: 300)
            .shadow(radius: 4)
    }

    // MARK: - Pokemon Image

    private var pokemonImage: some View {
        ImageLoaderView(
            viewModel: ImageLoaderViewModel(
                urlString: pokemonImageURL(for: pokemon) ?? ""
            ),
            showBackground: false
        )
        .frame(width: 220, height: 220)
    }

    private func pokemonImageURL(
        for pokemon: PokemonDetailResponse
    ) -> String? {
        pokemon.sprites.other?.officialArtwork?.frontDefault
            ?? pokemon.sprites.frontDefault
    }

    // MARK: - Types Row

    private var typesRow: some View {
        HStack(spacing: 12) {
            ForEach(pokemon.pokemonTypes, id: \.self) { type in
                typeBadge(type)
            }
        }
    }

    private func typeBadge(_ type: PokemonType) -> some View {
    Text(type.name.capitalized)
        .font(.system(size: 14, weight: .semibold))
        .foregroundColor(.white)
        .padding(.horizontal, 18)
        .padding(.vertical, 8)
        .background(
            Capsule()
                .fill(Color(type.color))
        )
}

    // MARK: - Weight / Height

    private var weightHeightRow: some View {
        HStack(spacing: 40) {
            VStack(spacing: 4) {
                Text(String(format: "%.1f KG", Double(pokemon.weight) / 10.0))
                    .font(.system(size: 18, weight: .semibold))
                Text("Weight")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
            }

            VStack(spacing: 4) {
                Text(String(format: "%.1f M", Double(pokemon.height) / 10.0))
                    .font(.system(size: 18, weight: .semibold))
                Text("Height")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
            }
        }
        .padding(.top, 8)
    }

    // MARK: - Base Stats 區塊

    private var statsSection: some View {
        VStack(alignment: .leading, spacing: 25) {
            Text("Base Stats")
                .font(.system(size: 20, weight: .bold))
                .padding(.bottom, 4)

            StatRowView(
                title: "HP",
                value: pokemon.statValue(named: "hp") ?? 0,
                color: .red
            )
            StatRowView(
                title: "ATK",
                value: pokemon.statValue(named: "attack") ?? 0,
                color: .orange
            )
            StatRowView(
                title: "DEF",
                value: pokemon.statValue(named: "defense") ?? 0,
                color: .blue
            )
            StatRowView(
                title: "SPD",
                value: pokemon.statValue(named: "speed") ?? 0,
                color: .cyan
            )
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
