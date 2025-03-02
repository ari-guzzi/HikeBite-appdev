//
//  ContentView.swift
//  HikeBite
//
//  Created by Ari Guzzi on 1/13/25.
//
import Firebase
import FirebaseFirestore
import FirebaseStorage
import SwiftUI

struct ContentView: View {
    @State private var searchText = ""
    @State private var results = [Result]()
    @Binding var selectedTrip: Trip?
    var apiKey: String? {
        Bundle.main.object(forInfoDictionaryKey: "API_KEY") as? String
    }
    var baseURL: String? {
        Bundle.main.object(forInfoDictionaryKey: "API_BASE_URL") as? String
    }
    var body: some View {
        NavigationView {
            VStack {
//                List(results, id: \.id) { item in
//                    NavigationLink(destination: RecipeDetailView(recipe: item, selectedTrip: selectedTrip)) {
//                        VStack(alignment: .center) {
//                            Text(item.title)
//                                .fontWeight(.bold)
//                                .frame(maxWidth: .infinity, alignment: .center)
//                                .multilineTextAlignment(.center)
//                        }
//                    }
//                }
                List(results, id: \.id) { item in
                    NavigationLink(destination: RecipeDetailView(recipe: item, selectedTrip: selectedTrip)) {
                        VStack(alignment: .center) {
                            if let imageURL = item.imageURL, let url = URL(string: imageURL) {
                                AsyncImage(url: url) { image in
                                    image.resizable()
                                         .aspectRatio(contentMode: .fill)
                                         .frame(width: 100, height: 100)
                                         .clipped()
                                } placeholder: {
                                    ProgressView()
                                }
                            }
                            Text(item.title)
                                .fontWeight(.bold)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .multilineTextAlignment(.center)
                        }
                    }
                }
                .listStyle(PlainListStyle())
                .navigationTitle("Recipe Search")
                .searchable(
                    text: $searchText,
                    placement: .navigationBarDrawer(displayMode: .always),
                    prompt: "Search Recipes"
                )
                .onChange(of: searchText) { oldValue, newValue in
                    if newValue != oldValue && !newValue.isEmpty {
                        fetchData(searchQuery: newValue)
                    }
                }
            }
        }
        .onAppear {
            print("ContentView appeared")
            if FirebaseApp.app() != nil {
                fetchData()
                print("Firebase is configured and fetchData called")
            } else {
                print("Firebase is not configured")
            }
        }
    }
    /// Fetches recipes from Firestore, with optional search query
    func fetchData(searchQuery: String = "") {
        print("Fetching recipes...")
        let db = Firestore.firestore()
        var query: Query = db.collection("Recipes")

        if !searchQuery.isEmpty {
            query = query.whereField("title", isGreaterThanOrEqualTo: searchQuery)
                .whereField("title", isLessThanOrEqualTo: searchQuery + "\u{f8ff}")
        }

        query.getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching recipes: \(error.localizedDescription)")
                return
            }

            guard let documents = snapshot?.documents else {
                print("No recipes found")
                return
            }

            var fetchedRecipes: [Result] = []

            for document in documents {
                let data = document.data()
                // Ensure required fields exist
                guard let title = data["title"] as? String,
                      let description = data["description"] as? String,
                      let filter = data["filter"] as? [String],
                      let ingredientsArray = data["ingredients"] as? [[String: Any]] else {
                    print("❌ Skipping document \(document.documentID) due to missing required fields")
                    continue
                }

                // Convert ingredients safely
                var ingredients: [IngredientPlain] = [] 
                for ingredientData in ingredientsArray {
                    if let name = ingredientData["name"] as? String,
                       let amount = ingredientData["amount"] as? Double,
                       let unit = ingredientData["unit"] as? String,
                       let calories = ingredientData["calories"] as? Int,
                       let weight = ingredientData["weight"] as? Int {
                        
                        let ingredient = IngredientPlain(name: name, amount: amount,  unit: unit, calories: calories, weight: weight)
                        ingredients.append(ingredient)
                    } else {
                        print("⚠️ Skipping ingredient in \(document.documentID) due to missing fields: \(ingredientData)")
                    }
                }

                let result = Result(
                    id: document.documentID,
                    title: title,
                    description: description,
                    filter: filter,
                    ingredients: ingredients
                )
                fetchedRecipes.append(result)
            }
            DispatchQueue.main.async {
                 self.results = fetchedRecipes
                 self.fetchImagesForRecipes(fetchedRecipes)
             }
        }
    }
    func fetchImagesForRecipes(_ recipes: [Result]) {
        let group = DispatchGroup()
        for var recipe in recipes {
            group.enter()
            fetchImageForRecipe(title: recipe.title) { imageURL in
                recipe.imageURL = imageURL
                group.leave()
            }
        }

        group.notify(queue: .main) {
            self.results = recipes // Update the UI once all images are fetched
        }
    }

    func fetchImageForRecipe(title: String, completion: @escaping (String?) -> Void) {
        guard let apiKey = self.apiKey, let baseURL = self.baseURL else {
            print("API key or base URL is nil")
            completion(nil)
            return
        }

        var components = URLComponents(string: "\(baseURL)/recipes/complexSearch")
        components?.queryItems = [
            URLQueryItem(name: "apiKey", value: apiKey),
            URLQueryItem(name: "query", value: title),
            URLQueryItem(name: "number", value: "1"), // Limit to one result for simplicity
            URLQueryItem(name: "addRecipeInformation", value: "true") // Ensure it includes image URLs
        ]

        guard let url = components?.url else {
            print("Invalid URL components")
            completion(nil)
            return
        }

        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "GET"

        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print("No data or there was an error: \(error!.localizedDescription)")
                completion(nil)
                return
            }

            do {
                let decoder = JSONDecoder()
                let response = try decoder.decode(RecipeSearchResponse.self, from: data)
                if let imageURL = response.results.first?.imageURL {
                    DispatchQueue.main.async {
                        completion(imageURL)
                    }
                } else {
                    print("No image found for the recipe")
                    completion(nil)
                }
            } catch {
                print("Decoding error: \(error)")
                completion(nil)
            }
        }.resume()
    }

}
struct RecipeSearchResponse: Codable {
    let results: [Result] // This should be an array of Recipe objects.
}

struct RecipeSearch: Codable {
    let offset, number: Int?
    let results: [Result]
    let totalResults: Int
}

struct SupportInfo: Codable {
    let url: String
    let text: String
}

func getDownloadURL(for storagePath: String, completion: @escaping (String?) -> Void) {
    let storageRef = Storage.storage().reference(forURL: storagePath)
    storageRef.downloadURL { url, error in
        if let error = error {
            completion(nil)
        } else if let url = url {
            completion(url.absoluteString)
        }
    }
}
