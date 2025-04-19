//
//  DuplicatePlanButton.swift
//  HikeBite
//
//  Created by Ari Guzzi on 4/19/25.
//

import SwiftUI

struct DuplicatePlanButton: View {
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack {
                Image(systemName: "doc.on.doc")
                    .foregroundColor(Color("AccentColor"))
                Text("Duplicate Plan")
                    .foregroundColor(Color("AccentColor"))
            }
            .padding(8)
            .background(Color.white)
            .cornerRadius(8)
            .shadow(radius: 3)
        }
        .buttonStyle(PlainButtonStyle())
    }
}
