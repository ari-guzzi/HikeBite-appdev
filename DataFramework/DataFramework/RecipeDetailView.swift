//
//  RecipeDetailView.swift
//  DataFramework
//
//  Created by Ari Guzzi on 12/3/24.
//

import SwiftUI
import SwiftData

struct RecipeDetailView: View {
    var recipe: Result
    @State private var ingredients: [Ingredient] = []
    @State private var recipeDetail: RecipeDetail?
    var apiKey: String? {
        Bundle.main.object(forInfoDictionaryKey: "API_KEY") as? String
    }
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var groceryListManager: GroceryListManager
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
                        .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                        .font(.title2)
                    ForEach(ingredients) { ingredient in
                        viewIngredients(ingredient: ingredient)
                    }
                    if let recipeDetail = recipeDetail {
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
            if let error = error {
                print("HTTP request failed: \(error)")
                return
            }
            guard let data = data else {
                print("No data received")
                return
            }
            do {
                let decodedResponse = try JSONDecoder().decode(IngredientWidget.self, from: data)
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
            if let error = error {
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
                    print("Recipe Instructions: \(recipeDetail.instructions)")
                }
            } catch {
                print("Decoding error: \(error)")
            }
        }.resume()
    }
    @ViewBuilder
    func viewIngredients(ingredient: Ingredient) -> some View {
        let ingredientUSVal = ingredient.amount.us.value
        let ingredientUSUnit = ingredient.amount.us.unit
        let capIngredName = ingredient.name.capitalized
        HStack {
            VStack(alignment: .leading) {
                Text("\(ingredient.name.capitalized)")
                    .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                Text("\(String(format: "%.1f", ingredient.amount.us.value)) \(ingredient.amount.us.unit)")
                    .font(.caption)
            }
            Spacer()
            Button {
                modelContext.insert(ingredient)
                DispatchQueue.main.async {
                    self.groceryListManager.addIngredient("\(ingredientUSVal) \(ingredientUSUnit) of \(capIngredName)")
                }
            } label: {
                let ingredName = "\(ingredientUSVal) \(ingredientUSUnit) of \(capIngredName)"
                Image(systemName: groceryListManager.items.first {
                    $0.name == "\(ingredName)"
                }?.isRecAdd ?? false ? "checkmark.circle.fill" : "plus.circle")
                    .foregroundColor(.green)
                    .accessibilityLabel("Add to grocery list")
            }
        }
        .padding()
        .border(/*@START_MENU_TOKEN@*/Color(hue: 1.0, saturation: 0.023, brightness: 0.907)/*@END_MENU_TOKEN@*/)
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

struct IngredientWidget: Codable {
    let ingredients: [Ingredient]
}

@Model
class Ingredient: Codable, Identifiable {
    var id: UUID = UUID()
    var name: String
    var image: String
    var amount: Amount

    enum CodingKeys: String, CodingKey {
        case id, name, image, amount
    }

    required init(name: String, image: String, amount: Amount) {
        self.name = name
        self.image = image
        self.amount = amount
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        image = try container.decode(String.self, forKey: .image)
        amount = try container.decode(Amount.self, forKey: .amount)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(image, forKey: .image)
        try container.encode(amount, forKey: .amount)
    }
}

struct Amount: Codable {
    let metric: Measurement
    let us: Measurement // swiftlint:disable:this identifier_name
}

struct Measurement: Codable {
    let unit: String
    let value: Double
}
struct RecipeDetail: Codable {
    let id: Int
    let title: String
    let readyInMinutes: Int
    let servings: Int
    let image: String
    let instructions: String
    var cleanedInstructions: String {
        instructions.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil)
    }
}

struct RecipeDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            RecipeDetailView(recipe: Result.example)
                .environmentObject(GroceryListManager())
        }
    }
}

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

