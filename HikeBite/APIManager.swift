//
//  APIManager.swift
//  HikeBite
//
//  Created by Ari Guzzi on 1/30/25.
//

import Foundation

class APIManager {
    static let shared = APIManager()

    private var apiKey: String? {
        return Bundle.main.object(forInfoDictionaryKey: "API_KEY") as? String
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
}

