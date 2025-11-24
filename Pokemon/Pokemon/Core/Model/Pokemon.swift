//
//  Pokemon.swift
//  Pokemon
//
//  Created by 莊羚羊 on 2025/11/23.
//

import Foundation


struct PokemonDetailResponse: Codable, Hashable, Identifiable {
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

extension PokemonDetailResponse {
    /// 把 PokeAPI 的 types 轉成你定義的 PokemonType enum
    var pokemonTypes: [PokemonType] {
        types
            .sorted { $0.slot < $1.slot } // 先照 slot 排
            .compactMap { PokemonType(from: $0.type.url) }
    }
    
    /// 方便取指定 stat（hp / attack / defense / speed 等）
    func statValue(named key: String) -> Int? {
        stats.first { $0.stat.name == key }?.baseStat
    }
    
    /// 用 sprites.frontDefault 當詳情大圖
    var spriteURLString: String? {
        sprites.frontDefault
    }
    
    /// 顯示用的 ID，例如 "#003"
    var displayID: String {
        String(format: "#%03d", id)
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
    
    // 🔹 新增：other（dream_world / official-artwork 等）
    let other: OtherSprites?

    enum CodingKeys: String, CodingKey {
        case frontDefault = "front_default"
        case frontShiny = "front_shiny"
        case frontFemale = "front_female"
        case frontShinyFemale = "front_shiny_female"
        case backDefault = "back_default"
        case backShiny = "back_shiny"
        case backFemale = "back_female"
        case backShinyFemale = "back_shiny_female"
        case other
    }
}

/// sprites.other
struct OtherSprites: Codable, Hashable {
    let dreamWorld: SpriteSet?
    let officialArtwork: OfficialArtworkSprites?

    enum CodingKeys: String, CodingKey {
        case dreamWorld = "dream_world"
        case officialArtwork = "official-artwork"
    }
    init(dreamWorld: SpriteSet?, officialArtwork: OfficialArtworkSprites?) {
        self.dreamWorld = dreamWorld
        self.officialArtwork = officialArtwork
    }
}

/// 例如 dream_world: front_default / front_female
struct SpriteSet: Codable, Hashable {
    let frontDefault: String?
    let frontFemale: String?

    enum CodingKeys: String, CodingKey {
        case frontDefault = "front_default"
        case frontFemale = "front_female"
    }
}

/// official-artwork: front_default / front_shiny
struct OfficialArtworkSprites: Codable, Hashable {
    let frontDefault: String?
    let frontShiny: String?

    enum CodingKeys: String, CodingKey {
        case frontDefault = "front_default"
        case frontShiny = "front_shiny"
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
    
    let nextParameters: APIParameters?
    
    enum CodingKeys: String, CodingKey {
        case count, next, previous, results
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.count = try container.decode(Int.self, forKey: .count)
        self.next = try container.decodeIfPresent(String.self, forKey: .next)
        self.previous = try container.decodeIfPresent(String.self, forKey: .previous)
        self.results = try container.decode([PokeListResult].self, forKey: .results)
        
        // 如果有 next URL，就解析出參數
        if let nextURL = self.next {
            self.nextParameters = APIParameters(url: nextURL)
        } else {
            self.nextParameters = nil
        }
    }
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
