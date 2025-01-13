//
//  HikeBiteApp.swift
//  HikeBite
//
//  Created by Ari Guzzi on 1/13/25.
//

import SwiftUI

@main
struct HikeBiteApp: App {
    var body: some Scene {
        WindowGroup {
            MainView()
        }
        .modelContainer(
            .standard
        )
    }
}
