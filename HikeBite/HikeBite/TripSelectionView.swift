//
//  TripSelectionView.swift
//  HikeBite
//
//  Created by Ari Guzzi on 2/22/25.
//

import SwiftUI

struct TripSelectionView: View {
    var tripManager: TripManager
    @Binding var selectedTrip: Trip?
    @Binding var showTripPicker: Bool
    @State private var tempSelectedTrip: Trip? = nil

    var body: some View {
        NavigationView {
            VStack {
                Picker("Select a Trip", selection: $tempSelectedTrip) {
                    Text("Select a Trip").tag(nil as Trip?)
                    ForEach(tripManager.trips) { trip in
                        Text(trip.name).tag(trip as Trip?)
                    }
                }
                .pickerStyle(WheelPickerStyle())
                .frame(height: 150)
                .padding()

                Button("OK") {
                    selectedTrip = tempSelectedTrip
                    showTripPicker = false
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            .navigationTitle("Choose Your Trip")
            .toolbar {
                Button("Cancel") {
                    showTripPicker = false
                }
            }
        }
    }
}
