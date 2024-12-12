//
//  RecipeDetailView.swift
//  DataFramework
//
//  Created by Ari Guzzi on 12/3/24.
//

import SwiftData
import SwiftUI

struct RecipeDetailView: View {
    var recipe: Result
    @State private var ingredients: [IngredientPlain] = []
    @State private var recipeDetail: RecipeDetail?
    @Query private var items: [GroceryItem]
    var apiKey: String? {
        Bundle.main.object(forInfoDictionaryKey: "API_KEY") as? String
    }
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        VStack {
            ScrollView {
                VStack(alignment: .leading) {
                    Text(recipe.title)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                        .font(.title)
                        .fontWeight(.bold)
                    VStack(alignment: .leading) {
                        AsyncImage(url: URL(string: recipe.image)) { image in
                            image.resizable().scaledToFit()
                        } placeholder: {
                            ProgressView()
                        }
                        .frame(height: 120)
                        .cornerRadius(10)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    Text("Ingredients:")
                        .fontWeight(.bold)
                        .font(.title2)
                    ForEach(ingredients) { ingredient in
                        viewIngredients(ingredient: ingredient)
                    }
                    if let recipeDetail {
                        viewRecipeDetails(recipeDetail: recipeDetail)
                    } else {
                        Text("Loading instructions...")
                    }
                }
                .navigationTitle("Recipe Details")
                .navigationBarTitleDisplayMode(.inline)
                .padding()
            }
        }
        .onAppear {
            fetchIngredients()
        }
    }
    private func fetchIngredients() {
        let baseRecipeUrl = "https://api.spoonacular.com/recipes/"
        let ingredientWidgetURL = "/ingredientWidget.json?apiKey="
        guard let apiKey = apiKey, let url = URL(string: "\(baseRecipeUrl)\(recipe.id)\(ingredientWidgetURL)\(apiKey)")
        else {
            print("Invalid API key or URL")
            return
        }
        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error {
                print("HTTP request failed: \(error)")
                return
            }
            guard let data = data else {
                print("No data received")
                return
            }
            do {
                let decodedResponse = try JSONDecoder().decode(IngredientArrayPlain.self, from: data)
                DispatchQueue.main.async {
                    self.ingredients = decodedResponse.ingredients
                }
            } catch {
                print("Decoding error: \(error)")
            }
        }.resume()
        // fetch recipe details
        let basicUrl = "https://api.spoonacular.com/recipes/"
        let recipeDetailUrl = URL(string: "\(basicUrl)\(recipe.id)/information?apiKey=\(apiKey)")
        URLSession.shared.dataTask(with: recipeDetailUrl!) { data, _, error in
            if let error {
                print("Error fetching recipe details: \(error)")
                return
            }
            guard let data = data else {
                print("No data received")
                return
            }
            do {
                let recipeDetail = try JSONDecoder().decode(RecipeDetail.self, from: data)
                DispatchQueue.main.async {
                    self.recipeDetail = recipeDetail
                }
            } catch {
                print("Decoding error: \(error)")
            }
        }.resume()
    }
    @ViewBuilder
    func viewIngredients(ingredient: IngredientPlain) -> some View {
        let ingredientUSVal = ingredient.amount.us.value
        let ingredientUSUnit = ingredient.amount.us.unit
        let capIngredName = ingredient.name.capitalized
        HStack {
            VStack(alignment: .leading) {
                Text("\(ingredient.name.capitalized)")
                    .fontWeight(.bold)
                Text("\(String(format: "%.1f", ingredient.amount.us.value)) \(ingredient.amount.us.unit)")
                    .font(.caption)
            }
            Spacer()
            Button {
                let newGroceryItem = GroceryItem(
                    name: "\(ingredientUSVal) \(ingredientUSUnit) of \(capIngredName)", isCompleted: false
                    )
                modelContext.insert(newGroceryItem)
            } label: {
                let ingredName = "\(ingredientUSVal) \(ingredientUSUnit) of \(capIngredName)"
                let existsInGroceryList = items.contains { $0.name == ingredName }

                Image(systemName: existsInGroceryList ? "checkmark.circle.fill" : "plus.circle")
                    .foregroundColor(.green)
            }
        }
        .padding()
        .border(Color(hue: 1.0, saturation: 0.023, brightness: 0.907))
    }
    func viewRecipeDetails(recipeDetail: RecipeDetail) -> some View {
        VStack {
            Text("Instructions:")
                .fontWeight(.bold)
                .font(.title2)
                .padding(.vertical)
            Text("Ready in \(recipeDetail.readyInMinutes) minutes")
            Text("Serves: \(recipeDetail.servings)")
            Text(recipeDetail.cleanedInstructions)
                .padding()
        }
    }
}
#Preview {
    RecipeDetailView(recipe: Result.example)
}
// as an example for the preview instead of calling the API
extension Result {
    static var example: Result {
        Result(
            id: 654959,
            title: "Pasta Bolognese",
            image: "https://spoonacular.com/recipeImages/654959-312x231.jpg",
            imageType: "png"
        )
    }
}
