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
    @Binding var showSnacksConsolidated: Bool
    @State private var showingAddMealSheet = false
    @State private var selectedMealType = ""
    @State private var selectedMeal: MealEntry?
    let mealTypes = ["Breakfast", "Lunch", "Dinner", "Snacks"]

    var body: some View {
        VStack {
            mealTypeList()
        }
        .sheet(isPresented: $showingAddMealSheet) {
            AddMealView(
                day: day,
                mealType: selectedMealType,
                tripName: tripName,
                dismiss: { showingAddMealSheet = false },
                refreshMeals: refreshMeals
            )
        }
        .onAppear {
            if selectedMealType.isEmpty && !mealTypes.isEmpty {
                selectedMealType = mealTypes.first ?? "Lunch"
            }
        }
        
    }

    @ViewBuilder
    private func mealTypeList() -> some View {
        ForEach(mealTypes.filter { $0 != "Snacks" || !showSnacksConsolidated }, id: \.self) { mealType in
            mealTypeSection(mealType)
        }
    }

    @ViewBuilder
    private func mealTypeSection(_ mealType: String) -> some View {
        let mealsForThisType = mealsForDay.filter { $0.meal.caseInsensitiveCompare(mealType) == .orderedSame }
        VStack(alignment: .leading) {
            sectionHeader(mealType: mealType)
            mealList(for: mealsForThisType)
        }
    }

    @ViewBuilder
    private func mealList(for meals: [MealEntry]) -> some View {
        if meals.isEmpty {
            Text("No meals yet")
                .font(.caption)
                .foregroundColor(.gray)
                .padding(.leading, 40)
        } else {
            ForEach(meals, id: \.id) { meal in
                mealItem(meal: meal, deleteMeal: deleteMeal, swapMeal: swapMeal)
                    .onTapGesture {
                        self.selectedMeal = meal // Set the meal for the popover
                    }
//                    .popover(isPresented: .constant(selectedMeal != nil && selectedMeal == meal), arrowEdge: .leading) {
//                        MealDetailView(meal: meal) // Show details in the popover
//                    }
            }
        }
    }

    private func sectionHeader(mealType: String) -> some View {
        HStack {
            Text(mealType)
                .font(
                Font.custom("Area Normal", size: 16)
                .weight(.heavy)
                )
                .foregroundColor(.black)
            Spacer()
            Text("X Calories X Grams")
                .font(.caption)
            Button(action: {
                print("Adding meal for type: \(mealType) on \(day)")
                selectedMealType = mealType
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    selectedMealType = mealType
                    showingAddMealSheet = true
                }
            }) {
                Image(systemName: "plus.circle.fill")
                    .foregroundColor(.green)
                    .font(.title2)
            }
        }
    }

    private func mealItem(meal: MealEntry, deleteMeal: @escaping (MealEntry) -> Void, swapMeal: @escaping (MealEntry) -> Void) -> some View {
        HStack {
            Button(action: {
                deleteMeal(meal)
                refreshMeals()}) {
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
        .background(Color(red: 0.91, green: 1, blue: 0.96))
        .cornerRadius(10)
        .padding(.horizontal)
    }
}
