//
//  DaysView.swift
//  HikeBite
//
//  Created by Ari Guzzi on 2/22/25.
//

import SwiftData
import SwiftUI

struct DaysView: View {
    var deleteMeal: (MealEntry) -> Void
    var swapMeal: (MealEntry) -> Void
    var tripName: String
    var refreshMeals: () -> Void
    var day: String
    @Binding var selectedTab: Int
    @Binding var showSnacksConsolidated: Bool
    @State private var showingAddMealSheet = false
    @State private var selectedMealType = ""
    let mealTypes = ["Breakfast", "Lunch", "Dinner", "Snacks"]
    @Query private var mealsForDay: [MealEntry]
    @Binding var selectedMealEntry: MealEntry?

    init(
        tripName: String,
        day: String,
        deleteMeal: @escaping (MealEntry) -> Void,
        swapMeal: @escaping (MealEntry) -> Void,
        refreshMeals: @escaping () -> Void,
        selectedTab: Binding<Int>,
        showSnacksConsolidated: Binding<Bool>,
        selectedMealEntry: Binding<MealEntry?>
    ) {
        self.tripName = tripName
        self.day = day
        self.deleteMeal = deleteMeal
        self.swapMeal = swapMeal
        self.refreshMeals = refreshMeals
        self._selectedTab = selectedTab
        self._showSnacksConsolidated = showSnacksConsolidated
        self._selectedMealEntry = selectedMealEntry

        self._mealsForDay = Query(filter: #Predicate<MealEntry> { meal in
            meal.tripName == tripName && meal.day == day
        })
    }
    var body: some View {
        VStack {
            ForEach(mealTypes.filter { $0 != "Snacks" || !showSnacksConsolidated }, id: \.self) { mealType in
                let mealsForType = mealsForDay.filter { $0.meal.caseInsensitiveCompare(mealType) == .orderedSame }
                let totals = calculateTotals(for: mealsForType)
                mealTypeSection(mealType, totals: totals)
                    .padding(.bottom, 12)
            }
        }
        .sheet(isPresented: $showingAddMealSheet) {
            AddMealView(
                day: day,
                mealType: selectedMealType,
                tripName: tripName,
                dismiss: {
                    showingAddMealSheet = false
                    refreshMeals()
                },
                refreshMeals: refreshMeals
            )
        }
    }
    private func calculateTotals(for meals: [MealEntry]) -> (calories: Int, grams: Int) {
        let totalCalories = meals.reduce(0) { $0 + $1.totalCalories }
        let totalGrams = meals.reduce(0) { $0 + $1.totalGrams }
        return (totalCalories, totalGrams)
    }
    @ViewBuilder
    private func mealTypeSection(_ mealType: String, totals: (calories: Int, grams: Int)) -> some View {
        VStack(alignment: .leading) {
            sectionHeader(mealType: mealType, totals: totals)
            mealList(for: mealsForDay.filter { $0.meal.caseInsensitiveCompare(mealType) == .orderedSame })
        }
    }
    private func sectionHeader(mealType: String, totals: (calories: Int, grams: Int)) -> some View {
        HStack {
            Text(mealType)
                .font(Font.custom("Area Normal", size: 16).weight(.heavy))
                .foregroundColor(.black)
            Spacer()
            Text("\(totals.calories) Calories, \(totals.grams) Grams")
                .font(.caption)
            Button(action: {
                selectedMealType = mealType
                showingAddMealSheet = true
            }) {
                Image(systemName: "plus.circle.fill")
                    .foregroundColor(.green)
                    .font(.title2)
            }
        }
    }
    @ViewBuilder
    private func mealList(for meals: [MealEntry]) -> some View {
        ForEach(meals, id: \.id) { meal in
            mealItem(meal: meal, deleteMeal: deleteMeal, swapMeal: swapMeal)
        }
    }
    private func mealItem(meal: MealEntry, deleteMeal: @escaping (MealEntry) -> Void, swapMeal: @escaping (MealEntry) -> Void) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(red: 0.91, green: 1, blue: 0.96))
                .shadow(color: .black.opacity(0.25), radius: 2, x: 0, y: 4)
            HStack(spacing: 8) {
                Button(action: { deleteMeal(meal); refreshMeals() }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.red)
                }
                Button(action: {
                    selectedMealEntry = meal
                }) {
                    Text("\(meal.recipeTitle) \(meal.servings > 1 ? "(\(meal.servings) servings)" : "")")
                        .font(.body)
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                Button(action: { swapMeal(meal) }) {
                    Image(systemName: "arrow.triangle.2.circlepath.circle.fill")
                        .foregroundColor(.blue)
                }
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
        }
        .padding(.horizontal)
        .padding(.vertical, 1)
    }
}
