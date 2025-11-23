//
//  PokeAPIClient.swift
//  Pokemon
//
//  Created by 莊羚羊 on 2025/11/23.
//

import Foundation

protocol PokeAPIClientType {

    // MARK: - Pokemon

    /// 取得 Pokemon 列表（有分頁）
    func fetchPokemonList(limit: Int, offset: Int) async throws -> PokemonListResponse

    /// 取得 Pokemon 詳細資訊
    func fetchPokemonDetail(id: Int) async throws -> PokemonDetailResponse

    // MARK: - Type

    /// 取得 Type 列表
//    func fetchTypeList(limit: Int, offset: Int) async throws -> TypeListResponse
//
//    // MARK: - Region
//
//    /// 取得 Region 列表
//    func fetchRegionList() async throws -> RegionListResponse
//
//    /// 取得 Region 詳細資訊
//    func fetchRegionDetail(id: Int) async throws -> RegionDetailResponse
}

/// 實際的 PokeAPI 實作
final class PokeAPIClient: PokeAPIClientType {

    private let httpClient: HTTPClient

    init(httpClient: HTTPClient = URLSessionHTTPClient()) {
        self.httpClient = httpClient
    }

    // MARK: - Pokemon

    func fetchPokemonList(limit: Int, offset: Int) async throws -> PokemonListResponse {
        try await httpClient.sendRequest(
            .pokemonList(limit: limit, offset: offset),
            responseType: PokemonListResponse.self
        )
    }

    func fetchPokemonDetail(id: Int) async throws -> PokemonDetailResponse {
        try await httpClient.sendRequest(
            .pokemonDetail(id: id),
            responseType: PokemonDetailResponse.self
        )
    }

    // MARK: - Type

    func fetchTypeList(limit: Int, offset: Int) async throws -> TypeListResponse {
        try await httpClient.sendRequest(
            .typeList(limit: limit, offset: offset),
            responseType: TypeListResponse.self
        )
    }

    // MARK: - Region

    func fetchRegionList() async throws -> RegionListResponse {
        try await httpClient.sendRequest(
            .regionList,
            responseType: RegionListResponse.self
        )
    }

    func fetchRegionDetail(id: Int) async throws -> RegionDetailResponse {
        try await httpClient.sendRequest(
            .regionDetail(id: id),
            responseType: RegionDetailResponse.self
        )
    }
}
