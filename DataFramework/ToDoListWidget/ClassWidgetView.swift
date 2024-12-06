//
//  ClassWidgetView.swift
//  DataFramework
//
//  Created by Ari Guzzi on 12/2/24.
//

import WidgetKit
import SwiftUI
import SwiftData

struct ClassWidgetView: View {
    @Query private var items: [GroceryItem]
    
    //var entry: Provider.Entry
    
    var body: some View {
        VStack(alignment: .leading) {
//            ForEach(items) { item in
//                Label(item.title, systemImage: "smallcircle.filled.circle");
                
//            }
        }
    }
}

#Preview {
    ClassWidgetView()
}
