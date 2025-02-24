//
//  ProfileNameView.swift
//  HikeBite
//
//  Created by Ari Guzzi on 2/23/25.
//

import SwiftUI

struct ProfileNameView: View {
    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                LinearGradient(gradient: Gradient(colors: [.blue, .white]), startPoint: .top, endPoint: .bottom)
                    .frame(height: 100)
                    .edgesIgnoringSafeArea(.top)
                HStack {
                    Image("profile")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 70, height: 70)
                        .clipShape(Circle())
                        .padding(.leading, 15)
                    VStack(alignment: .leading) {
                        Text("Sarah Sarahson")
                            .font(.title)
                        Text("Boulder, Colorado")
                            .font(.subheadline)
                    }
                    .padding(.leading, 10)
                    Spacer()
                }
            }
            .frame(height: 100)
        }
    }
}

