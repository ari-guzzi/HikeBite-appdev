//
//  MealPlanTemplate.swift
//  HikeBite
//
//  Created by Ari Guzzi on 2/2/25.
//

import SwiftUI

struct MealPlanTemplate: Identifiable, Codable {
    var id: String
    var name: String
    var meals: [String: [String: String]]
    
    // This won't be included in JSON decoding
    var mealNames: [String: [String: String]] = [:]

    enum CodingKeys: String, CodingKey {
        case id, name, meals // Exclude mealNames from Codable
    }
}

