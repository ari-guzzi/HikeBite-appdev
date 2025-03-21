//
//  TripsView.swift
//  HikeBite
//
//  Created by Ari Guzzi on 3/15/25.
//

import SwiftUI

struct TripsView: View {
    @Environment(\.modelContext) private var modelContext
    @ObservedObject var tripManager: TripManager
    @Binding var selectedTrip: Trip?
    @State private var showCreatePlanSheet = false
    @Binding var selectedTab: Int
    @Binding var showLogin: Bool
    @EnvironmentObject var viewModel: AuthViewModel
    @State var numberOfDays: Int
    @State var tripDate: Date

    var upcomingTrips: [Trip] {
        let now = Date()
        let upcoming = tripManager.trips.filter { $0.date >= now }
        return upcoming
    }

    var previousTrips: [Trip] {
        let now = Date()
        let past = tripManager.trips.filter { $0.date < now }
        return past
    }
    init(tripManager: TripManager, selectedTrip: Binding<Trip?>, selectedTab: Binding<Int>, showLogin: Binding<Bool>, numberOfDays: Int, tripDate: Date) {
        self._tripManager = ObservedObject(initialValue: tripManager)
        self._selectedTrip = selectedTrip
        self._selectedTab = selectedTab
        self._showLogin = showLogin
        self.numberOfDays = numberOfDays
        self.tripDate = tripDate
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
                BackgroundGradient()
                VStack(spacing: 0) {
                    header
                    tripContent
                        .frame(width: UIScreen.main.bounds.width)
                }
            }
            .onAppear {
                print("🔄 ProfileView appeared. Fetching trips...")
                tripManager.fetchTrips(modelContext: modelContext)
            }
        }
        .sheet(isPresented: $showCreatePlanSheet) {
            CreatePlanView { name, days, date in
                saveNewPlan(name: name, days: days, date: date)
                tripManager.fetchTrips(modelContext: modelContext)
            }
        }
    } // body
    private var header: some View {
        HStack {
            Text("Trips")
                .font(
                    Font.custom("FONTSPRINGDEMO-FieldsDisplayExtraBoldRegular", size: 48)
                        .weight(.heavy)
                )
                .padding(.leading, 50)
                .foregroundColor(.black)
            Spacer()
            Button("New trip plan  + ", action: { showCreatePlanSheet = true })
                .padding([.top, .bottom], 4)
                .padding([.leading, .trailing], 10)
                .labelStyle(.titleOnly)
                .controlSize(.small)
                .background(Color(.systemGray5))
                .clipShape(Rectangle())
                .cornerRadius(20)
                .padding()
        }
    }
    private var tripContent: some View {
        Group {
            if tripManager.trips.isEmpty {
                Text("No trips yet. Create a new one!")
                    .foregroundColor(.gray)
                    .padding()
                Button(action: { showCreatePlanSheet = true }) {
                    HStack {
                        Text("Create New Trip Plan").foregroundColor(Color("AccentColor"))
                        Image(systemName: "plus.circle").foregroundColor(Color("AccentColor"))
                    }
                }
            } else {
                ScrollView {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 0) {
                            upcomingTripsView
                        }
                        ZStack(alignment: .bottom) {
                            BottomMountain()
                            if !previousTrips.isEmpty {
                                if !previousTrips.isEmpty {
                                    VStack(alignment: .leading) {
                                        Text("Previous Trips")
                                            .font(Font.custom("Area Normal", size: 24).weight(.bold))
                                            .foregroundColor(Color(red: 0.17, green: 0.17, blue: 0.17))
                                            .padding(.leading, 20)
                                        List(previousTrips) { trip in
                                            NavigationLink(
                                                destination: PlansView(
                                                    tripManager: tripManager,
                                                    numberOfDays: trip.days,
                                                    tripDate: trip.date,
                                                    selectedTrip: Binding(
                                                        get: { trip },
                                                        set: { _ in self.selectedTrip = trip }
                                                    ),
                                                    modelContext: modelContext,
                                                    selectedTab: $selectedTab)
                                            ) {
                                                tripRow(trip: trip)
                                            }
                                            .listStyle(.plain)
                                            .listRowBackground(Color.clear)
                                            .scrollIndicators(.hidden)

                                        }
                                        .scrollIndicators(.hidden)
                                        .background(Color.clear)
                                      .listStyle(PlainListStyle())
                                      .frame(height: 300)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    private var upcomingTripsView: some View {
        ZStack() {
            FunnyLines()
            VStack {
                if !upcomingTrips.isEmpty {
                    VStack(alignment: .leading, spacing: 0) {
                        HStack(spacing: 10){
                            Text("Upcoming Trips")
                                .font(Font.custom("Area Normal", size: 24).weight(.bold))
                                .foregroundColor(Color(red: 0.17, green: 0.17, blue: 0.17))
                                .padding(.leading, 30)
                            Spacer()
                        }
                        .padding(0)
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 15) {
                                ForEach(upcomingTrips) { trip in
                                    NavigationLink(
                                        destination: PlansView(tripManager: tripManager,
                                                               numberOfDays: trip.days,
                                                               tripDate: trip.date,
                                                               selectedTrip: $selectedTrip,
                                                               modelContext: modelContext,
                                                               selectedTab: $selectedTab)
                                    ) {
                                        UpcomingTripCardPlansView(trip: trip)
                                            .onAppear {
                                                self.selectedTrip = trip
                                            }
                                    }
                                    .simultaneousGesture(TapGesture().onEnded {
                                        self.selectedTrip = trip
                                    })
                                }
                            }
                        }
                            .padding(.horizontal)
                        }
                    }
                Button(action: { showCreatePlanSheet = true }) {
                    PlanNewTrip()
                    .padding()
                }
            }
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
    private func tripRow(trip: Trip) -> some View {
            HStack {
                VStack(alignment: .leading) {
                    Text(trip.name).font(
                        Font.custom("Area Normal", size: 16)
                        .weight(.heavy)
                        )
                        .multilineTextAlignment(.center)
                        .foregroundColor(.black)
                    Text(trip.date.formatted(date: .long, time: .omitted))
                        .font(
                        Font.custom("Fields", size: 16)
                        .weight(.medium)
                        )
                        .multilineTextAlignment(.center)
                        .foregroundColor(.black)
                }
                .padding()
                Spacer()
//                Button(action: {
//                    selectedTrip = trip
//                    selectedTab = 2
//                }) {
//                    Image(systemName: "calendar.circle.fill").foregroundColor(.black).padding()
//                }
            }
            .frame(width: UIScreen.main.bounds.width - 40, height: 56)
                .background(Color.white)
                .cornerRadius(9)
                .shadow(color: .black.opacity(0.25), radius: 2, x: 0, y: 4)
                .listRowInsets(EdgeInsets())
                //.padding(.horizontal, 16)
                .padding(.vertical, 3)
            .listRowBackground(Color.clear)
    }
    
    private func saveNewPlan(name: String, days: Int, date: Date) {
        do {
            let newTrip = Trip(name: name, days: days, date: date)
            modelContext.insert(newTrip)
            try modelContext.save()
            print("✅ New trip saved successfully")
            DispatchQueue.main.async {
                self.selectedTrip = newTrip
                self.numberOfDays = newTrip.days
                self.tripDate = newTrip.date
                showCreatePlanSheet = false
            }
        } catch {
            print("❌ Failed to save trip: \(error.localizedDescription)")
        }
    }
    private struct PlanNewTrip: View {
        var body: some View {
            VStack {
                Text("Plan a new trip")
                    .font(
                        Font.custom("Area Normal", size: 24)
                            .weight(.bold)
                    )
                    .multilineTextAlignment(.center)
                    .foregroundColor(.black)
                ZStack {
                    Rectangle()
                        .foregroundColor(.clear)
                        .frame(width: 360, height: 58)
                        .background(.white)
                        .cornerRadius(9)
                    HStack {
                        Text("Trip name")
                            .font(
                                Font.custom("Area Normal", size: 16)
                                    .weight(.bold)
                            )
                            .multilineTextAlignment(.center)
                            .foregroundColor(Color(red: 0.15, green: 0.6, blue: 0.38).opacity(0.4))
                        Spacer()
                        Rectangle()
                            .foregroundColor(.clear)
                            .frame(width: 4, height: 25)
                            .background(Color(red: 0.15, green: 0.6, blue: 0.38).opacity(0.4))
                            .cornerRadius(9)
                        Spacer()
                        Text("Date")
                            .font(
                                Font.custom("Area Normal", size: 16)
                                    .weight(.bold)
                            )
                            .multilineTextAlignment(.center)
                            .foregroundColor(Color(red: 0.15, green: 0.6, blue: 0.38).opacity(0.4))
                        Spacer()
                        Rectangle()
                            .foregroundColor(.clear)
                            .frame(width: 4, height: 25)
                            .background(Color(red: 0.15, green: 0.6, blue: 0.38).opacity(0.4))
                            .cornerRadius(9)
                        Spacer()
                        Text("# of days")
                            .font(
                                Font.custom("Area Normal", size: 16)
                                    .weight(.bold)
                            )
                            .multilineTextAlignment(.center)
                            .foregroundColor(Color(red: 0.15, green: 0.6, blue: 0.38).opacity(0.4))
                    }
                    .frame(width: 300)
                }
            }
        }
    }
}
