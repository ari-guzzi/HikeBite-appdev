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
    var onTripCreated: (String, Int, Date) -> Void

    var body: some View {
        NavigationView {
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
                }
                .padding()

                DatePicker("Trip Date", selection: $tripDate, displayedComponents: .date)
                    .padding()

                Button(action: {
                    onTripCreated(tripName, numberOfDays, tripDate)
                }) {
                    Text("Start Planning")
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(tripName.isEmpty ? Color.gray : Color.blue)
                        .cornerRadius(10)
                        .padding()
                }
                .disabled(tripName.isEmpty)

                Spacer()
            }
            .padding()
        }
    }
}
