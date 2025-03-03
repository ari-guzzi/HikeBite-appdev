//
//  ContentView.swift
//  HikeBite
//
//  Created by Ari Guzzi on 1/13/25.
//
import SwiftUI
import Firebase
import FirebaseFirestore
import FirebaseStorage

struct ContentView: View {
    @State private var searchText = ""
    @State private var results = [Result]()
    @State private var activeFilters: Set<String> = []
    @State private var showingFilter = false
    @Binding var selectedTrip: Trip?
    var apiKey: String? {
        Bundle.main.object(forInfoDictionaryKey: "API_KEY") as? String
    }
    var baseURL: String? {
        Bundle.main.object(forInfoDictionaryKey: "API_BASE_URL") as? String
    }
    var body: some View {
        NavigationView {
            VStack {
                filteredList
                    .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search Recipes")
                    .onChange(of: searchText) { newValue in
                        fetchData(searchQuery: newValue)
                    }
                    .navigationTitle("Recipe Search")
                    .toolbar {
                        filterButton
                    }
                    .sheet(isPresented: $showingFilter) {
                        FilterView(activeFilters: $activeFilters) {
                            showingFilter = false
                        }
                    }
            }
            
            .onAppear {
                if FirebaseApp.app() != nil {
                    fetchData()
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: AddRecipeView()) {
                        Image(systemName: "plus")
                    }
                }
            }
        }
    }
    var filteredList: some View {
        List(results.filter(shouldIncludeResult), id: \.id) { item in
            NavigationLink(destination: RecipeDetailView(recipe: item)) {
                RecipeRow(item: item)
            }
        }
        .listStyle(PlainListStyle())
    }
    var filterButton: some View {
        Button(action: {
            showingFilter.toggle()
        }) {
            Image(systemName: activeFilters.isEmpty ? "line.horizontal.3.decrease.circle" : "line.horizontal.3.decrease.circle.fill")
                .foregroundColor(activeFilters.isEmpty ? .primary : .blue)
        }
    }
    func shouldIncludeResult(_ result: Result) -> Bool {
        activeFilters.isEmpty || Set(activeFilters).isSubset(of: Set(result.filter))
    }
//            func fetchData(searchQuery: String = "") {
//                let db = Firestore.firestore()
//                var query: Query = db.collection("Recipes")
//                if !searchQuery.isEmpty {
//                    query = query.whereField("title", isGreaterThanOrEqualTo: searchQuery)
//                        .whereField("title", isLessThanOrEqualTo: searchQuery + "\u{f8ff}")
//                }
//                query.getDocuments { snapshot, error in
//                    if let error = error {
//                        print("Error fetching recipes: \(error.localizedDescription)")
//                        return
//                    }
//                    guard let documents = snapshot?.documents else {
//                        print("No recipes found")
//                        return
//                    }
//                    self.results = documents.compactMap { document in
//                        try? document.data(as: Result.self)
//                    }
//                }
//            }
    func fetchData(searchQuery: String = "") {
        let db = Firestore.firestore()
        let recipesRef = db.collection("Recipes")

        // If search query is provided, filter results based on title
        var query: Query = recipesRef
        if !searchQuery.isEmpty {
            query = query.whereField("title", isGreaterThanOrEqualTo: searchQuery)
                         .whereField("title", isLessThanOrEqualTo: searchQuery + "\u{f8ff}")
        }

        query.getDocuments { snapshot, error in
            if let error = error {
                print("❌ Error fetching recipes: \(error.localizedDescription)")
                return
            }

            guard let documents = snapshot?.documents else {
                print("⚠️ No recipes found.")
                return
            }

            let fetchedRecipes = documents.compactMap { doc -> Result? in
                do {
                    return try doc.data(as: Result.self) // Decode documents into Result
                } catch {
                    print("⚠️ Failed to decode document: \(doc.documentID) - \(error)")
                    return nil
                }
            }

            DispatchQueue.main.async {
                self.results = fetchedRecipes
                print("✅ Fetched \(self.results.count) recipes.")
            }
        }
    }

}
    struct RecipeRow: View {
        var item: Result
        var body: some View {
            VStack(alignment: .center) {
                Text(item.title)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .multilineTextAlignment(.center)
            }
        }
    }
    struct RecipeSearch: Codable {
        let offset, number: Int?
        let results: [Result]
        let totalResults: Int
    }
    struct SupportInfo: Codable {
        let url: String
        let text: String
    }
    func getDownloadURL(for storagePath: String, completion: @escaping (String?) -> Void) {
        let storageRef = Storage.storage().reference(forURL: storagePath)
        storageRef.downloadURL { url, error in
            if let error = error {
                completion(nil)
            } else if let url = url {
                completion(url.absoluteString)
            }
        }
    }
struct FilterView: View {
    @Binding var activeFilters: Set<String>
    let allFilters = [
        "no-stove", "no-water", "dairy-free", "vegan", "vegetarian", "fresh",
        "premade", "light-weight", "breakfast", "lunch", "dinner", "beverages", "snacks"
    ]
    var onDone: () -> Void
    var body: some View {
        NavigationView {
            List(allFilters, id: \.self) { filter in
                HStack {
                    Text(filter.capitalized)
                    Spacer()
                    Image(systemName: activeFilters.contains(filter) ? "checkmark.circle.fill" : "circle")
                        .foregroundColor(activeFilters.contains(filter) ? .blue : .gray)
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    toggleFilter(filter)
                }
            }
            .navigationTitle("Filters")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        onDone()
                    }
                }
            }
        }
    }
    private func toggleFilter(_ filter: String) {
        if activeFilters.contains(filter) {
            activeFilters.remove(filter)
        } else {
            activeFilters.insert(filter)
        }
    }
}
