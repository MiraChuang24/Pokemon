//
//  HomeViewController.swift
//  Pokemon
//
//  Created by 莊羚羊 on 2025/11/24.
//

import Foundation
import SnapKit
import UIKit
import Combine

final class HomeViewController: UIViewController {

    typealias DataSource = UICollectionViewDiffableDataSource<
        HomeSection, HomeItem
    >

    private lazy var collectionView: UICollectionView = {
        .init(frame: .zero, collectionViewLayout: createLayout())
    }()

    private lazy var dataSource = createDataSource()

    var onTapSeeMoreFeatured: (() -> Void)?
    var onTapPokemon: ((PokemonDetailResponse) -> Void)?  // 點某隻寶可夢要進詳細頁
    
    var vm = HomeViewModel()
    private var cancellables = Set<AnyCancellable>()

    override func viewDidLoad() {

        super.viewDidLoad()
        setupView()
        setupCombine()
        vm.getPokemons()
        vm.getAllTypes()
        vm.getAllRegion()
    }

    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    private func setupCombine() {
        // 監聽 Pokémon IDs 變化，更新 UI
        vm.$pokemonItems
            .receive(on: DispatchQueue.main)
            .sink { [weak self] ids in
                guard let self = self else { return }
                print("📱 Received \(ids.count) Pokemon IDs")
                self.applySnapshot()
            }
            .store(in: &cancellables)
        vm.pokemonDidChange
               .receive(on: DispatchQueue.main)
               .sink { [weak self] id in
                   self?.reloadPokemon(id: id)
               }
               .store(in: &cancellables)
        vm.$typeItems
            .receive(on: DispatchQueue.main)
            .sink { [weak self] items in
                guard let self = self else { return }
                print("📱 Received \(items.count) Type items")
                self.reloadTypeSection()
            }
            .store(in: &cancellables)
        vm.$regionItems
            .receive(on: DispatchQueue.main)
            .sink { [weak self] ids in
                guard let self = self else { return }
                print("📱 Received \(ids.count) Pokemon IDs")
                self.applySnapshot()
            }
            .store(in: &cancellables)
        vm.regionDidChange
               .receive(on: DispatchQueue.main)
               .sink { [weak self] id in
                   self?.reloadRegion(id: id)
               }
               .store(in: &cancellables)
//        // 監聽載入狀態
//        vm.$isLoading
//            .receive(on: DispatchQueue.main)
//            .sink { [weak self] isLoading in
//                guard let self = self else { return }
//                if isLoading {
//                    print("⏳ Loading Pokémon...")
//                    // 可以在這裡顯示 loading indicator
//                } else {
//                    print("✅ Loading complete")
//                    // 隱藏 loading indicator
//                }
//            }
//            .store(in: &cancellables)

        // 監聽錯誤訊息
        vm.$errorMessage
            .compactMap { $0 }  // 只處理非 nil 的錯誤
            .receive(on: DispatchQueue.main)
            .sink { [weak self] errorMessage in
                guard let self = self else { return }
                print("❌ Error: \(errorMessage)")
                self.showErrorAlert(message: errorMessage)
            }
            .store(in: &cancellables)
    }
    private func reloadPokemon(id: Int) {
        var snapshot = dataSource.snapshot()
        let item = HomeItem.pokemon(id)

        // 確認這個 item 目前有在 snapshot 裡，才 reload
        guard snapshot.indexOfItem(item) != nil else {
            return
        }

        snapshot.reloadItems([item])
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    private func reloadRegion(id: Int) {
        var snapshot = dataSource.snapshot()
        let item = HomeItem.region(id)

        // 確認這個 item 目前有在 snapshot 裡，才 reload
        guard snapshot.indexOfItem(item) != nil else {
            return
        }

        snapshot.reloadItems([item])
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
    /// 重新載入 Type Section 的 UI
    func reloadTypeSection() {
        var snapshot = dataSource.snapshot()
        
        // 確認 types section 存在
        guard snapshot.sectionIdentifiers.contains(.types) else {
            print("⚠️ Types section not found in snapshot")
            return
        }
        
        // 刪除 types section 的舊 items
        let currentTypeItems = snapshot.itemIdentifiers(inSection: .types)
        snapshot.deleteItems(currentTypeItems)
        
        // 添加新的 type items
        snapshot.appendItems(vm.typeItems, toSection: .types)
        
        // 套用變更，並帶有動畫效果
        dataSource.apply(snapshot, animatingDifferences: true)
        
        print("✅ Reloaded types section with \(vm.typeItems.count) items")
    }
    private func setupView() {
        collectionView.backgroundColor = .clear
        view.backgroundColor = .secondarySystemBackground
        setupCollectionView()
    }
    private func setupCollectionView() {
        collectionViewUI()
        collectionView.delegate = self
        // Register cells
        HomeItem.allCases.forEach { [weak self] item in
            guard let self else { return }
            collectionView.register(
                item.cellNib,
                forCellWithReuseIdentifier: item.cellIdentifier
            )
        }
        
        // Register header
        collectionView.register(
            HomeSectionHeaderView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: HomeSectionHeaderView.reuseIdentifier
        )
        
        collectionView.dataSource = dataSource
        applySnapshot()
    }
    private func collectionViewUI() {
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    private func createDataSource() -> DataSource {
        let dataSource = DataSource(
            collectionView: collectionView
        ) { collectionView, indexPath, item in
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: item.cellIdentifier,
                for: indexPath
            )

            // 根據不同的 item 類型配置 cell
            switch item {
            case .pokemon(let id):
                if let pokemonCell = cell
                    as? FeaturedPokemonCollectionViewCell
                {
                    let state = self.vm.pokemons[id] ?? .noData
                    pokemonCell.configure(with: id, state: state)
                }
            case .type(let type):
                if let typeCell = cell
                    as? TypeCollectionViewCell
                {
                    typeCell.configure(with: type)
                }
            case .region(let id):
                if let regionCell = cell
                    as? RegionCollectionViewCell
                {
                    let region = self.vm.regions[id]
                    regionCell.configure(with: region)
                }
            }

            return cell
        }
        
        // Configure supplementary view (header)
        dataSource.supplementaryViewProvider = { collectionView, kind, indexPath in
            guard kind == UICollectionView.elementKindSectionHeader else {
                return nil
            }
            
            let header = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: HomeSectionHeaderView.reuseIdentifier,
                for: indexPath
            ) as? HomeSectionHeaderView
            
            if let section = HomeSection(rawValue: indexPath.section) {
                header?.configure(title: section.title, showMoreButton: section.showMoreButton)
                
                // Handle more button tap
                header?.onMoreButtonTapped = { [weak self] in
                    self?.handleMoreButtonTapped(for: section)
                }
            }
            
            return header
        }

        return dataSource
    }
    // 在 viewDidLoad 或適當的地方應用 snapshot
    private func applySnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<HomeSection, HomeItem>()

        // Featured Pokémon Section
        snapshot.appendSections([.featuredPokémon])
        snapshot.appendItems(vm.pokemonItems, toSection: .featuredPokémon)
        // Types Section
        snapshot.appendSections([.types])
        snapshot.appendItems(vm.typeItems, toSection: .types)

        // Regions Section
        snapshot.appendSections([.regions])
        snapshot.appendItems(vm.regionItems, toSection: .regions)

        dataSource.apply(snapshot, animatingDifferences: false)
    }
    private func createLayout() -> UICollectionViewLayout {
        return UICollectionViewCompositionalLayout {
            [weak self] sectionIndex, environment in
            guard let self,
                let section = HomeSection(rawValue: sectionIndex)
            else { return nil }

            switch section {
            case .featuredPokémon:
                return featuredPokémonLayout()
            case .types:
                return typesLayout()
            case .regions:
                return regionsLayout()
            }
        }
    }

    /// Featured Pokémon Section: 1 row, 3 columns, horizontal scrolling, 9 items max
    private func featuredPokémonLayout() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .estimated(60)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(0.85),  // Show 3 cells, each cell ≈ 1/3
            heightDimension: .estimated(180)
        )
        let group = NSCollectionLayoutGroup.vertical(
            layoutSize: groupSize,
            repeatingSubitem: item,
            count: 3
        )
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .groupPaging
        section.contentInsets = NSDirectionalEdgeInsets(
            top: 8,
            leading: 16,
            bottom: 16,
            trailing: 16
        )
        section.interGroupSpacing = 16
        
        // Add header
        
        section.boundarySupplementaryItems = [createHeaderLayout()]
        
        return section
    }

    /// Types Section: horizontal scrolling, item width fixed (e.g., 80pt), height small
    private func typesLayout() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .fractionalHeight(1)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(0.3),
            heightDimension: .fractionalWidth(0.18)
        )
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: groupSize,
            subitems: [item]
        )

        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .continuous
        section.contentInsets = NSDirectionalEdgeInsets(
            top: 0,
            leading: 16,
            bottom: 16,
            trailing: 16
        )
        section.interGroupSpacing = 12
        
        // Add header
        
        section.boundarySupplementaryItems = [createHeaderLayout()]
        
        return section
    }

    /// Regions Section: 1 row, 6 columns, no scrolling, cells evenly spaced
    private func regionsLayout() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(0.5),
            heightDimension: .fractionalWidth(0.25)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .estimated(60)
        )
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: groupSize,
            repeatingSubitem: item,
            count: 2
        )
        group.interItemSpacing = .fixed(20)

        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .none
        section.contentInsets = NSDirectionalEdgeInsets(
            top: 0,
            leading: 16,
            bottom: 16,
            trailing: 16
        )
        section.interGroupSpacing = 20
        
        // Add header
        
        section.boundarySupplementaryItems = [createHeaderLayout()]
        
        return section
    }

     private func createHeaderLayout() -> NSCollectionLayoutBoundarySupplementaryItem{
        // Add header
        let headerSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(44)
        )
        let header = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerSize,
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
        )
        return header
    }
    // MARK: - Helper Methods
    
    /// 處理 More 按鈕點擊
    private func handleMoreButtonTapped(for section: HomeSection) {
        print("🔘 More button tapped for section: \(section.title)")
        
        switch section {
        case .featuredPokémon:
            onTapSeeMoreFeatured?()
        case .types:
            showAlert(title: "Types", message: "Navigate to full types list")
        case .regions:
            showAlert(title: "Regions", message: "Navigate to full regions list")
        }
    }
    
    /// 顯示簡單提示（可以替換為實際的導航邏輯）
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "確定", style: .default))
        present(alert, animated: true)
    }

    /// 顯示錯誤提示
    private func showErrorAlert(message: String) {
        let alert = UIAlertController(
            title: "錯誤",
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "確定", style: .default))
        present(alert, animated: true)
    }
}
// MARK: - UICollectionViewDelegate
extension HomeViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)

        guard let item = dataSource.itemIdentifier(for: indexPath) else {
            return
        }

        switch item {
        case .pokemon(let id):
            // 從 ViewModel 拿這隻寶可夢的狀態
            guard let state = vm.pokemons[id] else { return }

            // 只有在已經載入完成時才跳詳情頁
            if case let .loaded(pokemon) = state {
                onTapPokemon?(pokemon)       // ⭐️ 呼叫 closure 交給外層處理導航
            } else {
                print("⚠️ Pokemon \(id) not loaded yet, state: \(state)")
            }

        case .type:
            break

        case .region:
            break
        }
    }
}
