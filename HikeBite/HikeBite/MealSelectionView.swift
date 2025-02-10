//
//  MealSelectionView.swift
//  HikeBite
//
//  Created by Ari Guzzi on 1/30/25.
//

import SwiftUI

struct MealSelectionView: View {
    @Binding var selectedDay: String
    @Binding var selectedMeal: String
    var onSave: () -> Void

    let days = ["Day 1", "Day 2", "Day 3"]
    let meals = ["Breakfast", "Lunch", "Dinner", "Snacks"]

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            VStack {
                Picker("Select a Day", selection: $selectedDay) {
                    ForEach(days, id: \.self) { day in
                        Text(day)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .padding()

                Picker("Select a Meal", selection: $selectedMeal) {
                    ForEach(meals, id: \.self) { meal in
                        Text(meal)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .padding()

                Button(action: {
                    onSave()
                    dismiss()
                }) {
                    Text("Add to Plan")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding()

                Button(action: { dismiss() }) {
                    Text("Cancel").foregroundColor(.red)
                }
                .padding()
            }
            .navigationTitle("Add to Plan")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
