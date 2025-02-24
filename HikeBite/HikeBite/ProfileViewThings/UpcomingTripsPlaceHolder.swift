//
//  UpcomingTripsPlaceHolder.swift
//  HikeBite
//
//  Created by Ari Guzzi on 2/23/25.
//

import SwiftUI

struct UpcomingTripsPlaceHolder: View {
    var body: some View {
        VStack(spacing: -20) {
            Image("backpacking")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 150.0, height: 150)
                .scaledToFit()
            VStack(alignment: .leading) {
                Text("Trip Name")
                    .font(.caption)
                    .foregroundColor(Color.black)
                    .frame(width: 150, alignment: .center)
                Text("January 29, 2024")
                    .font(.caption2)
                    .foregroundColor(Color.black)
                    .frame(width: 150, alignment: .center)
            }
        }
    }
}
