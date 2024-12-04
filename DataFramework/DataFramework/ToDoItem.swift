//
//  ToDoItem.swift
//  DataFramework
//
//  Created by Ari Guzzi on 11/18/24.
//

import SwiftData

@Model
class ToDoItem {
    var title: String
    var isComplete: Bool
    @Relationship(deleteRule: .cascade)
    var tags: [ItemTag]
    
    init(title: String, isComplete: Bool = false) {
        self.title = title
        self.isComplete = isComplete
        self.tags = [ItemTag(), ItemTag()]
    }
}
@Model
class ItemTag {
    var value: Int
    init(value: Int = Int.random(in: 1000 ... 9999)) {
        self.value = value
    }
}
