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
                        .id(day)
                }
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                print("📌 PlansView loaded with trip: \(selectedTrip?.name ?? "None")")
                fetchMeals()
            }
        }
        .onChange(of: mealEntries) { _ in
            updateMealEntriesState()
        }
        .onChange(of: selectedTrip) { newTrip in
            guard let newTrip = newTrip else {
                print("❌ No trip selected!")
                return
            }
            print("🔄 Trip changed to: \(newTrip.name)")
            numberOfDays = newTrip.days // Don't delete this
            tripDate = newTrip.date // Don't delete this
            fetchMeals()
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
                .onChange(of: selectedTrip) { newTrip in
                    print("🔄 Trip changed: \(newTrip?.name ?? "None")")
                    fetchMeals()
                }
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
        let mealsForThisDay = mealsForDay(day: day)
        print("📆 Rendering \(mealsForThisDay.count) meals for \(day)")
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
//    private func mealsForDay(day: String) -> [MealEntry] {
//        let filteredMeals = mealEntriesState.filter { meal in
//            meal.tripName == selectedTrip?.name && meal.day == day
//        }
//        
//        guard let tripName = selectedTrip?.name else {
//            print("❌ No selected trip! Returning empty meal list.")
//            return []
//        }
//        print("🔍 Looking for meals with tripName: \(tripName), day: \(day)")
//
//        let meals = mealEntriesState.filter { meal in
//
//            let isMatch = meal.tripName == tripName && meal.day.filter { $0.isNumber } == day.filter { $0.isNumber }
//            print("🔍 Checking meal: \(meal.recipeTitle) - tripName: \(meal.tripName), day: \(meal.day) (Expected: \(day)) -> \(isMatch ? "✅ Match" : "❌ No Match")")
//            return isMatch
//        }
//        
//        print("📆 Found \(meals.count) meals for \(tripName) on \(day)")
//        return meals
//    }
    private func mealsForDay(day: String) -> [MealEntry] {
        guard let tripName = selectedTrip?.name else {
            print("❌ No selected trip! Returning empty meal list.")
            return []
        }

        let normalizedDay = day.filter { $0.isNumber }  // Normalize to just numbers
        
        print("🔍 Looking for meals with tripName: \(tripName), day: \(day)")

        let meals = mealEntriesState.filter { meal in
            let mealDayNormalized = meal.day.filter { $0.isNumber }
            let isMatch = meal.tripName.trimmingCharacters(in: .whitespacesAndNewlines) == tripName.trimmingCharacters(in: .whitespacesAndNewlines)
                && mealDayNormalized == normalizedDay
            print("🔍 Checking meal: \(meal.recipeTitle) - tripName: \(meal.tripName), day: \(meal.day) (Expected: \(day)) -> \(isMatch ? "✅ Match" : "❌ No Match")")
            return isMatch
        }
        
        print("📆 Found \(meals.count) meals for \(tripName) on \(day)")
        return meals
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
        print("🧐 mealsForDay BEFORE update: \(mealEntriesState.count) meals")

        DispatchQueue.global(qos: .userInitiated).async {
            do {
                let fetchedMeals: [MealEntry] = try modelContext.fetch(FetchDescriptor<MealEntry>())

                DispatchQueue.main.async {
                    print("📋 All stored meals in SwiftData:")
                    for meal in fetchedMeals {
                        print("🔍 Meal: \(meal.recipeTitle) - Trip: \(meal.tripName) - Day: \(meal.day)")
                    }

                    let filteredMeals = fetchedMeals.filter { $0.tripName == selectedTrip?.name ?? "Unknown Trip" }
                    print("✅ Meals successfully loaded into state: \(filteredMeals.count)")

                    // 🔄 Force UI Update by clearing first
                    self.mealEntriesState = []
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        self.mealEntriesState = filteredMeals
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    print("❌ Failed to load meals: \(error.localizedDescription)")
                }
            }
        }
    }
}
