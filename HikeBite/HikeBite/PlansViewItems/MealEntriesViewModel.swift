//
//  MealEntriesViewModel.swift
//  HikeBite
//
//  Created by Ari Guzzi on 2/15/25.
//
import SwiftData
import SwiftUI

class MealEntriesViewModel: ObservableObject {
    @Published var mealEntries: [MealEntry] = []
    private var modelContext: ModelContext
    private var tripName: String
    init(modelContext: ModelContext, tripName: String) {
        self.modelContext = modelContext
        self.tripName = tripName
        fetchMeals(for: tripName)
    }
    func fetchMeals(for tripName: String) {
        do {
            let fetchedMeals: [MealEntry] = try modelContext.fetch(FetchDescriptor<MealEntry>())
            let filteredMeals = fetchedMeals.filter { $0.tripName == tripName }
            DispatchQueue.main.async {
                self.mealEntries = filteredMeals
                print("✅ Updated ViewModel: Loaded \(filteredMeals.count) meals for \(tripName)")
            }
        } catch {
            print("❌ Failed to load meals: \(error.localizedDescription)")
        }
    }
}
