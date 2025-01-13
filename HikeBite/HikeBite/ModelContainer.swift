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
        let container = try! ModelContainer( // swiftlint:disable:this force_try
            for: GroceryItem.self,
            configurations: config
                )
        return container
    }
}
