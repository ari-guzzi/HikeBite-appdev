//
//  ItemRow.swift
//  DataFramework
//
//  Created by Ari Guzzi on 11/18/24.
//

import SwiftUI

struct ItemRow: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable var item: ToDoItem
    var body: some View {
        HStack {
            VStack {
                Button {
                    item.isComplete = true
                } label: {
                    Label("Complete Task",
                          systemImage: item.isComplete ? "checkmark.circle" : "circle")
                    .labelStyle(.iconOnly)
                }
                
                Text(item.title)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(4)
                    .overlay {
                        Rectangle()
                            .stroke(lineWidth: 2)
                    }
                Spacer()
                Button(role: .destructive) {
                    modelContext.delete(item)
                } label: {
                    Label("Delete", systemImage: "trash.fill")
                        .labelStyle(.iconOnly)
                }
            }
        }
        HStack {
            ForEach(item.tags, id:\.self) { tag in
                Text(String(tag.value))
                    .underline()
            }
        }
    }
}


//#Preview {
//    ItemRow()
//}
