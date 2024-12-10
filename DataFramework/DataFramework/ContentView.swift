//
//  ContentView.swift
//  DataFramework
//
//  Created by Ari Guzzi on 12/3/24.
//

import SwiftData
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
                                    .aspectRatio(contentMode: .fit)
                            } placeholder: {
                                ProgressView()
                            }
                            .frame(height: 120)
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
            fetchData()
        }
    }
    func fetchData(searchQuery: String = "", diet: String = "") {
        guard let apiKey = apiKey,
            let baseURL = baseURL,
            var components = URLComponents(string: "\(baseURL)/recipes/complexSearch")
        else {
            print("Invalid URL or API key missing")
            return
            }
        var queryItems = [URLQueryItem(name: "apiKey", value: apiKey)]
        if !searchQuery.isEmpty {
            queryItems.append(URLQueryItem(name: "query", value: searchQuery))
        }
        components.queryItems = queryItems
        guard let url = components.url else {
            print("Invalid URL components")
            return
        }
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "GET"

        URLSession.shared.dataTask(with: request) { data, _, error in
            guard let data = data else {
                print("No data received")
                return
            }

            do {
                let reqResponse = try JSONDecoder().decode(RecipeSearch.self, from: data)
                DispatchQueue.main.async {
                    self.results = reqResponse.results
                }
            } catch {
                print("Decoding error: \(error)")
            }
        }.resume()
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

struct Result: Codable {
    let id: Int
    let title: String
    let image: String
    let imageType: String
}

struct SupportInfo: Codable {
    let url: String
    let text: String
}
