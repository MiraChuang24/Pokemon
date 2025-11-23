//
//  UIFont+AppTextStyle.swift
//  Pokemon
//
//  Created by 莊羚羊 on 2025/11/24.
//

import Foundation
import UIKit

extension UIFont {
    static var pokemonCareBody: UIFont = {
        .systemFont(ofSize: 18, weight: .bold)
    }()
    static let pokemonCareType: UIFont = {
        .systemFont(ofSize: 12)
    }()
}
