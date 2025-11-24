//
//  MockPokeAPIClient.swift
//  PokemonTests
//
//  Created by 莊雯聿 on 2025/11/24.
//

import Testing

@testable import Pokemon

// Mock implementation for PokeAPIClientType
final class MockPokeAPIClient: PokeAPIClientType {

    // Example mock data
    let mockPokemonList = PokemonListResponse(
        count: 3,
        next: nil,
        previous: nil,
        results: [
            PokeListResult(name: "bulbasaur", url: "https://pokeapi.co/api/v2/pokemon/1/", id: 1),
            PokeListResult(name: "ivysaur", url: "https://pokeapi.co/api/v2/pokemon/2/", id: 2),
            PokeListResult(name: "venusaur", url: "https://pokeapi.co/api/v2/pokemon/3/", id: 3)
        ],
        nextParameters: nil
    )

    let mockPokemonDetail = PokemonDetailResponse(
        id: 1,
        name: "bulbasaur",
        baseExperience: 64,
        height: 7,
        isDefault: true,
        order: 1,
        weight: 69,
        abilities: [],
        forms: [],
        species: Species(name: "bulbasaur", url: ""),
        sprites: Sprites(
            frontDefault: nil, frontShiny: nil, frontFemale: nil, frontShinyFemale: nil,
            backDefault: nil, backShiny: nil, backFemale: nil, backShinyFemale: nil, other: nil
        ),
        stats: [],
        types: [],
        moves: []
    )

    let mockTypeList = TypeListResponse(
        count: 2,
        next: nil,
        previous: nil,
        results: [
            TypeListItem(name: "grass", url: "https://pokeapi.co/api/v2/type/12/"),
            TypeListItem(name: "poison", url: "https://pokeapi.co/api/v2/type/4/")
        ],
        nextParameters: nil
    )

    let mockRegionList = RegionListResponse(
        count: 2,
        next: nil,
        previous: nil,
        results: [
            RegionListItem(name: "kanto", url: "https://pokeapi.co/api/v2/region/1/"),
            RegionListItem(name: "johto", url: "https://pokeapi.co/api/v2/region/2/")
        ],
        nextParameters: nil
    )

    let mockRegionDetail = RegionDetailResponse(
        id: 1,
        name: "kanto",
        locations: [],
        mainGeneration: nil,
        names: [],
        pokedexes: [],
        versionGroups: []
    )

    func fetchPokemonList(limit: Int, offset: Int) async throws -> PokemonListResponse {
        return mockPokemonList
    }

    func fetchPokemonDetail(id: Int) async throws -> PokemonDetailResponse {
        return mockPokemonDetail
    }

    func fetchTypeList(limit: Int, offset: Int) async throws -> TypeListResponse {
        return mockTypeList
    }

    func fetchRegionList() async throws -> RegionListResponse {
        return mockRegionList
    }

    func fetchRegionDetail(id: Int) async throws -> RegionDetailResponse {
        return mockRegionDetail
    }
}
