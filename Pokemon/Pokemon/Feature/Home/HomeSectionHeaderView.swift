//
//  HomeSectionHeaderView.swift
//  Pokemon
//
//  Created by 莊羚羊 on 2025/11/24.
//

import SnapKit
import UIKit

class HomeSectionHeaderView: UICollectionReusableView {
    static let reuseIdentifier = "HomeSectionHeaderView"

    // MARK: - UI Components

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 25, weight: .bold)
        label.textColor = .label
        return label
    }()

    private let moreButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("See More", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.setTitleColor(.systemBlue, for: .normal)
        return button
    }()

    private let stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.alignment = .center
        stack.distribution = .equalSpacing
        return stack
    }()

    // MARK: - Properties

    var onMoreButtonTapped: (() -> Void)?

    // MARK: - Initialization

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
        backgroundColor = .clear

        addSubview(stackView)
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(moreButton)

        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(
                UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
            )
        }

        moreButton.addTarget(
            self,
            action: #selector(moreButtonTapped),
            for: .touchUpInside
        )
    }

    // MARK: - Configuration

    func configure(title: String, showMoreButton: Bool = true) {
        titleLabel.text = title
        moreButton.isHidden = !showMoreButton
    }

    // MARK: - Actions

    @objc private func moreButtonTapped() {
        onMoreButtonTapped?()
    }
}
