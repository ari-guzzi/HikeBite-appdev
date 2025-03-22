//
//  PreviousTripsView.swift
//  HikeBite
//
//  Created by Ari Guzzi on 2/23/25.
//

import SwiftUI

struct PreviousTripsView: View {
    let previousTrips = ["Previous Trip 1", "Previous Trip 2", "Previous Trip 3", "Previous Trip 4", "Previous Trip 5"]
    var body: some View {
        VStack {
            HStack {
                Text("Previous Trips")
                    .font(.largeTitle)
                    .padding(.leading, 20)
                Spacer()
            }
            .padding(.top)
            List(previousTrips, id: \.self) { previousTrip in
                HStack {
                    Text(previousTrip)
                        .font(.title3)
                    Spacer()
//                    Image(systemName: "chevron.right")
//                        .foregroundColor(.gray)
                }
            }
            .listStyle(PlainListStyle())
        }
        .edgesIgnoringSafeArea(.all)
    }
}
