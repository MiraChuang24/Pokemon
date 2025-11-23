//
//  APIEndpoint.swift
//  Pokemon
//
//  Created by 莊羚羊 on 2025/11/23.
//

import Foundation

protocol APIEndpoint {

    var method: HTTPMethod { get }
    var path: String { get }
    var headers: [String: String]? { get }
    var queryItems: [URLQueryItem]? { get }
}
