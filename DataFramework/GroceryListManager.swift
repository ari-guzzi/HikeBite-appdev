//
//  GroceryListManager.swift
//  DataFramework
//
//  Created by Ari Guzzi on 12/3/24.
//

import SwiftUI
import SwiftData


class GroceryListManager: ObservableObject {
    @Published var items: [GroceryItem] = []

    func toggleCompleted(for item: GroceryItem) {
        guard let index = items.firstIndex(where: { $0.id == item.id }) else { return }
        items[index].isCompleted.toggle()
    }

    func deleteItems(at offsets: IndexSet) {
        items.remove(atOffsets: offsets)
    }

    func addIngredient(_ ingredient: String) {
        if let index = items.firstIndex(where: { $0.name == ingredient }) {
        } else {
            let newItem = GroceryItem(name: ingredient, isCompleted: false)
            items.append(newItem)
            DispatchQueue.main.async {
                self.items.append(newItem)
                print("Ingredient added: \(ingredient)")
            }
        }
    }
}

@Model
class GroceryItem: Identifiable {
    let id: UUID
    var name: String
    var isCompleted: Bool
    var isRecAdd: Bool

    init(id: UUID = UUID(), name: String, isCompleted: Bool, isRecAdd: Bool = false) {
        self.id = id
        self.name = name
        self.isCompleted = isCompleted
        self.isRecAdd = isRecAdd
    }
}

