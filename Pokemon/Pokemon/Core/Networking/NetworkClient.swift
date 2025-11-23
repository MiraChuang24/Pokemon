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

        // 🟦 LOG: Request Info
        print("=== API Request Start ===")
        print("--- Request Info ---")
        print("URL: \(request.url?.absoluteString ?? "nil")")
        print("Method: \(request.httpMethod ?? "nil")")
        print("Headers: \(request.allHTTPHeaderFields ?? [:])")

        if let body = request.httpBody,
            let bodyString = String(data: body, encoding: .utf8)
        {
            print("Body: \(bodyString)")
        } else {
            print("Body: nil")
        }

        // 2. 呼叫 URLSession
        let (data, response): (Data, URLResponse)
        do {
            (data, response) = try await session.data(for: request)
        } catch {
            print("❌ Request Error: \(error)")
            print("=== API Request End ===\n")
            throw NetworkError.requestFailed(underlying: error)
        }

        // 3. 驗證 HTTP Response
        guard let httpResponse = response as? HTTPURLResponse else {
            print("❌ Invalid Response")
            print("=== API Request End ===\n")
            throw NetworkError.invalidResponse
        }

        // 🟥 如果 statusCode 不在 200~299 之間，先印出後 throw
        guard (200..<300).contains(httpResponse.statusCode) else {
            print("--- Response Info ---")
            print("Status Code: \(httpResponse.statusCode)")

            if let raw = String(data: data, encoding: .utf8) {
                print("Raw Response: \(raw)")
            }

            print("=== API Request End ===\n")
            throw NetworkError.httpStatusCode(httpResponse.statusCode)
        }

        // 4. 解碼 JSON
        do {
            let decoder = JSONDecoder()
            let decoded = try decoder.decode(T.self, from: data)

            // 🟩 印出 Response JSON
            print("--- Response Info ---")
            print("Status Code: \(httpResponse.statusCode)")

            print("Decoded data:\n \(decoded)")
            print("=== API Request End ===\n")

            return decoded
        } catch {
            print("❌ Decoding Error: \(error)")
            if let raw = String(data: data, encoding: .utf8) {
                print("Raw JSON: \(raw)")
            }
            print("=== API Request End ===\n")
            throw NetworkError.decodingFailed(underlying: error)
        }
    }
}
