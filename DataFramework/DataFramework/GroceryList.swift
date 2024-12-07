//
//  GroceryList.swift
//  DataFramework
//
//  Created by Ari Guzzi on 12/3/24.
//

import SwiftUI
import SwiftData

struct GroceryList: View {
    @Query private var items: [GroceryItem]
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        List {
            ForEach(items) { item in
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
                        toggleCompletion(for: item)
                    } label: {
                        Image(systemName: item.isCompleted ? "checkmark.circle" : "circle")
                            .foregroundColor(.green)
                            .accessibilityLabel("Toggle Item Completion")
                    }
                }
            }
            .onDelete(perform: deleteItems)
        }
        .navigationTitle("Grocery List")
    }
    private func toggleCompletion(for item: GroceryItem) {
            item.isCompleted.toggle()
            try? modelContext.save()
        }
    private func deleteItems(at offsets: IndexSet) {
            for index in offsets {
                let item = items[index]
                modelContext.delete(item)
            }
            try? modelContext.save()
        }
}
//
//#Preview {
//    GroceryList()
//}
