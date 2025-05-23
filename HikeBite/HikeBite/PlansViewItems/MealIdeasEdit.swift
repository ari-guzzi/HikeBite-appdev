//
//  MealIdeasEdit.swift
//  HikeBite
//
//  Created by Ari Guzzi on 4/5/25.
//
import Combine
import Firebase
import FirebaseFirestore
import FirebaseStorage
import Foundation
import SwiftData
import SwiftUI

struct MealIdeasEdit: View {
    @Binding var mealEntry: MealEntry
    var recipe: Result
    @State private var selectedTrip: Trip? = nil
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
    @StateObject var tripManager = TripManager()
    @State private var totalCalories = 0
    @State private var totalGrams = 0
    @Environment(\.dismiss) private var dismiss
    let screenWidth = UIScreen.main.bounds.width
    var onDismiss: (() -> Void)?
    init(mealEntry: Binding<MealEntry>, recipe: Result, onDismiss: (() -> Void)? = nil) {
        self._mealEntry = mealEntry
        self.recipe = recipe
        self._servings = State(initialValue: mealEntry.wrappedValue.servings)
        self.onDismiss = onDismiss
    }
    var body: some View {
        let columns = [GridItem(.adaptive(minimum: 80), spacing: 10)]
        NavigationView {
            ScrollView {
                VStack(alignment: .leading) {
                    ZStack {
                        LinearGradient(gradient: Gradient(colors: [Color(red: 0.67, green: 0.85, blue: 0.76), .white]),
                                       startPoint: .bottom,
                                       endPoint: .top)
                        .frame(height: UIScreen.main.bounds.height * 0.6)
                        .edgesIgnoringSafeArea([.all])
                        FunnyLines()
                            .ignoresSafeArea(.all)
                        VStack {
                            Text(mealEntry.recipeTitle)
                                .frame(width: screenWidth)
                                .font(.title)
                                .fontWeight(.bold)
                                .padding(.top)
                            Text("Total Calories: \(totalCalories)")
                                .font(
                                    Font.custom("--FONTSPRINGDEMO-FieldsDisplayMediumRegular", size: 16)
                                )
                            Text("Total Grams: \(totalGrams)")
                                .font(
                                    Font.custom("--FONTSPRINGDEMO-FieldsDisplayMediumRegular", size: 16)
                                )
                            if !recipe.description.isEmpty {
                                Text(recipe.description)
                                    .font(.body)
                                    .foregroundColor(.gray)
                                    .padding(.horizontal)
                                    .padding(.top, 4)
                            }
                            Button("Save Changes") {
                                mealEntry.servings = servings
                                mealEntry.totalCalories = totalCalories
                                mealEntry.totalGrams = totalGrams
                                do {
                                    try modelContext.save()
                                    print("✅ Meal entry updated")
                                    onDismiss?()
                                    dismiss()
                                } catch {
                                    print("❌ Failed to update meal entry: \(error.localizedDescription)")
                                }
                            }
                            .font(.headline)
                            .padding(10)
                            .frame(maxWidth: .infinity)
                            .background(Color(red: 0, green: 0.41, blue: 0.22))
                            .foregroundColor(.white)
                            .cornerRadius(20)
                            filterChipsView()
                            HStack {
                                Text("Servings: \(servings)")
                                    .font(.title2)
                                    .font(.system(size: 24, weight: .bold))
                                Spacer()
                                Button(action: { if servings > 1 { servings -= 1 } }) {
                                    Image(systemName: "minus.circle").font(.system(size: 24)).foregroundColor(.red)
                                }
                                Button(action: { servings += 1 }) {
                                    Image(systemName: "plus.circle").font(.system(size: 24)).foregroundColor(.green)
                                }
                                Spacer()
                            }
                            .frame(width: screenWidth - 20)
                        }
                        .frame(width: screenWidth - 10)
                    }
                    ZStack {
                        LinearGradient(gradient: Gradient(colors: [Color(red: 0.67, green: 0.85, blue: 0.76), .white]),
                                       startPoint: .top,
                                       endPoint: .center)
                        .offset(y: -30)
                        .edgesIgnoringSafeArea([.all])
                        VStack {
                            Text("Ingredients:")
                                .font(.title2)
                                .font(.system(size: 24, weight: .bold))
                                .padding(.vertical)
                            ForEach(mutableIngredients.indices, id: \.self) { index in
                                viewIngredient(ingredient: $mutableIngredients[index], servings: servings)
                            }
                            .frame(width: screenWidth - 50)
                        }
                        .offset(y: -100)
                    }
                }
                .offset(y: -80)
            }
            .navigationBarTitle("Meal Details", displayMode: .inline)
        }
        .onAppear {
            mutableIngredients = recipe.ingredients
            updateTotals()
            if let urlString = recipe.img, let imageUrl = URL(string: urlString) {
                self.imageURL = imageUrl
            }
        }
    }
    func loadRecipeImage() {
        guard let imgPath = recipe.img else {
            print("No image path available.")
            return
        }
        getDownloadURL(for: imgPath) { url in
            if let url = url {
                self.imageURL = url
                print("URL set for AsyncImage: \(url)")
            } else {
                print("Failed to load URL for image path: \(imgPath)")
            }
        }
    }
    func getDownloadURL(for imageUrlString: String, completion: @escaping (URL?) -> Void) {
        guard let url = URL(string: imageUrlString) else {
            print("Invalid URL: \(imageUrlString)")
            completion(nil)
            return
        }
        let pathComponents = url.pathComponents
        // This might need adjustment depending on your specific URL structure
        let imagePath = pathComponents.suffix(2).joined(separator: "/")
        let storageRef = Storage.storage().reference(withPath: imagePath)
        storageRef.downloadURL { url, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Error fetching URL: \(error.localizedDescription)")
                    completion(nil)
                } else if let url = url {
                    print("Fetched URL: \(url)")
                    completion(url)
                }
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
            recipeID: recipe.id ?? "",
            recipeTitle: recipe.title,
            servings: servings,
            tripName: selectedTrip.name,
            totalCalories: totalCalories,
            totalGrams: totalGrams
        )
        modelContext.insert(newMealEntry)
        do {
            try modelContext.save()
            print("✅ Meal saved to \(selectedTrip.name): \(newMealEntry.recipeTitle) for \(newMealEntry.day), \(newMealEntry.meal) with \(servings) servings")
        } catch {
            print("❌ Failed to save meal entry: \(error.localizedDescription)")
        }
    }
    func updateTotals() {
        totalCalories = mutableIngredients.reduce(0) { sum, ingredient in
            sum + (ingredient.calories ?? 0) * servings
        }
        totalGrams = mutableIngredients.reduce(0) { sum, ingredient in
            sum + (ingredient.weight ?? 0) * servings
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
                    .font(Font.custom("FONTSPRINGDEMO-FieldsDisplayMediumRegular", size: 20))
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
        .cornerRadius(9)
        .overlay(
            RoundedRectangle(cornerRadius: 9)
                .stroke(Color(red: 0, green: 0.41, blue: 0.22), lineWidth: 1)
        )
    }
    @ViewBuilder
    func filterChipsView() -> some View {
        if !recipe.filter.isEmpty {
            HStack {
                Text("Filters:")
                    .font(.system(size: 24, weight: .bold))
                    .padding(.vertical, 4)
                Spacer()
            }
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 80), spacing: 10)], alignment: .leading, spacing: 12) {
                ForEach(recipe.filter, id: \.self) { filter in
                    Text(filter.capitalized)
                        .font(.system(size: 14, weight: .medium))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color(red: 0.91, green: 1, blue: 0.96))
                        .cornerRadius(20)
                        .fixedSize()
                        .shadow(color: .black.opacity(0.25), radius: 2, x: 0, y: 4)
                }
            }
            .padding(.horizontal, 5)
        }
    }
}
