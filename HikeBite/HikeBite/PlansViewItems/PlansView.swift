//
//  PlansView.swift
//  HikeBite
//
//  Created by Ari Guzzi on 1/17/25.
//
//
import SwiftData
import SwiftUI

struct PlansView: View {
    @ObservedObject var tripManager: TripManager
    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel: MealEntriesViewModel
    @Query private var mealEntries: [MealEntry]
    @State var mealEntriesState: [MealEntry] = []
    @State private var mealToSwap: MealEntry?
    @State private var showingSwapSheet = false
    @State private var showCreatePlanSheet = false
    @State private var showDuplicatePlanSheet = false
    @State var numberOfDays: Int
    @State var tripDate: Date
    @Binding var selectedTab: Int
    @Binding var selectedTrip: Trip?
    var days: [String] {
        (1...numberOfDays).map { "Day \($0)" }
    }
    init(tripManager: TripManager, numberOfDays: Int, tripDate: Date, selectedTrip: Binding<Trip?>, modelContext: ModelContext, selectedTab: Binding<Int>) {
        self.tripManager = tripManager
        self.numberOfDays = numberOfDays
        self.tripDate = tripDate
        self._selectedTrip = selectedTrip
        _viewModel = StateObject(wrappedValue: MealEntriesViewModel(modelContext: modelContext, tripName: selectedTrip.wrappedValue?.name ?? "Unknown Trip"))
        self._selectedTab = selectedTab
    }
    var body: some View {
        VStack {
            headerView
            tripImageView
            ScrollView {
                ForEach(days, id: \.self) { day in
                    mealSectionView(for: day)
                }
            }
        }
        .onAppear {
            fetchMeals()
            print("📌 PlansView loaded with trip: \(selectedTrip?.name ?? "Unknown Trip")")
            DispatchQueue.main.async {
                viewModel.fetchMeals(for: selectedTrip?.name ?? "Unknown Trip")
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.mealEntriesState = viewModel.mealEntries
                print("🔄 Meals after update: \(mealEntriesState.count)")
                for meal in mealEntriesState {
                    print("📋 Meal Loaded: \(meal.recipeTitle) on \(meal.day) (\(meal.meal))")
                }
            }
        }
        .onChange(of: mealEntries) { _ in
            updateMealEntriesState()
        }
        .onChange(of: selectedTrip) { newTrip in
            print("🔄 Trip changed: \(newTrip?.name ?? "None")")
            fetchMeals() // ✅ Fetch meals again when the trip changes
        }
        .sheet(isPresented: $showDuplicatePlanSheet) {
            if let trip = selectedTrip {
                DuplicatePlanView(originalTrip: trip, duplicatePlan: duplicatePlan)
            }
        }
        .sheet(isPresented: $showCreatePlanSheet) {
            CreatePlanView { name, days, date in
                saveNewPlan(name: name, days: days, date: date)
            }
        }
        .sheet(isPresented: Binding(
            get: { showingSwapSheet && mealToSwap != nil },
            set: { showingSwapSheet = $0 }
        )) {
            if var mealToSwap = mealToSwap {
                SwapMealView(
                    mealToSwap: mealToSwap,
                    dismiss: {
                        showingSwapSheet = false
                        mealToSwap = MealEntry(day: "", meal: "", recipeTitle: "", servings: 1, tripName: "") // Reset mealToSwap
                    }
                )
                .id(mealToSwap.id)
            }
        }
    }
    private var headerView: some View {
        HStack {
            Button(action: { showDuplicatePlanSheet = true }) {
                HStack {
                    Text("Duplicate Plan").foregroundColor(.blue)
                    Image(systemName: "doc.on.doc").foregroundColor(.blue)
                }
            }
            .padding()
            Spacer()
            TripPicker(selectedTrip: $selectedTrip, tripManager: tripManager)
            Button(action: { showCreatePlanSheet = true }) {
                HStack {
                    Text("Create New Trip").foregroundColor(Color.blue)
                    Image(systemName: "plus.circle").foregroundColor(.blue)
                }
            }
            .padding()
        }
    }
    private var tripImageView: some View {
        ZStack {
            Image("backpacking")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 400)
                .scaledToFit()
                .clipShape(RoundedRectangle(cornerRadius: 20))

            Text(selectedTrip?.name ?? "Unknown Trip")
                .font(.title)
                .foregroundColor(Color.white)
                .multilineTextAlignment(.center)
                .frame(width: 350)
                .offset(y: -90)
        }
    }
    private func mealSectionView(for day: String) -> some View {
        let formattedDay = "Day \(day.filter { $0.isNumber })"
        let mealsForThisDay = mealsForDay(day: day)
        return Section(header: Text(day).font(.title).fontWeight(.bold).padding(.leading, 30)) {
            DaysView(
                mealsForDay: mealsForThisDay,
                deleteMeal: deleteMeal,
                swapMeal: { meal in
                    mealToSwap = meal
                    showingSwapSheet = true
                },
                tripName: selectedTrip?.name ?? "Unknown Trip",
                refreshMeals: { fetchMeals() },
                day: day,
                selectedTab: $selectedTab
            )
        }
    }
    private func updateMealEntriesState() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.mealEntriesState = viewModel.mealEntries
            print("🔄 Meals after update: \(mealEntriesState.count)")
            for meal in mealEntriesState {
                print("📋 Meal Loaded: \(meal.recipeTitle) on \(meal.day) (\(meal.meal))")
            }
        }
    }
    private func duplicatePlan(name: String, days: Int, date: Date) {
        do {
            let newTrip = Trip(name: name, days: days, date: date)
            modelContext.insert(newTrip)
            let originalMeals = mealEntriesState.filter { $0.tripName == selectedTrip?.name ?? "Unknown Trip" }
            for meal in originalMeals {
                let duplicatedMeal = MealEntry(
                    day: meal.day,
                    meal: meal.meal,
                    recipeTitle: meal.recipeTitle,
                    servings: meal.servings,
                    tripName: newTrip.name
                )
                modelContext.insert(duplicatedMeal)
            }
            try modelContext.save()
            print("✅ Successfully duplicated plan '\(selectedTrip)' as '\(name)'")
            showDuplicatePlanSheet = false // Close the duplicate sheet
        } catch {
            print("❌ Failed to duplicate plan: \(error.localizedDescription)")
        }
    }
    private func mealsForDay(day: String) -> [MealEntry] {
        return mealEntriesState.filter { $0.tripName == selectedTrip?.name ?? "Unknown Trip" }
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
    private func deleteMeal(_ meal: MealEntry) {
        modelContext.delete(meal)
        do {
            try modelContext.save()
            print("✅ Deleted meal: \(meal.recipeTitle)")
        } catch {
            print("❌ Error deleting meal: \(error.localizedDescription)")
        }
    }
    private func fetchMeals() {
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                let fetchedMeals: [MealEntry] = try modelContext.fetch(FetchDescriptor<MealEntry>())
                let filteredMeals = fetchedMeals.filter { $0.tripName == selectedTrip?.name ?? "Unknown Trip" }
                DispatchQueue.main.async {
                    self.mealEntriesState.removeAll()
                    self.mealEntriesState = filteredMeals
                    
                    print("✅ Meals successfully loaded into state: \(mealEntriesState.count)")
                    for meal in mealEntriesState {
                        print("📋 Meal Loaded: \(meal.recipeTitle) on \(meal.day) (\(meal.meal))")
                    }
                }
            } catch {
                print("❌ Failed to load meals: \(error.localizedDescription)")
            }
        }
    }
}
