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
    @State private var shouldNavigateToPlans = false
    @State private var activeTrip: Trip? = nil
    // @State private var hasNavigatedFromSelectedTrip = false
    var upcomingTrips: [Trip] {
        let now = Date()
        let upcoming = tripManager.trips.filter {
            if let endDate = Calendar.current.date(byAdding: .day, value: $0.days, to: $0.date) {
                return endDate >= now
            }
            return false
        }
        return upcoming
    }
    
    var previousTrips: [Trip] {
        let now = Date()
        let past = tripManager.trips.filter {
            if let endDate = Calendar.current.date(byAdding: .day, value: $0.days, to: $0.date) {
                return endDate < now
            }
            return false
        }
        return past
    }
    init(tripManager: TripManager, selectedTrip: Binding<Trip?>, selectedTab: Binding<Int>, showLogin: Binding<Bool>, numberOfDays: Int, tripDate: Date) {
        self._tripManager = ObservedObject(initialValue: tripManager)
        self._selectedTrip = selectedTrip
        self._selectedTab = selectedTab
        self._showLogin = showLogin
        self.numberOfDays = numberOfDays
        self.tripDate = tripDate
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
                    NavigationLink(
                        destination: PlansView(
                            tripManager: tripManager,
                            numberOfDays: selectedTrip?.days ?? 0,
                            tripDate: selectedTrip?.date ?? Date(),
                            selectedTrip: $selectedTrip,
                            modelContext: modelContext,
                            selectedTab: $selectedTab
                        ),
                        isActive: $shouldNavigateToPlans
                    ) {
                        EmptyView()
                    }
                    .hidden()
                    header
                    tripContent
                        .frame(width: UIScreen.main.bounds.width)
                }
            }
            .onAppear {
                print("🔄 Tripsview appeared. Fetching trips...")
                tripManager.fetchTrips(modelContext: modelContext)
                if let trip = selectedTrip, !tripManager.hasNavigatedForSelectedTrip {
                        print("🚀 selectedTrip is \(trip.name), navigating to PlansView")
                        //DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            tripManager.hasNavigatedForSelectedTrip = true
                            shouldNavigateToPlans = true
                        //}
                } else {
                    print("🛑 Skipping auto-navigation, already navigated for selected trip")
                }
            }
        }
        .sheet(isPresented: $showCreatePlanSheet) {
            CreatePlanView { name, days, date in
                saveNewPlan(name: name, days: days, date: date)
                tripManager.fetchTrips(modelContext: modelContext)
            }
        }
        .onChange(of: selectedTrip) { newValue in
            guard let trip = newValue else { return }
            print("✳️ selectedTrip changed to \(trip.name)")
            tripManager.hasNavigatedForSelectedTrip = true
            shouldNavigateToPlans = true
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
                emptyTripsView
            } else {
                tripListContent
            }
        }
    }
    private var emptyTripsView: some View {
        VStack {
            Text("No trips yet. Create a new one!")
                .foregroundColor(.gray)
                .padding()
            Button(action: { showCreatePlanSheet = true }) {
                HStack {
                    Text("Create New Trip Plan").foregroundColor(Color("AccentColor"))
                    Image(systemName: "plus.circle").foregroundColor(Color("AccentColor"))
                }
            }
        }
    }
    private var tripListContent: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                upcomingTripsView
                previousTripsSection
            }
        }
    }
    private var previousTripsSection: some View {
        ZStack(alignment: .bottom) {
            BottomMountain()
            if !previousTrips.isEmpty {
                VStack(alignment: .leading) {
                    Text("Previous Trips")
                        .font(Font.custom("Area Normal", size: 24).weight(.bold))
                        .foregroundColor(Color(red: 0.17, green: 0.17, blue: 0.17))
                        .padding(.leading, 20)
                    List(previousTrips) { trip in
                        Button {
                            selectedTrip = trip
                        } label: {
                            tripRow(trip: trip)
                        }
                        .listStyle(.plain)
                        .listRowBackground(Color.clear)
                        .scrollIndicators(.hidden)
                    }
                    .offset(x: 5)
                    .scrollIndicators(.hidden)
                    .background(Color.clear)
                    .listStyle(PlainListStyle())
                    .frame(height: 300)
                }
            }
        }
    }
    private var upcomingTripsView: some View {
        ZStack {
            FunnyLines()
            VStack {
                if !upcomingTrips.isEmpty {
                    VStack(alignment: .leading, spacing: 0) {
                        HStack(spacing: 10) {
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
                                    Button {
                                        selectedTrip = trip
                                    } label: {
                                        UpcomingTripCardPlansView(trip: trip)
                                    }
                                    
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
            Image(systemName: "chevron.right")
                .foregroundColor(.black)
                .padding(.trailing, 10)
        }
        .scrollIndicators(.hidden)
        .listRowBackground(Color.clear)
        .frame(width: UIScreen.main.bounds.width - 35, height: 56)
        .background(Color.white)
        .cornerRadius(9)
        .shadow(color: .black.opacity(0.25), radius: 2, x: 0, y: 4)
        .listRowInsets(EdgeInsets())
        .padding(.vertical, 3)
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
}
