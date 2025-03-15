//
//  TripCardView.swift
//  HikeBite
//
//  Created by Ari Guzzi on 2/23/25.
//

import SwiftUI

struct TripCardView: View {
    var trip: Trip
    
    var body: some View {
        ZStack {
        // Background image independent of other content
//        Image("topolines")
//            .resizable()
//            .aspectRatio(contentMode: .fill)
//            .frame(width: 510, height: 254)  // Set the desired frame for the background
//            .clipped()
//            .opacity(0.2)
//            .cornerRadius(9)  // Match corner radius if needed
//            .position(x: 155, y: 127)  // Center position in the parent frame
//        
        VStack(alignment: .leading, spacing: 0) {
            ZStack(alignment: .bottom) {
                
                Rectangle()
                    .foregroundColor(.clear)
                    .frame(width: 310, height: 254)
                    .background(
                        Image("backpacking")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 310, height: 254)
                            .clipped()
                    )
                    .cornerRadius(9)
                    .shadow(color: .black.opacity(0.25), radius: 2, x: 0, y: 4)
                
                Rectangle()
                    .foregroundColor(.clear)
                    .frame(width: 310, height: 177)
                    .background(
                        LinearGradient(
                            stops: [
                                Gradient.Stop(color: .white.opacity(0), location: 0.00),
                                Gradient.Stop(color: .white.opacity(0.5), location: 0.65),
                                Gradient.Stop(color: .white, location: 1.00),
                            ],
                            startPoint: UnitPoint(x: 0.5, y: 0),
                            endPoint: UnitPoint(x: 0.5, y: 0.62)
                        )
                    )
                    .cornerRadius(9)
                    .shadow(color: .black.opacity(0.25), radius: 2, x: 0, y: 4)
                
                VStack(alignment: .leading) {
                    Text(trip.name)
                        .font(.custom("Area Normal", size: 24))
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                        .frame(width: 277, height: 25, alignment: .leading)
                    
                    HStack {
                        Spacer()
                        Text("View trip")
                            .font(.custom("Fields", size: 16))
                            .fontWeight(.medium)
                            .foregroundColor(Color(red: 0.02, green: 0.31, blue: 0.23))
                            .frame(width: 93, height: 18.66764, alignment: .center)
                        Image(systemName: "arrow.right")
                            .frame(width: 24, height: 24)
                    }
                    .background(Color.white) // Ensure text is easily readable on the gradient
                    .cornerRadius(4)
                }
                .padding(.horizontal)
                .padding(.bottom)
            }
            }
        }
        .padding() // Add padding around the entire VStack if needed
    }
}
