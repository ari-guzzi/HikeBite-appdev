//
//  MainView.swift
//  HikeBite
//
//  Created by Ari Guzzi on 1/13/25.
//
import Firebase
import FirebaseFirestore
import FirebaseStorage
import SwiftData
import SwiftUI

struct MainView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var tripManager: TripManager
    @State private var selectedTab: Int = 0
    @State private var showCreateTrip = false
    @State private var showTripPicker = false
    @State private var showLogin = false
    @State var mealEntriesState: [MealEntry] = []
    @State private var numberOfDays: Int = 0
    @State private var tripDate: Date = Date()
    @State private var results: [Result] = []
    @State private var isLoadingRecipes = true
    @State var selectedTemplate: MealPlanTemplate? = nil
    @State var showTemplatePreview: Bool = false
    @State var selectedRecipe: Result? = nil
    @State var showRecipeDetail: Bool = false

    @State private var selectedTrip: Trip? {
        didSet {
            if selectedTrip != nil {
                selectedTab = 2
            }
        }
    }
    init() {
        UITabBar.appearance().backgroundColor = UIColor.white
    }
    var body: some View {
        TabView(selection: $selectedTab) {
            ProfileView(
                tripManager: tripManager,
                selectedTrip: $selectedTrip,
                selectedTab: $selectedTab,
                showLogin: $showLogin,
                results: results,
                isLoadingRecipes: isLoadingRecipes,
                selectedTemplate: $selectedTemplate,
                showTemplatePreview: $showTemplatePreview,
                selectedRecipe: $selectedRecipe,
                showRecipeDetail: $showRecipeDetail
            )
                .tabItem { Label("Profile", systemImage: "person.fill") }
                .tag(0)

            Templates(
                selectedTrip: $selectedTrip,
                selectedTab: $selectedTab,
                fetchMeals: fetchMeals,
                externalSelectedTemplate: $selectedTemplate,
                externalShowPreview: $showTemplatePreview
            )
            .tabItem {
                Label("Templates", systemImage: "list.bullet.rectangle.portrait")
            }
            .tag(1)
                TripsView(
                    tripManager: tripManager,
                    selectedTrip: $selectedTrip,
                    selectedTab: $selectedTab,
                    showLogin: $showLogin,
                    numberOfDays: numberOfDays,
                    tripDate: tripDate
                )
                .tabItem {
                    Label("Trips", systemImage: "map.fill")
                }
            .tag(2)

            ContentView(
                selectedTrip: $selectedTrip,
                externalSelectedRecipe: $selectedRecipe,
                externalShowDetail: $showRecipeDetail
            )
            .tabItem {
                    Label("Meals", systemImage: "fork.knife")
                }
                .tag(3)
        }
        .onAppear {
            tripManager.fetchTrips(modelContext: modelContext)
            fetchSpecificRecipes()
        }
        .sheet(isPresented: $showLogin) { // Show LoginView as a sheet when needed
            LoginView(showLogin: $showLogin)
        }
        .sheet(isPresented: $showCreateTrip) {
            CreatePlanView { name, days, date in
                let newTrip = Trip(name: name, days: days, date: date)
                modelContext.insert(newTrip)
                Task {
                    do {
                        try modelContext.save()
                        tripManager.fetchTrips(modelContext: modelContext)
                        DispatchQueue.main.async {
                            selectedTrip = newTrip
                            selectedTab = 2
                            showCreateTrip = false
                        }
                    } catch {
                        print("Failed to save trip: \(error)")
                    }
                }
            }
        }
    }
    func fetchMeals() {
        do {
            let fetchedMeals: [MealEntry] = try modelContext.fetch(FetchDescriptor<MealEntry>())
            mealEntriesState = fetchedMeals
            print("✅ Meals successfully loaded: \(mealEntriesState.count)")
        } catch {
            print("❌ Failed to load meals: \(error.localizedDescription)")
        }
    }
    func fetchSpecificRecipes() {
        let db = Firestore.firestore()
        let validIDs: Set<String> = ["18", "19", "35"]
        var newResults: [Result] = []
        let group = DispatchGroup()

        for id in validIDs {
            group.enter()
            db.collection("Recipes").document(id).getDocument { snapshot, error in
                guard let snapshot = snapshot, snapshot.exists else {
                    print("⚠️ Recipe with ID \(id) not found.")
                    group.leave()
                    return
                }

                do {
                    var result = try snapshot.data(as: Result.self)
                    if let imgPath = result.img {
                        // enter again because of nested async
                        group.enter()
                        getDownloadURL(for: imgPath) { url in
                            result.img = url
                            newResults.append(result)
                            group.leave()
                        }
                    } else {
                        newResults.append(result)
                    }
                } catch {
                    print("❌ Failed to decode recipe \(id): \(error.localizedDescription)")
                }

                group.leave() // now only once per document
            }
        }

        group.notify(queue: .main) {
            self.results = newResults
            self.isLoadingRecipes = false
            print("✅ Fetched specific recipes: \(self.results.map { $0.id ?? "?" })")
        }
    }




}
