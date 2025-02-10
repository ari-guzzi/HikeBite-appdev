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
    @Query private var trips: [Trip]
    var upcomingTrips: [Trip] {
        trips.filter { $0.date >= Date() }
    }
    var previousTrips: [Trip] {
        trips.filter { $0.date < Date() }
    }
    var body: some View {
        NavigationStack {
            VStack {
                ProfileNameView()
                if trips.isEmpty {
                    Text("No trips yet. Create a new one!")
                        .foregroundColor(.gray)
                        .padding()
                } else {
                    ScrollView {
                        if !upcomingTrips.isEmpty {
                            Text("Upcoming Trips")
                                .font(.largeTitle)
                                .padding(.leading, 20)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 10) {
                                    ForEach(upcomingTrips) { trip in
                                        TripCardView(trip: trip)
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                        if !previousTrips.isEmpty {
                            Text("Previous Trips")
                                .font(.largeTitle)
                                .padding(.leading, 20)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            List(previousTrips) { trip in
                                NavigationLink(destination: PlansView(tripName: trip.name, numberOfDays: trip.days, tripDate: trip.date)) {
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
            print("🔄 ProfileView refreshed - Found \(trips.count) trips.")
        }
    }
        func forceRefresh() {
            Task {
                try? await Task.sleep(nanoseconds: 200_000_000)  // 0.2s delay
                print("🔄 Forcing ProfileView to refresh - Found \(trips.count) trips.")
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
