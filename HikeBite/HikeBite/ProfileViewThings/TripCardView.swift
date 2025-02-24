//
//  TripCardView.swift
//  HikeBite
//
//  Created by Ari Guzzi on 2/23/25.
//

import SwiftUI

struct TripCardView: View {
    var trip: Trip

    var body: some View {
        VStack(spacing: 0) {
            Image("backpacking")  // Maybe Replace Later
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 150.0, height: 150)
                .clipShape(RoundedRectangle(cornerRadius: 15))
            VStack(alignment: .center, spacing: 5) {
                Text(trip.name)
                    .font(.caption)
                    .foregroundColor(.black)
                    .frame(width: 150, alignment: .center)
                Text(trip.date.formatted(date: .long, time: .omitted))
                    .font(.caption2)
                    .foregroundColor(.gray)
                    .frame(width: 150, alignment: .center)
            }
            .padding(.vertical, 8)
            .frame(width: 150)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 3)
        .padding(.bottom, 10)
    }
}
