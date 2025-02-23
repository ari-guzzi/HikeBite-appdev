//
//  PlanSelectionView.swift
//  HikeBite
//
//  Created by Ari Guzzi on 2/15/25.
//
import FirebaseFirestore
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
    var body: some View {
        VStack {
            Text("Choose a Plan")
                .font(.title)
                .padding()         
            if let trip = selectedTrip {
                Button {
                    applyTemplateToTrip(template: template, trip: trip)
                } label: {
                    Text("Add to Current Plan: \(trip.name)")
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
            CreatePlanView { name, days, date in
                createNewTripFromTemplate(name: name, days: days, date: date, template: template)
            }
        }
    }
    private func applyTemplateToTrip(template: MealPlanTemplate, trip: Trip) {
        let db = Firestore.firestore()
        let templateDays = template.mealTemplates.keys.sorted()
        let tripDays = (1...trip.days).map { "Day \($0)" } // Ensures trip days match expected format
        var addedMeals: [MealEntry] = []
        let group = DispatchGroup()
        print("🔄 Applying template '\(template.title)' to trip '\(trip.name)' with \(trip.days) days...")
        for (index, tripDay) in tripDays.enumerated() {
            if index < templateDays.count {
                let templateDay = templateDays[index] // Get corresponding template day
                print("📆 Mapping Template Day \(templateDay) → Trip Day \(tripDay)")

                if let meals = template.mealTemplates[templateDay] {
                    for (mealType, mealIDs) in meals {
                        for mealID in mealIDs {
                            let mealIDString = String(mealID) // Convert to String
                            group.enter()
                            db.collection("Recipes").document(mealIDString).getDocument { snapshot, error in
                                defer { group.leave() }

                                guard let document = snapshot, document.exists,
                                      let mealTitle = document.data()?["title"] as? String else {
                                    print("⚠️ No recipe found for meal ID \(mealID)")
                                    return
                                }
                                let newMealEntry = MealEntry(
                                    day: tripDay, // Use mapped trip day
                                    meal: mealType,
                                    recipeTitle: mealTitle,
                                    servings: 1,
                                    tripName: trip.name
                                )
                                DispatchQueue.main.async {
                                    modelContext.insert(newMealEntry)
                                    addedMeals.append(newMealEntry)
                                    print("✅ Added meal: \(mealTitle) for \(tripDay), \(mealType)")
                                }
                            }
                        }
                    }
                }
            }
            else {
                print("⚠️ No meals for \(tripDay), explicitly storing empty day.")

                let emptyMealEntry = MealEntry(
                    day: tripDay,
                    meal: "None",
                    recipeTitle: "No meals added",
                    servings: 0,
                    tripName: trip.name
                )

                DispatchQueue.main.async {
                    modelContext.insert(emptyMealEntry)
                    addedMeals.append(emptyMealEntry)
                    print("✅ Added empty placeholder for \(tripDay)")
                }
            }
        }
        group.notify(queue: .main) {
            do {
                try modelContext.save()
                print("✅ Successfully saved \(addedMeals.count) meals for trip '\(trip.name)'")
                DispatchQueue.main.async {
                    fetchMeals() // Refresh UI
                    selectedTab = 2
                    dismissTemplates()
                }
            } catch {
                print("❌ Error saving meals: \(error.localizedDescription)")
            }
        }
    }

    private func createNewTripFromTemplate(name: String, days: Int, date: Date, template: MealPlanTemplate) {
        let newTrip = Trip(name: name, days: days, date: date)
        modelContext.insert(newTrip)
        DispatchQueue.main.async {
            selectedTrip = newTrip
        }
        applyTemplateToTrip(template: template, trip: newTrip)
        do {
            try modelContext.save()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                fetchMeals()
                selectedTab = 2
                dismissTemplates()
            }
        } catch {
            print("❌ Failed to apply template: \(error.localizedDescription)")
        }
    }
}
