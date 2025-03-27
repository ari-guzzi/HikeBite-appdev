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
    @State private var activeFilters: Set<String> = []
    @State private var showingFilter = false
    var body: some View {
        NavigationView {
            VStack {
                Text("Swap \(mealToSwap.recipeTitle)")
                    .font(.headline)
                    .padding()          
                if isLoading {
                    ProgressView("Loading recipes...")
                } else if filteredRecipes.isEmpty {
                    Text("No recipes found.")
                        .foregroundColor(.gray)
                        .padding()
                } else {
                    List(filteredRecipes, id: \.id) { recipe in
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
                Button("Cancel") { dismiss() }
            }
            .toolbar {
                filterButton
            }
            .sheet(isPresented: $showingFilter) {
                FilterView(activeFilters: $activeFilters) {
                    showingFilter = false
                }
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
    // List of recipes filtered based on active filters
    private var filteredRecipes: [Result] {
        recipes.filter(shouldIncludeResult)
    }
    // Button to open filter selection
    private var filterButton: some View {
        Button(action: {
            showingFilter.toggle()
        }) {
            Image(systemName: activeFilters.isEmpty ? "line.horizontal.3.decrease.circle" : "line.horizontal.3.decrease.circle.fill")
                .foregroundColor(activeFilters.isEmpty ? .primary : .blue)
        }
    }
    // Determines whether a recipe should be included based on filters
    private func shouldIncludeResult(_ result: Result) -> Bool {
        activeFilters.isEmpty || Set(activeFilters).isSubset(of: Set(result.filter ?? []))
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
        print("📢 Fetching recipes from Firestore (Attempt 1)...")
        db.collection("Recipes").getDocuments { snapshot, error in
            if let error = error {
                print("❌ Error fetching recipes: \(error.localizedDescription)")
                DispatchQueue.main.async { isLoading = false }
                return
            }
            guard let documents = snapshot?.documents else {
                print("⚠️ No recipes found.")
                DispatchQueue.main.async { isLoading = false }
                return
            }
            // print("📜 Raw Firestore Data: \(documents.map { $0.data() })")
            let fetchedRecipes = documents.compactMap { doc -> Result? in
                try? doc.data(as: Result.self)
            }
            DispatchQueue.main.async {
                self.recipes = fetchedRecipes
                self.isLoading = false
                print("✅ Successfully fetched \(fetchedRecipes.count) recipes.")
            }
        }
    }
}
