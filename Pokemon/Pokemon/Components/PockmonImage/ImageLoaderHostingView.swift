//
//  ImageLoaderHostingView.swift
//  Pokemon
//
//  Created by 莊羚羊 on 2025/11/23.
//

import UIKit
import SwiftUI
import SnapKit

final class ImageLoaderHostingView: UIView {

    // 共用的 ViewModel
    let viewModel: ImageLoaderViewModel

    // 裡面包一個 HostingController
    private let hostingController: UIHostingController<ImageLoaderView>

    // MARK: - 初始化（給程式碼用）
    override init(frame: CGRect) {
        let vm = ImageLoaderViewModel(urlString: "")
        self.viewModel = vm
        self.hostingController = UIHostingController(
            rootView: ImageLoaderView(viewModel: vm)
        )
        super.init(frame: frame)
        commonInit()
    }

    // MARK: - 初始化（給 XIB / Storyboard 用）
    required init?(coder: NSCoder) {
        let vm = ImageLoaderViewModel(urlString: "")
        self.viewModel = vm
        self.hostingController = UIHostingController(
            rootView: ImageLoaderView(viewModel: vm)
        )
        super.init(coder: coder)
        commonInit()
    }

    // MARK: - 共用設定
    private func commonInit() {
        hostingController.view.backgroundColor = .clear

        addSubview(hostingController.view)
        hostingController.view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    // MARK: - 對外 API：UIKit / XIB 都用這個設 URL
    func configure(urlString: String?) {
        viewModel.setURLString(str: urlString)
    }
}
