//
//  UpcomingTripCardPlansView.swift
//  HikeBite
//
//  Created by Ari Guzzi on 3/15/25.
//

import SwiftUI

struct UpcomingTripCardPlansView: View {
    var trip: Trip
    var body: some View {
        ZStack {
            VStack(alignment: .leading, spacing: 0) {
                ZStack(alignment: .bottom) {
                    Rectangle()
                        .foregroundColor(.clear)
                        .frame(width: 179, height: 171)
                        .background(
                            Image("pinetrees")
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 179, height: 171)
                                .clipped()
                        )
                        .cornerRadius(9)
                        .shadow(color: .black.opacity(0.25), radius: 2, x: 0, y: 4)
                    Rectangle()
                        .foregroundColor(.clear)
                        .frame(width: 179, height: 172)
                        .background(
                            LinearGradient(
                                stops: [
                                    Gradient.Stop(color: .white.opacity(0), location: 0.00),
                                    Gradient.Stop(color: .white.opacity(0.5), location: 0.65),
                                    Gradient.Stop(color: .white, location: 1.00),
                                ],
                                startPoint: UnitPoint(x: 0.5, y: 0),
                                endPoint: UnitPoint(x: 0.5, y: 0.62)
                            )
                        )
                        .cornerRadius(9)
                        .shadow(color: .black.opacity(0.25), radius: 2, x: 0, y: 4)
                    VStack(alignment: .leading) {
                        Text(trip.name)
                            .font(
                                Font.custom("Area Normal", size: 16)
                                    .weight(.bold)
                            )
                            .foregroundColor(.black)
                            .frame(width: 165, height: 25, alignment: .leading)
                        HStack {
                            Text(trip.date.formatted(date: .long, time: .omitted))
                                .font(
                                    Font.custom("Fields", size: 12)
                                        .weight(.medium)
                                )
                                .foregroundColor(.black)
                                .frame(width: 131, height: 17, alignment: .leading)
                            Spacer()
                            Image(systemName: "arrow.right")
                                .frame(width: 24, height: 24)
                        }
                        .background(Color.white)
                        .cornerRadius(4)
                    }
                    .padding(.horizontal)
                    .padding(.bottom)
                }
            }
        }
        .padding(0)
    }
}
