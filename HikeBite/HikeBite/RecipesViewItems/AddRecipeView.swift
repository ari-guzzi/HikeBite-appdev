//
//  AddRecipeView.swift
//  HikeBite
//
//  Created by Ari Guzzi on 3/2/25.
//

import FirebaseAuth
import FirebaseFirestore
import Foundation
import Firebase
import SwiftUI

struct AddRecipeView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    @State private var title = ""
    @State private var description = ""
    @State private var ingredients: [IngredientPlain] = []
    @State private var selectedFilters: Set<String> = []
    @State private var imageURL: String? = nil
    @State private var isUploading = false
    @Environment(\.presentationMode) var presentationMode

    let allFilters = ["no-stove", "no-water", "no-dairy", "vegan", "vegetarian", "fresh", "premade", "light-weight", "breakfast", "lunch", "dinner", "beverages", "snack"]

    var body: some View {
        if let user = viewModel.currentUser {
            NavigationView {
                Form {
                    Section(header: Text("Recipe Details")) {
                        TextField("Recipe Title", text: $title)
                        TextField("Description", text: $description)
                    }
                    
                    Section(header: Text("Filters")) {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                ForEach(allFilters, id: \.self) { filter in
                                    FilterTag(filter: filter, isSelected: selectedFilters.contains(filter)) {
                                        toggleFilter(filter)
                                    }
                                }
                            }
                        }
                    }
                    
                    Section(header: Text("Ingredients")) {
                        ForEach(ingredients.indices, id: \.self) { index in
                            VStack {
                                TextField("Ingredient Name", text: $ingredients[index].name)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())

                                HStack {
                                    TextField("Amount", value: $ingredients[index].amount, formatter: NumberFormatter())
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                        .keyboardType(.decimalPad)

                                    TextField("Unit", text: $ingredients[index].unit)
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                }

                                HStack {
                                    TextField("Calories", value: $ingredients[index].calories, formatter: NumberFormatter())
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                        .keyboardType(.numberPad)

                                    TextField("Weight (g)", value: $ingredients[index].weight, formatter: NumberFormatter())
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                        .keyboardType(.numberPad)
                                }
                            }
                            .padding(.vertical, 5)
                        }

                        Button("Add Ingredient") {
                            ingredients.append(IngredientPlain(name: "", amount: nil, unit: "", calories: nil, weight: nil))
                        }
                    }

                    
                    Section {
                        Button(action: uploadRecipe) {
                            if isUploading {
                                ProgressView()
                            } else {
                                Text("Upload Recipe")
                            }
                        }
                        .disabled(title.isEmpty || description.isEmpty)
                    }
                }
                .navigationTitle("Add Recipe")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Cancel") {
                            presentationMode.wrappedValue.dismiss()
                        }
                    }
                }
            }
        } else {
            Text("Please go create an account in profile view to upload a recipe.")
        }
    }

    private func toggleFilter(_ filter: String) {
        if selectedFilters.contains(filter) {
            selectedFilters.remove(filter)
        } else {
            selectedFilters.insert(filter)
        }
    }
    private func uploadRecipe() {
        let user = viewModel.currentUser
        let newResult = Result(
              id: nil,  // Firestore will generate this automatically
              title: title,
              description: description,
              filter: Array(selectedFilters),
              ingredients: ingredients,
              imageURL: imageURL, // Optional: if user uploads an image
              createdBy: user?.email ?? "unknown email",  // Use the authenticated user's email
              timestamp: Date() // Use `Date()` instead of `Timestamp`
         )
        isUploading = true

        do {
            let db = Firestore.firestore()
            let _ = try db.collection("Recipes").addDocument(from: newResult) { error in
                isUploading = false
                if let error = error {
                    print("Error uploading recipe: \(error.localizedDescription)")
                } else {
                    print("✅ Recipe uploaded successfully!")
                    presentationMode.wrappedValue.dismiss()
                }
            }
        } catch {
            print("Error saving recipe: \(error.localizedDescription)")
        }
    }
}

// Small view for filter tags
struct FilterTag: View {
    let filter: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Text(filter.capitalized)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(isSelected ? Color.blue.opacity(0.7) : Color.gray.opacity(0.3))
            .cornerRadius(10)
            .onTapGesture {
                action()
            }
    }
}

extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content
    ) -> some View {
        ZStack(alignment: alignment) {
            placeholder().opacity(shouldShow ? 1 : 0)
            self
        }
    }
}
