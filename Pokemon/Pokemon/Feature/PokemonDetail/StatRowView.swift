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

                    Capsule()
                        .fill(Color.white)
                        .fill(
                            LinearGradient(
                                colors: [color, color.opacity(0.6)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(
                            width: max(
                                0,
                                min(
                                    geo.size.width * CGFloat(value) / CGFloat(maxValue),
                                    geo.size.width
                                )
                            )
                        )
                    HStack{
                        Spacer()
                        Text("\(value)/\(maxValue)")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.black)
                        Spacer()
                    }
                }
            }

            
        }
        .frame(height: 15)
    }
}
