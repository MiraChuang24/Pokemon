//
//  PokemonDetailView.swift
//  Pokemon
//
//  Created by 莊羚羊 on 2025/11/24.
//

import SwiftUI

struct PokemonDetailView: View {

    // MARK: - Input
    let pokemon: PokemonDetailResponse

    // MARK: - ViewModel
    @StateObject private var viewModel: PokemonDetailViewModel

    // MARK: - 顏色與型別
    private var typeColors: [Color] {
        let types = pokemon.pokemonTypes
        if types.isEmpty {
            return [Color(.white), Color(.white)]
        } else if types.count == 1 {
            let c = Color(types[safe: 0]?.color ?? .white)
            return [c, c.opacity(0.6)]
        } else {
            return [
                Color(types[safe: 0]?.color ?? .white),
                Color((types[safe: 1]?.color ?? .white)),
            ]
        }
    }
    var pokemonImageURL: String? {
        pokemon.sprites.other?.officialArtwork?.frontDefault
            ?? pokemon.sprites.frontDefault
    }
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
    // MARK: - Body
    var body: some View {
        ZStack(alignment: .top) {

            headerView

            ScrollView {
                contentSection
            }
        }
        .ignoresSafeArea()
        .background(Color(.systemBackground))
        .toolbar {
            headerTitle
            favoriteButton
        }
    }
}
extension PokemonDetailView {

    // MARK: Header 漸層區塊
    fileprivate var headerView: some View {
        RoundedRectangle(cornerRadius: 50, style: .continuous)
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
    // MARK: 主內容區塊（Image / Info / Stats）
    fileprivate var contentSection: some View {
        VStack(spacing: 24) {
            pokemonImage
                .padding(.top, 150)

            infoSection
                .padding(.horizontal, 24)
                .padding(.bottom, 32)
        }
    }
    // MARK: Image 區塊
    fileprivate var pokemonImage: some View {
        ImageLoaderView(
            viewModel: ImageLoaderViewModel(
                urlString: pokemonImageURL ?? ""
            ),
            showBackground: false
        )
        .frame(width: 220, height: 220)
    }

    // MARK: Info 區塊（名稱 / Type / 身高體重 / Stats
    fileprivate var infoSection: some View {
        VStack(spacing: 16) {
            nameSection
            typesRow
            weightHeightRow
            statsSection
        }
    }

    fileprivate var nameSection: some View {
        Text(pokemon.name.capitalized)
            .font(.system(size: 32, weight: .bold))
            .foregroundColor(.primary)
    }
    // MARK: Type 標籤
    fileprivate var typesRow: some View {
        HStack(spacing: 12) {
            ForEach(pokemon.pokemonTypes, id: \.self) { type in
                typeBadge(type)
            }
        }
    }

    fileprivate func typeBadge(_ type: PokemonType) -> some View {
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
    // MARK: Weight / Height
    fileprivate var weightHeightRow: some View {
        HStack(spacing: 40) {
            weightColumn
            heightColumn
        }
        .padding(.top, 8)
    }

    fileprivate var weightColumn: some View {
        VStack(spacing: 4) {
            Text("\(Double(pokemon.weight) / 10.0, specifier: "%.1f") KG")
                .font(.system(size: 18, weight: .semibold))
            Text("Weight")
                .font(.system(size: 14))
                .foregroundColor(.secondary)
        }
    }

    fileprivate var heightColumn: some View {
        VStack(spacing: 4) {
            Text("\(Double(pokemon.height) / 10.0, specifier: "%.1f") M")
                .font(.system(size: 18, weight: .semibold))
            Text("Height")
                .font(.system(size: 14))
                .foregroundColor(.secondary)
        }
    }
    // MARK: Base Stats
    fileprivate var statsSection: some View {
        VStack(alignment: .leading, spacing: 25) {
            Text("Base Stats")
                .font(.system(size: 20, weight: .bold))

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
    // MARK: Toolbar 按鈕
    fileprivate var headerTitle: some ToolbarContent {
        ToolbarItem(placement: .principal) {
            Text(pokemon.displayID)
                .font(.headline)
                .foregroundColor(.white)
        }
    }

    fileprivate var favoriteButton: some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
            Button {
                viewModel.toggleFavorite()
            } label: {
                Image(systemName: viewModel.isFavorite ? "heart.fill" : "heart")
                    .foregroundColor(.white)
                    .font(.system(size: 20))
            }
        }
    }
}
