//
//  ToDoItemPage.swift
//  DataFramework
//
//  Created by Ari Guzzi on 12/2/24.
//

import SwiftUI

struct ToDoItemPage: View {
    let item: ToDoItem
    
    var body: some View {
        VStack {
            Text("Great Item Page")
                .font(.callout)
            Spacer()
            Text(item.title)
                .font(.title3)
            Spacer()
        }
    }
}
//
//#Preview {
//    ToDoItemPage()
//}
