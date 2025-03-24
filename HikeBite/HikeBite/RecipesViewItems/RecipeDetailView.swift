//
//  RecipeDetailView.swift
//  HikeBite
//
//  Created by Ari Guzzi on 1/13/25.
//
import Foundation
import SwiftData
import SwiftUI
import Combine
import Firebase
import FirebaseFirestore
import FirebaseStorage

struct RecipeDetailView: View {
    var recipe: Result
    var selectedTrip: Trip?
    @Environment(\.modelContext) private var modelContext
    @State private var mutableIngredients: [IngredientPlain] = []
    @Query private var items: [GroceryItem]
    @State private var servings = 1
    @State private var showAddToPlanSheet = false
    @State private var selectedDay = "Day 1"
    @State private var selectedMeal = "Breakfast"
    let days = ["Day 1", "Day 2", "Day 3"]
    let meals = ["Breakfast", "Lunch", "Dinner", "Snacks"]
    @State private var image: Image?
    @State private var imageURL: URL?

    var body: some View {
        VStack {
            ScrollView {
                VStack(alignment: .leading) {
                    Text(recipe.title)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .font(.title)
                        .fontWeight(.bold)
                        .padding(.top)
                    AsyncImage(url: imageURL) { phase in
                        switch phase {
                        case .success(let image):
                            image.resizable()
                                 .aspectRatio(contentMode: .fill)
                                 .frame(width: 100, height: 100)
                                 .cornerRadius(8)
                        case .empty:
                            ProgressView()
                        case .failure(_):
                            Text("Unable to load image")
                            .frame(width: 100, height: 100)
                            .background(Color.gray)
                            .cornerRadius(8)
                        @unknown default:
                            EmptyView()
                        }
                    }
//                    if let imageURL = imageURL {
//                        AsyncImage(url: imageURL) { phase in
//                            switch phase {
//                            case .success(let image):
//                                image.resizable()
//                                     .aspectRatio(contentMode: .fill)
//                                     .frame(width: 300, height: 200)
//                                     .cornerRadius(10)
//                            case .failure(_):
//                                Text("Unable to load image")
//                                    .foregroundColor(.red)
//                                    .frame(width: 300, height: 200)
//                            case .empty:
//                                ProgressView()
//                                    .frame(width: 300, height: 200)
//                            @unknown default:
//                                EmptyView()
//                            }
//                        }
//                    } else {
//                        Color.gray.opacity(0.3)
//                            .frame(width: 300, height: 200)
//                            .cornerRadius(10)
//                    }

                        if !recipe.description.isEmpty {
                            Text(recipe.description)
                                .font(.body)
                                .foregroundColor(.gray)
                                .padding(.horizontal)
                                .padding(.top, 4)
                        }
                        if let createdBy = recipe.createdBy, !createdBy.isEmpty {
                            HStack {
                                Text("Created by: ")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                Text(createdBy)
                                    .font(.subheadline)
                                    .bold()
                            }
                            .padding(.horizontal)
                        }

                        if let timestamp = recipe.timestamp {
                            HStack {
                                Text("Uploaded on: ")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                Text(timestamp.formatted(date: .abbreviated, time: .shortened)) // Formats date nicely
                                    .font(.subheadline)
                                    .bold()
                            }
                            .padding(.horizontal)
                        }
                    if !recipe.filter.isEmpty {
                        Text("Filters:")
                            .fontWeight(.bold)
                            .font(.title2)
                            .padding(.vertical, 4)
                        HStack {
                            ForEach(recipe.filter, id: \.self) { filter in
                                Text(filter)
                                    .padding(8)
                                    .background(Color.gray.opacity(0.2))
                                    .cornerRadius(8)
                            }
                        }
                        .padding(.bottom, 8)
                    }

                    HStack {
                        Text("Servings: \(servings)").font(.headline)
                        Spacer()
                        Button(action: { if servings > 1 { servings -= 1 } }) {
                            Image(systemName: "minus.circle").foregroundColor(.red)
                        }
                        Button(action: { servings += 1 }) {
                            Image(systemName: "plus.circle").foregroundColor(.green)
                        }
                    }
                    .padding()

                    Text("Ingredients:")
                        .fontWeight(.bold)
                        .font(.title2)
                        .padding(.vertical)

                    ForEach(mutableIngredients.indices, id: \.self) { index in
                        viewIngredient(ingredient: $mutableIngredients[index], servings: servings)
                    }
                }
                .navigationTitle("Recipe Details")
                .navigationBarTitleDisplayMode(.inline)
                .padding()
            }

            Button(action: {
                showAddToPlanSheet = true
            }) {
                Text("Add to My Plan")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .padding()
            }
        }
        .sheet(isPresented: $showAddToPlanSheet) {
            MealSelectionView(selectedDay: $selectedDay, selectedMeal: $selectedMeal, servings: $servings) {
                addRecipeToPlan()
            }
        }
        .onAppear {
            mutableIngredients = recipe.ingredients
            loadRecipeImage()
            }
        }
    func loadRecipeImage() {
        guard let imgPath = recipe.img else {
            print("No image path available.")
            return
        }
        getDownloadURL(for: imgPath) { url in
            if let urlString = url, let url = URL(string: urlString) {
                DispatchQueue.main.async {
                    self.imageURL = url
                    print(url)
                }
            }
        }
    }

    func getDownloadURL(for imageName: String, completion: @escaping (String?) -> Void) {
        let storageRef = Storage.storage().reference(withPath: imageName)
        storageRef.downloadURL { url, error in
            if let error = error {
                print("Error fetching URL: \(error.localizedDescription)")
                completion(nil)
            } else if let url = url {
                completion(url.absoluteString)  // This is the HTTP URL
            }
        }
    }
    private func addRecipeToPlan() {
        guard let selectedTrip = selectedTrip else {
            print("❌ No trip selected!")
            return
        }

        let totalCalories = mutableIngredients.reduce(0) { $0 + (($1.calories ?? 0) * servings) }
        let totalGrams = mutableIngredients.reduce(0) { $0 + (($1.weight ?? 0) * servings) }
        let newMealEntry = MealEntry(
            day: selectedDay,
            meal: selectedMeal,
            recipeTitle: recipe.title,
            servings: servings,
            tripName: selectedTrip.name
        )
        modelContext.insert(newMealEntry)
        do {
            try modelContext.save()
            print("✅ Meal saved to \(selectedTrip.name): \(newMealEntry.recipeTitle) for \(newMealEntry.day), \(newMealEntry.meal) with \(servings) servings")
        } catch {
            print("❌ Failed to save meal entry: \(error.localizedDescription)")
        }
    }
    @ViewBuilder
    func viewIngredient(ingredient: Binding<IngredientPlain>, servings: Int) -> some View {
        let ingredientName = ingredient.wrappedValue.name.capitalized
        let adjustedAmount = (ingredient.wrappedValue.amount ?? 0.0) * Double(servings)
        let formattedAmount = "\(String(format: "%.1f", adjustedAmount)) \(ingredient.wrappedValue.unit)"
        let groceryItemName = "\(formattedAmount) of \(ingredientName)"

        HStack {
            VStack(alignment: .leading) {
                Text(ingredientName).fontWeight(.bold)
                Text("Amount: \(formattedAmount)").font(.caption)
                Text("Calories: \((ingredient.wrappedValue.calories ?? 0) * servings) kcal").font(.caption)
                Text("Weight: \((ingredient.wrappedValue.weight ?? 0) * servings) g").font(.caption)
            }
            Spacer()

            Button {
                let newGroceryItem = GroceryItem(name: groceryItemName, isCompleted: false)
                modelContext.insert(newGroceryItem)

                do {
                    try modelContext.save()
                    print("✅ Added to grocery list: \(newGroceryItem.name)")
                } catch {
                    print("❌ Failed to add grocery item: \(error.localizedDescription)")
                }
            } label: {
                let existsInGroceryList = items.contains { $0.name == groceryItemName }
                Image(systemName: existsInGroceryList ? "checkmark.circle.fill" : "plus.circle")
                    .foregroundColor(.green)
            }
        }
        .padding()
        .border(Color(hue: 1.0, saturation: 0.023, brightness: 0.907))
    }

    }

struct RecipeSearchResponse: Codable {
    let results: [Recipe]
    let offset: Int
    let number: Int
    let totalResults: Int
}

struct Recipe: Codable, Identifiable {
    let id: Int
    let title: String
    let image: String
    let imageType: String
    let readyInMinutes: Int?
    let servings: Int?
    let sourceUrl: String?
    // Include other fields as necessary, ensuring they are marked optional if they can be absent

    var identifier: String { return "\(id)" }
}
