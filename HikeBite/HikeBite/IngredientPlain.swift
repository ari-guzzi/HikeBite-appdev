//
//  IngredientPlain.swift
//  DataFramework
//
//  Created by Ari Guzzi on 12/7/24.
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
