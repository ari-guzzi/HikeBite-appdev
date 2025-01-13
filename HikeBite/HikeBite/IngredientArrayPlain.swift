//
//  IngredientArrayPlain.swift
//  DataFramework
//
//  Created by Ari Guzzi on 12/7/24.
//

import SwiftUI

struct IngredientArrayPlain: Codable {
    let ingredients: [IngredientPlain]

    enum CodingKeys: String, CodingKey {
        case ingredients
    }
}
