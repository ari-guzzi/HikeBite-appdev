//
//  ModelContainer.swift
//  HikeBite
//
//  Created by Ari Guzzi on 1/13/25.
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
