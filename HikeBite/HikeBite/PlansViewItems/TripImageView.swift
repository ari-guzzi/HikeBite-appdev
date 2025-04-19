//
//  TripImageView.swift
//  HikeBite
//
//  Created by Ari Guzzi on 4/19/25.
//

import SwiftUI

struct TripImageView: View {
    let tripName: String

    var body: some View {
        ZStack {
            Image("pinetrees")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: UIScreen.main.bounds.width, height: 300)
                .clipped()
                .cornerRadius(10)
                .shadow(color: .black.opacity(0.25), radius: 2, x: 0, y: 4)
                .overlay(
                    LinearGradient(
                        gradient: Gradient(colors: [.white, .clear]),
                        startPoint: .top,
                        endPoint: .center
                    )
                    .frame(height: 300)
                )
                .overlay(
                    VStack {
                        Spacer()
                        LinearGradient(
                            gradient: Gradient(stops: [
                                .init(color: .clear, location: 0),
                                .init(color: .white, location: 1)
                            ]),
                            startPoint: .top,
                            endPoint: .center
                        )
                        .frame(height: 112)
                    }
                )
                Text(tripName ?? "Unknown Trip")
                    .font(
                        Font.custom("Area Normal", size: 24)
                            .weight(.bold)
                    )
                    .foregroundColor(.black)
                    .frame(width: 287, height: 45.25401, alignment: .topLeading)
                    .offset(x: -40, y: -90)
            VStack {
                Spacer()
                Rectangle()
                    .fill(Color.white)
                    .frame(height: 50)
                    .cornerRadius(10)
            }
        }
        .frame(height: 216)
    }
}
