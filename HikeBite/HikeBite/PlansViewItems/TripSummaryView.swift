//
//  TripSummaryView.swift
//  HikeBite
//
//  Created by Ari Guzzi on 4/4/25.
//

import SwiftUI

struct TripSummaryView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @State private var meals: [MealEntry] = []
    var trip: Trip
    var allMeals: [MealEntry]
    var onDone: () -> Void
    var body: some View {
        VStack {
            ScrollView {
                VStack(spacing: 16) {

                    Text(trip.name)
                        .font(Font.custom("FONTSPRINGDEMO-FieldsDisplaySemiBoldRegular", size: 28))
                        .padding(.bottom, 4)

                    Text("Duration: \(trip.days) days")
                        .font(.subheadline)
                        .foregroundColor(.gray)

                    summaryStats

                    Divider()

                    VStack(alignment: .leading, spacing: 10) {
                        Text("Meals by Day")
                            .font(.headline)
                            .padding(.bottom, 5)

                        ForEach(groupedMeals.keys.sorted(), id: \.self) { day in
                            VStack(alignment: .leading) {
                                Text(day)
                                    .font(.subheadline)
                                    .fontWeight(.bold)

                                ForEach(groupedMeals[day] ?? []) { meal in
                                    Text("• \(meal.meal): \(meal.recipeTitle) (\(meal.servings)x)")
                                        .font(.caption)
                                }
                            }
                            .padding(.bottom, 6)
                        }
                    }
                    .padding()
                }
                .padding()
            }

            Button("Close") {
                dismiss()
                onDone()
            }
            .padding(.horizontal, 30)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 30)
                    .fill(Color("AccentColor"))
            )
            .foregroundColor(.white)
            .font(Font.custom("FONTSPRINGDEMO-FieldsDisplayMediumRegular", size: 16))
            .padding(.bottom)
        }
        .onAppear {
            meals = allMeals.filter { $0.tripName == trip.name }
        }
    }

    private var summaryStats: some View {
        let totalCalories = meals.reduce(0) { $0 + $1.totalCalories }
        let totalGrams = meals.reduce(0) { $0 + $1.totalGrams }

        return VStack(alignment: .leading, spacing: 4) {
            Text("Total Meals: \(meals.count)")
            Text("Total Calories: \(totalCalories)")
            Text("Total Weight: \(totalGrams) g")
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }

    private var groupedMeals: [String: [MealEntry]] {
        Dictionary(grouping: meals, by: { $0.day })
    }
}

