//
//  Templates.swift
//  HikeBite
//
//  Created by Ari Guzzi on 1/30/25.
//
import Firebase
import FirebaseAppCheck
import FirebaseFirestore
import FirebaseStorage
import SwiftUI

class TemplateViewModel: ObservableObject {
    @Published var templates: [MealPlanTemplate] = []

    func loadTemplatesFromJSON() {
        if let url = Bundle.main.url(forResource: "Templates", withExtension: "json") {
            do {
                let data = try Data(contentsOf: url)
                let decoder = JSONDecoder()
                let loadedTemplates = try decoder.decode([MealPlanTemplate].self, from: data)

                DispatchQueue.main.async {
                    self.templates = loadedTemplates
                    print("✅ Loaded templates:", self.templates) // Debugging output
                }
            } catch {
                print("❌ Error decoding JSON:", error.localizedDescription)
            }
        } else {
            print("⚠️ templates.json not found in bundle.")
        }
    }

}

struct Templates: View {
    @StateObject var viewModel = TemplateViewModel()
    @State private var selectedTemplate: MealPlanTemplate?
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 150))], spacing: 16) {
                    ForEach(viewModel.templates) { template in
                        Button {
                            selectedTemplate = template // Open preview when clicked
                        } label: {
                            VStack {
                                Image(systemName: "photo") // Placeholder for meal plan image
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 100)
                                    .cornerRadius(10)
                                Text(template.name)
                                    .font(.headline)
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Meal Plan Templates")
            .onAppear {
                print("📢 TemplatesView appeared! Fetching templates...")
                viewModel.loadTemplatesFromJSON()
            }
            .sheet(item: $selectedTemplate) { template in
                TemplatePreviewView(template: template)
            }
        }
    }
}

#Preview {
    Templates()
}

struct TemplatePreviewView: View {
    var template: MealPlanTemplate
    @State private var mealNames: [String: [String: String]] = [:] // Stores meal names

    var body: some View {
        VStack {
            Text(template.name).font(.largeTitle)

            List {
                ForEach(template.meals.keys.sorted(), id: \.self) { day in
                    Section(header: Text(day.capitalized)) {
                        ForEach(template.meals[day]!.keys.sorted(), id: \.self) { mealType in
                            Text("\(mealType.capitalized): \(mealNames[day]?[mealType] ?? "Loading...")")
                        }
                    }
                }
            }
            Button {
                addToUserPlans(template: template)
            } label: {
                Label("Add to My Plans", systemImage: "plus")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .padding()
        }
        .onAppear {
            fetchMealNames()
        }
    }
    func fetchMealNames() {
        let db = Firestore.firestore()
        var updatedMealNames = mealNames // Use the @State mealNames in the view

        let group = DispatchGroup() // Ensures all Firebase calls complete before updating the UI

        for (day, meals) in template.meals {
            for (mealType, mealID) in meals {
                group.enter()
                db.collection("Recipes").document(mealID).getDocument { snapshot, error in
                    if let document = snapshot, document.exists {
                        let mealTitle = document.data()?["title"] as? String ?? "Unknown" // Fetch "title"
                        if updatedMealNames[day] == nil {
                            updatedMealNames[day] = [:]
                        }
                        updatedMealNames[day]?[mealType] = mealTitle
                    } else {
                        print("⚠️ Meal ID \(mealID) not found in Recipes collection.")
                        if updatedMealNames[day] == nil {
                            updatedMealNames[day] = [:]
                        }
                        updatedMealNames[day]?[mealType] = "Not Found"
                    }
                    group.leave()
                }
            }
        }

        group.notify(queue: .main) {
            mealNames = updatedMealNames // Update UI once all meals are fetched
        }
    }
    func addToUserPlans(template: MealPlanTemplate) {
        let db = Firestore.firestore()
        let newPlan = template
        db.collection("mealPlans").addDocument(data: [
            "name": newPlan.name,
            "meals": newPlan.meals
        ])
    }
}
