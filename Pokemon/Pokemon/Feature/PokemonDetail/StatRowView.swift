//
//  StatRowView.swift
//  Pokemon
//
//  Created by 莊羚羊 on 2025/11/24.
//

import Foundation
import SwiftUI

struct StatRowView: View {
    let title: String
    let value: Int
    let maxValue: Int = 255
    let color: Color

    var body: some View {
        HStack(spacing: 12) {
            Text(title)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.secondary)
                .frame(width: 32, alignment: .leading)

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color(.systemGray5))
                        .frame(height: 10)

                    Capsule()
                        .fill(color)
                        .frame(
                            width: max(
                                0,
                                min(
                                    geo.size.width * CGFloat(value) / CGFloat(maxValue),
                                    geo.size.width
                                )
                            ),
                            height: 10
                        )
                }
            }
            .frame(height: 10)

            Text("\(value)/\(maxValue)")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.secondary)
                .frame(width: 70, alignment: .trailing)
        }
        .frame(height: 24)
    }
}
