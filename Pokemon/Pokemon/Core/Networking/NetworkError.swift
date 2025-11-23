//
//  NetworkError.swift
//  Pokemon
//
//  Created by 莊羚羊 on 2025/11/23.
//

import Foundation

/// 網路層共用錯誤定義
enum NetworkError: Error, LocalizedError {
    case invalidURL
    case requestFailed(underlying: Error)
    case invalidResponse
    case httpStatusCode(Int)
    case decodingFailed(underlying: Error)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "無效的 URL"
        case .requestFailed(let underlying):
            return "網路請求失敗：\(underlying.localizedDescription)"
        case .invalidResponse:
            return "無效的回應格式"
        case .httpStatusCode(let code):
            return "伺服器回傳錯誤狀態碼：\(code)"
        case .decodingFailed(let underlying):
            return "資料解析失敗：\(underlying.localizedDescription)"
        }
    }
}
