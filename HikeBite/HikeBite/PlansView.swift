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
    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel: MealEntriesViewModel
    @Query private var mealEntries: [MealEntry]
    @State private var mealEntriesState: [MealEntry] = []
    @State private var mealToSwap: MealEntry?
    @State private var showingSwapSheet = false
    @State private var showCreatePlanSheet = false
    @State var tripName: String
    @State var numberOfDays: Int
    @State var tripDate: Date
    var selectedTrip: Trip
    var days: [String] {
        (1...numberOfDays).map { "Day \($0)" }
    }
    init(tripName: String, numberOfDays: Int, tripDate: Date, selectedTrip: Trip, modelContext: ModelContext) {
        self.tripName = tripName
        self.numberOfDays = numberOfDays
        self.tripDate = tripDate
        self.selectedTrip = selectedTrip
        _viewModel = StateObject(wrappedValue: MealEntriesViewModel(modelContext: modelContext, tripName: tripName))
    }
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Button {
                    showCreatePlanSheet = true
                } label: {
                    HStack {
                        Text("Create New Plan")
                            .foregroundColor(Color.blue)
                        Image(systemName: "plus.circle")
                            .foregroundColor(.blue)
                    }
                }
                .padding()
            }

            ZStack {
                Image("backpacking")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 400)
                    .scaledToFit()
                    .clipShape(RoundedRectangle(cornerRadius: 20))

                Text(tripName)
                    .font(.title)
                    .foregroundColor(Color.white)
                    .multilineTextAlignment(.center)
                    .frame(width: 350)
                    .offset(y: -90)
            }

            ScrollView {
                ForEach(days, id: \.self) { day in
                    let mealsForThisDay = viewModel.mealEntries.filter { $0.day == day }
                    Section(header: Text(day).font(.title).fontWeight(.bold).padding(.leading, 30)) {
                        DaysView(
                            mealsForDay: mealsForThisDay,
                            deleteMeal: deleteMeal,
                            swapMeal: { meal in
                                mealToSwap = meal
                                showingSwapSheet = true
                            }
                        )
                    }
                }
            }
        }
        .onAppear {
            print("📌 PlansView loaded with trip: \(tripName)")
            viewModel.fetchMeals(for: tripName)

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.mealEntriesState = viewModel.mealEntries
                print("🔄 Meals after update: \(mealEntriesState.count)")
            }
        }
        .onChange(of: mealEntries) { newEntries in
            print("🔄 UI Update Triggered. Found: \(newEntries.count) meals.")
            mealEntriesState = newEntries.filter { $0.tripName == tripName }
            print("🔄 Meal entries updated in UI. Found: \(mealEntriesState.count)")
        }
        .sheet(isPresented: $showCreatePlanSheet) {
            CreatePlanView { name, days, date in
                saveNewPlan(name: name, days: days, date: date)
            }
        }
        .sheet(isPresented: $showingSwapSheet) {
            if let mealToSwap = mealToSwap {
                SwapMealView(mealToSwap: mealToSwap, dismiss: { showingSwapSheet = false })
            }
        }
    }
    private func mealsForDay(day: String) -> [MealEntry] {
        return mealEntriesState.filter { $0.day == day && $0.tripName == tripName }
    }
    private func saveNewPlan(name: String, days: Int, date: Date) {
        do {
            let tripsBeforeSave: [Trip] = try modelContext.fetch(FetchDescriptor<Trip>())
            print("📂 Trips before saving: \(tripsBeforeSave.count)")
            let newTrip = Trip(name: name, days: days, date: date)
            modelContext.insert(newTrip)
            try modelContext.save()
            print("✅ New trip saved successfully")
            let tripsAfterSave: [Trip] = try modelContext.fetch(FetchDescriptor<Trip>())
            print("📂 Trips after saving: \(tripsAfterSave.count)")
            for trip in tripsAfterSave {
                print("📌 Trip Name: \(trip.name) - \(trip.days) days - Date: \(trip.date)")
            }
        } catch {
            print("❌ Failed to save trip: \(error.localizedDescription)")
        }

        DispatchQueue.main.async {
            showCreatePlanSheet = false
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
        do {
            let fetchedMeals: [MealEntry] = try modelContext.fetch(FetchDescriptor<MealEntry>())
            let filteredMeals = fetchedMeals.filter { $0.tripName == tripName }
            DispatchQueue.main.async {
                mealEntriesState = filteredMeals
            }
            print("✅ Meals successfully loaded into state: \(mealEntriesState.count)")
        } catch {
            print("❌ Failed to load meals: \(error.localizedDescription)")
        }
    }
}
struct FoodListView: View {
    var meals: [MealEntry]

    var body: some View {
        HStack(alignment: .top) {
            Rectangle()
                .frame(width: 2)
                .foregroundColor(.black)
                .padding(.leading, 22.0)
                .padding(.trailing, 10)

            VStack(alignment: .leading, spacing: 10) {
                ForEach(meals, id: \.recipeTitle) { meal in
                    Text(meal.recipeTitle)
                        .font(.body)
                }
            }
            .padding()
            .background(Color(red: 0.968, green: 0.957, blue: 0.957))
            .cornerRadius(10)

            Spacer()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
struct DaysView: View {
    var mealsForDay: [MealEntry]
    var deleteMeal: (MealEntry) -> Void
    var swapMeal: (MealEntry) -> Void

    var body: some View {
        ForEach(["Breakfast", "Lunch", "Dinner", "Snacks"], id: \.self) { mealType in
            let mealsForThisMealType = mealsForDay.filter { $0.meal == mealType }     
            VStack(alignment: .leading) {
                HStack {
                    Image(systemName: "circlebadge.fill")
                        .foregroundColor(Color.gray)
                        .padding(.leading)
                    Text(mealType)
                        .font(.title2)
                    
                    Spacer()
                }
                
                if mealsForThisMealType.isEmpty {
                    Text("No meals yet")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .padding(.leading, 40)
                } else {
                    VStack {
                        ForEach(mealsForThisMealType, id: \.recipeTitle) { meal in
                            HStack {
                                Button(action: { deleteMeal(meal) }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.red)
                                        .padding(.trailing, 10)
                                }
                                Text("\(meal.recipeTitle) \(meal.servings > 1 ? "(\(meal.servings) servings)" : "")")
                                    .font(.body)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                Button(action: { swapMeal(meal) }) {
                                    Image(systemName: "arrow.triangle.2.circlepath.circle.fill")
                                        .foregroundColor(.blue)
                                        .padding(.leading, 10)
                                }
                            }
                            .padding(.vertical, 5)
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .onAppear {
                print("🔍 DaysView rendering with \(mealsForDay.count) meals")
            }
            Rectangle()
                .frame(width: 300, height: 1.0)
                .foregroundColor(.black)
        }
    }
}
