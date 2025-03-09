//
//  IngredientPlain.swift
//  HikeBite
//
//  Created by Ari Guzzi on 1/13/25.
//
import SwiftUI

struct IngredientPlain: Codable, Identifiable, Hashable {
    var id: UUID = UUID()
    var name: String
    var amount: Double?
    var unit: String
    var calories: Int?
    var weight: Int?
    enum CodingKeys: String, CodingKey {
        case name, amount, unit, calories, weight
    }
}
