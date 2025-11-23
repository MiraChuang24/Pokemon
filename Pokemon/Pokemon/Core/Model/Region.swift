//
//  Region.swift
//  Pokemon
//
//  Created by 莊羚羊 on 2025/11/23.
//

import Foundation

// MARK: - Region List Response
struct RegionListResponse: Codable {
    let count: Int
    let next: String?
    let previous: String?
    let results: [RegionListItem]

    let nextParameters: APIParameters?

    enum CodingKeys: String, CodingKey {
        case count, next, previous, results
    }

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.count = try container.decode(Int.self, forKey: .count)
        self.next = try container.decodeIfPresent(String.self, forKey: .next)
        self.previous = try container.decodeIfPresent(String.self, forKey: .previous)
        self.results = try container.decode([RegionListItem].self, forKey: .results)

        if let nextURL = self.next {
            self.nextParameters = APIParameters(url: nextURL)
        } else {
            self.nextParameters = nil
        }
    }
}

// MARK: - Region List Item
struct RegionListItem: Codable, Hashable {
    let name: String
    let url: String
    let id: Int?     // 從 URL 自動解析 region id

    enum CodingKeys: String, CodingKey {
        case name, url
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.name = try container.decode(String.self, forKey: .name)
        self.url = try container.decode(String.self, forKey: .url)

        // 從 URL 尾端解析出 /region/{id}/
        let trimmed = url.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        if let last = trimmed.split(separator: "/").last,
           let parsedID = Int(last) {
            self.id = parsedID
        } else {
            self.id = nil
        }
    }
}

// MARK: - Region Detail Response
struct RegionDetailResponse: Codable, Hashable {
    let id: Int
    let name: String
    let locations: [RegionLocation]
    let mainGeneration: NamedAPIResource?
    let names: [RegionName]
    let pokedexes: [NamedAPIResource]
    let versionGroups: [RegionVersionGroup]

    enum CodingKeys: String, CodingKey {
        case id, name, locations
        case mainGeneration = "main_generation"
        case names
        case pokedexes
        case versionGroups = "version_groups"
    }
}
struct RegionLocation: Codable, Hashable {
    let name: String
    let url: String
    let id: Int?

    enum CodingKeys: String, CodingKey {
        case name, url
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.name = try container.decode(String.self, forKey: .name)
        self.url = try container.decode(String.self, forKey: .url)

        // 從 URL "/location/{id}/" 解析出數字
        let trimmed = url.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        if let last = trimmed.split(separator: "/").last,
           let parsedID = Int(last) {
            self.id = parsedID
        } else {
            self.id = nil
        }
    }
}

struct RegionVersionGroup: Codable, Hashable {
    let name: String
    let url: String
    let id: Int?

    enum CodingKeys: String, CodingKey {
        case name, url
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.name = try container.decode(String.self, forKey: .name)
        self.url = try container.decode(String.self, forKey: .url)

        // 從 "/version-group/{id}/" 解析 ID
        let trimmed = url.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        if let last = trimmed.split(separator: "/").last,
           let parsedID = Int(last) {
            self.id = parsedID
        } else {
            self.id = nil
        }
    }
}
struct RegionName: Codable, Hashable {
    let name: String
    let language: NamedAPIResource
}
struct NamedAPIResource: Codable, Hashable {
    let name: String
    let url: String
}

