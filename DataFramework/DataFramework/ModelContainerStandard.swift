//
//  ModelContainerStandard.swift
//  DataFramework
//
//  Created by Ari Guzzi on 12/2/24.
//
import SwiftData
import SwiftUI

extension ModelContainer {

    static var standard: ModelContainer {
        let config = ModelConfiguration(
            isStoredInMemoryOnly: false,
            groupContainer: .automatic
        )
        let container = try! ModelContainer(
            for: GroceryItem.self,
            configurations: config
        )
        return container
    }
    static var ingredientContainer: ModelContainer {
        let config = ModelConfiguration(
            isStoredInMemoryOnly: false,
            groupContainer: .automatic
        )
        let container = try! ModelContainer(
            for: IngredientWidget.self, Ingredient.self,
            configurations: config
        )
        return container
    }
}

