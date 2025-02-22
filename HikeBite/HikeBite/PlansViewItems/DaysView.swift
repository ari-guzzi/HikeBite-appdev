//
//  DaysView.swift
//  HikeBite
//
//  Created by Ari Guzzi on 2/22/25.
//

import FirebaseFirestore
import SwiftUI

struct DaysView: View {
    var mealsForDay: [MealEntry]
    var deleteMeal: (MealEntry) -> Void
    var swapMeal: (MealEntry) -> Void
    var tripName: String
    var refreshMeals: () -> Void
    var day: String
    @Binding var selectedTab: Int
    @State private var showingAddMealSheet = false
    @State private var selectedMealType = ""

    var body: some View {
        VStack {
            ForEach(["Breakfast", "Lunch", "Dinner", "Snacks"], id: \.self) { mealType in
                let mealsForThisMealType = mealsForDay.filter { $0.meal == mealType }

                VStack(alignment: .leading) {
                    HStack {
                        Image(systemName: "circlebadge.fill")
                            .foregroundColor(Color.gray)
                            .padding(.leading)
                        Text(mealType)
                            .font(.title2)
                        Spacer()
                        Button(action: {
                            selectedMealType = mealType
                            print("🛠️ Selected MealType: \(selectedMealType), Day: \(day)")
                            //  Delay opening the sheet to ensure mealType updates
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                showingAddMealSheet = true
                            }
                        }) {
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(.green)
                                .font(.title2)
                        }
                    }

                    if mealsForThisMealType.isEmpty {
                        Text("No meals yet")
                            .font(.caption)
                            .foregroundColor(.gray)
                            .padding(.leading, 40)
                    } else {
                        VStack {
                            ForEach(mealsForThisMealType, id: \.recipeTitle) { meal in
                                HStack {
                                    Button(action: { deleteMeal(meal) }) {
                                        Image(systemName: "xmark.circle.fill")
                                            .foregroundColor(.red)
                                            .padding(.trailing, 10)
                                    }
                                    Text("\(meal.recipeTitle) \(meal.servings > 1 ? "(\(meal.servings) servings)" : "")")
                                        .font(.body)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                    Button(action: { swapMeal(meal) }) {
                                        Image(systemName: "arrow.triangle.2.circlepath.circle.fill")
                                            .foregroundColor(.blue)
                                            .padding(.leading, 10)
                                    }
                                }
                                .padding(.vertical, 5)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                Rectangle()
                    .frame(width: 300, height: 1.0)
                    .foregroundColor(.black)
            }
            .onChange(of: selectedMealType) { newValue in
                print("🔄 MealType Updated: \(newValue)")
            }
        }
        .sheet(isPresented: $showingAddMealSheet) {
            AddMealView(
                day: day,
                mealType: selectedMealType,
                tripName: tripName,
                dismiss: { showingAddMealSheet = false },
                refreshMeals: { refreshMeals() }
            )
        }
    }
}

