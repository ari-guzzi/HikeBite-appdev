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
        NavigationView {
            Form {
                Section(header: Text("New Plan Name")) {
                    TextField("Enter plan name", text: $newPlanName)
                }

                Section(header: Text("Number of Days")) {
                    Stepper("\(newPlanDays) Days", value: $newPlanDays, in: 1...10)
                }

                Section(header: Text("Start Date")) {
                    DatePicker("Select Date", selection: $newPlanDate, displayedComponents: .date)
                }
            }
            .navigationTitle("Duplicate Plan")
            .navigationBarItems(
                leading: Button("Cancel") { dismiss() },
                trailing: Button("Duplicate") {
                    guard !newPlanName.isEmpty else { return }
                    duplicatePlan(newPlanName, newPlanDays, newPlanDate)
                    dismiss()
                }
            )
        }
    }
}
