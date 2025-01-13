//
//  IngredientArrayPlain.swift
//  HikeBite
//
//  Created by Ari Guzzi on 1/13/25.
//

import SwiftUI

struct IngredientArrayPlain: Codable {
    let ingredients: [IngredientPlain]

    enum CodingKeys: String, CodingKey {
        case ingredients
    }
}
