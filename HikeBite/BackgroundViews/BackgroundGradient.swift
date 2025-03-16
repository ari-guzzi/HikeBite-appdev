//
//  BackgroundGradient.swift
//  HikeBite
//
//  Created by Ari Guzzi on 3/15/25.
//

import SwiftUI

struct BackgroundGradient: View {
    var body: some View {
        LinearGradient(gradient: Gradient(colors: [.white, Color("AccentLight")]),
                       startPoint: .top,
                       endPoint: .bottom)
        .edgesIgnoringSafeArea([.top, .leading, .trailing])
    }
}

#Preview {
    BackgroundGradient()
}
