//
//  AddMealView.swift
//  HikeBite
//
//  Created by Ari Guzzi on 2/22/25.
//
import FirebaseFirestore
import SwiftUI

struct AddMealView: View {
    @Environment(\.modelContext) private var modelContext
    var day: String
    var mealType: String
    var tripName: String
    var dismiss: () -> Void
    var refreshMeals: () -> Void
    @State private var recipes: [Result] = []
    @State private var isLoading = true
    @State private var activeFilters: Set<String> = []
    @State private var showingFilter = false
    var body: some View {
        NavigationView {
            VStack {
                Text("Add Meal to \(mealType) on \(day)")
                    .font(.headline)
                    .padding()

                if isLoading {
                    ProgressView("Loading recipes...")
                } else {
                    List(filteredRecipes, id: \.id) { recipe in
                        Button {
                            addMeal(recipe: recipe)
                        } label: {
                            HStack {
                                Text(recipe.title)
                                    .padding()
                            }
                        }
                    }
                }
            }
            .navigationTitle("Select a Meal")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    filterButton
                }
            }
            .onAppear {
                let attrs = [
                   NSAttributedString.Key.foregroundColor: UIColor.black,
                   NSAttributedString.Key.font: UIFont(name: "FONTSPRINGDEMO-FieldsDisplaySemiBoldRegular", size: 48)!
               ]
               UINavigationBar.appearance().titleTextAttributes = attrs
               UINavigationBar.appearance().largeTitleTextAttributes = attrs
                print("🛠️ AddMealView appeared with: Day - \(day), MealType - \(mealType)")
                if mealType.isEmpty {
                    print("❌ Error: MealType was empty, retrying...")
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        print("🔄 Retrying with: \(mealType)")
                    }
                }
                print("📢 Calling fetchRecipesFromFirebase()")
                fetchRecipesFromFirebase()
            }
            .onDisappear {
                isLoading = false
            }
            .sheet(isPresented: $showingFilter) {
                FilterView(activeFilters: $activeFilters) {
                    showingFilter = false
                }
            }
            .onChange(of: recipes) { newRecipes in
                if !newRecipes.isEmpty {
                    print("🔄 Recipes updated: \(newRecipes.count) found")
                    isLoading = false
                }
            }
        }
    }
    // List of recipes filtered based on active filters
    private var filteredRecipes: [Result] {
        recipes.filter(shouldIncludeResult)
    }
    // Button to open filter selection, updates if filters are active
    private var filterButton: some View {
        Button(action: {
            showingFilter.toggle()
        }) {
            Image(systemName: activeFilters.isEmpty ? "line.horizontal.3.decrease.circle" : "line.horizontal.3.decrease.circle.fill")
                .foregroundColor(activeFilters.isEmpty ? .primary : .blue) // Default vs active color
        }
    }
    // Determines whether a recipe should be included based on filters
    private func shouldIncludeResult(_ result: Result) -> Bool {
        activeFilters.isEmpty || Set(activeFilters).isSubset(of: Set(result.filter))
    }
    private func addMeal(recipe: Result) {
        guard !day.isEmpty, !mealType.isEmpty else {
            print("❌ Error: Attempting to add a meal with missing day or mealType.")
            return
        }
        let newMeal = MealEntry(
            id: UUID(),
            day: day,
            meal: mealType,
            recipeTitle: recipe.title,
            servings: 1,
            tripName: tripName
        )
        modelContext.insert(newMeal)

        do {
            try modelContext.save()
            print("✅ Added \(recipe.title) to \(tripName) on \(day) for \(mealType)")
            DispatchQueue.main.async {
                dismiss()
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                refreshMeals()
            }
        } catch {
            print("❌ Failed to add meal: \(error.localizedDescription)")
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
            print("📜 Raw Firestore Data: \(documents.map { $0.data() })")
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
