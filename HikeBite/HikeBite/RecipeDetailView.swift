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
    // @State private var ingredients: [IngredientPlain] = []
    @State private var recipeDetail: RecipeDetail?
    @Query private var items: [GroceryItem]
    @State private var mutableIngredients: [IngredientPlain] = []
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

                    ForEach(mutableIngredients.indices, id: \.self) { index in
                        viewIngredient(ingredient: $mutableIngredients[index])
                    }
                }
                .navigationTitle("Recipe Details")
                .navigationBarTitleDisplayMode(.inline)
                .padding()
            }
        }
    }
    @ViewBuilder
    func viewIngredient(ingredient: Binding<IngredientPlain>) -> some View {
        var formattedAmount = String(format: "%.1f", ingredient.wrappedValue.amount)
        var ingredientName = ingredient.name

        HStack {
            VStack(alignment: .leading) {
                // Display name and amount
                Text(ingredient.wrappedValue.name.capitalized)
                    .fontWeight(.bold)
                Text("\(String(format: "%.1f", ingredient.wrappedValue.amount)) \(ingredient.wrappedValue.unit)")
                    .font(.caption)

                // Display fetched details
                if let detail = ingredient.wrappedValue.detail {
                    Text("Calories: \(String(format: "%.1f", detail.calories)) kcal")
                        .font(.caption)
                    Text("Weight: \(String(format: "%.1f", detail.weight)) g")
                        .font(.caption)
                } else {
                    Text("Fetching details...")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            Spacer()

            // Add to Grocery List Button
            Button {
                let newGroceryItem = GroceryItem(
                    id: UUID(),
                    name: "\(String(format: "%.1f", ingredient.wrappedValue.amount)) \(ingredient.wrappedValue.unit) of \(ingredient.wrappedValue.name.capitalized)",
                    isCompleted: false
                )
                modelContext.insert(newGroceryItem)
            } label: {
                let existsInGroceryList = items.contains {
                    $0.name == "\(String(format: "%.1f", ingredient.wrappedValue.amount)) \(ingredient.wrappedValue.unit) of \(ingredient.wrappedValue.name.capitalized)"
                }
                Image(systemName: existsInGroceryList ? "checkmark.circle.fill" : "plus.circle")
                    .foregroundColor(.green)
            }
        }
        .padding()
        .border(Color.gray.opacity(0.3))
        .onAppear {
            mutableIngredients = recipe.ingredients
            fetchIngredientDetails(for: ingredient.wrappedValue) { detail in
                DispatchQueue.main.async {
                    if let index = mutableIngredients.firstIndex(where: { $0.name == ingredient.wrappedValue.name }) {
                        mutableIngredients[index].detail = detail
                    }
                }
            }
        }
    }
    func fetchIngredientDetails(for ingredient: IngredientPlain, completion: @escaping (IngredientDetail?) -> Void) {
        guard let apiKey = apiKey else {
            print("API key missing")
            completion(nil)
            return
        }
        // URL encode the ingredient name
        let encodedName = ingredient.name.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let searchUrl = "https://spoonacular-recipe-food-nutrition-v1.p.rapidapi.com/food/ingredients/search?query=\(encodedName)&number=1"
        guard let url = URL(string: searchUrl) else {
            print("Invalid URL")
            completion(nil)
            return
        }

        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(apiKey, forHTTPHeaderField: "X-RapidAPI-Key")
        request.setValue("spoonacular-recipe-food-nutrition-v1.p.rapidapi.com", forHTTPHeaderField: "X-RapidAPI-Host")
        request.httpMethod = "GET"

        URLSession.shared.dataTask(with: request) { data, _, error in
            if let error = error {
                print("Error searching ingredient: \(error.localizedDescription)")
                completion(nil)
                return
            }

            guard let data = data else {
                print("No data received")
                completion(nil)
                return
            }

            do {
                let searchResponse = try JSONDecoder().decode(IngredientSearchResponse.self, from: data)
                guard let firstResult = searchResponse.results.first else {
                    print("No matching ingredient found for \(ingredient.name)")
                    completion(nil)
                    return
                }
                // Use the `id` to fetch detailed information
                self.fetchIngredientInformation(
                    id: firstResult.id,
                    amount: ingredient.amount,
                    unit: ingredient.unit,
                    completion: completion
                )
            } catch {
                print("Decoding error for ingredient search: \(error)")
                completion(nil)
            }
        }.resume()
    }

    func fetchIngredientInformation(id: Int, amount: Double, unit: String, completion: @escaping (IngredientDetail?) -> Void) {
        guard let apiKey = apiKey else {
            print("API key missing")
            completion(nil)
            return
        }
        
        let detailUrl = "https://spoonacular-recipe-food-nutrition-v1.p.rapidapi.com/food/ingredients/\(id)/information?amount=\(amount)&unit=\(unit)"
        guard let url = URL(string: detailUrl) else {
            print("Invalid URL for ingredient details")
            completion(nil)
            return
        }

        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(apiKey, forHTTPHeaderField: "X-RapidAPI-Key")
        request.setValue("spoonacular-recipe-food-nutrition-v1.p.rapidapi.com", forHTTPHeaderField: "X-RapidAPI-Host")
        request.httpMethod = "GET"

        URLSession.shared.dataTask(with: request) { data, _, error in
            if let error = error {
                print("Error fetching ingredient information: \(error.localizedDescription)")
                completion(nil)
                return
            }

            guard let data = data else {
                print("No data received")
                completion(nil)
                return
            }

            do {
                let ingredientDetail = try JSONDecoder().decode(IngredientDetail.self, from: data)
                completion(ingredientDetail)
            } catch {
                print("Decoding error for ingredient details: \(error)")
                completion(nil)
            }
        }.resume()
    }

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

struct IngredientSearchResponse: Codable {
    let results: [IngredientSearchResult]
}

struct IngredientSearchResult: Codable {
    let id: Int
    var name: String
}
struct IngredientDetail: Codable {
    let calories: Double
    let weight: Double
    let nutrients: [Nutrient]
}

struct Nutrient: Codable {
    let name: String
    let amount: Double
    let unit: String
}
