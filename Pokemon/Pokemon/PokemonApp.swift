//
//  PokemonApp.swift
//  Pokemon
//
//  Created by 莊羚羊 on 2025/11/23.
//

import SwiftUI

@main
struct PokemonApp: App {
    @StateObject private var mainRouter = MainRouter()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(mainRouter)
        }
    }
}
