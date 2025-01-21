//
//  IngredientPlain.swift
//  HikeBite
//
//  Created by Ari Guzzi on 1/13/25.
//
import SwiftUI

struct IngredientPlain: Codable, Identifiable {
    var id: UUID = UUID() // Unique ID for SwiftUI ForEach
    var name: String
    let amount: Double
    let unit: String
    var detail: IngredientDetail?
    
    enum CodingKeys: String, CodingKey {
        case name, amount, unit, detail
    }
}

