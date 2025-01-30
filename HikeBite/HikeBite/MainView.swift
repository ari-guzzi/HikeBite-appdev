//
//  MainView.swift
//  HikeBite
//
//  Created by Ari Guzzi on 1/13/25.
//

import SwiftUI

struct MainView: View {
    @State private var selectedTab: Int = 0
    var body: some View {
        TabView(selection: $selectedTab) {
            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                }
                .tag(0)
            Templates()
                .tabItem {
                    Label("Templates", systemImage: "newspaper")
                }
                .tag(1)
            PlansView()
                .tabItem {
                    Label("Trips", systemImage: "list.bullet.rectangle.fill")
                }
                .tag(2)
            ContentView()
                .tabItem {
                    Label("Meals", systemImage: "book.fill")
                }
                .tag(3)
        }
        .onOpenURL { url in
            if url.host == "navigate" {
                selectedTab = 2
            }
        }
    }
}

#Preview {
    MainView()
}
