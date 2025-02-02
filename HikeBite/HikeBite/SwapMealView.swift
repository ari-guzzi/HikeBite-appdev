//
//  SwapMealView.swift
//  HikeBite
//
//  Created by Ari Guzzi on 2/1/25.
//
import SwiftUI
import FirebaseFirestore

struct SwapMealView: View {
    @Environment(\.modelContext) private var modelContext
    var mealToSwap: MealEntry
    var dismiss: () -> Void

    @State private var recipes: [Result] = [] // Store fetched recipes
    @State private var isLoading = true       // Track loading state

    var body: some View {
        NavigationView {
            VStack {
                Text("Swap \(mealToSwap.recipeTitle)")
                    .font(.headline)
                    .padding()

                if isLoading {
                    ProgressView("Loading recipes...") // Show loading spinner
                } else {
                    List(recipes, id: \.id) { recipe in
                        Button {
                            swapMeal(with: recipe.title)
                        } label: {
                            HStack {
                                AsyncImage(url: URL(string: recipe.image)) { image in
                                    image.resizable().scaledToFit()
                                } placeholder: {
                                    Image(systemName: "photo")
                                }
                                .frame(width: 40, height: 40)
                                .clipShape(RoundedRectangle(cornerRadius: 8))

                                Text(recipe.title)
                                    .padding()
                            }
                        }
                    }
                }
            }
            .navigationTitle("Choose a Replacement")
            .toolbar {
                Button("Cancel") {
                    dismiss()
                }
            }
            .onAppear {
                fetchRecipesFromFirebase()
            }
        }
    }

    // Swap the meal with a new one
    private func swapMeal(with newTitle: String) {
        mealToSwap.recipeTitle = newTitle

        do {
            try modelContext.save()
            print("Swapped \(mealToSwap.recipeTitle) with \(newTitle)")
            dismiss()
        } catch {
            print("Error swapping meal: \(error.localizedDescription)")
        }
    }

    // Fetch recipes from Firebase Firestore
    private func fetchRecipesFromFirebase() {
        let db = Firestore.firestore()
        db.collection("Recipes").getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching recipes: \(error.localizedDescription)")
                isLoading = false
                return
            }
            guard let documents = snapshot?.documents else {
                print("No recipes found")
                isLoading = false
                return
            }

            // Parse documents into Result objects
            var fetchedRecipes: [Result] = []
            for document in documents {
                let data = document.data()
                let recipe = Result(
                    id: document.documentID,
                    title: data["title"] as? String ?? "Unknown Recipe",
                    image: data["image"] as? String ?? "https://example.com/placeholder.jpg",
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
                fetchedRecipes.append(recipe)
            }

            DispatchQueue.main.async {
                self.recipes = fetchedRecipes
                self.isLoading = false
            }
        }
    }
}
