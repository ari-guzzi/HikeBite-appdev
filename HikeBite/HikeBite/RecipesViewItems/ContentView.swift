//
//  ContentView.swift
//  HikeBite
//
//  Created by Ari Guzzi on 1/13/25.
//
import Firebase
import FirebaseFirestore
import FirebaseStorage
import SwiftUI

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
    init(selectedTrip: Binding<Trip?>) {
                self._selectedTrip = selectedTrip
            UITableView.appearance().backgroundColor = .clear
            UITableViewCell.appearance().backgroundColor = .clear
        }
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(gradient: Gradient(colors: [.white, Color("AccentLight")]),
                               startPoint: .top,
                               endPoint: .bottom)
                .edgesIgnoringSafeArea([.top, .leading, .trailing])
                VStack {
                    HStack{
                        Text("Sort Meals")
                            .foregroundColor(Color("AccentColor"))
                            .padding(.leading, 30)
                        filterButton
                        Spacer()
                    }
                    filteredList
                    
                        .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "What are you looking for?")
                        .onChange(of: searchText) { newValue in
                            fetchData(searchQuery: newValue)
                        }
                        .navigationTitle("Meal Ideas")
                    
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
                            HStack{ Text("Upload a meal")
                                Image(systemName: "plus")
                                    .foregroundColor(.black)
                            }
                        }
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
            .listRowBackground(Color.clear)
            .padding(.horizontal, 10)  // Adds horizontal padding to each row
            .padding(.vertical, 5)  // Adds vertical padding to create space between rows
            .background(Color.white)  // Sets background color of each row
            .cornerRadius(10)  // Applies corner radius to each row's background
            .shadow(color: .gray, radius: 3, x: 0, y: 2)  // Adds shadow to each row
        }
        .listStyle(PlainListStyle())  // Removes default list styling
        .padding()
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
//    func fetchData(searchQuery: String = "") {
//        let db = Firestore.firestore()
//        let recipesRef = db.collection("Recipes")
//
//        // If search query is provided, filter results based on title
//        var query: Query = recipesRef
//        if !searchQuery.isEmpty {
//            query = query.whereField("title", isGreaterThanOrEqualTo: searchQuery)
//                         .whereField("title", isLessThanOrEqualTo: searchQuery + "\u{f8ff}")
//        }
//
//        query.getDocuments { snapshot, error in
//            if let error = error {
//                print("❌ Error fetching recipes: \(error.localizedDescription)")
//                return
//            }
//
//            guard let documents = snapshot?.documents else {
//                print("⚠️ No recipes found.")
//                return
//            }
//
//            let fetchedRecipes = documents.compactMap { doc -> Result? in
//                var result = try? doc.data(as: Result.self)
//                if let imagePath = result?.imageURL {
//                    getDownloadURL(for: imagePath) { url in
//                        result?.imageURL = url
//                    }
//                }
//                return result
//            }
////                do {
////                    return try doc.data(as: Result.self) // Decode documents into Result
////                } catch {
////                    print("⚠️ Failed to decode document: \(doc.documentID) - \(error)")
////                    return nil
////                }
////            }
//
//            DispatchQueue.main.async {
//                self.results = fetchedRecipes
//                print("✅ Fetched \(self.results.count) recipes.")
//            }
//        }
//    }
    func fetchData(searchQuery: String = "") {
        let db = Firestore.firestore()
        let recipesRef = db.collection("Recipes")
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

            var newResults = [Result]()  // Temporary storage for fetched results
            let group = DispatchGroup()  // Use a dispatch group to synchronize URL fetching

            for document in documents {
                var result = try? document.data(as: Result.self)
                if let imagePath = result?.img { // This should be a gs:// URL
                    group.enter()  // Enter the dispatch group
                    getDownloadURL(for: imagePath) { url in
                        DispatchQueue.main.async {
                            result?.img = url // Update the result with the HTTP URL
                            if let finalResult = result {
                                newResults.append(finalResult)
                            }
                            group.leave()  // Leave the dispatch group
                        }
                    }
                } else {
                    if let finalResult = result {
                        newResults.append(finalResult)
                    }
                }
            }


            group.notify(queue: .main) {  // Notify when all URLs have been fetched
                self.results = newResults
                print("✅ Fetched \(self.results.count) recipes with URLs.")
            }
        }
    }


}
struct RecipeRow: View {
    var item: Result

    var body: some View {
        VStack(alignment: .center) {
            HStack {
                AsyncImage(url: URL(string: item.img ?? "")) { phase in
                    switch phase {
                    case .success(let image):
                        image.resizable()
                             .aspectRatio(contentMode: .fill)
                             .frame(width: 100, height: 100)
                             .cornerRadius(8)
                    case .empty:
                        ProgressView()
                    case .failure(_):
                        Text("Unable to load image")
                        .frame(width: 100, height: 100)
                        .background(Color.gray)
                        .cornerRadius(8)
                    @unknown default:
                        EmptyView()
                    }
                }
                Text(item.title)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .multilineTextAlignment(.center)
            }
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
func getDownloadURL(for imageName: String, completion: @escaping (String?) -> Void) {
    let storageBaseURL = "gs://hikebite-48dbe.firebasestorage.app/"
    let fullPath = storageBaseURL + imageName
    let storageRef = Storage.storage().reference(forURL: fullPath)
    storageRef.downloadURL { url, error in
        if let error = error {
            print("Error fetching URL: \(error.localizedDescription)")
            completion(nil)
        } else if let url = url {
            print("Fetched URL: \(url.absoluteString)")
            completion(url.absoluteString)  // This is the HTTP URL
        }
    }
}


struct FilterView: View {
    @Binding var activeFilters: Set<String>
    let allFilters = [
        "no-stove", "no-water", "no-dairy", "vegan", "vegetarian", "fresh",
        "premade", "light-weight", "breakfast", "lunch", "dinner", "beverages", "snack"
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
