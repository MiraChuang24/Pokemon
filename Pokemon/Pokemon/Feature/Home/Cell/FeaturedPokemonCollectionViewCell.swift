//
//  FeaturedPokemonCollectionViewCell.swift
//  Pokemon
//
//  Created by 莊羚羊 on 2025/11/24.
//

import Combine
import UIKit

class FeaturedPokemonCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var pokemonCareView: PokemonCareUIView!

    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func configure(with id: Int, state: PokemonCareState) {
        pokemonCareView.updateView(with: state)
    }
}

