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
//    var body: some View {
//        VStack {
//            Button(action: { showTripPicker = true }) {
//                Text(selectedTrip?.name ?? "Select a Trip")
//                    .frame(maxWidth: .infinity)
//                    .padding()
//                    .background(Color.gray.opacity(0.2))
//                    .cornerRadius(10)
//                    .foregroundColor(.black)
//            }
//            .padding()
//        }
//        .sheet(isPresented: $showTripPicker) {
//            TripSelectionView(tripManager: tripManager, selectedTrip: $selectedTrip, showTripPicker: $showTripPicker)
//        }
//    }
}
