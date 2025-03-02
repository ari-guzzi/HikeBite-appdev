//
//  ProfileNameView.swift
//  HikeBite
//
//  Created by Ari Guzzi on 2/23/25.
//

import SwiftUI

struct ProfileNameView: View {
    @EnvironmentObject var viewModel: AuthViewModel

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ZStack {
                    LinearGradient(gradient: Gradient(colors: [.blue, .white]), startPoint: .top, endPoint: .bottom)
                        .frame(height: 100)
                        .edgesIgnoringSafeArea(.top)
                    HStack {
                        NavigationLink(destination: SettingsPage()) {
                            Image("profile")
                                .resizable()
                                .scaledToFill()
                                .frame(width: 70, height: 70)
                                .clipShape(Circle())
                                .padding(.leading, 15)
                        }
                        VStack(alignment: .leading) {
                            if let user = viewModel.currentUser {
                                Text("\(user.fullname)")
                                    .font(.title)
                                Text("\(user.email)")
                                    .font(.subheadline)
                            } else {
                                Text("Hello There!")
                                    .font(.title)
                                Text("Welcome to HikeBite")
                                    .font(.subheadline)
                            }
                        }
                        .padding(.leading, 10)
                        Spacer()
                    }
                }
                .frame(height: 100)
            }
        }
    }
}

