//
//  FunnyLines.swift
//  HikeBite
//
//  Created by Ari Guzzi on 3/15/25.
//

import SwiftUI

struct FunnyLines: View {
    var body: some View {
        Image("topolines")
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: 405, height: 350)
            .clipped()
            .opacity(0.1)
            .padding(0)
            .contentShape(Rectangle())
            .layoutPriority(1)
            .blur(radius: 2)
    }
}

#Preview {
    FunnyLines()
}
