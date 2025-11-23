//
//  Types.swift
//  Pokemon
//
//  Created by 莊羚羊 on 2025/11/23.
//

import Foundation
import UIKit

enum PokemonType: Int, CaseIterable, Codable {
    case normal = 1
    case fighting = 2
    case flying = 3
    case poison = 4
    case ground = 5
    case rock = 6
    case bug = 7
    case ghost = 8
    case steel = 9
    case fire = 10
    case water = 11
    case grass = 12
    case electric = 13
    case psychic = 14
    case ice = 15
    case dragon = 16
    case dark = 17
    case fairy = 18
    case stellar = 19
    case unknownType = 10001  // 官方「unknown」
    case shadow = 10002  // 官方「shadow」

    var name: String {
        switch self {
        case .normal: return "normal"
        case .fighting: return "fighting"
        case .flying: return "flying"
        case .poison: return "poison"
        case .ground: return "ground"
        case .rock: return "rock"
        case .bug: return "bug"
        case .ghost: return "ghost"
        case .steel: return "steel"
        case .fire: return "fire"
        case .water: return "water"
        case .grass: return "grass"
        case .electric: return "electric"
        case .psychic: return "psychic"
        case .ice: return "ice"
        case .dragon: return "dragon"
        case .dark: return "dark"
        case .fairy: return "fairy"
        case .stellar: return "stellar"
        case .unknownType: return "unknown"
        case .shadow: return "shadow"
        }
    }

    var color: UIColor {
        switch self {
        case .normal: return UIColor(hex: "#A8A77A")
        case .fighting: return UIColor(hex: "#C22E28")
        case .flying: return UIColor(hex: "#A98FF3")
        case .poison: return UIColor(hex: "#A33EA1")
        case .ground: return UIColor(hex: "#E2BF65")
        case .rock: return UIColor(hex: "#B6A136")
        case .bug: return UIColor(hex: "#A6B91A")
        case .ghost: return UIColor(hex: "#735797")
        case .steel: return UIColor(hex: "#B7B7CE")
        case .fire: return UIColor(hex: "#EE8130")
        case .water: return UIColor(hex: "#6390F0")
        case .grass: return UIColor(hex: "#7AC74C")
        case .electric: return UIColor(hex: "#F7D02C")
        case .psychic: return UIColor(hex: "#F95587")
        case .ice: return UIColor(hex: "#96D9D6")
        case .dragon: return UIColor(hex: "#6F35FC")
        case .dark: return UIColor(hex: "#705746")
        case .fairy: return UIColor(hex: "#D685AD")
        case .stellar: return UIColor(hex: "#FFD700")  // 自訂（官方較新）
        case .unknownType: return UIColor(hex: "#68A090")
        case .shadow: return UIColor(hex: "#333366")
        }
    }
}
extension UIColor {
    convenience init(hex: String) {
        var hexNormalized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexNormalized = hexNormalized.replacingOccurrences(of: "#", with: "")

        var rgb: UInt64 = 0
        Scanner(string: hexNormalized).scanHexInt64(&rgb)

        let r = CGFloat((rgb & 0xFF0000) >> 16) / 255
        let g = CGFloat((rgb & 0x00FF00) >> 8) / 255
        let b = CGFloat(rgb & 0x0000FF) / 255

        self.init(red: r, green: g, blue: b, alpha: 1.0)
    }
}
extension PokemonType {
    init(from urlString: String) {
        let trimmed = urlString.trimmingCharacters(
            in: CharacterSet(charactersIn: "/")
        )
        let last = trimmed.split(separator: "/").last.flatMap { Int($0) } ?? -1
        self = PokemonType(rawValue: last) ?? .unknownType
    }
}

// MARK: - Type List Response
struct TypeListResponse: Codable {
    let count: Int
    let next: String?
    let previous: String?
    let results: [TypeListItem]

    let nextParameters: APIParameters?

    enum CodingKeys: String, CodingKey {
        case count, next, previous, results
    }

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.count = try container.decode(Int.self, forKey: .count)
        self.next = try container.decodeIfPresent(String.self, forKey: .next)
        self.previous = try container.decodeIfPresent(
            String.self,
            forKey: .previous
        )
        self.results = try container.decode(
            [TypeListItem].self,
            forKey: .results
        )

        if let nextURL = self.next {
            self.nextParameters = APIParameters(url: nextURL)
        } else {
            self.nextParameters = nil
        }
    }
}

// MARK: - Type List Item
struct TypeListItem: Codable, Hashable {
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

        // 從 URL 拆出最後的 id，例如 /type/10/ -> 10
        let trimmed = url.trimmingCharacters(
            in: CharacterSet(charactersIn: "/")
        )
        if let last = trimmed.split(separator: "/").last,
            let parsedID = Int(last)
        {
            self.id = parsedID
        } else {
            self.id = nil
        }
    }

    /// 對應到你剛剛的 PokemonType enum（用 url 解析）
    var pokemonType: PokemonType {
        PokemonType(from: url)
    }
}
