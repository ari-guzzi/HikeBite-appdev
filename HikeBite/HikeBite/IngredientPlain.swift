//
//  IngredientPlain.swift
//  HikeBite
//
//  Created by Ari Guzzi on 1/13/25.
//
import SwiftUI

struct IngredientPlain: Codable, Identifiable {
    var id: UUID = UUID() // Unique ID for SwiftUI ForEach
    let name: String
    let amount: Double
    let unit: String

    enum CodingKeys: String, CodingKey {
        case name, amount, unit
    }
}
