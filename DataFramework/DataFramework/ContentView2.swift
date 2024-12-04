//
//  ContentView.swift
//  DataFramework
//
//  Created by Ari Guzzi on 11/18/24.
//

import SwiftUI
import SwiftData

struct ContentView2: View {
    @Environment(\.modelContext) private var modelContext
    @State private var title = ""
    @Query private var items: [ToDoItem]
    @Query private var tags: [ItemTag]
    @State private var path: [ToDoItem] = []
    
    var body: some View {
        NavigationStack(path: $path) {
            VStack {
                itemList
                Text("all tags below:")
                tagList
                    .padding()
            }
            .navigationDestination(for: ToDoItem.self) { item in
                ToDoItemPage(item: item)
            }
        }
        .onOpenURL { url in
            handleDeepLink(url)
        }
//        .onChange(of: items) {
    }
    var itemList: some View {
        ScrollView {
            ForEach(items.filter{!$0.isComplete}) { item in
                ItemRow(item: item)
            }
            TextField("Add Item", text: $title)
                .textFieldStyle(.roundedBorder)
            Button("Add Item") {
                let item = ToDoItem(title: title)
                modelContext.insert(item)
                title = ""
            }
            .buttonStyle(.borderedProminent)
            .disabled(title.isEmpty)
            
            ForEach(items.filter { $0.isComplete}) { item in
                ItemRow(item: item)
            }
        }
    }
    var tagList: some View {
        ScrollView(.horizontal) {
            HStack {
                ForEach(tags) { tag in
                    Text(String(tag.value))
                        .underline()
                }
            }
        }
    }
    func handleDeepLink(_ url:URL) {
        if url.host == "newtask" {
            newRandomItemCreateAndReturn();
        } else if url.host == "navigate" {
                let item = newRandomItemCreateAndReturn()
                path.append(item)
        }
    }
    
    @discardableResult
    func newRandomItemCreateAndReturn() -> ToDoItem {
        let noun = ["Capstone", "15th St.", "Pearl", "Boulder", "Buffs"].randomElement()!
        let number = Int.random(in: 1000 ... 9999)
        let title = noun + " " + number.description
        
        let newItem = ToDoItem(title: title)
        modelContext.insert(newItem)
        return newItem
    }
} //content view

#Preview {
    ContentView()
        .modelContainer(
            for: ToDoItem.self,
            inMemory: true,
            isAutosaveEnabled: true
        )
}
