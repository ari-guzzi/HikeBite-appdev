//
//  MealDetailView.swift
//  HikeBite
//
//  Created by Ari Guzzi on 3/8/25.
//

import SwiftUI

struct MealDetailView: View {
    var meal: MealEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Meal Details").font(.headline)
            Text("Title: \(meal.recipeTitle)")
            Text("Servings: \(meal.servings)")
            Text("Ingredients: ")        }
        .padding()
        .frame(width: 300, height: 200)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(radius: 10)
    }
}
