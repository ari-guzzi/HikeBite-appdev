//
//  TripManager.swift
//  HikeBite
//
//  Created by Ari Guzzi on 2/14/25.
//
import Combine
import Foundation
import SwiftData
import FirebaseFirestore

@MainActor  // Ensures all updates are done on the main thread
class TripManager: ObservableObject {
    @Published var allRecipes: [Result] = []
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
    func fetchRecipes() {
        let db = Firestore.firestore()
        db.collection("Recipes").getDocuments { snapshot, error in
            if let error = error {
                print("❌ Error fetching recipes: \(error.localizedDescription)")
                return
            }

            guard let documents = snapshot?.documents else {
                print("🚫 No recipe documents found")
                return
            }

            print("📦 Firestore returned \(documents.count) documents")

            for doc in documents {
                let rawID = doc.documentID
                let rawData = doc.data()
                print("📄 Document ID: \(rawID)")
                print("📄 Raw Data: \(rawData)")
                
                do {
                    let recipe = try doc.data(as: Result.self)
                    print("✅ Recipe decoded: \(recipe.title), id: \(recipe.id ?? "nil")")
                } catch {
                    print("❌ Failed to decode recipe: \(error)")
                }
            }


            let recipes: [Result] = documents.compactMap { doc in
                do {
                    let recipe = try doc.data(as: Result.self)
                    print("✅ Loaded recipe: \(recipe.title), id: \(recipe.id ?? "nil")")
                    return recipe
                } catch {
                    print("❌ Could not decode recipe: \(error.localizedDescription)")
                    return nil
                }
            }
            

            DispatchQueue.main.async {
                self.allRecipes = recipes
                print("📖 Total loaded: \(recipes.count)")
            }
        }
    }

    deinit {
        print("TripManager is being deinitialized")
    }
}

