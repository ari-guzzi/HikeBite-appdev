//
//  ProfileView.swift
//  HikeBite
//
//  Created by Ari Guzzi on 1/17/25.
//
import SwiftData
import SwiftUI

struct ProfileView: View {
    @Environment(\.modelContext) private var modelContext
    @ObservedObject var tripManager: TripManager
    @Binding var selectedTrip: Trip?
    @Binding var selectedTab: Int
    @Binding var showLogin: Bool
    @EnvironmentObject var viewModel: AuthViewModel

    var upcomingTrips: [Trip] {
        let now = Date()
        let upcoming = tripManager.trips.filter { $0.date >= now }
        print("⏳ Filtering upcoming trips: \(upcoming.count) found")
        return upcoming
    }

    var previousTrips: [Trip] {
        let now = Date()
        let past = tripManager.trips.filter { $0.date < now }
        print("⏳ Filtering previous trips: \(past.count) found")
        return past
    }

    var body: some View {
        NavigationStack {
            VStack {
                if viewModel.currentUser == nil {
                    Button() {
                        showLogin = true
                    } label: {
                        HStack(spacing: 3) {
                            Text("Sign In / Sign Up!")
                                .fontWeight(.bold)
                        }
                        .font(.system(size: 14))
                    }
                }
                    ProfileNameView()
                    NavigationLink(destination: GroceryList()) {
                        Text("View Grocery List")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding()
                    if tripManager.trips.isEmpty {
                        Text("No trips yet. Create a new one!")
                            .foregroundColor(.gray)
                            .padding()
                    } else {
                        ScrollView {
                            ScrollView {
                                if !upcomingTrips.isEmpty {
                                    Text("Upcoming Trips")
                                        .font(.largeTitle)
                                        .padding(.leading, 20)
                                    
                                    ScrollView(.horizontal, showsIndicators: false) {
                                        HStack(spacing: 10) {
                                            ForEach(upcomingTrips) { trip in
                                                Button(action: {
                                                    selectedTrip = trip
                                                    selectedTab = 2
                                                }) {
                                                    TripCardView(trip: trip)
                                                }
                                            }
                                        }
                                        .padding(.horizontal)
                                    }
                                }
                            }
                            if !previousTrips.isEmpty {
                                Text("Previous Trips")
                                    .font(.largeTitle)
                                    .padding(.leading, 20)
                                
                                List {
                                    ForEach(previousTrips) { trip in
                                        HStack {
                                            VStack(alignment: .leading) {
                                                Text(trip.name).font(.headline)
                                                Text(trip.date.formatted(date: .long, time: .omitted))
                                                    .font(.subheadline)
                                                    .foregroundColor(.gray)
                                            }
                                            Spacer()
                                            Button(action: {
                                                selectedTrip = trip
                                                selectedTab = 2
                                            }) {
                                                Image(systemName: "chevron.right")
                                                    .foregroundColor(.gray)
                                            }
                                        }
                                        .swipeActions {
                                            Button(role: .destructive) {
                                                deleteTrip(trip)
                                            } label: {
                                                Label("Delete", systemImage: "trash")
                                            }
                                        }
                                    }
                                    .onDelete(perform: deleteTripAt)
                                }
                                .frame(height: 250)
                            }
                            
                        }
                    }
                }
            }
        .onAppear {
            print("🔄 ProfileView appeared. Fetching trips...")
            tripManager.fetchTrips(modelContext: modelContext)
        }
    }
    private func deleteTripAt(_ offsets: IndexSet) {
        for index in offsets {
            let tripToDelete = previousTrips[index]
            deleteTrip(tripToDelete) 
        }
    }
    private func deleteTrip(_ trip: Trip) {
        modelContext.delete(trip)
        do {
            try modelContext.save()
            print("✅ Deleted trip: \(trip.name)")
        } catch {
            print("❌ Failed to delete trip: \(error.localizedDescription)")
        }
        tripManager.trips.removeAll { $0.id == trip.id }
    }
}
