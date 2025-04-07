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
                    HStack {
                        NavigationLink(destination: SettingsPage()) {
                            if let imageURL = viewModel.currentUser?.profileImgeURL, let url = URL(string: imageURL) {
                                AsyncImage(url: url) { phase in
                                    switch phase {
                                    case .success(let image):
                                        image.resizable()
                                            .scaledToFill()
                                            .frame(width: 70, height: 70)
                                            .clipShape(Circle())
                                    case .failure(_):
                                        Image("profile") // Default profile image
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 70, height: 70)
                                            .clipShape(Circle())
                                    case .empty:
                                        ProgressView()
                                    @unknown default:
                                        EmptyView()
                                    }
                                }
                            } else {
                                Image("profile") // Default profile image
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 70, height: 70)
                                    .clipShape(Circle())
                            }
                        }
                        VStack(alignment: .leading) {
                            if let user = viewModel.currentUser {
                                Text("\(user.fullname)")
                                    .font(.title)
                                Text("\(user.email)")
                                    .font(.subheadline)
                            } else {
                                Text("Hello, There")
                                    .font(
                                        Font.custom("FONTSPRINGDEMO-FieldsDisplayExtraBoldRegular", size: 48)
                                            .weight(.heavy)
                                    )
                                Text("Welcome to HikeBite")
                                    .font(Font.custom("FONTSPRINGDEMO-FieldsDisplayMediumRegular", size: 16))
                            }
                        }
                        .padding(.leading, 10)
                        Spacer()
                    }
                    .frame(width: UIScreen.main.bounds.width - 10)
                }
            }
            .frame(height: 100)
        }
    }
}
