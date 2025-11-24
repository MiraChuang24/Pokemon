//
//  PokemonListRowView.swift
//  Pokemon
//
//  Created by 莊羚羊 on 2025/11/24.
//

import Foundation
import SwiftUI

struct PokemonListRowView: View {
    let pokemon: PokemonDetailResponse
    let isFavorite: Bool
    let onFavoriteTap: () -> Void

    @StateObject private var imageViewModel: ImageLoaderViewModel

    init(
        pokemon: PokemonDetailResponse,
        isFavorite: Bool,
        onFavoriteTap: @escaping () -> Void
    ) {
        self.pokemon = pokemon
        self.isFavorite = isFavorite
        self.onFavoriteTap = onFavoriteTap
        _imageViewModel = StateObject(
            wrappedValue: ImageLoaderViewModel(
                urlString: pokemon.sprites.frontDefault ?? ""
            )
        )
    }

    var body: some View {
        HStack(spacing: 16) {
            // Pokemon 圖片
            ImageLoaderView(viewModel: imageViewModel)
                .frame(width: 80, height: 80)

            // Pokemon 資訊
            VStack(alignment: .leading, spacing: 6) {
                // Name
                Text(pokemon.name.capitalized)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)

                // Number
                Text("#\(pokemon.id)")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.secondary)

                // Types
                HStack(spacing: 6) {
                    ForEach(pokemon.types, id: \.self) { typeElement in
                        PokemonTypeTag(
                            type: PokemonType(from: typeElement.type.url)
                        )
                    }
                }
            }

            Spacer()

            // Favorite Button
            Button(action: onFavoriteTap) {
                Image(systemName: isFavorite ? "heart.fill" : "heart")
                    .font(.title2)
                    .foregroundColor(isFavorite ? .red : .gray)
                    .contentTransition(.symbolEffect(.replace))
            }
            .buttonStyle(.plain)
        }
        .padding(8)
        .background(Color(.white))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}

// MARK: - PokemonTypeTag

struct PokemonTypeTag: View {
    let type: PokemonType

    var body: some View {
        Text(type.name.capitalized)
            .font(.caption)
            .fontWeight(.semibold)
            .foregroundColor(.white)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(Color(type.color))
            .cornerRadius(8)
    }
}
