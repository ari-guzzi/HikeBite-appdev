//
//  TripPicker.swift
//  HikeBite
//
//  Created by Ari Guzzi on 2/23/25.
//

import SwiftUI

struct TripPicker: View {
    @Binding var selectedTrip: Trip?
    @ObservedObject var tripManager: TripManager
    @State private var showTripPicker = false
    var body: some View {
        Picker("Select a Trip", selection: $selectedTrip) { // ✅ Ensure Binding
            ForEach(tripManager.trips) { trip in
                Text(trip.name).tag(trip as Trip?)
            }
        }
        .pickerStyle(MenuPickerStyle())
        .sheet(isPresented: $showTripPicker) {
            TripSelectionView(tripManager: tripManager, selectedTrip: $selectedTrip, showTripPicker: $showTripPicker)
        }
        .onChange(of: selectedTrip) { newValue in
            print("🔄 selectedTrip changed: \(newValue?.name ?? "None")")
        }

    }
}
