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
                ProfileNameView()

                if tripManager.trips.isEmpty {
                    Text("No trips yet. Create a new one!")
                        .foregroundColor(.gray)
                        .padding()
                } else {
                    ScrollView {
                        if !upcomingTrips.isEmpty {
                            Text("Upcoming Trips")
                                .font(.largeTitle)
                                .padding(.leading, 20)
                            HStack(spacing: 10) {
                            List(upcomingTrips) { trip in
                                Button(action: {
                                    selectedTrip = trip
                                    selectedTab = 2
                                }) {
                                    TripCardView(trip: trip)
                                }
                                }
                            }
                            .frame(height: 250)  // Keeps List at a fixed height
                        }
                        if !previousTrips.isEmpty {
                            Text("Previous Trips")
                                .font(.largeTitle)
                                .padding(.leading, 20)
                            List(previousTrips) { trip in
                                Button(action: {
                                    selectedTrip = trip
                                    selectedTab = 2
                                }) {
                                    VStack(alignment: .leading) {
                                        Text(trip.name).font(.headline)
                                        Text(trip.date.formatted(date: .long, time: .omitted))
                                            .font(.subheadline)
                                            .foregroundColor(.gray)
                                    }
                                }
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
}
struct ProfileNameView: View {
    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                LinearGradient(gradient: Gradient(colors: [.blue, .white]), startPoint: .top, endPoint: .bottom)
                    .frame(height: 100)
                    .edgesIgnoringSafeArea(.top)
                HStack {
                    Image("profile")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 70, height: 70)
                        .clipShape(Circle())
                        .padding(.leading, 15)
                    VStack(alignment: .leading) {
                        Text("Sarah Sarahson")
                            .font(.title)
                        Text("Boulder, Colorado")
                            .font(.subheadline)
                    }
                    .padding(.leading, 10)
                    Spacer()
                }
            }
            .frame(height: 100)
        }
    }
}
struct UpcomingTripsView: View {
    var body: some View {
        HStack {
            Text("Upcoming Trips")
                .font(.largeTitle)
                .padding(.leading)
                .padding(.bottom, -5.0)
            Spacer()
        }
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 5) {
                UpcomingTripsPlaceHolder()
                UpcomingTripsPlaceHolder()
                UpcomingTripsPlaceHolder()
                UpcomingTripsPlaceHolder()
            }
        }
    }
}
struct UpcomingTripsPlaceHolder: View {
    var body: some View {
        VStack(spacing: -20) {
            Image("backpacking")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 150.0, height: 150)
                .scaledToFit()
            VStack(alignment: .leading) {
                Text("Trip Name")
                    .font(.caption)
                    .foregroundColor(Color.black)
                    .frame(width: 150, alignment: .center)
                Text("January 29, 2024")
                    .font(.caption2)
                    .foregroundColor(Color.black)
                    .frame(width: 150, alignment: .center)
            }
        }
    }
}

struct PreviousTripsView: View {
    let previousTrips = ["Previous Trip 1", "Previous Trip 2", "Previous Trip 3", "Previous Trip 4", "Previous Trip 5"]
    var body: some View {
        VStack {
            HStack {
                Text("Previous Trips")
                    .font(.largeTitle)
                    .padding(.leading, 20)
                Spacer()
            }
            .padding(.top)
            List(previousTrips, id: \.self) { previousTrip in
                HStack {
                    Text(previousTrip)
                        .font(.title3)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundColor(.gray)
                }
            }
            .listStyle(PlainListStyle())
        }
        .edgesIgnoringSafeArea(.all)
    }
}

struct TripCardView: View {
    var trip: Trip

    var body: some View {
        VStack(spacing: 0) {
            Image("backpacking")  // Replace with dynamic image if available
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 150.0, height: 150)
                .clipShape(RoundedRectangle(cornerRadius: 15))
            VStack(alignment: .center, spacing: 5) {
                Text(trip.name)
                    .font(.caption)
                    .foregroundColor(.black)
                    .frame(width: 150, alignment: .center)
                Text(trip.date.formatted(date: .long, time: .omitted))
                    .font(.caption2)
                    .foregroundColor(.gray)
                    .frame(width: 150, alignment: .center)
            }
            .padding(.vertical, 8)
            .frame(width: 150)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 3)
        .padding(.bottom, 10)
    }
}
