////
////  GroceryListManager.swift
////  DataFramework
////
////  Created by Ari Guzzi on 12/3/24.
////
//
//import SwiftUI
//import SwiftData
//
//
//class GroceryListManager: ObservableObject {
//    @Published var items: [GroceryItem] = []
//    @Environment(\.modelContext) private var modelContext
//    
//    func toggleCompleted(for item: GroceryItem) {
//        guard let index = items.firstIndex(where: { $0.id == item.id }) else { return }
//        items[index].isCompleted.toggle()
//    }
//
//    func deleteItems(at offsets: IndexSet) {
//        items.remove(atOffsets: offsets)
//    }
//
//    func addIngredient(_ ingredient: String) {
//        if let index = items.firstIndex(where: { $0.name == ingredient }) {
//        } else {
//            let newItem = GroceryItem(name: ingredient, isCompleted: false)
//            items.append(newItem)
//            DispatchQueue.main.async {
//                self.items.append(newItem)
//                print("Ingredient added: \(ingredient)")
//            }
//        }
//    }
//}
