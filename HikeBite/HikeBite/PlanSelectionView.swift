//
//  PlanSelectionView.swift
//  HikeBite
//
//  Created by Ari Guzzi on 2/15/25.
//

import SwiftUI

struct PlanSelectionView: View {
    @Environment(\.modelContext) private var modelContext
    var template: MealPlanTemplate
    @Environment(\.dismiss) private var dismiss
    @State private var showCreatePlanSheet = false
    var selectedTrip: Trip?
    var fetchMeals: () -> Void
    var dismissTemplates: () -> Void
    var body: some View {
        VStack {
            Text("Choose a Plan")
                .font(.title)
                .padding()

            if let trip = selectedTrip {
                Button {
                    addToExistingTrip(trip: trip)
                } label: {
                    Text("Add to \(trip.name)")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding()
            }

            Button {
                showCreatePlanSheet = true
            } label: {
                Text("Create New Plan")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding()
        }
        .sheet(isPresented: $showCreatePlanSheet) {
            CreatePlanView { name, days, date in
                createNewTripFromTemplate(name: name, days: days, date: date, template: template)
            }
        }
    }

    private func addToExistingTrip(trip: Trip) {
        print("✅ Adding template to existing trip: \(trip.name)")
        applyTemplateToTrip(template: template, trip: trip)
        dismissTemplates()
    }

    private func createNewTripFromTemplate(name: String, days: Int, date: Date, template: MealPlanTemplate) {
        let newTrip = Trip(name: name, days: days, date: date)
        modelContext.insert(newTrip)

        do {
            try modelContext.save()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { 
                fetchMeals()
                dismissTemplates()
            }
        } catch {
            print("❌ Failed to apply template: \(error.localizedDescription)")
        }
    }
    private func applyTemplateToTrip(template: MealPlanTemplate, trip: Trip) {
        let tripDays = trip.days
        let templateDays = template.meals.keys.sorted()
        var addedMeals: [MealEntry] = []

        for (index, day) in templateDays.prefix(tripDays).enumerated() {
            if let meals = template.meals[day] {
                for (mealType, mealID) in meals {
                    let newMealEntry = MealEntry(
                        day: "Day \(index + 1)",
                        meal: mealType,
                        recipeTitle: mealID,
                        servings: 1,
                        tripName: trip.name
                    )
                    modelContext.insert(newMealEntry)
                    addedMeals.append(newMealEntry) // ✅ Store meals for debugging
                }
            }
        }

        do {
            try modelContext.save()
            print("✅ Applied template '\(template.name)' to trip '\(trip.name)' with \(addedMeals.count) meals")
            
            // ✅ Ensure UI refresh
            DispatchQueue.main.async {
                fetchMeals()
            }
            
        } catch {
            print("❌ Failed to apply template: \(error.localizedDescription)")
        }
    }

}
