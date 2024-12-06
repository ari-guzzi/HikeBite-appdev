//
//  GroceryItem.swift
//  DataFramework
//
//  Created by Ari Guzzi on 12/5/24.
//

import SwiftUI
import SwiftData

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

