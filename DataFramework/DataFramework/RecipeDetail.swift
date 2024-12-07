//
//  RecipeDetail.swift
//  DataFramework
//
//  Created by Ari Guzzi on 12/7/24.
//

import SwiftUI

struct RecipeDetail: Codable {
    let id: Int
    let title: String
    let readyInMinutes: Int
    let servings: Int
    let image: String
    let instructions: String
    var cleanedInstructions: String {
        instructions.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil)
    }
}
