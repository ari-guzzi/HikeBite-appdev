//
//  mainView.swift
//  DataFramework
//
//  Created by Ari Guzzi on 12/3/24.
//

import SwiftUI

struct MainView: View {
    var body: some View {
        TabView {
            ContentView()
                .tabItem {
                    Label("Recipes", systemImage: "book.fill")
                }
                .environmentObject(GroceryListManager())

            GroceryList()
                .tabItem {
                    Label("Grocery List", systemImage: "cart.fill")
                }
                .environmentObject(GroceryListManager())
        }
    }
}

#Preview {
    MainView()
}
