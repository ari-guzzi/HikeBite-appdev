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
    @State private var showCreatePlanSheet = false
    @Binding var selectedTrip: Trip?
    var fetchMeals: () -> Void
    var dismissTemplates: () -> Void
    @Binding var selectedTab: Int
    @State private var showWarningSheet = false
    @State private var warningMessage: String = ""
    var body: some View {
        let templateMaxDays = template.mealTemplates.keys
            .compactMap { Int($0.filter { $0.isNumber }) }
            .max() ?? 0
        VStack {
            Text("Choose a Plan")
                .font(.title)
                .padding()
            if let trip = selectedTrip {
                let templateMaxDays = template.mealTemplates.keys.compactMap { Int($0.filter { $0.isNumber }) }.max() ?? 0
                VStack {
                    if trip.days <= templateMaxDays {
                        Button {
                            print("🔄 Applying template to existing trip: \(trip.name)")
                            applyTemplateToTrip(template, trip: trip, modelContext: modelContext)
                        } label: {
                            Text("Add to Current Plan: \(trip.name)")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.green)
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
            } label: {
                Text("Add to New Plan")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding()
        }
        .sheet(isPresented: $showCreatePlanSheet) {
            CreateTripView(templateMaxDays: templateMaxDays) { name, days, date in
                createNewTripFromTemplate(name: name, days: days, date: date, template: template)
            }
        }
    }
    // **Applies a meal plan template to an existing trip**
    private func applyTemplateToTrip(_ template: MealPlanTemplate, trip: Trip, modelContext: ModelContext) {
        let templateMaxDays = template.mealTemplates.keys.compactMap { Int($0.filter { $0.isNumber }) }.max() ?? 0
        
        guard trip.days <= templateMaxDays else {
            print("❌ Cannot apply template. Trip (\(trip.days) days) is longer than the template (\(templateMaxDays) days).")
            return
        }
        print("🔄 Applying template '\(template.title)' to trip '\(trip.name)' with \(trip.days) days...")
        let db = Firestore.firestore()
        var mealNames: [String: [String: String]] = [:]
        let group = DispatchGroup()

        for (templateDay, meals) in template.mealTemplates {
            for (mealType, mealIDs) in meals {
                for mealID in mealIDs {
                    let mealIDString = String(mealID)
                    group.enter()

                    db.collection("Recipes").document(mealIDString).getDocument { snapshot, error in
                        if let document = snapshot, document.exists {
                            let mealTitle = document.data()?["title"] as? String ?? "Unknown Meal"
                            if mealNames[templateDay] == nil {
                                mealNames[templateDay] = [:]
                            }
                            mealNames[templateDay]?[mealType] = mealTitle
                        } else {
                            print("⚠️ Meal ID \(mealID) not found in Recipes collection.")
                            if mealNames[templateDay] == nil {
                                mealNames[templateDay] = [:]
                            }
                            mealNames[templateDay]?[mealType] = "Not Found"
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
                for (mealType, mealIDs) in meals {
                    for mealID in mealIDs {
                        let mealTitle = mealNames[templateDay]?[mealType] ?? "Unknown Meal"
                        let newMeal = MealEntry(
                            id: UUID(),
                            day: tripDay.description,
                            meal: mealType,
                            recipeTitle: mealTitle,
                            servings: 1,
                            tripName: trip.name
                        )

                        modelContext.insert(newMeal)
                        addedMeals.append(newMeal)
                        print("✅ Added meal: \(mealTitle) for \(tripDay), \(mealType)")
                        print("🔍 Saving Meal: '\(newMeal.recipeTitle)' - Trip: '\(newMeal.tripName)' - Day: '\(newMeal.day)'")
                        print("🦵 Checking Meal Assignment - Title: '\(mealTitle)', Trip: '\(trip.name)', Day: '\(tripDay)', MealType: '\(mealType)'")

                    }
                }
            }

            do {
                try modelContext.save()
                print("✅ Successfully saved \(addedMeals.count) meals for trip '\(trip.name)'")

                // ** NEW: Fetch and log all stored meals **
                let allMeals: [MealEntry] = try modelContext.fetch(FetchDescriptor<MealEntry>())
                print("📋 All meals in SwiftData after saving:")
                for meal in allMeals {
                    print("🔍 Meal: \(meal.recipeTitle) - Trip: \(meal.tripName) - Day: \(meal.day)")
                }

                DispatchQueue.main.async {
                    self.fetchMeals()
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
private func createNewTripFromTemplate(name: String, days: Int, date: Date, template: MealPlanTemplate) {
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
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            applyTemplateToTrip(template, trip: newTrip, modelContext: modelContext)

            DispatchQueue.main.async {
                self.fetchMeals()
                selectedTab = 2
                dismissTemplates()
            }
        }
    }
}
