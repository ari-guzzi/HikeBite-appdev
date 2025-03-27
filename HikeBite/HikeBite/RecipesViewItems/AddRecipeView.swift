//
//  AddRecipeView.swift
//  HikeBite
//
//  Created by Ari Guzzi on 3/2/25.
//
import Firebase
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage
import Foundation
import SwiftUI

struct AddRecipeView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    @State private var title = ""
    @State private var description = ""
    @State private var ingredients: [IngredientPlain] = []
    @State private var selectedFilters: Set<String> = []
    @State private var showImagePicker = false
    @State private var image: UIImage? = nil
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
//                    Section(header: Text("Upload Image")) {
//                        if let image = image {
//                            Image(uiImage: image)
//                                .resizable()
//                                .scaledToFit()
//                                .frame(height: 200)
//                        }
//                        Button("Select Image") {
//                            showImagePicker = true
//                        }
//                    }
//                    Section(header: Text("Filters")) {
//                        ScrollView(.horizontal, showsIndicators: false) {
//                            HStack {
//                                ForEach(allFilters, id: \.self) { filter in
//                                    FilterTag(filter: filter, isSelected: selectedFilters.contains(filter)) {
//                                        toggleFilter(filter)
//                                    }
//                                }
//                            }
//                        }
//                    }
                    Section(header: Text("Ingredients")) {
                        ForEach(ingredients.indices, id: \.self) { index in
                            VStack {
                                TextField("Ingredient Name", text: $ingredients[index].name)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
//                                HStack {
//                                    TextField("Amount", value: $ingredients[index].amount, formatter: NumberFormatter())
//                                        .textFieldStyle(RoundedBorderTextFieldStyle())
//                                        .keyboardType(.decimalPad)
//                                    TextField("Unit", text: $ingredients[index].unit.orEmpty())
//                                        .textFieldStyle(RoundedBorderTextFieldStyle())
//                                }
//                                HStack {
//                                    TextField("Calories", value: $ingredients[index].calories, formatter: NumberFormatter())
//                                        .textFieldStyle(RoundedBorderTextFieldStyle())
//                                        .keyboardType(.numberPad)
//                                    TextField("Weight (g)", value: $ingredients[index].weight, formatter: NumberFormatter())
//                                        .textFieldStyle(RoundedBorderTextFieldStyle())
//                                        .keyboardType(.numberPad)
//                                }
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
            .sheet(isPresented: $showImagePicker) {
                ImagePicker(image: $image)
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
        guard let imageData = image?.jpegData(compressionQuality: 0.8) else {
            print("Image data not available")
            return
        }
        
        let imageName = "recipe_images/\(UUID().uuidString).jpg"
        let storageRef = Storage.storage().reference().child(imageName)
        
        isUploading = true
        storageRef.putData(imageData, metadata: nil) { metadata, error in
            guard metadata != nil else {
                print("Failed to upload image: \(error?.localizedDescription ?? "unknown error")")
                self.isUploading = false
                return
            }
            
            storageRef.downloadURL { url, error in
                guard let downloadURL = url else {
                    print("Failed to get download URL: \(error?.localizedDescription ?? "unknown error")")
                    self.isUploading = false
                    return
                }
                
                // Extract just the image name from the URL
                let urlString = downloadURL.absoluteString
                if let imageNameOnly = self.extractImageName(from: urlString) {
                    self.saveRecipeToFirestore(imageName: imageNameOnly)
                } else {
                    print("Failed to extract image name from URL")
                    self.isUploading = false
                }
            }
        }
    }
    private func extractImageName(from urlString: String) -> String? {
        if let url = URL(string: urlString) {
            // Split the path into components
            let pathComponents = url.pathComponents
            
            // Find the index of the desired directory 'recipe_images'
            if let recipeImagesIndex = pathComponents.firstIndex(of: "recipe_images") {
                // Construct the desired path from 'recipe_images' onwards
                let desiredPathComponents = pathComponents.suffix(from: recipeImagesIndex)
                let cleanedPath = desiredPathComponents.joined(separator: "/")
                
                return cleanedPath
            }
        }
        return nil
    }



    
    private func saveRecipeToFirestore(imageName: String) {
        let newRecipe = Result(
            title: title,
            description: description,
            filter: Array(selectedFilters),
            ingredients: ingredients,
            img: imageName,
            createdBy: viewModel.currentUser?.email ?? "unknown",
            timestamp: Date()
        )
        
        let db = Firestore.firestore()
        do {
            let _ = try db.collection("Recipes").addDocument(from: newRecipe) { error in
                self.isUploading = false
                if let error = error {
                    print("Error saving recipe to Firestore: \(error.localizedDescription)")
                } else {
                    print("Recipe successfully uploaded with image name: \(imageName)")
                    self.presentationMode.wrappedValue.dismiss()
                }
            }
        } catch {
            print("Error saving recipe: \(error.localizedDescription)")
            self.isUploading = false
        }
    }
}
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
