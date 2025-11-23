//
//  PokemonCareUIView.swift
//  Pokemon
//
//  Created by 莊羚羊 on 2025/11/24.
//

import UIKit
import SnapKit
import Combine

class PokemonCareUIView: UIView, NibOwnerLoadable {

    @IBOutlet weak var pockmonImageView: ImageLoaderHostingView!
    @IBOutlet weak var numberLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var typesStack: UIStackView!
    @IBOutlet weak var favoriteButton: UIButton!

    // MARK: - State

    private var pokemonID: Int?
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    // MARK: - Setup

    private func setupView() {
        loadNibContent()
        backgroundColor = .pokemonCareBK
        pockmonImageView.backgroundColor = .clear
        numberLabel.font = .pokemonCareBody
        nameLabel.font = .pokemonCareBody

        setupFavoriteButton()
        bindFavoriteStorage()
    }

    private func setupFavoriteButton() {
        favoriteButton.tintColor = .systemRed
        favoriteButton.backgroundColor = .white
        favoriteButton.layer.cornerRadius = favoriteButton.bounds.height / 2
        favoriteButton.layer.masksToBounds = true
        favoriteButton.setTitle("", for: .normal)
        // 預設顯示空心
        favoriteButton.setImage(
            UIImage(systemName: "heart"),
            for: .normal
        )

        favoriteButton.addTarget(
            self,
            action: #selector(favoriteButtonTapped),
            for: .touchUpInside
        )
    }

    /// 監聽 FavoriteStorage 的變化，只要收藏集合改變，就更新這張卡片的愛心狀態
    private func bindFavoriteStorage() {
        FavoriteStorage.shared.valuesPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] favorites in
                guard let self,
                      let id = self.pokemonID
                else { return }

                let isFavorite = favorites.contains(id)
                self.updateFavoriteButton(isFavorite: isFavorite)
            }
            .store(in: &cancellables)
    }

    // MARK: - Public API

    func updateView(with state: PokemonCareState) {
        switch state {
        case .noData:
            pokemonID = nil
            pockmonImageView.configure(urlString: nil)
            numberLabel.text = ""
            nameLabel.text = ""
            clearTypes()
            favoriteButton.isEnabled = false
            updateFavoriteButton(isFavorite: false)

        case .loading:
            pokemonID = nil
            pockmonImageView.configure(urlString: nil)
            numberLabel.text = "Loading..."
            nameLabel.text = ""
            clearTypes()
            favoriteButton.isEnabled = false
            updateFavoriteButton(isFavorite: false)

        case .loaded(let pokemon):
            pokemonID = pokemon.id

            pockmonImageView.configure(
                urlString: pokemon.sprites.frontDefault
            )
            numberLabel.text = "#\(pokemon.id)"
            nameLabel.text = pokemon.name.uppercased()
            updateTypes(pokemon: pokemon)

            favoriteButton.isEnabled = true
            let isFavorite = FavoriteStorage.shared.isFavorite(pokemon.id)
            updateFavoriteButton(isFavorite: isFavorite)

        case .error:
            pokemonID = nil
            pockmonImageView.configure(urlString: nil)
            numberLabel.text = "Error"
            nameLabel.text = ""
            clearTypes()
            favoriteButton.isEnabled = false
            updateFavoriteButton(isFavorite: false)
        }
    }

    // MARK: - Favorite

    @objc
    private func favoriteButtonTapped() {
        guard let id = pokemonID else { return }
        FavoriteStorage.shared.toggle(id)
        // UI 更新會由 bindFavoriteStorage 的 sink 自動處理
    }

    private func updateFavoriteButton(isFavorite: Bool) {
        let imageName = isFavorite ? "heart.fill" : "heart"
        favoriteButton.setImage(UIImage(systemName: imageName), for: .normal)
        favoriteButton.tintColor = isFavorite ? .systemRed : .systemGray3
    }

    // MARK: - Types

    private func clearTypes() {
        typesStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
    }

    private func updateTypes(pokemon: PokemonDetailResponse) {
        clearTypes()

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
