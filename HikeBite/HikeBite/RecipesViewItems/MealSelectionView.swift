//
//  MealSelectionView.swift
//  HikeBite
//
//  Created by Ari Guzzi on 1/30/25.
//

import SwiftUI

struct MealSelectionView: View {
    @Binding var selectedTrip: Trip?
    @Binding var selectedDay: String
    @Binding var selectedMeal: String
    @Binding var servings: Int
    var onSave: () -> Void
    @EnvironmentObject var tripManager: TripManager
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Select a Trip")) {
                    if tripManager.trips.isEmpty {
                        Text("No trips available. Please add a trip first.")
                    } else {
                        Picker("Trip", selection: $selectedTrip) {
                            ForEach(tripManager.trips, id: \.id) { trip in
                                Text(trip.name).tag(trip as Trip?)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                    }
                }
                // Ensure a trip is selected before showing these options
                if let trip = selectedTrip {
                    Section(header: Text("Select a Day")) {
                        Picker("Day", selection: $selectedDay) {
                            ForEach(1...(trip.days), id: \.self) { day in
                                Text("Day \(day)").tag("Day \(day)")
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                    }
                    Section(header: Text("Select a Meal")) {
                        Picker("Meal", selection: $selectedMeal) {
                            ForEach(["Breakfast", "Lunch", "Dinner", "Snacks"], id: \.self) { meal in
                                Text(meal)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                    }
                    Section(header: Text("Servings")) {
                        Stepper("Servings: \(servings)", value: $servings, in: 1...20)
                    }
                }
                Button("Add to Plan") {
                    onSave()
                    dismiss()
                }
                .disabled(selectedTrip == nil)
            }
            .navigationTitle("Add to Plan")
            .navigationBarItems(trailing: Button("Cancel", action: { dismiss() }))
        }
        .onAppear {
            tripManager.fetchTrips(modelContext: modelContext)
        }
    }
}
