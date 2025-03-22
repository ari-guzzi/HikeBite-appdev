//
//  BottomMountain.swift
//  HikeBite
//
//  Created by Ari Guzzi on 3/15/25.
//

import SwiftUI

struct BottomMountain: View {
    var body: some View {
        Image("transparentBackgroundAbstractmountain")
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: UIScreen.main.bounds.width, height: 114)
            .clipped()
            .opacity(0.2)
    }
}

#Preview {
    BottomMountain()
}
