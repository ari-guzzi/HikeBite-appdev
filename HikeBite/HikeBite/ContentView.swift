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
    
    var body: some View {
        NavigationView {
            VStack {
                List(results, id: \.id) { item in
                    NavigationLink(destination: RecipeDetailView(recipe: item)) {
                        VStack(alignment: .center) {
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
                    filter: filter,
                    ingredients: ingredients
                )
                fetchedRecipes.append(result)
            }

            DispatchQueue.main.async {
                self.results = fetchedRecipes
            }
        }
    }
}


#Preview {
    ContentView()
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
