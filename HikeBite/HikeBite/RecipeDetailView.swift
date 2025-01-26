//
//  RecipeDetailView.swift
//  HikeBite
//
//  Created by Ari Guzzi on 1/13/25.
//

import SwiftData
import SwiftUI
import Foundation


struct RecipeDetailView: View {
    var recipe: Result
    @Environment(\.modelContext) private var modelContext
    @State private var mutableIngredients: [IngredientPlain] = []
    @State private var ingredientCache: [String: IngredientDetail] = [:]
    @Query private var items: [GroceryItem]
    var apiKey: String? {
        let key = Bundle.main.object(forInfoDictionaryKey: "API_KEY") as? String
        return key
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
        .onAppear {
            mutableIngredients = recipe.ingredients // Initialize mutableIngredients
            fetchDetailsForIngredients()
        }
    }
    @ViewBuilder
    func viewIngredient(ingredient: Binding<IngredientPlain>) -> some View {
        let ingredientName = ingredient.wrappedValue.name.capitalized
        let formattedAmount = String(format: "%.1f", ingredient.wrappedValue.amount)
        
        HStack {
            VStack(alignment: .leading) {
                Text(ingredientName).fontWeight(.bold)
                Text("\(formattedAmount) \(ingredient.wrappedValue.unit)").font(.caption)
                
                if let detail = ingredient.wrappedValue.detail {
                    if let caloriesText = computeCalorieText(detail: detail, amount: ingredient.wrappedValue.amount, unit: ingredient.wrappedValue.unit) {
                        Text("Calories: \(caloriesText)").font(.caption)
                    } else {
                        Text("Calories not available").font(.caption).foregroundColor(.red)
                    }
                } else {
                    Text("Fetching details...").font(.caption).foregroundColor(.gray)
                }
            }
        }
        .padding()
        .border(Color.gray.opacity(0.3))
    }


    func computeCalorieText(detail: IngredientDetail, amount: Double, unit: String) -> String? {
        guard let calories = detail.nutrition?.nutrients.first(where: { $0.name.lowercased() == "calories" }) else {
            print("Missing calorie data for ingredient.")
            return nil
        }
        
        // Check for weightPerServing, fallback if missing
        if let weightPerServing = detail.weightPerServing {
            print("Calories: \(calories.amount), Base Unit: \(weightPerServing.unit), Weight Per Serving: \(weightPerServing.amount)")
            let convertedCalories = convertCalories(
                baseCalories: calories.amount,
                baseUnit: weightPerServing.unit,
                targetAmount: amount,
                targetUnit: unit
            )
            print("Converted Calories: \(convertedCalories)")
            return "\(String(format: "%.1f", convertedCalories)) kcal"
        } else {
            print("Missing weightPerServing for ingredient. Using base calorie amount.")
            return "\(String(format: "%.1f", calories.amount)) kcal"
        }
    }



    func computeDebugInfo(for ingredient: IngredientPlain) {
        if let detail = ingredient.detail,
           let calories = detail.nutrition?.nutrients.first(where: { $0.name.lowercased() == "calories" }),
           let weightPerServing = detail.weightPerServing {
            print("Calories (raw): \(calories.amount) \(calories.unit)")
            print("Weight per Serving: \(weightPerServing.amount) \(weightPerServing.unit)")
        } else {
            print("Fetching details for \(ingredient.name)...")
        }
    }

    private func fetchDetailsForIngredients() {
        for index in mutableIngredients.indices {
            let ingredient = mutableIngredients[index]
            print("Processing ingredient: \(ingredient.name)")
            let cacheKey = ingredient.name.lowercased()
            if let cachedDetail = ingredientCache[cacheKey] {
                print("Using cached details for \(ingredient.name)")
                DispatchQueue.main.async {
                    self.mutableIngredients[index].detail = cachedDetail
                }
                continue
            }
            fetchIngredientDetails(for: ingredient) { detail in
                if let detail = detail {
                    DispatchQueue.main.async {
                        self.mutableIngredients[index].detail = detail
                        self.ingredientCache[ingredient.name.lowercased()] = detail
                        print("UI updated with detail for \(ingredient.name): \(detail)")
                    }
                } else {
                    print("Detail fetch failed for \(ingredient.name)")
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
        
        // Step 1: Search for the ingredient by name
        let encodedName = ingredient.name.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let searchUrl = "https://spoonacular-recipe-food-nutrition-v1.p.rapidapi.com/food/ingredients/search?query=\(encodedName)&number=1"
        
        guard let searchRequestUrl = URL(string: searchUrl) else {
            print("Invalid search URL")
            completion(nil)
            return
        }
        
        var searchRequest = URLRequest(url: searchRequestUrl)
        searchRequest.setValue(apiKey, forHTTPHeaderField: "X-RapidAPI-Key")
        searchRequest.setValue("spoonacular-recipe-food-nutrition-v1.p.rapidapi.com", forHTTPHeaderField: "X-RapidAPI-Host")
        searchRequest.httpMethod = "GET"
        
        URLSession.shared.dataTask(with: searchRequest) { data, response, error in
            if let error = error {
                print("Error searching ingredient: \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            guard let data = data else {
                print("No data received from ingredient search")
                completion(nil)
                return
            }
            
            print("Raw API response for search:", String(data: data, encoding: .utf8) ?? "Invalid data")
            
            do {
                let searchResponse = try JSONDecoder().decode(IngredientSearchResponse.self, from: data)
                
                guard let results = searchResponse.results, let firstResult = results.first else {
                    print("No results found in API response for \(ingredient.name)")
                    completion(nil)
                    return
                }
                
                // Fetch detailed information
                self.fetchIngredientInformation(
                    id: firstResult.id,
                    amount: ingredient.amount,
                    unit: ingredient.unit,
                    completion: completion
                )
            } catch {
                print("Decoding error for search response: \(error)")
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

        let detailUrl = "https://spoonacular-recipe-food-nutrition-v1.p.rapidapi.com/food/ingredients/\(id)/information?amount=\(amount)&unit=\(normalizeUnit(unit))"
        guard let url = URL(string: detailUrl) else {
            print("Invalid URL for ingredient details")
            completion(nil)
            return
        }

        var request = URLRequest(url: url)
        request.setValue(apiKey, forHTTPHeaderField: "X-RapidAPI-Key")
        request.setValue("spoonacular-recipe-food-nutrition-v1.p.rapidapi.com", forHTTPHeaderField: "X-RapidAPI-Host")
        request.httpMethod = "GET"

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error fetching ingredient info: \(error.localizedDescription)")
                completion(nil)
                return
            }

            guard let data = data else {
                print("No data received")
                completion(nil)
                return
            }

            // Print raw response for debugging
            print("Raw API response for ingredient \(id): \(String(data: data, encoding: .utf8) ?? "Invalid data")")

            do {
                let ingredientDetail = try JSONDecoder().decode(IngredientDetail.self, from: data)

                // Debug the extracted data
                if let nutrition = ingredientDetail.nutrition,
                   let calories = nutrition.nutrients.first(where: { $0.name.lowercased() == "calories" }) {
                    print("Calories found: \(calories.amount) \(calories.unit)")
                } else {
                    print("No calorie information found.")
                }

                if ingredientDetail.weightPerServing == nil {
                    print("No weightPerServing provided in response.")
                }

                completion(ingredientDetail)
            } catch {
                print("Decoding error: \(error)")
                completion(nil)
            }
        }.resume()
    }



    func convertIngredientAmount(
        ingredientName: String,
        sourceAmount: Double,
        sourceUnit: String,
        targetUnit: String,
        completion: @escaping (String?) -> Void
    ) {
        guard let apiKey = apiKey else {
            print("API key missing")
            completion(nil)
            return
        }

        let baseUrl = "https://spoonacular-recipe-food-nutrition-v1.p.rapidapi.com/recipes/convert"
        var components = URLComponents(string: baseUrl)
        components?.queryItems = [
            URLQueryItem(name: "ingredientName", value: ingredientName),
            URLQueryItem(name: "sourceAmount", value: "\(sourceAmount)"),
            URLQueryItem(name: "sourceUnit", value: normalizeUnit(sourceUnit)),
            URLQueryItem(name: "targetUnit", value: normalizeUnit(targetUnit))
        ]

        guard let url = components?.url else {
            print("Invalid URL for conversion")
            completion(nil)
            return
        }

        var request = URLRequest(url: url)
        request.setValue(apiKey, forHTTPHeaderField: "x-rapidapi-key")
        request.setValue("spoonacular-recipe-food-nutrition-v1.p.rapidapi.com", forHTTPHeaderField: "x-rapidapi-host")
        request.httpMethod = "GET"

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error converting ingredient: \(error.localizedDescription)")
                completion(nil)
                return
            }

            guard let data = data else {
                print("No data received")
                completion(nil)
                return
            }

            do {
                let response = try JSONDecoder().decode(ConversionResponse.self, from: data)
                print("Conversion Response: \(response)")
                completion(response.answer)
            } catch {
                print("Decoding error for conversion: \(error)")
                completion(nil)
            }
        }.resume()
    }

    
    func fetchConversion(for ingredient: IngredientPlain, completion: @escaping (String?) -> Void) {
        guard let apiKey = apiKey else {
            print("API key missing")
            completion(nil)
            return
        }
        let baseUrl = "https://api.spoonacular.com/recipes/convert"
        var components = URLComponents(string: baseUrl)
        components?.queryItems = [
            URLQueryItem(name: "ingredientName", value: ingredient.name),
            URLQueryItem(name: "sourceAmount", value: "\(ingredient.amount)"),
            URLQueryItem(name: "sourceUnit", value: ingredient.unit),
            URLQueryItem(name: "targetUnit", value: "grams")
        ]
        guard let url = components?.url else {
            print("Invalid URL")
            completion(nil)
            return
        }
        var request = URLRequest(url: url)
        request.setValue(apiKey, forHTTPHeaderField: "x-api-key")
        URLSession.shared.dataTask(with: request) { data, _, error in
            if let error = error {
                print("Error converting ingredient: \(error.localizedDescription)")
                completion(nil)
                return
            }
            guard let data = data else {
                print("No data received")
                completion(nil)
                return
            }
            do {
                let response = try JSONDecoder().decode(ConversionResponse.self, from: data)
                completion(response.answer)
            } catch {
                print("Decoding error for conversion: \(error)")
                completion(nil)
            }
        }.resume()
    }
    func normalizeUnit(_ unit: String) -> String {
        switch unit.lowercased() {
        case "oz": return "ounce"
        case "tbsp": return "tablespoon"
        case "tsp": return "teaspoon"
        case "lb": return "pound"
        case "g": return "gram"
        case "kg": return "kilogram"
        case "ml": return "milliliter"
        case "l": return "liter"
        default: return unit.lowercased() // Pass-through for unrecognized units
        }
    }
    func convertCalories(baseCalories: Double, baseUnit: String, targetAmount: Double, targetUnit: String) -> Double {
        let conversionFactors: [String: Double] = [
            "ounce": 28.3495,      // 1 ounce = 28.3495 grams
            "gram": 1.0,          // Base unit (grams)
            "tablespoon": 15.0,   // 1 tablespoon = 15 grams (approx)
            "teaspoon": 5.0,      // 1 teaspoon = 5 grams (approx)
            "cup": 240.0          // 1 cup = 240 grams (approx)
        ]

        // Debugging: Input data
        print("Starting calorie conversion...")
        print("Base Calories: \(baseCalories), Base Unit: \(baseUnit), Target Amount: \(targetAmount), Target Unit: \(targetUnit)")

        guard let baseFactor = conversionFactors[baseUnit.lowercased()],
              let targetFactor = conversionFactors[targetUnit.lowercased()] else {
            print("Unsupported unit conversion: \(baseUnit) to \(targetUnit)")
            return baseCalories // Return raw calories as a fallback
        }

        // Convert base calories to calories per gram
        let caloriesPerGram = baseCalories / baseFactor
        // Convert to target unit
        let convertedCalories = caloriesPerGram * targetFactor * targetAmount

        // Debugging: Conversion result
        print("Calories Per Gram: \(caloriesPerGram)")
        print("Converted Calories: \(convertedCalories)")
        
        return convertedCalories
    }

}
struct IngredientSearchResponse: Codable {
    let results: [IngredientSearchResult]?
}

struct IngredientSearchResult: Codable {
    let id: Int
    var name: String
}
struct IngredientDetail: Codable {
    let nutrition: NutritionInfo?
    let weightPerServing: WeightPerServing?
    var convertedDescription: String?
}
struct WeightPerServing: Codable {
    let amount: Double
    let unit: String
}
struct NutritionInfo: Codable {
    let nutrients: [Nutrient]
}
struct Nutrient: Codable {
    let name: String
    let amount: Double
    let unit: String
}
struct ConversionResponse: Codable {
    let sourceAmount: Double?
    let sourceUnit: String?
    let targetAmount: Double?
    let targetUnit: String?
    let answer: String?
}
