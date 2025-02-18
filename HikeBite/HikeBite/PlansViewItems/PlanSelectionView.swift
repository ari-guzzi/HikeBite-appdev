//
//  PlanSelectionView.swift
//  HikeBite
//
//  Created by Ari Guzzi on 2/15/25.
//
import FirebaseFirestore
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
        let db = Firestore.firestore()
        let tripDays = trip.days
        let templateDays = template.meals.keys.sorted()
        var addedMeals: [MealEntry] = []
        let group = DispatchGroup() // Ensures all Firestore requests complete before updating the UI

        for (index, day) in templateDays.prefix(tripDays).enumerated() {
            if let meals = template.meals[day] {
                for (mealType, mealID) in meals {
                    group.enter() //  Start tracking a Firestore request

                    //  Fetch the correct recipe title from Firestore
                    db.collection("Recipes").document(mealID).getDocument { snapshot, error in
                        defer { group.leave() } // Mark Firestore request as complete

                        var mealTitle = "Unknown Recipe" // Default fallback
                        if let document = snapshot, document.exists {
                            mealTitle = document.data()?["title"] as? String ?? "Unknown Recipe"
                        } else {
                            print("⚠️ Recipe with ID \(mealID) not found in Firestore")
                        }

                        //  create and insert the MealEntry with the correct title
                        let newMealEntry = MealEntry(
                            day: "Day \(index + 1)",
                            meal: mealType,
                            recipeTitle: mealTitle,
                            servings: 1,
                            tripName: trip.name
                        )

                        DispatchQueue.main.async {
                            modelContext.insert(newMealEntry)
                            addedMeals.append(newMealEntry)
                        }
                    }
                }
            }
        }

        // Once all Firestore requests complete, save to database
        group.notify(queue: .main) {
            do {
                try modelContext.save()
                print("✅ Successfully applied template '\(template.name)' to trip '\(trip.name)'")
            } catch {
                print("❌ Failed to apply template: \(error.localizedDescription)")
            }
        }
    }
}
