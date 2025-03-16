//
//  DaysView.swift
//  HikeBite
//
//  Created by Ari Guzzi on 2/22/25.
//

import FirebaseFirestore
import SwiftUI

//struct DaysView: View {
//    var mealsForDay: [MealEntry]
//    var deleteMeal: (MealEntry) -> Void
//    var swapMeal: (MealEntry) -> Void
//    var tripName: String
//    var refreshMeals: () -> Void
//    var day: String
//    @Binding var selectedTab: Int
//    @Binding var showSnacksConsolidated: Bool
//    @State private var showingAddMealSheet = false
//    @State private var selectedMealType = ""
//    @State private var selectedMeal: MealEntry?
//
//    let mealTypes = ["Breakfast", "Lunch", "Dinner", "Snacks"] 
//
//    var body: some View {
//        VStack {
//            Text("X Calories X Grams")
//            ForEach(mealTypes.filter { $0 != "Snacks" || !showSnacksConsolidated }, id: \.self) { mealType in
//                let mealsForThisType = mealsForDay.filter { $0.meal.caseInsensitiveCompare(mealType) == .orderedSame }
//
//                VStack(alignment: .leading) {
//                    HStack {
//                        Image(systemName: "circlebadge.fill")
//                            .foregroundColor(Color.gray)
//                            .padding(.leading)
//                        Text(mealType)
//                            .font(.title2)
//                        Spacer()
//                        Text("X Calories X Grams")
//                            .font(.caption)
//                        Button(action: {
//                            selectedMealType = mealType
//                            print("➕ Adding Meal: \(selectedMealType) on \(day)")
//                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
//                                showingAddMealSheet = true
//                            }
//                        }) {
//                            Image(systemName: "plus.circle.fill")
//                                .foregroundColor(.green)
//                                .font(.title2)
//                        }
//                    }
//                    .padding(.top, 10)
//
//                    if mealsForThisType.isEmpty {
//                        Text("No meals yet")
//                            .font(.caption)
//                            .foregroundColor(.gray)
//                            .padding(.leading, 40)
//                    } else {
//                        VStack {
//                            ForEach(mealsForThisType, id: \.id) { meal in
//                                HStack {
//                                    Button(action: { deleteMeal(meal) }) {
//                                        Image(systemName: "xmark.circle.fill")
//                                            .foregroundColor(.red)
//                                            .padding(.trailing, 10)
//                                    }
//                                    Text("\(meal.recipeTitle) \(meal.servings > 1 ? "(\(meal.servings) servings)" : "")")
//                                        .font(.body)
//                                        .frame(maxWidth: .infinity, alignment: .leading)
//                                    Button(action: { swapMeal(meal) }) {
//                                        Image(systemName: "arrow.triangle.2.circlepath.circle.fill")
//                                            .foregroundColor(.blue)
//                                            .padding(.leading, 10)
//                                    }
//                                }
//                                .padding(.vertical, 5)
//                                .background(Color(.systemGray6))
//                                .cornerRadius(10)
//                                .padding(.horizontal)
//                            }
//                        }
//                    }
//                }
//                Rectangle()
//                    .frame(width: 300, height: 1.0)
//                    .foregroundColor(.black)
//            }
//            .onChange(of: selectedMealType) { newValue in
//                print("🔄 MealType Updated: \(newValue)")
//            }
//        }
//        .sheet(isPresented: $showingAddMealSheet) {
//            AddMealView(
//                day: day,
//                mealType: selectedMealType,
//                tripName: tripName,
//                dismiss: { showingAddMealSheet = false },
//                refreshMeals: { refreshMeals() }
//            )
//        }
//    }
//}


//struct DaysView: View {
//    var mealsForDay: [MealEntry]
//    var deleteMeal: (MealEntry) -> Void
//    var swapMeal: (MealEntry) -> Void
//    var tripName: String
//    var refreshMeals: () -> Void
//    var day: String
//    @Binding var selectedTab: Int
//    @Binding var showSnacksConsolidated: Bool
//    @State private var showingAddMealSheet = false
//    @State private var selectedMealType = ""
//    @State private var selectedMeal: MealEntry?
//    let mealTypes = ["Breakfast", "Lunch", "Dinner", "Snacks"]
//    var body: some View {
//        VStack {
//            mealTypeList()
//        }
//    }
//    @ViewBuilder
//    private func mealTypeList() -> some View {
//        ForEach(mealTypes.filter { $0 != "Snacks" || !showSnacksConsolidated }, id: \.self) { mealType in
//            let mealsForThisType = mealsForDay.filter { $0.meal.caseInsensitiveCompare(mealType) == .orderedSame }
//            VStack(alignment: .leading) {
//                sectionHeader(mealType: mealType)
//                if mealsForThisType.isEmpty {
//                    Text("No meals yet")
//                        .font(.caption)
//                        .foregroundColor(.gray)
//                        .padding(.leading, 40)
//                } else {
//                    VStack {
//                        ForEach(mealsForThisType, id: \.id) { meal in
//                            mealItem(meal: meal, deleteMeal: deleteMeal, swapMeal: swapMeal)
//                                .onTapGesture {
//                                    self.selectedMeal = meal
//                                        .popover(isPresented: .constant(selectedMeal != nil && selectedMeal == meal), arrowEdge: .leading) {
//                                            MealDetailView(meal: meal)
//                                        }
//                                }
//                        }
//                    }
//                }
//            }
//        }
//    }
// @ViewBuilder
//    private func sectionHeader(mealType: String) -> some View {
//        HStack {
//            HStack {
//                Image(systemName: "circlebadge.fill")
//                    .foregroundColor(Color.gray)
//                    .padding(.leading)
//                Text(mealType)
//                    .font(.title2)
//                Spacer()
//                Text("X Calories X Grams")
//                    .font(.caption)
//                Button(action: {
//                    selectedMealType = mealType
//                    print("➕ Adding Meal: \(selectedMealType) on \(day)")
//                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
//                        showingAddMealSheet = true
//                    }
//                }) {
//                    Image(systemName: "plus.circle.fill")
//                        .foregroundColor(.green)
//                        .font(.title2)
//                }
//            }
//        }
//    }
//        @ViewBuilder
//        private func mealItem(meal: MealEntry, deleteMeal: @escaping (MealEntry) -> Void, swapMeal: @escaping (MealEntry) -> Void) -> some View {
//            HStack {
//                Button(action: { deleteMeal(meal) }) {
//                    Image(systemName: "xmark.circle.fill")
//                        .foregroundColor(.red)
//                        .padding(.trailing, 10)
//                }
//                Text("\(meal.recipeTitle) \(meal.servings > 1 ? "(\(meal.servings) servings)" : "")")
//                    .font(.body)
//                    .frame(maxWidth: .infinity, alignment: .leading)
//                Button(action: { swapMeal(meal) }) {
//                    Image(systemName: "arrow.triangle.2.circlepath.circle.fill")
//                        .foregroundColor(.blue)
//                        .padding(.leading, 10)
//                }
//            }
//            .padding(.vertical, 5)
//            .background(Color(.systemGray6))
//            .cornerRadius(10)
//            .padding(.horizontal)
//        }
//    }


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
                selectedMealType = mealType
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
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
        .background(Color(red: 0.91, green: 1, blue: 0.96))
        .cornerRadius(10)
        .padding(.horizontal)
    }
}
