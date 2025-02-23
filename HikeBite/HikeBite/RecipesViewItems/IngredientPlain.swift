//
//  IngredientPlain.swift
//  HikeBite
//
//  Created by Ari Guzzi on 1/13/25.
//
import SwiftUI

struct IngredientPlain: Codable, Identifiable {
    var id: UUID = UUID()
    var name: String
    let amount: Double
    let unit: String
    let calories: Int
    let weight: Int
    enum CodingKeys: String, CodingKey {
        case name, amount, unit, calories, weight
    }
}
