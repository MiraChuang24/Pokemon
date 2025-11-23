//
//  HomeView.swift
//  Pokemon
//
//  Created by 莊羚羊 on 2025/11/24.
//

import SwiftUI

struct HomeView: UIViewControllerRepresentable {
    @EnvironmentObject private var router: MainRouter

    func makeUIViewController(context: Context) -> UIViewController {
        let vc = HomeViewController()

        // 把導航行為綁到 closure
        vc.onTapSeeMoreFeatured = {
            router.push(.pokemonList)
        }

        vc.onTapPokemon = { id in
            router.push(.pokemonDetail(id: id))
        }

        return vc
    }
    func updateUIViewController(
        _ uiViewController: UIViewController,
        context: Context
    ) {

    }
}
