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

    // MARK: - Init

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

    // MARK: - Body

    var body: some View {
        rowContent
            .padding(8)
            .background(Color.white)
            .cornerRadius(16)
            .shadow(
                color: Color.black.opacity(0.1),
                radius: 4,
                x: 0,
                y: 2
            )
    }
}
// MARK: - Subviews

extension PokemonListRowView {

    /// 主要的 Row 內容：圖片 + 資訊 + 收藏按鈕
    fileprivate var rowContent: some View {
        HStack(spacing: 16) {
            pokemonImage
            pokemonInfo
            Spacer()
            favoriteButton
        }
    }

    /// Pokémon 圖片
    fileprivate var pokemonImage: some View {
        ImageLoaderView(viewModel: imageViewModel)
            .frame(width: 80, height: 80)
    }

    /// 名稱 / 編號 / 屬性
    fileprivate var pokemonInfo: some View {
        VStack(alignment: .leading, spacing: 6) {
            nameText
            numberText
            typeTags
        }
    }

    /// 收藏按鈕
    fileprivate var favoriteButton: some View {
        Button(action: onFavoriteTap) {
            Image(systemName: isFavorite ? "heart.fill" : "heart")
                .font(.title2)
                .foregroundColor(isFavorite ? .red : .gray)
                .contentTransition(.symbolEffect(.replace))
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Info Subviews

extension PokemonListRowView {

    fileprivate var nameText: some View {
        Text(pokemon.name.capitalized)
            .font(.title3)
            .fontWeight(.bold)
            .foregroundColor(.primary)
    }

    fileprivate var numberText: some View {
        Text("#\(pokemon.id)")
            .font(.caption)
            .fontWeight(.semibold)
            .foregroundColor(.secondary)
    }

    fileprivate var typeTags: some View {
        HStack(spacing: 6) {
            ForEach(pokemon.types, id: \.self) { typeElement in
                PokemonTypeTag(
                    type: PokemonType(from: typeElement.type.url)
                )
            }
        }
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
