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
    @State private var showWelcomeSheet = false
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
    init(tripManager: TripManager, selectedTrip: Binding<Trip?>, selectedTab: Binding<Int>, showLogin: Binding<Bool>) {
        self._tripManager = ObservedObject(initialValue: tripManager)
        self._selectedTrip = selectedTrip
        self._selectedTab = selectedTab
        self._showLogin = showLogin
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
                            .padding(10)
                            .background(
                                RoundedRectangle(cornerRadius: 9)
                                    .stroke(Color(red: 0.15, green: 0.6, blue: 0.38), lineWidth: 1)
                                    .background(Color.white)
                                    .shadow(color: .black.opacity(0.25), radius: 2, x: 0, y: 4)
                            )
                            .cornerRadius(9)
                        
                    }
                    .padding()
                    ScrollView {
                        ScrollView {
                            if !upcomingTrips.isEmpty {
                                ZStack {
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
                            ZStack(alignment: .bottom) {
                                Image("transparentBackgroundAbstractmountain")
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 405, height: 114)
                                    .clipped()
                                    .opacity(0.2)
                                PlanNewTrip()
                                    .padding(.bottom, 25)
                            }
                            ZStack {
                                VStack {
                                    Rectangle()
                                        .foregroundColor(.clear)
                                        .frame(width: 413, height: 243)
                                        .background(
                                            Image("trees")
                                                .resizable()
                                                .aspectRatio(contentMode: .fill)
                                                .frame(width: 413, height: 243)
                                                .clipped()
                                        )
                                        .cornerRadius(9)
                                }
                                VStack {
                                    Text("Not sure where to start?")
                                        .font(.title3)
                                        .foregroundColor(.white)
                                    ZStack {
                                        Button {
                                            showWelcomeSheet = true
                                        } label: {
                                            Label("Explore HikeBite", systemImage: "point.topleft.filled.down.to.point.bottomright.curvepath")
                                                .font(.headline)
                                                .padding()
                                                .frame(maxWidth: .infinity)
                                                .background(Color(.white))
                                                .foregroundColor(Color("AccentColor"))
                                                .cornerRadius(30)
                                                .padding(.horizontal)
                                                .frame(width: 300)
                                        }
                                    }
                                    .padding(.top, 20)
                                }
                                .sheet(isPresented: $showWelcomeSheet) {
                                    WelcomeToHikeBite()
                                }
                                
                            }
                        }
                    }
                }
            }
        }
        .onAppear {
            if tripManager.trips.isEmpty {
                tripManager.fetchTrips(modelContext: modelContext)
            }
        }
    }
}
