//
//  IngredientPlain.swift
//  HikeBite
//
//  Created by Ari Guzzi on 1/13/25.
//
import SwiftUI

struct IngredientPlain: Codable, Identifiable {
    var id: UUID = UUID()
    let name: String
    let image: String
    let amount: Amount

    enum CodingKeys: String, CodingKey {
        case name, image, amount
    }
}
