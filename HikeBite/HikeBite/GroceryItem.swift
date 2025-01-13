//
//  GroceryItem.swift
//  HikeBite
//
//  Created by Ari Guzzi on 1/13/25.
//
import SwiftData
import SwiftUI

@Model
class GroceryItem: Identifiable {
    let id: UUID
    var name: String
    var isCompleted: Bool
    var isRecentlyAdd: Bool
    @Relationship(deleteRule: .cascade)
        var completionDate: ItemDate?

    init(id: UUID = UUID(), name: String, isCompleted: Bool, isRecentlyAdd: Bool = false) {
        self.id = id
        self.name = name
        self.isCompleted = isCompleted
        self.isRecentlyAdd = isRecentlyAdd
        self.completionDate = nil
    }
}
@Model
class ItemDate {
    var date: Date
    init(date: Date = Date()) {
        self.date = date
    }
}
