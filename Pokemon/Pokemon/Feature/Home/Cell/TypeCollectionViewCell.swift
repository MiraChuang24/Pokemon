//
//  TypeCollectionViewCell.swift
//  Pokemon
//
//  Created by 莊羚羊 on 2025/11/24.
//

import UIKit

class TypeCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var typeBKView: UIView!

    @IBOutlet weak var typeLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        setupView()
    }
    override func prepareForReuse() {
        super.prepareForReuse()
        typeLabel.text = ""
    }

    func setupView() {
        typeLabel.font = .pokemonCareBody
        typeLabel.textColor = .white
        typeBKView.layer.cornerRadius = 12
        typeBKView.backgroundColor = .clear
    }

    func configure(with type: PokemonType) {
        typeBKView.backgroundColor = type.color
        typeLabel.text = type.name.capitalized
    }

}
