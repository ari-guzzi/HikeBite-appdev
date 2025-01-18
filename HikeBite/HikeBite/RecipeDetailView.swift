//
//  RecipeDetailView.swift
//  HikeBite
//
//  Created by Ari Guzzi on 1/13/25.
//

import SwiftData
import SwiftUI

struct RecipeDetailView: View {
    var recipe: Result
    @Environment(\.modelContext) private var modelContext
    @State private var ingredients: [IngredientPlain] = []
    @State private var recipeDetail: RecipeDetail?
    @Query private var items: [GroceryItem]
    var apiKey: String? {
        Bundle.main.object(forInfoDictionaryKey: "API_KEY") as? String
    }

    var body: some View {
            VStack {
                ScrollView {
                    VStack(alignment: .leading) {
                        // Recipe Title
                        Text(recipe.title)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .font(.title)
                            .fontWeight(.bold)
                            .padding(.top)

                        // Recipe Image
                        AsyncImage(url: URL(string: recipe.image)) { image in
                            image.resizable()
                                .scaledToFit()
                        } placeholder: {
                            ProgressView()
                        }
                        .frame(height: 200)
                        .cornerRadius(10)
                        .padding()

                        // Needs Stove
                        if recipe.needStove {
                            Text("Requires a stove!")
                                .font(.headline)
                                .padding(.vertical, 4)
                        } else {
                            Text("No stove required.")
                                .font(.headline)
                                .padding(.vertical, 4)
                        }

                        // Ingredients Section
                        Text("Ingredients:")
                            .fontWeight(.bold)
                            .font(.title2)
                            .padding(.vertical)

                        ForEach(recipe.ingredients, id: \.name) { ingredient in
                            viewIngredient(ingredient: ingredient)
                        }
                    }
                    .navigationTitle("Recipe Details")
                    .navigationBarTitleDisplayMode(.inline)
                    .padding()
                }
            }
        }
    @ViewBuilder
    func viewIngredient(ingredient: IngredientPlain) -> some View {
        let formattedAmount = String(format: "%.1f", ingredient.amount as CVarArg)
        let ingredientName = ingredient.name.capitalized
        HStack {
            VStack(alignment: .leading) {
                Text(ingredientName)
                    .fontWeight(.bold)
                Text("\(formattedAmount) \(ingredient.unit)")
                    .font(.caption)
            }
            Spacer()
            Button {
                let newGroceryItem = GroceryItem(
                    id: UUID(),
                    name: "\(formattedAmount) \(ingredient.unit) of \(ingredientName)",
                    isCompleted: false
                )
                modelContext.insert(newGroceryItem)
            } label: {
                let existsInGroceryList = items.contains {
                    $0.name == "\(formattedAmount) \(ingredient.unit) of \(ingredientName)"
                }
                Image(systemName: existsInGroceryList ? "checkmark.circle.fill" : "plus.circle")
                    .foregroundColor(.green)
            }
        }
        .padding()
        .border(Color.gray.opacity(0.3))
    }

//    @ViewBuilder
//    func viewIngredient(ingredient: IngredientPlain) -> some View {
//        let formattedAmount = String(format: "%.1f", ingredient.amount as CVarArg)
//        let ingredientName = ingredient.name.capitalized
//        HStack {
//            VStack(alignment: .leading) {
//                Text(ingredientName)
//                    .fontWeight(.bold)
//                Text("\(formattedAmount) \(ingredient.unit)")
//                    .font(.caption)
//            }
//            Spacer()
//            Button {
//                let newGroceryItem = GroceryItem(
//                    name: "\(formattedAmount) \(ingredient.unit) of \(ingredientName)",
//                    isCompleted: false
//                )
//                modelContext.insert(newGroceryItem)
//            } label: {
//                let ingredName = "\(formattedAmount) \(ingredient.unit) of \(ingredientName)"
//                let existsInGroceryList = items.contains {
//                    $0.name == "\(formattedAmount) \(ingredient.unit) of \(ingredientName)"
//                }
//                Image(systemName: existsInGroceryList ? "checkmark.circle.fill" : "plus.circle")
//                    .foregroundColor(.green)
//            }
//        }
//        .padding()
//        .border(Color.gray.opacity(0.3))
//    }
}
//#Preview {
//    RecipeDetailView(recipe: Result.example)
//}
//// as an example for the preview instead of calling the API
//extension Result {
//    static var example: Result {
//        Result(
//            id: "1",
//            title: "PBJ Wrap",
//            image: "gs://hikebite-48dbe.firebasestorage.app/pbjwrap.jpg",
//            imageType: "jpeg",
//            needStove: false,
//            ingredients: [
//                { name: "Tortilla", amount: 70, unit: "g" },
//                { name: "Peanut Butter", amount: 5, unit: "tbsp" },
//                { name: "Jelly", amount: 5, unit: "tbsp" }
//        )
//    }
//}
