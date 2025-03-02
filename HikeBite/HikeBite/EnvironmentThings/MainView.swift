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
    @StateObject private var tripManager = TripManager()
    @State private var selectedTab: Int = 0
    @State private var showCreateTrip = false
    @State private var showTripPicker = false
    @State var mealEntriesState: [MealEntry] = []
    @State private var selectedTrip: Trip? { 
        didSet {
            if selectedTrip != nil {
                selectedTab = 2
            }
        }
    }
    var body: some View {
        TabView(selection: $selectedTab) {
            ProfileView(tripManager: tripManager, selectedTrip: $selectedTrip, selectedTab: $selectedTab)
                .tabItem { Label("Profile", systemImage: "person") }
                .tag(0)

            Templates(selectedTrip: $selectedTrip, selectedTab: $selectedTab, fetchMeals: fetchMeals)
                .tabItem {
                    Label("Templates", systemImage: "newspaper")
                }
                .tag(1)
            Group {
                if let trip = selectedTrip {
                    PlansView(
                        tripManager: tripManager,
                        numberOfDays: trip.days,
                        tripDate: trip.date,
                        selectedTrip: $selectedTrip,
                        modelContext: modelContext,
                        selectedTab: $selectedTab
                    )
                } else {
                    VStack {
                        HStack {
                            Text("Select Trip")
                            TripPicker(selectedTrip: $selectedTrip, tripManager: tripManager)
                        }
                        Button("Create a New Trip") {
                            showCreateTrip = true
                        }
                    }
                }
            }
            .tabItem {
                Label("Trips", systemImage: "list.bullet.rectangle.fill")
            }
            .tag(2)

            ContentView(selectedTrip: $selectedTrip)
                .tabItem {
                    Label("Meals", systemImage: "book.fill")
                }
                .tag(3)
        }
        .onAppear {
            tripManager.fetchTrips(modelContext: modelContext)
        }
        .sheet(isPresented: $showCreateTrip) {
            CreatePlanView { name, days, date in
                let newTrip = Trip(name: name, days: days, date: date)
                modelContext.insert(newTrip)
                Task {
                    do {
                        try modelContext.save()
                        tripManager.fetchTrips(modelContext: modelContext)
                        DispatchQueue.main.async {
                            selectedTrip = newTrip
                            selectedTab = 2
                            showCreateTrip = false
                        }
                    } catch {
                        print("Failed to save trip: \(error)")
                    }
                }
            }
        }
    }
    func fetchMeals() {
        do {
            let fetchedMeals: [MealEntry] = try modelContext.fetch(FetchDescriptor<MealEntry>())
            mealEntriesState = fetchedMeals
            print("✅ Meals successfully loaded: \(mealEntriesState.count)")
        } catch {
            print("❌ Failed to load meals: \(error.localizedDescription)")
        }
    }
}
