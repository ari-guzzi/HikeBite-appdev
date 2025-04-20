//
//  TripSummaryView.swift
//  HikeBite
//
//  Created by Ari Guzzi on 4/4/25.
//
import SwiftData
import SwiftUI

struct TripSummaryView: View {
    @Environment(\.modelContext) private var modelContext
    @ObservedObject var tripManager: TripManager
    @Environment(\.dismiss) private var dismiss
    // @State private var meals: [MealEntry] = []
    var source: TripSummarySource
    @Binding var selectedTrip: Trip?
    @Binding var selectedTab: Int
    var trip: Trip
    // var allMeals: [MealEntry]
    // @Query private var allMealEntries: [MealEntry]
    @State private var filteredMeals: [MealEntry] = []
    var allMeals: [MealEntry]

//    var filteredMeals: [MealEntry] {
//        allMealEntries.filter { $0.tripName == trip.name }
//    }

    var onDone: () -> Void
    @Binding var isPresented: Bool
    @Binding var shouldNavigateToPlans: Bool
    var body: some View {
        ZStack {
            BackgroundGradient()
        VStack {
            ScrollView {
                VStack(spacing: 16) {
                    HStack {
                        Spacer()
                        Text(trip.name)
                            .font(Font.custom("FONTSPRINGDEMO-FieldsDisplaySemiBoldRegular", size: 28))
                            .padding(.bottom, 4)
                        Spacer()
                        Button(action: {
                            switch source {
                            case .plansView:
                                isPresented = false
                            case .profileView, .tripsView:
                                isPresented = false
                                selectedTrip = nil
                                tripManager.lastNavigatedTripID = nil
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                                    selectedTrip = trip
                                    selectedTab = 2
                                }
                            }
                        }) {
                            Image(systemName: "square.and.pencil")
                                .font(.system(size: 24))
                        }
                    }
                    Text("Duration: \(trip.days) days")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                    summaryStats
                    
                    Divider()
                    
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Meals by Day")
                            .font(.headline)
                            .padding(.bottom, 5)
                        
                        ForEach(groupedMeals.keys.sorted(), id: \.self) { day in
                            VStack(alignment: .leading) {
                                Text(day)
                                    .font(.subheadline)
                                    .fontWeight(.bold)
                                
                                ForEach(groupedMeals[day] ?? []) { meal in
                                    Text("• \(meal.meal): \(meal.recipeTitle) (\(meal.servings)x)")
                                        .font(.caption)
                                }
                            }
                            .padding(.bottom, 6)
                        }
                    }
                    .padding()
                }
                .padding()
            }
            
            //            Button("Close") {
            //                dismiss()
            //                onDone()
            //            }
            Button("Close") {
                switch source {
                case .plansView:
                    // If you came *from* PlansView, go back to TripsView
                    selectedTrip = nil
                    tripManager.lastNavigatedTripID = nil
                    selectedTab = 2  // Switch to the profile tab
                    shouldNavigateToPlans = false
                    dismiss()        // Dismiss the sheet
                case .profileView, .tripsView:
                    dismiss()        // Just dismiss the sheet
                }
                onDone() // always call the completion handler
            }
            
            .padding(.horizontal, 30)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 30)
                    .fill(Color("AccentColor"))
            )
            .foregroundColor(.white)
            .font(Font.custom("FONTSPRINGDEMO-FieldsDisplayMediumRegular", size: 16))
            .padding(.bottom)
        }
        .onAppear {
            filteredMeals = allMeals.filter { $0.tripName == trip.name }
        }
    }
    }
    private var summaryStats: some View {
        let totalCalories = filteredMeals.reduce(0) { $0 + $1.totalCalories }
        let totalGrams = filteredMeals.reduce(0) { $0 + $1.totalGrams }

        return VStack(alignment: .leading, spacing: 4) {
            Text("Total Meals: \(filteredMeals.count)")
            Text("Total Calories: \(totalCalories)")
            Text("Total Weight: \(totalGrams) g")
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
    private var groupedMeals: [String: [MealEntry]] {
        Dictionary(grouping: filteredMeals, by: { $0.day })
    }
}
enum TripSummarySource {
    case plansView
    case profileView
    case tripsView
}
