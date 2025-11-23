//
//  Pokemon.swift
//  Pokemon
//
//  Created by 莊羚羊 on 2025/11/23.
//

import Foundation

struct PokemonDetailResponse: Codable, Hashable {
    let id: Int
    let name: String
    let baseExperience: Int
    let height: Int
    let isDefault: Bool
    let order: Int
    let weight: Int
    let abilities: [Ability]
    let forms: [Form]
    let species: Species
    let sprites: Sprites
    let stats: [Stat]
    let types: [TypeElement]
    let moves: [Move]

    enum CodingKeys: String, CodingKey {
        case id, name, height, order, weight, abilities, forms, species, sprites,
            stats, types, moves
        case baseExperience = "base_experience"
        case isDefault = "is_default"
    }
}

struct Sprites: Codable, Hashable {
    let frontDefault: String?
    let frontShiny: String?
    let frontFemale: String?
    let frontShinyFemale: String?
    let backDefault: String?
    let backShiny: String?
    let backFemale: String?
    let backShinyFemale: String?
    
    enum CodingKeys: String, CodingKey {
        case frontDefault = "front_default"
        case frontShiny = "front_shiny"
        case frontFemale = "front_female"
        case frontShinyFemale = "front_shiny_female"
        case backDefault = "back_default"
        case backShiny = "back_shiny"
        case backFemale = "back_female"
        case backShinyFemale = "back_shiny_female"
    }
}

struct Ability: Codable, Hashable {
    let ability: Species
    let isHidden: Bool
    let slot: Int

    enum CodingKeys: String, CodingKey {
        case ability
        case isHidden = "is_hidden"
        case slot
    }
}

struct Species: Codable, Hashable {
    let name: String
    let url: String
}

struct Form: Codable, Hashable {
    let name: String
    let url: String
}

struct Stat: Codable, Hashable {
    let baseStat: Int
    let effort: Int
    let stat: Species

    enum CodingKeys: String, CodingKey {
        case effort, stat
        case baseStat = "base_stat"
    }
}

struct TypeElement: Codable, Hashable {
    let slot: Int
    let type: Species
}

struct Move: Codable, Hashable {
    let move: Species
    let versionGroupDetails: [VersionGroupDetail]

    enum CodingKeys: String, CodingKey {
        case move
        case versionGroupDetails = "version_group_details"
    }
}

struct VersionGroupDetail: Codable, Hashable {
    let levelLearnedAt: Int
    let moveLearnMethod: Species
    let versionGroup: Species

    enum CodingKeys: String, CodingKey {
        case moveLearnMethod = "move_learn_method"
        case versionGroup = "version_group"
        case levelLearnedAt = "level_learned_at"
    }
}
struct PokemonListResponse: Codable {
    let count: Int
    let next: String?
    let previous: String?
    let results: [PokeListResult]
}

struct PokeListResult: Codable, Hashable {
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

        // 從 URL 拆出最後的 id
        let trimmed = url.trimmingCharacters(
            in: CharacterSet(charactersIn: "/")
        )
        if let last = trimmed.split(separator: "/").last,
            let parsedID = Int(last)
        {
            self.id = parsedID
        } else {
            throw DecodingError.dataCorruptedError(
                forKey: .url,
                in: container,
                debugDescription: "URL does not contain valid ID: \(url)"
            )
        }
    }
}
