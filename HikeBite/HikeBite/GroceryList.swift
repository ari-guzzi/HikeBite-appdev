//
//  GroceryList.swift
//  DataFramework
//
//  Created by Ari Guzzi on 12/3/24.
//

import SwiftData
import SwiftUI

struct GroceryList: View {
    @Query private var items: [GroceryItem]
    @Environment(\.modelContext) private var modelContext
    var body: some View {
        VStack {
            Text("To Buy")
            List {
                ForEach(items.filter { !$0.isCompleted}) { item in
                    groceryItemView(item: item)
                }
                .onDelete(perform: deleteItems)
            }
            Spacer()
            Text("Completed")
                .padding()
            List {
                ForEach(items.filter { $0.isCompleted}) { item in
                    groceryItemView(item: item)
                }
            }
            .navigationTitle("Grocery List")
        }
    }
    private func deleteItems(at offsets: IndexSet) {
        for index in offsets {
            let item = items[index]
            modelContext.delete(item)
            }
        try? modelContext.save()
    }
    func formattedDate(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
    func groceryItemView(item: GroceryItem) -> some View {
        HStack {
            VStack {
                if item.isCompleted {
                    Text(item.name)
                        .strikethrough()
                        .foregroundColor(.gray)
                    if let date = item.completionDate {
                        let formatter = formattedDate(from: date.date)
                        Text("Date Completed: \(formatter)")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                } else {
                    Text(item.name)
                }
            }
            Spacer()
            Button {
                item.isCompleted.toggle()
                if item.isCompleted {
                    let itemDate = ItemDate()
                    item.completionDate = itemDate
                }
            } label: {
                Image(systemName: item.isCompleted ? "checkmark.circle" : "circle")
                    .foregroundColor(.green)
                    .accessibilityLabel("Toggle Item Completion")
            }
        }
    }
}
// #Preview {
//    GroceryList()
// }
