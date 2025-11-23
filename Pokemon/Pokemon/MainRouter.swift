//
//  MainRouter.swift
//  Pokemon
//
//  Created by 莊羚羊 on 2025/11/24.
//

import Foundation
import SwiftUI
import Combine
/// 管理主流程的 NavigationStack
final class MainRouter: ObservableObject {
    @Published var path: [AppRoute] = []

    func push(_ route: AppRoute) {
        path.append(route)
    }

    func pop() {
        guard !path.isEmpty else { return }
        path.removeLast()
    }

    func popToRoot() {
        path.removeAll()
    }
}
