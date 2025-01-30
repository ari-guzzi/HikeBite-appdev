//
//  ProfileView.swift
//  HikeBite
//
//  Created by Ari Guzzi on 1/17/25.
//

import SwiftUI

struct ProfileView: View {
    var body: some View {
        NavigationStack {
            VStack {
                ProfileNameView()
                NavigationLink(destination: GroceryList()) {
                    Label("Grocery List", systemImage: "cart.fill")
                        .padding()
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(8)
                }
                UpcomingTripsView()
                PreviousTripsView()
            }
        }
    }
}

#Preview {
    ProfileView()
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
