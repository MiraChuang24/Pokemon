//
//  NetworkClient.swift
//  Pokemon
//
//  Created by 莊羚羊 on 2025/11/23.
//

import Foundation


protocol HTTPClient {
    func sendRequest<T: Decodable>(
        _ endpoint: PokeAPIEndpoint,
        responseType: T.Type
    ) async throws -> T
}

final class URLSessionHTTPClient: HTTPClient {

    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    func sendRequest<T: Decodable>(
        _ endpoint: PokeAPIEndpoint,
        responseType: T.Type
    ) async throws -> T {
        // 1. 組 URLRequest
        let request: URLRequest
        do {
            request = try endpoint.makeRequest()
        } catch {
            throw NetworkError.invalidURL
        }

        // 2. 呼叫 URLSession
        let (data, response): (Data, URLResponse)
        do {
            (data, response) = try await session.data(for: request)
        } catch {
            throw NetworkError.requestFailed(underlying: error)
        }

        // 3. 驗證 HTTP Response
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }

        // statusCode 不在 200~299 之間
        guard (200..<300).contains(httpResponse.statusCode) else {
            throw NetworkError.httpStatusCode(httpResponse.statusCode)
        }

        // 4. 解碼 JSON
        do {
            let decoder = JSONDecoder()
            let decoded = try decoder.decode(T.self, from: data)

            return decoded
        } catch {
            throw NetworkError.decodingFailed(underlying: error)
        }
    }
}
