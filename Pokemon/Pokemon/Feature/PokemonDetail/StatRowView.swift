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
            titleView
            barView
        }
        .frame(height: 15)
    }
}

private extension StatRowView {

    // 標題（HP / ATK / DEF / SPD）
    var titleView: some View {
        Text(title)
            .font(.system(size: 14, weight: .semibold))
            .foregroundColor(.secondary)
            .frame(width: 32, alignment: .leading)
    }

    // 整條 Bar（背景 + 前景 + 文字）
    var barView: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                barBackground
                barForeground(width: geo.size.width)
                barLabel
            }
        }
    }

    // 灰色背景條
    var barBackground: some View {
        Capsule()
            .fill(Color(.systemGray5))
    }

    // 有顏色的進度條
    func barForeground(width: CGFloat) -> some View {
        let clampedValue = max(0, min(value, maxValue))
        let ratio = CGFloat(clampedValue) / CGFloat(maxValue)
        let barWidth = width * ratio

        return Capsule()
            .fill(.white)
            .fill(
                LinearGradient(
                    colors: [color, color.opacity(0.6)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .frame(width: barWidth)
    }

    // 中間顯示「value/maxValue」的文字
    var barLabel: some View {
        HStack {
            Spacer()
            Text("\(value)/\(maxValue)")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.black)
            Spacer()
        }
    }
}

