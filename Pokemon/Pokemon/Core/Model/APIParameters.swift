//
//  APIParameters.swift
//  Pokemon
//
//  Created by 莊羚羊 on 2025/11/23.
//

import Foundation

struct APIParameters {
    var offset: Int
    var limit: Int
    
    init?(url: String) {
        guard let url = URL(string: url),
              let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              let queryItems = components.queryItems else {
            return nil
        }
        
        var offset: Int?
        var limit: Int?
        
        for item in queryItems {
            switch item.name {
            case "offset":
                offset = item.value.flatMap { Int($0) }
            case "limit":
                limit = item.value.flatMap { Int($0) }
            default:
                break
            }
        }
        
        guard let offset = offset, let limit = limit else {
            return nil
        }
        
        self.offset = offset
        self.limit = limit
    }
}
