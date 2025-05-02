//
//  UpcomingTripCardPlansView.swift
//  HikeBite
//
//  Created by Ari Guzzi on 3/15/25.
//
import SwiftData
import SwiftUI

struct UpcomingTripCardPlansView: View {
    @Binding var shouldNavigateToPlans: Bool
    @Environment(\.modelContext) private var modelContext
    @ObservedObject var tripManager: TripManager
    var trip: Trip
        var allMealEntries: [MealEntry]
        @Binding var selectedTrip: Trip?
        @Binding var selectedTab: Int
    var body: some View {
        ZStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 0) {
                ZStack(alignment: .bottom) {
                    // Background image rectangle
                    Rectangle()
                        .foregroundColor(.clear)
                        .frame(width: 179, height: 171)
                        .background(
                            Image("pinetrees")
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 179, height: 171)
                                .clipped()
                        )
                        .cornerRadius(9)
                        .shadow(color: .black.opacity(0.25), radius: 2, x: 0, y: 4)

                    // Gradient overlay rectangle
                    Rectangle()
                        .foregroundColor(.clear)
                        .frame(width: 179, height: 172)
                        .background(
                            LinearGradient(
                                stops: [
                                    Gradient.Stop(color: .white.opacity(0), location: 0.00),
                                    Gradient.Stop(color: .white.opacity(0.5), location: 0.65),
                                    Gradient.Stop(color: .white, location: 1.00),
                                ],
                                startPoint: UnitPoint(x: 0.5, y: 0),
                                endPoint: UnitPoint(x: 0.5, y: 0.62)
                            )
                        )
                        .cornerRadius(9)
                        .shadow(color: .black.opacity(0.25), radius: 2, x: 0, y: 4)

                    // Bottom content
                    VStack(alignment: .leading) {
                        Text(trip.name)
                            .font(Font.custom("Area Normal", size: 16).weight(.bold))
                            .foregroundColor(.black)
                        HStack {
                            NavigationLink(destination:
                                            TripSummaryView(
                                                tripManager: tripManager,
                                                source: .tripsView,
                                                selectedTrip: $selectedTrip,
                                                selectedTab: $selectedTab,
                                                trip: trip,
                                                allMeals: allMealEntries,
                                                onDone: {},
                                                isPresented: .constant(false),
                                                shouldNavigateToPlans: .constant(false)
                                            )
                            ) {
                                Text("View Summary")
                                    .font(.system(size: 10, weight: .medium))
                                    .foregroundColor(.accentColor)
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 10)
                                    .background(Color("AccentLight").opacity(0.07))
                                    .cornerRadius(10)
                                    .shadow(color: .black.opacity(0.3), radius: 12, x: 0, y: 10)
                            }
                            Spacer()
                            Image(systemName: "arrow.right")
                                                            .frame(width: 24, height: 24)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom)
                }
            }

            // Date badge on top of the image
            Text(trip.date.formatted(date: .long, time: .omitted))
                .font(Font.custom("Fields", size: 12).weight(.medium))
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .cornerRadius(6)
                .foregroundColor(.white)
                .shadow(radius: 2)
                .padding(.top, 8)
        }
        .frame(width: 179, height: 171)
        .padding(0)
    }
}
