//
//  HomeViewController.swift
//  Pokemon
//
//  Created by 莊羚羊 on 2025/11/24.
//

import Combine
import Foundation
import SnapKit
import UIKit

final class HomeViewController: UIViewController {

    // MARK: - Typealias
    typealias DataSource = UICollectionViewDiffableDataSource<
        HomeSection, HomeItem
    >

    // MARK: - UI Components
    private lazy var collectionView: UICollectionView = {
        .init(frame: .zero, collectionViewLayout: createLayout())
    }()

    // MARK: - DataSource
    private lazy var dataSource = createDataSource()

    // MARK: - Callbacks (Navigation)
    var onTapSeeMoreFeatured: (() -> Void)?
    var onTapPokemon: ((PokemonDetailResponse) -> Void)?

    // MARK: - ViewModel
    var vm = HomeViewModel()

    // MARK: - Combine
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
        setupCombine()

        Task {
            await vm.fetchPokemons()
            await vm.fetchAllTypes()
            await vm.fetchAllRegion()
        }
    }
}

// MARK: - Setup UI
extension HomeViewController {

    private func setupView() {
        view.backgroundColor = .secondarySystemBackground
        setupCollectionView()
    }

    private func setupCollectionView() {
        
        collectionView.backgroundColor = .clear
        view.addSubview(collectionView)

        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        collectionView.delegate = self
        // Register All Cells
        HomeItem.allCases.forEach { item in
            collectionView.register(
                item.cellNib,
                forCellWithReuseIdentifier: item.cellIdentifier
            )
        }

        // Register Header
        collectionView.register(
            HomeSectionHeaderView.self,
            forSupplementaryViewOfKind: UICollectionView
                .elementKindSectionHeader,
            withReuseIdentifier: HomeSectionHeaderView.reuseIdentifier
        )

        collectionView.dataSource = dataSource
        applySnapshot()
    }
}

// MARK: - Combine Setup
extension HomeViewController {

    private func setupCombine() {

        // 合併三個更新 Section UI 的 publisher
        let listUpdates = Publishers.MergeMany(
            vm.$pokemonItems.map { _ in () },
            vm.$typeItems.map { _ in () },
            vm.$regionItems.map { _ in () }
        )

        listUpdates
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.applySnapshot()
            }
            .store(in: &cancellables)

        // 個別 reload Item（避免整個 section reload）
        vm.pokemonDidChange
            .receive(on: DispatchQueue.main)
            .sink { [weak self] id in
                self?.reloadItem(item: .pokemon(id))
            }
            .store(in: &cancellables)

        vm.regionDidChange
            .receive(on: DispatchQueue.main)
            .sink { [weak self] id in
                self?.reloadItem(item: .region(id))
            }
            .store(in: &cancellables)

        // Error Message
        vm.$errorMessage
            .compactMap { $0 }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] message in
                self?.showMessage(
                    title: "錯誤",
                    message: message
                )
            }
            .store(in: &cancellables)
    }
}

// MARK: - DataSource
extension HomeViewController {

    private func createDataSource() -> DataSource {
        let dataSource: DataSource = .init(collectionView: collectionView) {
            [weak self] collectionView, indexPath, item in

            guard let self else { return UICollectionViewCell() }

            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: item.cellIdentifier,
                for: indexPath
            )

            switch item {

            case .pokemon(let id):
                if let pokemonCell = cell as? FeaturedPokemonCollectionViewCell
                {
                    let state = self.vm.pokemons[id] ?? .noData
                    pokemonCell.configure(
                        with: id,
                        state: state,
                        style: (.init(rawValue: indexPath.row % 3) ?? .no)
                    )
                }

            case .type(let type):
                (cell as? TypeCollectionViewCell)?
                    .configure(with: type)

            case .region(let id):
                (cell as? RegionCollectionViewCell)?
                    .configure(with: self.vm.regions[id])
            }

            return cell
        }

        // Header Provider
        dataSource.supplementaryViewProvider = {
            [weak self] collectionView, kind, indexPath in
            guard let self else { return nil }
            guard kind == UICollectionView.elementKindSectionHeader else {
                return nil
            }

            let header =
                collectionView.dequeueReusableSupplementaryView(
                    ofKind: kind,
                    withReuseIdentifier: HomeSectionHeaderView.reuseIdentifier,
                    for: indexPath
                ) as? HomeSectionHeaderView

            if let section = HomeSection(rawValue: indexPath.section) {
                header?.configure(
                    title: section.title,
                    showMoreButton: section.showMoreButton
                )

                header?.onMoreButtonTapped = { [weak self] in
                    self?.handleMoreButtonTapped(for: section)
                }
            }

            return header
        }

        return dataSource
    }
}

// MARK: - Snapshot
extension HomeViewController {

    private func applySnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<HomeSection, HomeItem>()

        snapshot.appendSections([.featuredPokémon])
        snapshot.appendItems(vm.pokemonItems, toSection: .featuredPokémon)

        snapshot.appendSections([.types])
        snapshot.appendItems(vm.typeItems, toSection: .types)

        snapshot.appendSections([.regions])
        snapshot.appendItems(vm.regionItems, toSection: .regions)

        dataSource.apply(snapshot, animatingDifferences: false)
    }

    private func reloadItem(item: HomeItem) {
        var snapshot = dataSource.snapshot()
        guard snapshot.indexOfItem(item) != nil else { return }

        snapshot.reloadItems([item])
        dataSource.apply(snapshot, animatingDifferences: true)
    }
}

// MARK: - Layout
extension HomeViewController {

    private func createLayout() -> UICollectionViewLayout {
        UICollectionViewCompositionalLayout { [weak self] index, environment in
            guard let self,
                let section = HomeSection(rawValue: index)
            else { return nil }

            switch section {
            case .featuredPokémon: return self.featuredPokémonLayout()
            case .types: return self.typesLayout()
            case .regions: return self.regionsLayout()
            }
        }
    }

    // Featured Pokémon Section
    private func featuredPokémonLayout() -> NSCollectionLayoutSection {
        let item = NSCollectionLayoutItem(
            layoutSize: .init(
                widthDimension: .fractionalWidth(1),
                heightDimension: .estimated(60)
            )
        )

        let group = NSCollectionLayoutGroup.vertical(
            layoutSize: .init(
                widthDimension: .fractionalWidth(0.85),
                heightDimension: .estimated(180)
            ),
            repeatingSubitem: item,
            count: 3
        )

        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .groupPaging
        section.contentInsets = .init(
            top: 8,
            leading: 16,
            bottom: 16,
            trailing: 16
        )
        section.interGroupSpacing = 16
        section.boundarySupplementaryItems = [makeHeaderItem()]
        return section
    }

    // Types Section
    private func typesLayout() -> NSCollectionLayoutSection {
        let item = NSCollectionLayoutItem(
            layoutSize: .init(
                widthDimension: .fractionalWidth(1),
                heightDimension: .fractionalHeight(1)
            )
        )

        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: .init(
                widthDimension: .fractionalWidth(0.3),
                heightDimension: .fractionalWidth(0.18)
            ),
            subitems: [item]
        )

        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .continuous
        section.contentInsets = .init(
            top: 0,
            leading: 16,
            bottom: 16,
            trailing: 16
        )
        section.interGroupSpacing = 12
        section.boundarySupplementaryItems = [makeHeaderItem()]
        return section
    }

    // Regions Section
    private func regionsLayout() -> NSCollectionLayoutSection {
        let item = NSCollectionLayoutItem(
            layoutSize: .init(
                widthDimension: .fractionalWidth(0.5),
                heightDimension: .fractionalWidth(0.25)
            )
        )

        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: .init(
                widthDimension: .fractionalWidth(1),
                heightDimension: .estimated(60)
            ),
            repeatingSubitem: item,
            count: 2
        )

        group.interItemSpacing = .fixed(20)

        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .none
        section.contentInsets = .init(
            top: 0,
            leading: 16,
            bottom: 16,
            trailing: 16
        )
        section.interGroupSpacing = 20
        section.boundarySupplementaryItems = [makeHeaderItem()]
        return section
    }

    // MARK: - Header Layout
    private func makeHeaderItem() -> NSCollectionLayoutBoundarySupplementaryItem
    {
        NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: .init(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .estimated(44)
            ),
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
        )
    }
}

// MARK: - Actions
extension HomeViewController {

    private func handleMoreButtonTapped(for section: HomeSection) {
        switch section {
        case .featuredPokémon:
            onTapSeeMoreFeatured?()
        default:
            showMessage(
                title: "功能開發中",
                message: "此功能尚未完成，敬請期待！"
            )
        }
    }
}

// MARK: - Helper (Unified Alert)
extension HomeViewController {

    private func showMessage(title: String, message: String) {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "確定", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UICollectionViewDelegate
extension HomeViewController: UICollectionViewDelegate {

    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        collectionView.deselectItem(at: indexPath, animated: true)

        guard let item = dataSource.itemIdentifier(for: indexPath) else {
            return
        }

        switch item {

        case .pokemon(let id):
            if case .loaded(let pokemon) = vm.pokemons[id] {
                onTapPokemon?(pokemon)
            }

        case .type, .region:
            break
        }
    }
}
