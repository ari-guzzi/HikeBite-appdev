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
    var apiKey: String? {
        Bundle.main.object(forInfoDictionaryKey: "API_KEY") as? String
    }
    var baseURL: String? {
        Bundle.main.object(forInfoDictionaryKey: "API_BASE_URL") as? String
    }
    var body: some View {
        VStack {
            NavigationView {
                List(results, id: \.id) { item in
                    NavigationLink(destination: RecipeDetailView(recipe: item)) {
                        VStack(alignment: .center) {
                            Text(item.title)
                                .fontWeight(.bold)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .multilineTextAlignment(.center)
                            AsyncImage(url: URL(string: item.image)) { image in
                                image.resizable()
                                    .scaledToFill() // Ensures the image fills the view without distortion
                                    .frame(width: 200, height: 100) // Fixed size for all images
                                    .clipped() // Crops the overflowing part to fit the frame
                            } placeholder: {
                                ProgressView()
                            }
                            .frame(width: 200, height: 100) // Ensure placeholder matches the image size
                            .cornerRadius(10)
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
    func fetchData(searchQuery: String = "") {
        print("hello")
        // FirebaseApp.configure()
        // FirebaseConfiguration.shared.setLoggerLevel(.debug)
        let dbse = Firestore.firestore()
        var query: Query = dbse.collection("Recipes")
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
            let group = DispatchGroup() // Use a dispatch group to manage async tasks
            for document in documents {
                let data = document.data()
                var result = Result(
                    id: document.documentID,
                    title: data["title"] as? String ?? "",
                    image: "", // Placeholder for the resolved image URL
                    imageType: data["imageType"] as? String ?? "jpeg",
                    needStove: data["needStove"] as? Bool ?? false,
                    ingredients: (data["ingredients"] as? [[String: Any]] ?? []).compactMap { ingredientData in
                        guard
                            let name = ingredientData["name"] as? String,
                            let amount = ingredientData["amount"] as? Double,
                            let unit = ingredientData["unit"] as? String
                        else {
                            return nil
                        }
                        return IngredientPlain(name: name, amount: amount, unit: unit)
                    }
                )
                if let imagePath = data["image"] as? String {
                    group.enter()
                    getDownloadURL(for: imagePath) { url in
                        result.image = url ?? "https://example.com/placeholder.jpg"
                        fetchedRecipes.append(result)
                        group.leave()
                    }
                } else {
                    result.image = "https://example.com/placeholder.jpg"
                    fetchedRecipes.append(result)
                }
            }
            group.notify(queue: .main) {
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

struct Result: Codable, Identifiable {
    let id: String
    let title: String
    var image: String
    let imageType: String
    let needStove: Bool
    var ingredients: [IngredientPlain]
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
