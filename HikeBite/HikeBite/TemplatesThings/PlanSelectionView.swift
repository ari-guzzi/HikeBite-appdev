//
//  PlanSelectionView.swift
//  HikeBite
//
//  Created by Ari Guzzi on 2/15/25.
//
import FirebaseFirestore
import Foundation
import Network
import SwiftData
import SwiftUI

struct PlanSelectionView: View {
    @Environment(\.modelContext) private var modelContext
    var template: MealPlanTemplate
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var tripManager: TripManager
    @State private var showCreatePlanSheet = false
    @Binding var selectedTrip: Trip?
    var fetchMeals: () -> Void
    var dismissTemplates: () -> Void
    @Binding var selectedTab: Int
    @State private var showWarningSheet = false
    @State private var warningMessage: String = ""
    @State private var isNavigatingToSelectedTrip = false
    var body: some View {
        let templateMaxDays = template.mealTemplates.keys
            .compactMap { Int($0.filter { $0.isNumber }) }
            .max() ?? 0
        VStack {
            Text("Choose a Plan")
                .font(.title)
                .padding()
            if tripManager.trips.isEmpty {
                Text("No available trips.")
                        .foregroundColor(.gray)
                        .padding()
            } else {
                HStack {
                    Text("Select a trip to add this plan to:")
                    Picker("Select Trip", selection: $selectedTrip) {
                        ForEach(tripManager.trips, id: \.id) { trip in
                            Text(trip.name).tag(trip as Trip?)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .padding()
                }
            }
            if let trip = selectedTrip {
                let templateMaxDays = template.mealTemplates.keys.compactMap { Int($0.filter { $0.isNumber }) }.max() ?? 0
                VStack {
                    NavigationLink(
                        destination: PlansView(
                            tripManager: tripManager,
                            numberOfDays: selectedTrip?.days ?? 0,
                            tripDate: selectedTrip?.date ?? Date(),
                            selectedTrip: $selectedTrip,
                            modelContext: modelContext,
                            selectedTab: $selectedTab
                        ),
                        isActive: $isNavigatingToSelectedTrip
                    ) {
                        EmptyView()
                    }
                    .hidden()  // Hide since it's just used to trigger navigation

                    if trip.days <= templateMaxDays {
                        Button {
                            print("🔄 Applying template to existing trip: \(trip.name)")
                            applyTemplateToTrip(template, trip: trip, modelContext: modelContext, refreshMeals: fetchMeals)
                            isNavigatingToSelectedTrip = true
                        } label: {
                            Text("Add to Current Plan: \(trip.name)")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color("AccentLight"))
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        .padding()
                    
                    } else {
                        Text("⚠️ This template has **\(templateMaxDays) days**, but your current selected trip has **\(trip.days) days**.")
                            .foregroundColor(.red)
                            .padding()
                    }
                }
            }
            Button {
                showCreatePlanSheet = true
                isNavigatingToSelectedTrip = true
            } label: {
                Text("Add to New Plan")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color("AccentColor"))
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding()
        }
        .sheet(isPresented: $showCreatePlanSheet) {
            CreateTripView(templateMaxDays: templateMaxDays) { name, days, date in
                createNewTripFromTemplate(name: name, days: days, date: date, template: template, refreshMeals: fetchMeals)
            }
        }
        .onAppear {
            isNavigatingToSelectedTrip = false
            tripManager.fetchTrips(modelContext: modelContext)
        }
    }
    private func applyTemplateToTrip(_ template: MealPlanTemplate, trip: Trip, modelContext: ModelContext, refreshMeals: @escaping () -> Void) {
        print("🔄 Applying template '\(template.title)' to trip '\(trip.name)' with \(trip.days) days...")
        let db = Firestore.firestore()
        var mealDetails: [String: [String: (title: String, calories: Int, grams: Int)]] = [:]
        let group = DispatchGroup()

        for (templateDay, meals) in template.mealTemplates {
            for (mealType, mealIDs) in meals {
                for mealID in mealIDs {
                    let mealIDString = String(mealID)
                    group.enter()
                    db.collection("Recipes").document(mealIDString).getDocument { snapshot, error in
                        if let document = snapshot, document.exists {
                            let ingredients = (document.data()?["ingredients"] as? [[String: Any]])?.compactMap { dict -> IngredientPlain? in
                                // Deserialize the dictionary into IngredientPlain
                                do {
                                    let data = try JSONSerialization.data(withJSONObject: dict, options: [])
                                    return try JSONDecoder().decode(IngredientPlain.self, from: data)
                                } catch {
                                    print("Error deserializing ingredient: \(error.localizedDescription)")
                                    return nil
                                }
                            } ?? []
                            let totalCalories = ingredients.reduce(0) { $0 + ($1.calories ?? 0) }
                            let totalGrams = ingredients.reduce(0) { $0 + ($1.weight ?? 0) }
                            let mealTitle = document.data()?["title"] as? String ?? "Unknown Meal"

                            if mealDetails[templateDay] == nil { mealDetails[templateDay] = [:] }
                            mealDetails[templateDay]?[mealType] = (title: mealTitle, calories: Int(totalCalories), grams: Int(totalGrams))
                        } else {
                            print("⚠️ Meal ID \(mealID) not found in Recipes collection.")
                            if mealDetails[templateDay] == nil { mealDetails[templateDay] = [:] }
                            mealDetails[templateDay]?[mealType] = (title: "Not Found", calories: 0, grams: 0)
                        }
                        group.leave()
                    }
                }
            }
        }

        group.notify(queue: .main) {
            var addedMeals: [MealEntry] = []
            for (templateDay, meals) in template.mealTemplates {
                let tripDay = "Day \(Int(templateDay.filter { $0.isNumber }) ?? 0)"
                for (mealType, _) in meals {
                    if let mealDetail = mealDetails[templateDay]?[mealType] {
                        let newMeal = MealEntry(
                            id: UUID(),
                            day: tripDay,
                            meal: mealType,
                            recipeTitle: mealDetail.title,
                            servings: 1,
                            tripName: trip.name,
                            totalCalories: mealDetail.calories,
                            totalGrams: mealDetail.grams
                        )

                        modelContext.insert(newMeal)
                        addedMeals.append(newMeal)
                        
                        print("✅ Added Meal: \(newMeal.recipeTitle) - Trip: \(newMeal.tripName) - Day: \(newMeal.day) - MealType: \(mealType)")
                    }
                }
            }

            do {
                try modelContext.save()
                print("✅ Successfully saved \(addedMeals.count) meals for trip '\(trip.name)'")
                DispatchQueue.main.async {
                    refreshMeals()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        self.selectedTab = 2
                        self.dismissTemplates()
                    }
                }
            } catch {
                print("❌ Failed to apply template: \(error.localizedDescription)")
            }
        }
    }

    // **Creates a new trip from a template and applies meals**
    private func createNewTripFromTemplate(name: String, days: Int, date: Date, template: MealPlanTemplate, refreshMeals: @escaping () -> Void) {
        let templateMaxDays = template.mealTemplates.keys
            .compactMap { Int($0.filter { $0.isNumber }) }
            .max() ?? 0
        guard days <= templateMaxDays else {
            DispatchQueue.main.async {
                self.warningMessage = "This template only supports up to \(templateMaxDays) days. Please select a shorter trip."
                self.showWarningSheet = true
            }
            return
        }
        let newTrip = Trip(name: name, days: days, date: date)
        modelContext.insert(newTrip)
        DispatchQueue.main.async {
            selectedTrip = newTrip
            print("🔄 New trip selected: \(newTrip.name)")
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            print("🚀 Ensuring trip is saved before applying meals")
            applyTemplateToTrip(template, trip: newTrip, modelContext: modelContext, refreshMeals: {
                print("📥 Meals applied, now refreshing UI")
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    fetchMeals() // 🚀 Ensures meals are loaded AFTER save
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    selectedTab = 2
                    self.dismissTemplates()
                }
            })
        }

    }
}
