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
        VStack {
            Text("Create a New Trip")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding()
            
            TextField("Enter trip name", text: $tripName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            HStack {
                Text("Number of Days: \(numberOfDays)")
                Spacer()
                Stepper("", value: $numberOfDays, in: 1...14)
                    .onChange(of: numberOfDays) { newValue in
                        if newValue > templateMaxDays {
                            warningMessage = "❌ This template only supports up to \(templateMaxDays) days."
                        } else {
                            warningMessage = nil
                        }
                    }
            }
            .padding()
            DatePicker("Trip Date", selection: $tripDate, displayedComponents: .date)
                .padding()
            if let warningMessage = warningMessage {
                Text(warningMessage)
                    .font(.headline)
                    .foregroundColor(.red)
                    .padding()
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
                Text("Start Planning")
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(tripName.isEmpty || numberOfDays > templateMaxDays ? Color.gray : Color.blue)
                    .cornerRadius(10)
                    .padding()
            }
            .disabled(tripName.isEmpty || numberOfDays > templateMaxDays)
            
            Spacer()
        }
        .padding()
        .animation(.easeInOut, value: warningMessage)
    }
}
