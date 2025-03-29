//
//  CreateTripView.swift
//  HikeBite
//
//  Created by Ari Guzzi on 2/9/25.
//
import SwiftUI

struct CreateTripView: View {
    @State private var tripName: String = ""
    @State private var numberOfDays: Int = 3
    @State private var tripDate: Date = Date()
    @State private var warningMessage: String?
    var templateMaxDays: Int
    var onTripCreated: (String, Int, Date) -> Void
    
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
                Text("Create a New Trip Plan")
                    .font(Font.custom("FONTSPRINGDEMO-FieldsDisplaySemiBoldRegular", size: 32))
                    .multilineTextAlignment(.center)
                    .foregroundColor(.black)
                    .frame(width: 369, alignment: .top)
                    .padding(.bottom, 6)
                Text("Trip Name")
                    .font(Font.custom("FONTSPRINGDEMO-FieldsDisplayMediumRegular", size: 32))
                    .foregroundColor(Color(red: 0, green: 0.41, blue: 0.22))
                    .frame(width: 326, alignment: .leading)
                TextField("Enter trip name", text: $tripName)
                    .font(Font.custom("Area Normal", size: 16))
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                    .frame(width: 326, alignment: .leading)
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
                        
                        Text("\(numberOfDays) days")
                            .font(Font.custom("FONTSPRINGDEMO-FieldsDisplayMediumRegular", size: 24))
                            .foregroundColor(Color(red: 0, green: 0.41, blue: 0.22))
                        
                        Stepper("", value: $numberOfDays, in: 1...14)
                            .labelsHidden()
                    }
                    .padding(.horizontal, 10)
                }
                .padding()
                .onChange(of: numberOfDays) { newValue in
                    if newValue > templateMaxDays {
                        warningMessage = "❌ This template only supports up to \(templateMaxDays) days."
                    } else {
                        warningMessage = nil
                    }
                }
                ZStack {
                    Rectangle()
                        .foregroundColor(.clear)
                        .frame(width: 357, height: 100)
                        .background(Color.white)
                        .cornerRadius(9)
                        .shadow(color: .black.opacity(0.25), radius: 2, x: 0, y: 4)
                    
                    DatePicker("Start Date", selection: $tripDate, displayedComponents: .date)
                        .font(Font.custom("FONTSPRINGDEMO-FieldsDisplayMediumRegular", size: 32))
                        .foregroundColor(Color(red: 0, green: 0.41, blue: 0.22))
                        .frame(width: 326, alignment: .leading)
                        .padding()
                }
                if let warningMessage = warningMessage {
                    Text(warningMessage)
                        .font(.headline)
                        .foregroundColor(.red)
                        .padding(.top, 5)
                        .transition(.opacity)
                }
                Button(action: {
                    if numberOfDays > templateMaxDays {
                        warningMessage = "❌ Cannot create trip. Requested \(numberOfDays) days, but the template only has \(templateMaxDays) days."
                    } else {
                        warningMessage = nil
                        onTripCreated(tripName, numberOfDays, tripDate)
                    }
                }) {
                    Text("Create this Trip Plan")
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(tripName.isEmpty || numberOfDays > templateMaxDays ? Color.gray : Color("AccentColor"))
                        .cornerRadius(10)
                        .padding()
                }
                .disabled(tripName.isEmpty || numberOfDays > templateMaxDays)
                .frame(width: 326, alignment: .leading)
                Spacer()
            }
        }
    }
}

