//
//  SnacksView.swift
//  HikeBite
//
//  Created by Ari Guzzi on 3/8/25.
//

import SwiftData
import SwiftUI

struct SnacksView: View {
    // var snacks: [MealEntry]
    var deleteMeal: (MealEntry) -> Void
    var swapMeal: (MealEntry) -> Void
    var tripName: String
    var refreshMeals: () -> Void
    @State private var showingAddMealSheet = false
    @Binding var selectedMealEntry: MealEntry?
    @Query private var snacks: [MealEntry]
    /* @Query(filter: #Predicate<MealEntry> { meal in
            meal.tripName == tripName && meal.day == "Day 1" && meal.meal == "Snacks"
        }) private var snacks: [MealEntry] */

    init(
        tripName: String,
        deleteMeal: @escaping (MealEntry) -> Void,
        swapMeal: @escaping (MealEntry) -> Void,
        refreshMeals: @escaping () -> Void,
        selectedMealEntry: Binding<MealEntry?>
    ) {
        self.tripName = tripName
        self.deleteMeal = deleteMeal
        self.swapMeal = swapMeal
        self.refreshMeals = refreshMeals
        self._selectedMealEntry = selectedMealEntry

        self._snacks = Query(filter: #Predicate<MealEntry> { meal in
            meal.tripName == tripName &&
            meal.day == "Day 1" &&
            meal.meal == "Snacks"
        })
    }

    var body: some View {
        Section(header: HStack {
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
                            Button(action: {
                                selectedMealEntry = snack
                            }) {
                                Text("\(snack.recipeTitle) \(snack.servings > 1 ? "(\(snack.servings) servings)" : "")")
                                    .font(.body)
                                    .foregroundColor(.black)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            Button(action: { swapMeal(snack) }) {
                                Image(systemName: "arrow.triangle.2.circlepath.circle.fill")
                                    .foregroundColor(.blue)
                                    .padding(.leading, 10)
                            }
                        }
                        .padding(.vertical, 15)
                        .background(Color(red: 0.91, green: 1, blue: 0.96))
                        .cornerRadius(10)
                        .padding(.horizontal)
                    }
                    .shadow(color: .black.opacity(0.25), radius: 2, x: 0, y: 4)
                }
                .padding(.bottom, 4)
            }
        }
        .sheet(isPresented: $showingAddMealSheet) {
            AddMealView(
                day: "Day 1",
                mealType: "Snacks",
                tripName: tripName,
                dismiss: {
                    showingAddMealSheet = false
                    refreshMeals()
                },
                refreshMeals: refreshMeals
            )
        }
    }
}
