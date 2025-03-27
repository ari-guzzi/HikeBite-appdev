//
//  TripManager.swift
//  HikeBite
//
//  Created by Ari Guzzi on 2/14/25.
//
import Combine
import Foundation
import SwiftData

@MainActor  // Ensures all updates are done on the main thread
class TripManager: ObservableObject {
    @Published var trips: [Trip] = [] {
        didSet {
            objectWillChange.send()  // Forces SwiftUI to refresh
        }
    }
    func fetchTrips(modelContext: ModelContext) {
        do {
            let fetchedTrips: [Trip] = try modelContext.fetch(FetchDescriptor<Trip>())
            if fetchedTrips.isEmpty {
                print("🚨 No trips found after fetch.")
            } else {
                print("📂 TripManager Fetch: \(fetchedTrips.count) trips found.")
            }
            trips = fetchedTrips
        } catch {
            print("❌ Failed to fetch trips: \(error.localizedDescription)")
        }
    }

//    func fetchTrips(modelContext: ModelContext) {
//        do {
//            let fetchedTrips: [Trip] = try modelContext.fetch(FetchDescriptor<Trip>())
//            print("Fetched trips: \(fetchedTrips.map { $0.name })")
//            print("📂 TripManager Fetch: \(fetchedTrips.count) trips found.")
//
//            DispatchQueue.main.async { [weak self] in
//                guard let self = self else { return }
//                self.trips = fetchedTrips
//            }
//        } catch {
//            print("❌ Failed to fetch trips: \(error.localizedDescription)")
//        }
//    }
    deinit {
        print("TripManager is being deinitialized")
    }
}

