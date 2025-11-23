//
//  PokemonCareUIView.swift
//  Pokemon
//
//  Created by 莊羚羊 on 2025/11/24.
//

import Combine
import SnapKit
import UIKit

class PokemonCareUIView: UIView, NibOwnerLoadable {

    @IBOutlet weak var pockmonImageView: ImageLoaderHostingView!
    @IBOutlet weak var numberLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var typesStack: UIStackView!
    @IBOutlet weak var favoriteButton: UIButton!

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    private func setupView() {
        loadNibContent()
        backgroundColor = .pokemonCareBK
        pockmonImageView.backgroundColor = .clear
        numberLabel.font = .pokemonCareBody
        nameLabel.font = .pokemonCareBody

    }

    func updateView(with state: PokemonCareState) {
        switch state {
        case .noData:
            pockmonImageView.configure(urlString: nil)
            numberLabel.text = ""
            nameLabel.text = ""
            clearTypes()

        case .loading:
            pockmonImageView.configure(urlString: nil)
            numberLabel.text = "Loading..."
            nameLabel.text = ""
            clearTypes()

        case .loaded(let pokemon):
            pockmonImageView.configure(
                urlString: pokemon.sprites.frontDefault
            )
            numberLabel.text = "#\(pokemon.id)"
            nameLabel.text = pokemon.name.uppercased()
            updateTypes(pokemon: pokemon)

        case .error:
            pockmonImageView.configure(urlString: nil)
            numberLabel.text = "Error"
            nameLabel.text = ""
            clearTypes()
        }
    }

    private func clearTypes() {
        typesStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
    }

    private func updateTypes(pokemon: PokemonDetailResponse) {
        clearTypes()

        // 假設 pokemon.types: [PokemonTypeSlot] & 裡面有 type.name
        for typeEntry in pokemon.types {
            let type = PokemonType(from: typeEntry.type.url)

            typesStack.addArrangedSubview(typeView(type: type))
        }
    }

    func typeView(type: PokemonType) -> UIView {
        let label = UILabel()
        label.font = .pokemonCareType
        label.textColor = .white
        label.textAlignment = .center
        label.text = type.name.capitalized

        let bkView = UIView()
        bkView.backgroundColor = type.color

        bkView.addSubview(label)

        label.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(8)
            make.top.bottom.equalToSuperview().inset(3)
        }
        bkView.layer.cornerRadius = 5
        bkView.layer.masksToBounds = true
        return bkView
    }

}
@MainActor
class PokemonCareViewModel: ObservableObject {

    let pokeAPIClient: PokeAPIClient

    @Published var pokemonState: PokemonCareState = .noData

    init(pokeAPIClient: PokeAPIClient = .init()) {
        self.pokeAPIClient = pokeAPIClient
    }

    func fetchPokemon(id: Int) {
        pokemonState = .loading

        Task { [weak self] in
            guard let self else { return }

            do {
                let response = try await pokeAPIClient.fetchPokemonDetail(
                    id: id
                )
                self.pokemonState = .loaded(pokemon: response)
            } catch {
                self.pokemonState = .error
            }
        }
    }
}

enum PokemonCareState: Hashable {
    case noData
    case loading
    case loaded(pokemon: PokemonDetailResponse)
    case error
}
