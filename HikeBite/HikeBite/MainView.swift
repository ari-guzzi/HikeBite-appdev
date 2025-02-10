//
//  MainView.swift
//  HikeBite
//
//  Created by Ari Guzzi on 1/13/25.
//
import SwiftData
import SwiftUI

struct MainView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var trips: [Trip]  // ✅ Fetch saved trips

    @State private var selectedTab: Int = 0
    @State private var showCreateTrip = false

    var body: some View {
        TabView(selection: $selectedTab) {
            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                }
                .tag(0)

            Templates()
                .tabItem {
                    Label("Templates", systemImage: "newspaper")
                }
                .tag(1)

            if let latestTrip = trips.last {
                PlansView(tripName: latestTrip.name, numberOfDays: latestTrip.days, tripDate: latestTrip.date)
                    .tabItem {
                        Label("Trips", systemImage: "list.bullet.rectangle.fill")
                    }
                    .tag(2)
            } else {
                Button("Create a Trip") {
                    showCreateTrip = true
                }
                .tabItem {
                    Label("Trips", systemImage: "list.bullet.rectangle.fill")
                }
                .tag(2)
            }

            ContentView()
                .tabItem {
                    Label("Meals", systemImage: "book.fill")
                }
                .tag(3)
        }
        .sheet(isPresented: $showCreateTrip) {
            CreatePlanView { name, days, date in
                let newTrip = Trip(name: name, days: days, date: date)
                modelContext.insert(newTrip)
                Task {
                    do {
                        try modelContext.save()
                        print("✅ Trip successfully saved")
                        let fetchedTrips: [Trip] = try modelContext.fetch(FetchDescriptor<Trip>())
                        print("📂 All trips in SwiftData: \(fetchedTrips.count)")
                        for trip in fetchedTrips {
                            print("📌 Trip: \(trip.name), \(trip.days) days, Date: \(trip.date)")
                        }
                        try? await Task.sleep(nanoseconds: 200_000_000)
                        DispatchQueue.main.async {
                            selectedTab = 2
                            showCreateTrip = false
                        }
                    } catch {
                        print("❌ Failed to save trip: \(error.localizedDescription)")
                    }
                }
            }
        }
    }
}

#Preview {
    MainView()
}
