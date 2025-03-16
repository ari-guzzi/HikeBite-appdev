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
    init(tripManager: TripManager, selectedTrip: Binding<Trip?>, selectedTab: Binding<Int>, showLogin: Binding<Bool>) {
        self._tripManager = ObservedObject(initialValue: tripManager)
            self._selectedTrip = selectedTrip
            self._selectedTab = selectedTab
            self._showLogin = showLogin
        // This will make the background of all UITableViews in the app transparent.
        UITableView.appearance().backgroundColor = .clear
        UITableViewCell.appearance().backgroundColor = .clear
        UITableView.appearance().separatorStyle = .none
//        for familyName in UIFont.familyNames {
//            print(familyName)
//            for fontName in UIFont.fontNames(forFamilyName: familyName) {
//                print("--\(fontName)")
//            }
//        }
    }
    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(gradient: Gradient(colors: [.white, Color("AccentLight")]),
                               startPoint: .top,
                               endPoint: .bottom)
                .edgesIgnoringSafeArea([.top, .leading, .trailing])
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
                            .font(Font.custom("FONTSPRINGDEMO-FieldsDisplayMediumRegular", size: 16))
                            .foregroundColor(.black)
                            .padding(10)  // Adjust padding to control the size around the text
                            .background(
                                RoundedRectangle(cornerRadius: 9)
                                    .stroke(Color(red: 0.15, green: 0.6, blue: 0.38), lineWidth: 1)
                                    .background(Color.white)  // Ensure the background color fills the rounded rectangle
                                    .shadow(color: .black.opacity(0.25), radius: 2, x: 0, y: 4)
                            )
                            .cornerRadius(9)

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
                                    ZStack() {
                                        FunnyLines()
                                        VStack {
                                            HStack {
                                                Text("Upcoming Trips")
                                                    .font(Font.custom("Area Normal", size: 24).weight(.bold))
                                                    .foregroundColor(Color(red: 0.17, green: 0.17, blue: 0.17))
                                                    .padding(.leading, 30)
                                                Spacer()
                                            }
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
                                }
                            }
                            ZStack(alignment: .bottom) {
                                Image("transparentBackgroundAbstractmountain")
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 405, height: 114)
                                    .clipped()
                                    .opacity(0.2)
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
    } // body
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
    private func tripRow(trip: Trip) -> some View {
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
                    Image(systemName: "chevron.right").foregroundColor(.gray)
                }
            }
            .padding()
            .background(Color.white)
            .cornerRadius(10)
            .shadow(color: .gray, radius: 3, x: 0, y: 2)
            .listRowBackground(Color.clear)
    }
}
