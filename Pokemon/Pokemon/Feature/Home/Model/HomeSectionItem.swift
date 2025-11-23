//
//  HomeSectionItem.swift
//  Pokemon
//
//  Created by 莊羚羊 on 2025/11/24.
//

import Foundation
import UIKit

nonisolated enum HomeSection: Int, CaseIterable {
    case featuredPokémon
    case types
    case regions
    
    var title: String {
        switch self {
        case .featuredPokémon:
            return "Featured Pokémon"
        case .types:
            return "Types"
        case .regions:
            return "Regions"
        }
    }
    
    var showMoreButton: Bool { true }
}

nonisolated enum HomeItem: Hashable, CaseIterable {
    static let allCases: [HomeItem] = [.pokemon(0), .type(.unknownType), .region(0)]
    
    case pokemon(Int)
    case type(PokemonType)
    case region(Int)

    var cellNib: UINib {
        switch self {
        case .pokemon:
            return UINib(nibName: String(describing: FeaturedPokemonCollectionViewCell.self), bundle: nil)
        case .type:
            return UINib(nibName: String(describing: TypeCollectionViewCell.self), bundle: nil)
        case .region:
            return UINib(nibName: String(describing: RegionCollectionViewCell.self), bundle: nil)
        }
    }
    
    var cellIdentifier: String {
        switch self {
        case .pokemon:
            return String(describing: FeaturedPokemonCollectionViewCell.self)
        case .type:
            return String(describing: TypeCollectionViewCell.self)
        case .region:
            return String(describing: RegionCollectionViewCell.self)
        }
    }
}

