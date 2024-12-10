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
                    HStack {
                        Text(item.name)
                            .foregroundColor(.black)
                        Spacer()
                        Button {
                            item.isCompleted.toggle()
                        } label: {
                            Image(systemName: item.isCompleted ? "checkmark.circle" : "circle")
                                .foregroundColor(.green)
                                .accessibilityLabel("Toggle Item Completion")
                        }
                    }
                }
                .onDelete(perform: deleteItems)
            }
            Spacer()
            Text("Completed")
                .padding()
            List {
                ForEach(items.filter { $0.isCompleted}) { item in
                    HStack {
                        VStack {
                            Text(item.name)
                                .strikethrough()
                                .foregroundColor(.gray)
                            if let date = item.completionDate {
                                let formatter = formattedDate(from: date.date)
                                Text("Date Completed: \(formatter)")
                            }
                        }
                        Spacer()
                        Button {
                            let itemDate = ItemDate()
                            item.completionDate = itemDate
                            item.isCompleted.toggle()
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
                Text(item.name)
                    .strikethrough()
                    .foregroundColor(.gray)
                if let date = item.completionDate {
                    let formatter = formattedDate(from: date.date)
                    Text("Date Completed: \(formatter)")
                }
            }
            Spacer()
            Button {
                let itemDate = ItemDate()
                item.completionDate = itemDate
                item.isCompleted.toggle()
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
