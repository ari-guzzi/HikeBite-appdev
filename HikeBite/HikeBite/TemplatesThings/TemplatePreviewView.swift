//
//  TemplatePreviewView.swift
//  HikeBite
//
//  Created by Ari Guzzi on 2/23/25.
//

import Firebase
import FirebaseFirestore
import FirebaseStorage
import Network
import SwiftUI

struct TemplatePreviewView: View {
    var template: MealPlanTemplate
    @State private var mealNames: [String: [String: String]] = [:]
    @State private var showPlanSelection = false
    @Binding var selectedTrip: Trip?
    @Binding var selectedTab: Int
    @Environment(\.modelContext) private var modelContext
    var dismissTemplates: () -> Void
    var body: some View {
        ZStack {
            BackgroundGradient()
                .ignoresSafeArea(.all)
            FunnyLines()
                .ignoresSafeArea(.all)
            VStack {
                Text(template.title)
                    .font(.largeTitle)
                    .padding()
                
                List {
                    ForEach(template.mealTemplates.keys.sorted(), id: \.self) { day in
                        Section(header: Text(day.capitalized)) {
                            ForEach(template.mealTemplates[day]!.keys.sorted(), id: \.self) { mealType in
                                Text("\(mealType.capitalized): \(mealNames[day]?[mealType] ?? "Loading...")")
                            }
                        }
                    }
                }
                Button {
                    showPlanSelection = true
                } label: {
                    Label("Use This Template", systemImage: "checkmark.circle")
                        .padding()
                        .background(Color("AccentColor"))
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .padding()
            }
        }
        .onAppear {
            fetchMealNames()
            print("🔍 TemplatePreviewView Appeared")
            print("📝 Meal Templates Loaded:", template.mealTemplates)
            
            if template.mealTemplates.isEmpty {
                print("⚠️ mealTemplates is EMPTY! Firebase might not have returned data yet.")
            }
        }
        .sheet(isPresented: $showPlanSelection) {
            PlanSelectionView(
                template: template,
                selectedTrip: $selectedTrip,
                fetchMeals: {},
                dismissTemplates: {
                    showPlanSelection = false
                    dismissTemplates()},
                selectedTab: $selectedTab
            )
        }
    }
        // Fetches meal names from Firestore based on meal IDs
        func fetchMealNames() {
            let db = Firestore.firestore()
            var updatedMealNames = mealNames
            let group = DispatchGroup()
            for (day, meals) in template.mealTemplates {
                for (mealType, mealIDs) in meals {
                    for mealID in mealIDs {
                        let mealIDString = String(mealID)
                        group.enter()
                        db.collection("Recipes").document(mealIDString).getDocument { snapshot, error in
                            if let document = snapshot, document.exists {
                                let mealTitle = document.data()?["title"] as? String ?? "Unknown"
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
            }
            group.notify(queue: .main) {
                mealNames = updatedMealNames
            }
        }
    }
