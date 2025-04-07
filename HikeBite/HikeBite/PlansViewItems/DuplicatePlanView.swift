//
//  DuplicatePlanView.swift
//  HikeBite
//
//  Created by Ari Guzzi on 2/23/25.
//

import SwiftUI

struct DuplicatePlanView: View {
    @State private var newPlanName: String = ""
    @State private var newPlanDays: Int = 3
    @State private var newPlanDate: Date = Date()
    var originalTrip: Trip
    var duplicatePlan: (String, Int, Date) -> Void
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        ZStack {
            Image("topolines")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .edgesIgnoringSafeArea(.all)
                .opacity(0.08)
                .blur(radius: 2)
            VStack {
                Image("vector")
                Text("Duplicate this Trip for a New Plan")
                    .font(Font.custom("FONTSPRINGDEMO-FieldsDisplaySemiBoldRegular", size: 32))
                    .multilineTextAlignment(.center)
                    .foregroundColor(.black)
                    .frame(width: 369, alignment: .top)
                    .padding(.bottom, 6)
                Text("Trip Name")
                    .font(
                        Font.custom("FONTSPRINGDEMO-FieldsDisplayMediumRegular", size: 32)
                    )
                    .foregroundColor(Color(red: 0, green: 0.41, blue: 0.22))
                    .frame(width: 326, alignment: .leading)
                HStack {
                    TextField("Enter trip name", text: $newPlanName)
                        .font(Font.custom("Area Normal", size: 16))
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal)
                        .frame(width: 326, alignment: .leading)
                }
                ZStack {
                    Rectangle()
                        .foregroundColor(.clear)
                        .frame(width: 357, height: 100)
                        .background(Color.white)
                        .cornerRadius(9)
                        .shadow(color: .black.opacity(0.25), radius: 2, x: 0, y: 4)
                    HStack {
                        Text("Trip Length:")
                            .font(Font.custom("FONTSPRINGDEMO-FieldsDisplayMediumRegular", size: 24))
                            .foregroundColor(Color(red: 0, green: 0.41, blue: 0.22))
                        Text("\(newPlanDays) days")
                            .font(Font.custom("FONTSPRINGDEMO-FieldsDisplayMediumRegular", size: 24))
                            .foregroundColor(Color(red: 0, green: 0.41, blue: 0.22))
                        Stepper("", value: $newPlanDays, in: 1...14)
                            .labelsHidden()
                    }
                    .padding(.horizontal, 10)
                }
                .padding()
                ZStack {
                    Rectangle()
                        .foregroundColor(.clear)
                        .frame(width: 357, height: 100)
                        .background(Color.white)
                        .cornerRadius(9)
                        .shadow(color: .black.opacity(0.25), radius: 2, x: 0, y: 4)
                    DatePicker("Start Date", selection: $newPlanDate, displayedComponents: .date)
                        .font(
                            Font.custom("FONTSPRINGDEMO-FieldsDisplayMediumRegular", size: 32)
                        )
                        .foregroundColor(Color(red: 0, green: 0.41, blue: 0.22))
                        .frame(width: 326, alignment: .leading)
                        .padding()
                }
                Button(action: {
                    guard !newPlanName.isEmpty else { return }
                    duplicatePlan(newPlanName, newPlanDays, newPlanDate)
                    dismiss()
                }) { Text("Duplicate Trip")
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(newPlanName.isEmpty ? Color.gray : Color("AccentColor"))
                        .cornerRadius(10)
                        .padding()
                }
                .disabled(newPlanName.isEmpty)
                .frame(width: 326, alignment: .leading)
                Spacer()
            }
        }
    }
}
