//
//  RecipeDetailView.swift
//  HikeBite
//
//  Created by Ari Guzzi on 1/13/25.
//
import Combine
import Firebase
import FirebaseFirestore
import FirebaseStorage
import Foundation
import SwiftData
import SwiftUI

struct RecipeDetailView: View {
    var recipe: Result
    //var selectedTrip: Trip?
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
                            Text(recipe.title)
                                .frame(maxWidth: .infinity)
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
                            if let imageURL = imageURL {
                                AsyncImage(url: imageURL) { phase in
                                    switch phase {
                                    case .success(let image):
                                        image.resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .frame(width: 300, height: 200)
                                            .cornerRadius(10)
                                    case .failure(_):
                                        Text("Unable to load image")
                                            .frame(width: 300, height: 200)
                                            .background(Color.gray)
                                    case .empty:
                                        ProgressView()
                                            .frame(width: 300, height: 200)
                                    @unknown default:
                                        EmptyView()
                                    }
                                }
                            } else {
                                Color.gray.opacity(0.3)
                                    .frame(width: 300, height: 200)
                                    .cornerRadius(10)
                            }
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
                                    Text(timestamp.formatted(date: .abbreviated, time: .shortened))
                                        .font(.subheadline)
                                        .bold()
                                }
                                .padding(.horizontal)
                            }
                            Button("Add to my plan", action: {showAddToPlanSheet = true})
                                    .font(.headline)
                                    .padding(10)
                                    .frame(maxWidth: .infinity)
                                    .background(Color(red: 0, green: 0.41, blue: 0.22))
                                    .foregroundColor(.white)
                                    .cornerRadius(20)
                            if !recipe.filter.isEmpty {
                                HStack {
                                    Text("Filters:")
                                        .font(.system(size: 24, weight: .bold))
                                        .font(.title2)
                                        .padding(.vertical, 4)
                                    Spacer()
                                }
                                LazyVGrid(columns: columns, alignment: .leading, spacing: 3) {
                                    ForEach(recipe.filter, id: \.self) { filter in
                                        Text(filter)
                                            .padding(8)
                                            .background(Color(red: 0.91, green: 1, blue: 0.96))
                                            .cornerRadius(9)
                                            .shadow(color: .black.opacity(0.25), radius: 2, x: 0, y: 4)
                                    }
                                }

//                                HStack {
//                                    ForEach(recipe.filter, id: \.self) { filter in
//                                        Text(filter)
//                                            .padding(8)
//                                            .background(Color(red: 0.91, green: 1, blue: 0.96))
//                                            .cornerRadius(9)
//                                            .shadow(color: .black.opacity(0.25), radius: 2, x: 0, y: 4)
//                                    }
//                                    Spacer()
//                                }
                            }
                            ZStack {
                                Color(red: 0.67, green: 0.85, blue: 0.76)
                                    .edgesIgnoringSafeArea(.all)
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
                                .frame(width: UIScreen.main.bounds.width - 20)
                                .padding(.bottom, 25)
                                .background(Color(red: 0.67, green: 0.85, blue: 0.76))
                            }
                        }
                        .frame(width: UIScreen.main.bounds.width - 10)
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
                            .frame(width: UIScreen.main.bounds.width - 50)
                        }
                        .offset(y: -10)
                    }
                }
            }
            .navigationBarTitle("Meal Details", displayMode: .inline)
        }
        .sheet(isPresented: $showAddToPlanSheet) {
            MealSelectionView(selectedTrip: $selectedTrip, selectedDay: $selectedDay, selectedMeal: $selectedMeal, servings: $servings)
            {
                addRecipeToPlan()
            }
            .environmentObject(tripManager)
        }
        .onAppear {
            mutableIngredients = recipe.ingredients
            updateTotals()
            if let urlString = recipe.img, let imageUrl = URL(string: urlString) {
                self.imageURL = imageUrl
                print("Using URL: \(imageUrl)")
            } else {
                print("Invalid URL string: \(recipe.img ?? "nil")")
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
}
