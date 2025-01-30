//
//  Templates.swift
//  HikeBite
//
//  Created by Ari Guzzi on 1/30/25.
//
import FirebaseAppCheck
import Firebase
import FirebaseFirestore
import FirebaseStorage
import SwiftUI

class TemplateViewModel: ObservableObject {
    @Published var templates: [MealPlanTemplate] = []

    func fetchTemplates() {
        let db = Firestore.firestore()
        db.collection("templates").getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching templates: \(error.localizedDescription)")
                return
            }
            guard let documents = snapshot?.documents else {
                print("No templates found")
                return
            }
            // Map Firestore documents into MealPlanTemplate objects
            let fetchedTemplates = documents.compactMap { doc -> MealPlanTemplate? in
                let data = doc.data()
                return MealPlanTemplate(
                    id: doc.documentID,
                    name: data["name"] as? String ?? "Unnamed Plan",
                    description: data["description"] as? String ?? "",
                    meals: data["meals"] as? [String: [String: String]] ?? [:]
                )
            }
            DispatchQueue.main.async {
                self.templates = fetchedTemplates
            }
        }
    }
}

struct Templates: View {
    @StateObject var viewModel = TemplateViewModel()

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 150))], spacing: 16) {
                    ForEach(viewModel.templates) { template in
                        VStack {
                            Image(systemName: "photo") // Replace with real image
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
                .padding()
            }
            .navigationTitle("Meal Plan Templates")
            .onAppear {
                viewModel.fetchTemplates()
            }
        }
    }
}

#Preview {
    Templates()
}

struct MealPlanTemplate: Identifiable, Codable {
    var id: String
    var name: String
    var description: String
    var meals: [String: [String: String]]
}

struct TemplatePreviewView: View {
    var template: MealPlanTemplate

    var body: some View {
        VStack {
            Text(template.name).font(.largeTitle)
            Text(template.description).padding()
            List {
                ForEach(template.meals.keys.sorted(), id: \.self) { day in
                    Section(header: Text(day.capitalized)) {
                        ForEach(template.meals[day]!.keys.sorted(), id: \.self) { mealType in
                            Text("\(mealType.capitalized): \(template.meals[day]![mealType] ?? "Unknown")")
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
    }
    
    func addToUserPlans(template: MealPlanTemplate) {
        let db = Firestore.firestore()
        let newPlan = template // Copy template data
        db.collection("mealPlans").addDocument(data: [
            "name": newPlan.name,
            "meals": newPlan.meals
        ])
    }
}
