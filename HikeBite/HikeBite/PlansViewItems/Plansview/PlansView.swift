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
    @State private var showSnacksConsolidated = true
    @State private var consolidatedSnacks: [MealEntry] = []
    @State var numberOfDays: Int
    @State var tripDate: Date
    @Binding var selectedTab: Int
    @Binding var selectedTrip: Trip?
    @State private var isShowingPopover = false
    @State private var isShowingSummary = false
    @Environment(\.dismiss) private var dismiss
    @State private var selectedMealEntry: MealEntry?
    @State private var selectedRecipe: Result?
    @Binding var shouldNavigateToPlans: Bool
    @State private var shouldShowSummary = false
    private var tripMeals: [MealEntry] {
        mealEntries.filter { $0.tripName == selectedTrip?.name }
    }
    var days: [String] {
        (1...numberOfDays).map { "Day \($0)" }
    }
    init(tripManager: TripManager, numberOfDays: Int, tripDate: Date, selectedTrip: Binding<Trip?>, modelContext: ModelContext, selectedTab: Binding<Int>, shouldNavigateToPlans: Binding<Bool>) {
        self.tripManager = tripManager
        self.numberOfDays = numberOfDays
        self.tripDate = tripDate
        self._selectedTrip = selectedTrip
        _viewModel = StateObject(wrappedValue: MealEntriesViewModel(modelContext: modelContext, tripName: selectedTrip.wrappedValue?.name ?? "Unknown Trip"))
        self._selectedTab = selectedTab
        self._shouldNavigateToPlans = shouldNavigateToPlans
    }
    var body: some View {
        ZStack {
            backgroundView.blur(radius: isShowingPopover ? 4 : 0)
            mainContent.blur(radius: isShowingPopover ? 4 : 0)
            if isShowingPopover {
                Color.black.opacity(0.001).ignoresSafeArea()
                    .onTapGesture {
                        isShowingPopover = false
                    }
                VStack(alignment: .center, spacing: 16) {
                    snackToggle
                    DuplicatePlanButton { showDuplicatePlanSheet = true }
                }
                .padding().background(Color.white).cornerRadius(12).shadow(radius: 8).frame(width: 240)
                .overlay(
                    RoundedRectangle(cornerRadius: 12).stroke(Color.gray.opacity(0.2), lineWidth: 1)
                ).position(x: UIScreen.main.bounds.width - 50, y: 100)}}.padding(0)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) { Button { isShowingPopover.toggle() } label: { Image(systemName: "gearshape.fill").foregroundColor(.gray) } }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.mealEntriesState = mealEntries // Force update from @Query
                fetchMeals()
                updateAndPrintSnacks()
                tripManager.fetchRecipes()
                // DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { print("📋 Recipes loaded: \(tripManager.allRecipes.map { $0.title })") }
            }
        }
        .onChange(of: mealEntries) { _ in updateMealEntriesState() }
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
        .sheet(item: $selectedMealEntry) { meal in
            if let result = getResultForMeal(meal) {
                MealIdeasEdit(
                    mealEntry: Binding(get: { meal }, set: { selectedMealEntry = $0 }),
                    recipe: result,
                    onDismiss: { fetchMeals() }
                )
            } else {
                Text("⚠️ Recipe not found for '\(meal.recipeTitle)'")
            }
        }
        .sheet(isPresented: $isShowingSummary) {
            summarySheetView()
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
                        mealToSwap = MealEntry(day: "", meal: "", recipeID: "", recipeTitle: "", servings: 1, tripName: "", totalCalories: 0, totalGrams: 0) // Reset mealToSwap
                    }
                )
                .id(mealToSwap.id)
                .onChange(of: mealEntries) { newEntries in
                    DispatchQueue.main.async {
                        self.mealEntriesState = newEntries
                    }
                }
            }
        }
    }
    private func calculateTotals() -> (calories: Int, grams: Int) {
        let totalCalories = tripMeals.reduce(0) { $0 + $1.totalCalories }
        let totalGrams = tripMeals.reduce(0) { $0 + $1.totalGrams }
        return (totalCalories, totalGrams)
    }
    private var mainContent: some View {
        VStack(spacing: 0) {
            ScrollView {
                PlanHeaderView()
                TripImageView(tripName: selectedTrip?.name ?? "Unknown Trip")
                    .offset(y: -10)
                Text("Total Calories: \(calculateTotals().calories) | Total Weight: \(calculateTotals().grams) g")
                scrollViewContent
                Button("Summarize Trip") {
                    shouldShowSummary = true
                        fetchMeals()
                    
                }.padding(.horizontal, 30).padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 30)
                        .fill(Color("AccentColor"))
                )
                .foregroundColor(.white)
                .font(Font.custom("FONTSPRINGDEMO-FieldsDisplayMediumRegular", size: 16))
                Text("All trips are automatically saved for offline use.")
                    .font(.caption)
            }
        }
        .edgesIgnoringSafeArea(.top)
    }
    private var backgroundView: some View {
        Image("topolines")
            .resizable()
            .aspectRatio(contentMode: .fill)
            .edgesIgnoringSafeArea(.all)
            .opacity(0.08)
            .blur(radius: 2)
    }
    private var snackToggle: some View {
        VStack {
            Toggle("Show Snacks per Trip instead of per Day", isOn: $showSnacksConsolidated)
                .onChange(of: showSnacksConsolidated) { newValue in
                    viewModel.updateSnacksVisibility(show: newValue)
                    updateAndPrintSnacks()
                }
                .frame(maxWidth: UIScreen.main.bounds.width - 10)
        }
    }
    private var scrollViewContent: some View {
        ScrollView {
            ForEach(days, id: \.self, content: mealSectionView)
            if showSnacksConsolidated {
                SnacksView(
                    tripName: selectedTrip?.name ?? "Unknown Trip",
                    deleteMeal: deleteMeal,
                    swapMeal: { meal in
                        mealToSwap = meal
                        showingSwapSheet = true
                    },
                    refreshMeals: { fetchMeals() },
                    selectedMealEntry: $selectedMealEntry
                )

            }
        }
        .frame(maxWidth: UIScreen.main.bounds.width - 10)
    }
    private func updateAndPrintSnacks() {
        if showSnacksConsolidated {
            consolidatedSnacks = viewModel.mealEntries.filter { $0.meal.lowercased() == "snacks" }
        } else {
            consolidatedSnacks = []
            print("Snacks consolidation is off.")
        }
    }
    private func mealSectionView(for day: String) -> some View {
        let mealsForThisDay = mealsForDay(day: day)
        // print("📆 Rendering \(mealsForThisDay.count) meals for \(day)")
        return Section(header: Text(day)
            .font(Font.custom("FONTSPRINGDEMO-FieldsDisplaySemiBoldRegular", size: 32))
            .frame(maxWidth: .infinity, alignment: .leading)) {
                DaysView(
                    tripName: selectedTrip?.name ?? "Unknown Trip",
                    day: day,
                    deleteMeal: deleteMeal,
                    swapMeal: { meal in
                        mealToSwap = meal
                        showingSwapSheet = true
                    },
                    refreshMeals: { fetchMeals() },
                    selectedTab: $selectedTab,
                    showSnacksConsolidated: $showSnacksConsolidated,
                    selectedMealEntry: $selectedMealEntry
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
                    recipeID: meal.recipeID,
                    recipeTitle: meal.recipeTitle,
                    servings: meal.servings,
                    tripName: newTrip.name,
                    totalCalories: meal.totalCalories,
                    totalGrams: meal.totalGrams
                )
                modelContext.insert(duplicatedMeal)
            }
            try modelContext.save()
            print("✅ Successfully duplicated plan '\(selectedTrip?.name ?? "Unknown")' as '\(name)'")
            showDuplicatePlanSheet = false // Close the duplicate sheet
        } catch {
            print("❌ Failed to duplicate plan: \(error.localizedDescription)")
        }
    }
    private func mealsForDay(day: String) -> [MealEntry] {
        guard let tripName = selectedTrip?.name else {
           // print("❌ No selected trip! Returning empty meal list.")
            return []
        }
        let meals = mealEntriesState.filter {
            let mealDay = $0.day.trimmingCharacters(in: .whitespacesAndNewlines)
            let queryDay = day.trimmingCharacters(in: .whitespacesAndNewlines)
            let matches = $0.tripName == tripName && mealDay == queryDay
            return matches
        }
        // print("📆 Found \(meals.count) meals for trip \(tripName) on \(day)")
        return meals
    }
    private func cleanUpMealDays() {
        for meal in mealEntriesState {
            if meal.day.contains("Day Day") {
                meal.day = meal.day.replacingOccurrences(of: "Day Day", with: "Day ")
            }
        }
    }
    private func saveNewPlan(name: String, days: Int, date: Date) {
        do {
            let newTrip = Trip(name: name, days: days, date: date)
            modelContext.insert(newTrip)
            try modelContext.save()
            // print("✅ New trip saved successfully")
            DispatchQueue.main.async {
                self.selectedTrip = newTrip
                self.numberOfDays = newTrip.days
                self.tripDate = newTrip.date
                showCreatePlanSheet = false
            }
        } catch {
            print("Failed to save trip: \(error.localizedDescription)")
        }
    }
    private func deleteMeal(_ meal: MealEntry) {
        modelContext.delete(meal)
        refreshMeals()
        fetchMeals()
        do {
            refreshMeals()
            try modelContext.save()
            fetchMeals()
            // Remove the meal from the current state to immediately reflect changes
            mealEntriesState.removeAll { $0.id == meal.id }
            // print("Meal deleted successfully.")
            refreshMeals() // Call refresh to ensure UI is in sync with the latest data state.
        } catch { print("Error deleting meal: \(error.localizedDescription)") }
    }
    private func refreshMeals() {
        DispatchQueue.main.async {
            self.mealEntriesState = self.mealEntriesState.filter { !$0.isDeleted }
            // print("State after deletion: \(self.mealEntriesState.map { $0.id })")
        }
    }
    @ViewBuilder
    private func summarySheetView() -> some View {
        if let trip = selectedTrip {
            TripSummaryView(
                tripManager: tripManager,
                source: .plansView,
                selectedTrip: $selectedTrip,
                selectedTab: $selectedTab,
                trip: trip,
                allMeals: mealEntriesState,
                onDone: {
                    isShowingSummary = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                        selectedTrip = nil
                        tripManager.lastNavigatedTripID = nil
                        selectedTab = 2
                        shouldNavigateToPlans = false
                    }
                },
                isPresented: $isShowingSummary,
                shouldNavigateToPlans: $shouldNavigateToPlans
            )
            .id(trip.id)
        } else {
            Text("No trip selected.")
        }
    }
    func fetchMeals() {
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                let fetchedMeals: [MealEntry] = try DispatchQueue.main.sync {
                    try modelContext.fetch(FetchDescriptor<MealEntry>())
                }
                DispatchQueue.main.async {
                    let filteredMeals = fetchedMeals.filter {
                        $0.tripName == selectedTrip?.name ?? "Unknown Trip" }
                    self.mealEntriesState.removeAll()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        self.mealEntriesState = filteredMeals
                        if shouldShowSummary {
                            isShowingSummary = true
                            shouldShowSummary = false
                        }
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    print("❌ Failed to load meals: \(error.localizedDescription)")
                } } } }
    func getResultForMeal(_ meal: MealEntry) -> Result? {
        for recipe in tripManager.allRecipes {
            // print("🔍 Comparing recipe.id \(recipe.id ?? "nil") to meal.recipeID \(meal.recipeID)")
            if recipe.id == meal.recipeID { return recipe }
        }
        // print("❌ No match found for recipeID: \(meal.recipeID)")
        return nil
    }
}
