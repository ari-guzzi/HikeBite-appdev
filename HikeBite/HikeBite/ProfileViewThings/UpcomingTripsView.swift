//
//  UpcomingTripsView.swift
//  HikeBite
//
//  Created by Ari Guzzi on 2/23/25.
//

import SwiftUI

struct UpcomingTripsView: View {
    var body: some View {
        HStack {
            Text("Upcoming Trips")
                .font(.largeTitle)
                .padding(.leading)
                .padding(.bottom, -5.0)
            Spacer()
        }
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 5) {
                UpcomingTripsPlaceHolder()
                UpcomingTripsPlaceHolder()
                UpcomingTripsPlaceHolder()
                UpcomingTripsPlaceHolder()
            }
        }
    }
}
