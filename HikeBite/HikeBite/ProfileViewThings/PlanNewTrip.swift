//
//  PlanNewTrip.swift
//  HikeBite
//
//  Created by Ari Guzzi on 3/29/25.
//

import SwiftUI

struct PlanNewTrip: View {
    var body: some View {
        VStack {
            Text("Plan a new trip")
                .font(
                    Font.custom("FONTSPRINGDEMO-FieldsDisplaySemiBoldRegular", size: 24)
                )
                .multilineTextAlignment(.center)
                .foregroundColor(.black)
            ZStack {
                Rectangle()
                    .foregroundColor(.clear)
                    .frame(width: 360, height: 58)
                    .background(.white)
                    .cornerRadius(9)
                HStack {
                    Text("Trip name")
                        .font(
                            Font.custom("Area Normal", size: 16)
                                .weight(.bold)
                        )
                        .multilineTextAlignment(.center)
                        .foregroundColor(Color(red: 0.15, green: 0.6, blue: 0.38).opacity(0.4))
                    Spacer()
                    Rectangle()
                        .foregroundColor(.clear)
                        .frame(width: 4, height: 25)
                        .background(Color(red: 0.15, green: 0.6, blue: 0.38).opacity(0.4))
                        .cornerRadius(9)
                    Spacer()
                    Text("Date")
                        .font(
                            Font.custom("Area Normal", size: 16)
                                .weight(.bold)
                        )
                        .multilineTextAlignment(.center)
                        .foregroundColor(Color(red: 0.15, green: 0.6, blue: 0.38).opacity(0.4))
                    Spacer()
                    Rectangle()
                        .foregroundColor(.clear)
                        .frame(width: 4, height: 25)
                        .background(Color(red: 0.15, green: 0.6, blue: 0.38).opacity(0.4))
                        .cornerRadius(9)
                    Spacer()
                    Text("# of days")
                        .font(
                            Font.custom("Area Normal", size: 16)
                                .weight(.bold)
                        )
                        .multilineTextAlignment(.center)
                        .foregroundColor(Color(red: 0.15, green: 0.6, blue: 0.38).opacity(0.4))
                }
                .frame(width: 300)
            }
        }
    }
}


#Preview {
    PlanNewTrip()
}
