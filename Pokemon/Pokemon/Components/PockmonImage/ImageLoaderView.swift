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

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.imageBackground))

            if viewModel.isNoImage {
                Image("questionmark")
            } else if let imageURL = viewModel.imageURL {
                KFImage(imageURL)
                    .placeholder {
                        ProgressView()
                            .scaleEffect(1.5)
                    }
                    .retry(maxCount: 1, interval: .seconds(2))
                    .onSuccess { _ in
                        viewModel.finishSuccess()
                    }
                    .onFailure { error in
                        viewModel.finishFailure(error)
                    }
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding(3)
                    .frame(maxWidth: .infinity)
                    .clipped()

            } else if viewModel.showError {
                Button(action: {
                    viewModel.reload()
                }) {
                    HStack {
                        Image(systemName: "arrow.clockwise")
                    }
                    .font(.headline)
                    .foregroundColor(.black)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                }

            } else if viewModel.isLoading {
                VStack(spacing: 15) {
                    ProgressView()
                        .scaleEffect(1.5)
                }
            }
        }
    }
}

// MARK: - Preview
#Preview {
    VStack {
        ImageLoaderView(
            viewModel: ImageLoaderViewModel(
                urlString:
                    "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/132.png"
            )
        )
        ImageLoaderView(
            viewModel: ImageLoaderViewModel(
                urlString:
                    ""
            )
        )
        ImageLoaderView(
            viewModel: ImageLoaderViewModel(
                urlString:
                    "reload"
            )
        )
    }
}
