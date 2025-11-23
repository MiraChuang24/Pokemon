//
//  PokeAPIEndpoint.swift
//  Pokemon
//
//  Created by 莊羚羊 on 2025/11/23.
//

import Foundation

enum PokeAPIEndpoint: APIEndpoint {
    
    // MARK: - Pokemon 相關

    /// GET /pokemon?limit={limit}&offset={offset}
    case pokemonList(limit: Int, offset: Int)

    /// GET /pokemon/{id}
    case pokemonDetail(id: Int)

    // MARK: - Type 相關

    /// GET /type?limit={limit}&offset={offset}
    case typeList(limit: Int, offset: Int)

    // MARK: - Region 相關

    /// GET /region
    case regionList

    /// GET /region/{id}
    case regionDetail(id: Int)
}

extension PokeAPIEndpoint {

    /// HTTP 方法
    var method: HTTPMethod {
        switch self {
        case .pokemonList,
             .pokemonDetail,
             .typeList,
             .regionList,
             .regionDetail:
            return .get
        }
    }

    /// 相對路徑 path
    var path: String {
        switch self {
        case .pokemonList:
            return "/pokemon"
        case .pokemonDetail(let id):
            return "/pokemon/\(id)"
        case .typeList:
            return "/type"
        case .regionList:
            return "/region"
        case .regionDetail(let id):
            return "/region/\(id)"
        }
    }

    /// Query 參數
    var queryItems: [URLQueryItem]? {
        switch self {
        case .pokemonList(let limit, let offset):
            return [
                URLQueryItem(name: "limit", value: String(limit)),
                URLQueryItem(name: "offset", value: String(offset))
            ]

        case .typeList(let limit, let offset):
            return [
                URLQueryItem(name: "limit", value: String(limit)),
                URLQueryItem(name: "offset", value: String(offset))
            ]

        case .pokemonDetail,
             .regionList,
             .regionDetail:
            return nil
        }
    }
    
    /// headers
    var headers: [String : String]? { nil }
    
    /// 建立 URLRequest
    func makeRequest(baseURL: URL = APIConfig.baseURL) throws -> URLRequest {
        guard var components = URLComponents(
            url: baseURL.appendingPathComponent(path),
            resolvingAgainstBaseURL: false
        ) else {
            throw NetworkError.invalidURL
        }

        components.queryItems = queryItems

        guard let url = components.url else {
            throw NetworkError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        // header
        if let headers = headers {
            for (key, value) in headers {
                request.setValue(value, forHTTPHeaderField: key)
            }
        }
        return request
    }
}

