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
    var recipeTitle: String
    var servings: Int
    var tripName: String

    init(id: UUID = UUID(), day: String, meal: String, recipeTitle: String, servings: Int, tripName: String) {
        self.id = id
        self.day = day
        self.meal = meal
        self.recipeTitle = recipeTitle
        self.servings = servings
        self.tripName = tripName
    }
}
