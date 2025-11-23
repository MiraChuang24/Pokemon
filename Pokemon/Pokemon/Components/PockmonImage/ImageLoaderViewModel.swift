//
//  ImageLoaderViewModel.swift
//  Pokemon
//
//  Created by 莊羚羊 on 2025/11/23.
//

import Combine
import Foundation
import Kingfisher

/// 跨 UIKit / SwiftUI 可共用的 VM
final class ImageLoaderViewModel: ObservableObject {

    // MARK: - Input
    private var urlString: String? {
        didSet {
            if urlString == nil, urlString?.isEmpty ?? true {
                isNoImage = true
            } else {
                isNoImage = false
            }
        }
    }

    // MARK: - Output（給 View 綁定用）
    @Published private(set) var imageURL: URL?
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var showError: Bool = false
    @Published private(set) var isNoImage: Bool = true

    private(set) var errorMessage: String = "" {
        didSet {
            print(errorMessage)
        }
    }

    // MARK: - Init
    init(urlString: String) {
        self.urlString = urlString
        loadImage()
    }

    // MARK: - Public API（View 可以呼叫）
    func loadImage() {
        guard let urlString else { return }
        let trimmed = urlString.trimmingCharacters(in: .whitespaces)

        guard !trimmed.isEmpty else {
            setError("請輸入有效的 URL")
            return
        }

        guard let url = URL(string: trimmed) else {
            setError("URL 格式不正確")
            return
        }

        guard url.scheme == "http" || url.scheme == "https" else {
            setError("URL 必須以 http:// 或 https:// 開頭")
            return
        }

        isLoading = true
        showError = false
        errorMessage = ""
        imageURL = url
    }

    func reload() {

        guard let urlString else { return }
        // 清 Kingfisher 快取（用 urlString 當 key）
        let key = urlString.trimmingCharacters(in: .whitespaces)
        KingfisherManager.shared.cache.removeImage(forKey: key)

        loadImage()
    }

    // MARK: - Private
    private func setError(_ message: String) {
        isLoading = false
        showError = true
        errorMessage = message
        imageURL = nil
    }

    // MARK: - 給 KFImage callback 用
    func finishSuccess() {
        isLoading = false
        showError = false
    }

    func finishFailure(_ error: KingfisherError) {
        isLoading = false
        showError = true
        imageURL = nil
        errorMessage = "圖片載入失敗：\(error.localizedDescription)"

    }
    func setURLString(str: String?) {
        urlString = str
        reload()
    }
}
