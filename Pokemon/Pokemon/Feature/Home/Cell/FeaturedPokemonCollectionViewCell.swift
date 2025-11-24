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

    func configure(
        with id: Int,
        state: PokemonCareState,
        style: CornerRadius
    ) {
        pokemonCareView.updateView(with: state)
        setCornerRadius(for: style)
    }
    func setCornerRadius(for style: CornerRadius) {
        var corners: UIRectCorner = []
        var maskedCorners: CACornerMask = []

        switch style {
        case .top:  // First item in group
            corners = [.topLeft, .topRight]
            maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        case .bottom:  // Last item in group
            corners = [.bottomLeft, .bottomRight]
            maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        case .no:  // Middle item
            corners = []
            maskedCorners = []
        }

        pokemonCareView.layer.cornerRadius = corners.isEmpty ? 0 : 12
        pokemonCareView.layer.maskedCorners = maskedCorners
    }

    enum CornerRadius: Int {
        case top
        case no
        case bottom
    }
}
