//
//  GroceryList.swift
//  DataFramework
//
//  Created by Ari Guzzi on 12/3/24.
//

import SwiftUI
import SwiftData

struct GroceryList: View {
    @EnvironmentObject var groceryListManager: GroceryListManager
    
    var body: some View {
        List {
            ForEach(groceryListManager.items) { item in
                HStack {
                    if item.isCompleted {
                        Text(item.name)
                            .strikethrough()
                            .foregroundColor(.gray)
                    } else {
                        Text(item.name)
                            .foregroundColor(.black)
                    }
                    Spacer()
                    Button {
                        groceryListManager.toggleCompleted(for: item)
                    } label: {
                        Image(systemName: item.isCompleted ? "checkmark.circle" : "circle")
                            .foregroundColor(.green)
                            .accessibilityLabel("Toggle Item Completion")
                    }
                }
            }
            .onDelete(perform: groceryListManager.deleteItems)
        }
        .navigationTitle("Grocery List")
    }
}

#Preview {
    GroceryList()
}
