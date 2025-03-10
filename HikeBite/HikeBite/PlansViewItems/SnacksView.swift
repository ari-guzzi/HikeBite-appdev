//
//  SnacksView.swift
//  HikeBite
//
//  Created by Ari Guzzi on 3/8/25.
//

import SwiftUI

struct SnacksView: View {
    var snacks: [MealEntry]
    var deleteMeal: (MealEntry) -> Void
    var swapMeal: (MealEntry) -> Void
    var tripName: String
    var refreshMeals: () -> Void
    @State private var showingAddMealSheet = false
    
    var body: some View {
        Section(header:
                    HStack {
            Text("Snacks").font(.title).fontWeight(.bold)
            Spacer()
            Button(action: {
                showingAddMealSheet = true
            }) {
                Image(systemName: "plus.circle.fill")
                    .foregroundColor(.green)
                    .font(.title2)
            }
        }
            .padding(.leading, 30)
            .padding(.top, 10)
        ) {
            if snacks.isEmpty {
                Text("No snacks yet").font(.caption).foregroundColor(.gray)
            } else {
                VStack {
                    ForEach(snacks, id: \.id) { snack in
                        HStack {
                            Button(action: { deleteMeal(snack) }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.red)
                                    .padding(.trailing, 10)
                            }
                            Text("\(snack.recipeTitle) \(snack.servings > 1 ? "(\(snack.servings) servings)" : "")")
                                .font(.body)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            Button(action: { swapMeal(snack) }) {
                                Image(systemName: "arrow.triangle.2.circlepath.circle.fill")
                                    .foregroundColor(.blue)
                                    .padding(.leading, 10)
                            }
                        }
                        .padding(.vertical, 5)
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                        .padding(.horizontal)
                    }
                }
            }
        }
        .sheet(isPresented: $showingAddMealSheet) {
            AddMealView(
                day: "Day 1",
                mealType: "Snacks",
                tripName: tripName,
                dismiss: { showingAddMealSheet = false },
                refreshMeals: { refreshMeals() }
            )
        }
    }
}
