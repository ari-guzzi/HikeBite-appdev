//
//  DataFrameworkApp.swift
//  DataFramework
//
//  Created by Ari Guzzi on 11/18/24.
//

import SwiftUI
import SwiftData

@main
struct DataFrameworkApp: App {
    var body: some Scene {
        WindowGroup {
            MainView()
        }
        .modelContainer(
            .standard
        )
    }
}
