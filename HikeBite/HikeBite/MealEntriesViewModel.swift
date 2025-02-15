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
            print("📋 All Meals in Database: \(fetchedMeals.count)")

            DispatchQueue.main.async {
                self.mealEntries = fetchedMeals.filter { $0.tripName == tripName }
                print("✅ Meals successfully loaded into state: \(self.mealEntries.count)")
            }
        } catch {
            print("❌ Failed to load meals: \(error.localizedDescription)")
        }
    }
    func forceRefresh() {
        objectWillChange.send()
    }
}
