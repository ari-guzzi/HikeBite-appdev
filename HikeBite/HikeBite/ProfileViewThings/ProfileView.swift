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
    @State private var showCreatePlanSheet = false
    @State private var numberOfDays: Int = 0
    @State private var tripDate: Date = Date()
    @Query var entries: [MealEntry]
    let results: [Result]
    @Binding var selectedTemplate: MealPlanTemplate?
    @Binding var showTemplatePreview: Bool
    @Binding var selectedRecipe: Result?
    @Binding var showRecipeDetail: Bool
    @State private var showTripSummarySheet = false
    @State private var summaryTrip: Trip? = nil
    @State private var readyToShowSummarySheet = false
    var isLoadingRecipes: Bool
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
    init(
        tripManager: TripManager,
        selectedTrip: Binding<Trip?>,
        selectedTab: Binding<Int>,
        showLogin: Binding<Bool>,
        results: [Result],
        isLoadingRecipes: Bool,
        selectedTemplate: Binding<MealPlanTemplate?>,
        showTemplatePreview: Binding<Bool>,
        selectedRecipe: Binding<Result?>,
        showRecipeDetail: Binding<Bool>
    ) {
        self._tripManager = ObservedObject(initialValue: tripManager)
        self._selectedTrip = selectedTrip
        self._selectedTab = selectedTab
        self._showLogin = showLogin
        self._selectedTemplate = selectedTemplate
        self._showTemplatePreview = showTemplatePreview
        self._selectedRecipe = selectedRecipe
        self._showRecipeDetail = showRecipeDetail
        self.results = results
        self.isLoadingRecipes = isLoadingRecipes
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
                backgroundView
                VStack {
                    signInSignUp
                    ProfileNameView()
                    ScrollView {
                        groceryListButtonView
                        ScrollView {
                            upcomingTripsSection
                            createNewTripPlanView
                                .padding(.top, 100)
                                .padding(.top, upcomingTrips.isEmpty ? 0 : 100)
                            ZStack {
                                treesPictureView
                                howToHikeBiteView
                                .sheet(isPresented: $showWelcomeSheet) {
                                    WelcomeToHikeBite(isPresented: $showWelcomeSheet)
                                }
                            }
                            recipeLoadingView
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $showCreatePlanSheet) {
            CreatePlanView { name, days, date in
                saveNewPlan(name: name, days: days, date: date)
                tripManager.fetchTrips(modelContext: modelContext)
            }
        }
//        .sheet(isPresented: $showTripSummarySheet) {
//            if let trip = summaryTrip {
//                TripSummaryView(
//                    tripManager: tripManager,
//                    source: .profileView,
//                    selectedTrip: $selectedTrip,
//                    selectedTab: $selectedTab,
//                    trip: trip,
//                    allMeals: entries,
//                    onDone: { showTripSummarySheet = false },
//                    isPresented: $showTripSummarySheet, 
//                    shouldNavigateToPlans: $showTripSummarySheet
//                )
//            }
//        }
        .sheet(item: $summaryTrip) { trip in
            TripSummaryView(
                tripManager: tripManager,
                source: .profileView,
                selectedTrip: $selectedTrip,
                selectedTab: $selectedTab,
                trip: trip,
                //allMeals: entries,
                onDone: {
                    summaryTrip = nil
                },
                isPresented: Binding(
                    get: { summaryTrip != nil },
                    set: { newValue in if !newValue { summaryTrip = nil } }
                ),
                shouldNavigateToPlans: .constant(false)
            )
        }
        .onAppear {
            if tripManager.trips.isEmpty {
                tripManager.fetchTrips(modelContext: modelContext)
            }
        }
    }
    @ViewBuilder
    private var upcomingTripsSection: some View {
        ZStack {
            if !upcomingTrips.isEmpty {
                FunnyLines()
            }
            VStack {
                if !upcomingTrips.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            ForEach(upcomingTrips) { trip in
                                Button(action: {
                                    tripManager.lastNavigatedTripID = nil
                                    selectedTrip = nil
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                                        selectedTrip = trip
                                    }
                                    selectedTab = 2
                                }) {
                                    TripCardView(
                                        shouldNavigateToPlans: .constant(false),
                                        tripManager: tripManager,
                                        trip: trip,
                                        allMealEntries: entries,
                                        selectedTrip: $selectedTrip,
                                        selectedTab: $selectedTab,
                                        summaryTrip: $summaryTrip,
                                        showTripSummarySheet: $showTripSummarySheet,
                                        openTripSummarySheet: { openTripSummarySheet(for: $0) }
                                    )
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                TryOutATemplate(
                    selectedTemplate: $selectedTemplate,
                    showTemplatePreview: $showTemplatePreview,
                    selectedTab: $selectedTab
                )
            }
            .offset(y: upcomingTrips.isEmpty ? 0 : 40)
        }
    }
    @ViewBuilder
    private var groceryListButtonView: some View {
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
        .shadow(color: .black.opacity(0.25), radius: 2, x: 0, y: 4)
        .padding()
    }
    private var treesPictureView: some View {
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
    }
    private var howToHikeBiteView: some View {
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
    }
    private var backgroundView: some View {
        LinearGradient(
            gradient: Gradient(stops: [
                .init(color: .white, location: 0.0),
                .init(color: Color("AccentLight"), location: 0.965),
                .init(color: .white, location: 1.0)
            ]),
            startPoint: .top,
            endPoint: .bottom
        )
        .edgesIgnoringSafeArea([.top, .leading, .trailing])
    }
    private var signInSignUp: some View {
        Group {
            if viewModel.currentUser == nil {
                Button {
                    showLogin = true
                } label: {
                    HStack(spacing: 3) {
                        Text("Sign In / Sign Up!")
                            .fontWeight(.bold)
                    }
                    .font(.system(size: 14))
                }
            } else {
                EmptyView()
            }
        }
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
                selectedTab = 2
            }
        } catch {
            print("❌ Failed to save trip: \(error.localizedDescription)")
        }
    }
    private var createNewTripPlanView: some View {
        VStack {
            ZStack(alignment: .bottom) {
                Image("transparentBackgroundAbstractmountain")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 405, height: 114)
                    .clipped()
                    .opacity(0.2)
                Button("Create a new trip plan", action: { showCreatePlanSheet = true })
                    .padding(.horizontal, 30)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 30)
                            .fill(Color("AccentColor"))
                    )
                    .foregroundColor(.white)
                    .font(Font.custom("FONTSPRINGDEMO-FieldsDisplayMediumRegular", size: 16))
                    .padding(.bottom, 30)
            }
        }
    }
    private var recipeLoadingView: some View {
        Group {
            if isLoadingRecipes {
                ProgressView("Loading meal ideas...")
                    .padding()
            } else {
                DiscoverMealIdeas(
                    results: results,
                    entries: entries,
                    selectedTab: $selectedTab,
                    selectedRecipe: $selectedRecipe,
                    showRecipeDetail: $showRecipeDetail
                )
                .offset(y: -12)
            }
        }
    }
//    private func openTripSummarySheet(for trip: Trip) {
//        summaryTrip = nil
//        showTripSummarySheet = false
//        readyToShowSummarySheet = false
//
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
//            summaryTrip = trip
//
//            DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
//                if summaryTrip != nil {
//                    readyToShowSummarySheet = true
//                } else {
//                    print("❌ Still nil after delay")
//                }
//            }
//        }
//    }
    func openTripSummarySheet(for trip: Trip) {
        // Prevents racing or showing an empty view
        readyToShowSummarySheet = false
        summaryTrip = nil

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.02) {
            summaryTrip = trip

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.02) {
                // Only present the sheet if trip successfully set
                summaryTrip = trip
                if summaryTrip != nil {
                    readyToShowSummarySheet = true
                } else {
                    print("❌ summaryTrip still nil")
                }
            }
        }
    }




}
