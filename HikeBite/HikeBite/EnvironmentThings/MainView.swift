//
//  MainView.swift
//  HikeBite
//
//  Created by Ari Guzzi on 1/13/25.
//
import SwiftData
import SwiftUI

struct MainView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    @Environment(\.modelContext) private var modelContext
    @StateObject private var tripManager = TripManager()
    @State private var selectedTab: Int = 0
    @State private var showCreateTrip = false
    @State private var showTripPicker = false
    @State private var showLogin = false
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
            ProfileView(tripManager: tripManager, selectedTrip: $selectedTrip, selectedTab: $selectedTab, showLogin: $showLogin)
                .tabItem { Label("Profile", systemImage: "person.fill") }
                .tag(0)

            Templates(selectedTrip: $selectedTrip, selectedTab: $selectedTab, fetchMeals: fetchMeals)
                .tabItem {
                    Label("Templates", systemImage: "list.bullet.rectangle.portrait")
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
                Label("Trips", systemImage: "map.fill")
            }
            .tag(2)

            ContentView(selectedTrip: $selectedTrip)
                .tabItem {
                    Label("Meals", systemImage: "fork.knife")
                }
                .tag(3)
        }
        .onAppear {
            tripManager.fetchTrips(modelContext: modelContext)
        }
        .sheet(isPresented: $showLogin) { // Show LoginView as a sheet when needed
            LoginView(showLogin: $showLogin)
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
