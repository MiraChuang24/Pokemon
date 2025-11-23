//
//  RegionCollectionViewCell.swift
//  Pokemon
//
//  Created by 莊羚羊 on 2025/11/24.
//

import UIKit

class RegionCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var regionBKView: UIView!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var regionNameLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        setupView()
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        
    }

    func setupView() {
        regionBKView.layer.cornerRadius = 12
        regionBKView.backgroundColor = .pokemonCareBK

    }
    
    func configure(with region: RegionDetailResponse?) {
        if let region = region {
            locationLabel.text = "\(region.locations.count) Locations"
            regionNameLabel.text = "\(region.name)"
        }else {
            regionNameLabel.text = "no data"
            locationLabel.text = "no data"
        }
        
    }
}

