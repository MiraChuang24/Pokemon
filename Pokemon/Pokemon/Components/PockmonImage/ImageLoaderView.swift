//
//  ImageLoaderView.swift
//  Pokemon
//
//  Created by 莊羚羊 on 2025/11/23.
//

import Kingfisher
import SwiftUI

struct ImageLoaderView: View {
    @ObservedObject var viewModel: ImageLoaderViewModel
    var showBackground: Bool = true

    var body: some View {
        ZStack {
            backgroundView
            contentView
        }
    }
}
extension ImageLoaderView {
    fileprivate var backgroundView: some View {
        Group {
            if showBackground {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.secondarySystemBackground))
            }
        }
    }
    @ViewBuilder
    fileprivate var contentView: some View {
        if viewModel.isNoImage {
            noImageView
        } else if let url = viewModel.imageURL {
            remoteImageView(url)
        } else if viewModel.showError {
            errorView
        } else if viewModel.isLoading {
            loadingView
        }
    }
    fileprivate var noImageView: some View {
        Image("questionmark")
            .resizable()
            .scaledToFit()
            .padding(6)
    }
    fileprivate func remoteImageView(_ url: URL) -> some View {
        KFImage(url)
            .placeholder {
                ProgressView()
                    .scaleEffect(1.5)
            }
            .retry(maxCount: 1, interval: .seconds(2))
            .onSuccess { _ in viewModel.finishSuccess() }
            .onFailure { error in viewModel.finishFailure(error) }
            .resizable()
            .aspectRatio(contentMode: .fit)
            .padding(3)
            .frame(maxWidth: .infinity)
            .clipped()
    }
    fileprivate var errorView: some View {
        Button(action: { viewModel.reload() }) {
            Image(systemName: "arrow.clockwise")
                .font(.headline)
                .foregroundColor(.black)
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
        }
    }
    fileprivate var loadingView: some View {
        ProgressView()
            .scaleEffect(1.5)
    }
}
