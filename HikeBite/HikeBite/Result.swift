//
//  Result.swift
//  HikeBite
//
//  Created by Ari Guzzi on 2/13/25.
//

struct Result: Codable, Identifiable {
    let id: String
    let title: String
    let filter: [String]
    var ingredients: [IngredientPlain]
}
