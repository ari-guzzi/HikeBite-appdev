//
//  SwapMealView.swift
//  HikeBite
//
//  Created by Ari Guzzi on 2/1/25.
//
import FirebaseFirestore
import SwiftUI

struct SwapMealView: View {
    @Environment(\.modelContext) private var modelContext
    var mealToSwap: MealEntry
    var dismiss: () -> Void

    @State private var recipes: [Result] = []
    @State private var isLoading = true

    var body: some View {
        NavigationView {
            VStack {
                Text("Swap \(mealToSwap.recipeTitle)")
                    .font(.headline)
                    .padding()

                if isLoading {
                    ProgressView("Loading recipes...")
                } else {
                    List(recipes, id: \.id) { recipe in
                        Button {
                            swapMeal(with: recipe.title)
                        } label: {
                            HStack {
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
                print("🛠️ SwapMealView appeared. Fetching recipes...")
                fetchRecipesFromFirebase()
            }
            .onChange(of: recipes) { newRecipes in
                if !newRecipes.isEmpty {
                    print("🔄 Recipes updated: \(newRecipes.count) found")
                    isLoading = false  // Hide spinner once recipes are available
                }
            }
        }
    }

    private func swapMeal(with newTitle: String) {
        mealToSwap.recipeTitle = newTitle
        do {
            try modelContext.save()
            print("✅ Swapped \(mealToSwap.recipeTitle) with \(newTitle)")
            dismiss()
        } catch {
            print("❌ Error swapping meal: \(error.localizedDescription)")
        }
    }

    private func fetchRecipesFromFirebase() {
        let db = Firestore.firestore()
        db.collection("Recipes").getDocuments { snapshot, error in
            if let error = error {
                print("❌ Error fetching recipes: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    isLoading = false
                }
                return
            }

            guard let documents = snapshot?.documents else {
                print("⚠️ No recipes found")
                DispatchQueue.main.async {
                    isLoading = false
                }
                return
            }

            let fetchedRecipes = documents.compactMap { doc -> Result? in
                try? doc.data(as: Result.self)
            }

            DispatchQueue.main.async {
                self.recipes = fetchedRecipes
            }
        }
    }
}
