//
//  Result.swift
//  HikeBite
//
//  Created by Ari Guzzi on 2/13/25.
//

struct Result: Codable, Identifiable, Equatable {
    let id: String
    let title: String
    let filter: [String]
    var ingredients: [IngredientPlain]
    static func == (lhs: Result, rhs: Result) -> Bool {
        return lhs.id == rhs.id
    }
}
