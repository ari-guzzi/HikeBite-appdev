//
//  MealEntry.swift
//  HikeBite
//
//  Created by Ari Guzzi on 1/30/25.
//

import Foundation
import SwiftData

@Model
class MealEntry: Identifiable, Hashable {
    var id = UUID()
    var day: String
    var meal: String
    var recipeID: String
    var recipeTitle: String
    var servings: Int
    var tripName: String
    var totalCalories: Int
    var totalGrams: Int

    init(id: UUID = UUID(), day: String, meal: String, recipeID: String, recipeTitle: String, servings: Int, tripName: String, totalCalories: Int, totalGrams: Int) {
        self.id = id
        self.day = day
        self.meal = meal
        self.recipeID = recipeID
        self.recipeTitle = recipeTitle
        self.servings = servings
        self.tripName = tripName
        self.totalCalories = totalCalories
        self.totalGrams = totalGrams
    }
}
