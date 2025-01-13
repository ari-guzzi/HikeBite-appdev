//
//  RecipeDetail.swift
//  HikeBite
//
//  Created by Ari Guzzi on 1/13/25.
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
