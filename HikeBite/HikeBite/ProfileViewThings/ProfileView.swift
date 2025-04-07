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
                    ScrollView {
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
                        ScrollView {
                            ZStack {
                                FunnyLines()
                                VStack {
                                    if !upcomingTrips.isEmpty {
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
                                    TryOutATemplate(
                                        selectedTemplate: $selectedTemplate,
                                        showTemplatePreview: $showTemplatePreview,
                                        selectedTab: $selectedTab
                                    )
                                }
                                .offset(y: 50)
                            }
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
                            .padding(.top, 100)
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
                                    WelcomeToHikeBite(isPresented: $showWelcomeSheet)
                                }
                            }
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
                }
            }
        }
        .sheet(isPresented: $showCreatePlanSheet) {
            CreatePlanView { name, days, date in
                saveNewPlan(name: name, days: days, date: date)
                tripManager.fetchTrips(modelContext: modelContext)
            }
        }
        .onAppear {
            if tripManager.trips.isEmpty {
                tripManager.fetchTrips(modelContext: modelContext)
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
}
