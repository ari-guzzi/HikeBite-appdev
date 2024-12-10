//
//  MainView.swift
//  DataFramework
//
//  Created by Ari Guzzi on 12/3/24.
//

import SwiftUI

struct MainView: View {
    @State private var selectedTab: Int = 0
    var body: some View {
        TabView(selection: $selectedTab) {
            ContentView()
                .tabItem {
                    Label("Recipes", systemImage: "book.fill")
                }
                .tag(0)
            GroceryList()
                .tabItem {
                    Label("Grocery List", systemImage: "cart.fill")
                }
                .tag(1)
        }
        .onOpenURL { url in
            if url.host == "navigate" {
                selectedTab = 1
            }
        }
    }
}

#Preview {
    MainView()
}
