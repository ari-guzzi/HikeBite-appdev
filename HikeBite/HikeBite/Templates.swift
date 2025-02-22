//
//  Templates.swift
//  HikeBite
//
//  Created by Ari Guzzi on 1/30/25.
//
import Firebase
import FirebaseFirestore
import FirebaseStorage
import Network
import SwiftUI

class TemplateViewModel: ObservableObject {
    @Published var templates: [MealPlanTemplate] = []
    var fetchMeals: () -> Void
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue.global(qos: .background)
    private var retryCount = 0
    @Published var isLoading = true
    var hasLoadedOnce = false
    init(fetchMeals: @escaping () -> Void) {
        self.fetchMeals = fetchMeals
        monitor.start(queue: queue)
    }
    func loadTemplatesFromFirestore() {
        if monitor.currentPath.status != .satisfied {
            print("⚠️ No network connection. Retrying in 1 second...")
            DispatchQueue.global().asyncAfter(deadline: .now() + 1) {
                self.loadTemplatesFromFirestore()
            }
            return
        }
        print("📢 Fetching templates from Firestore (Attempt \(retryCount + 1))...")
        let db = Firestore.firestore()
        isLoading = true
        db.collection("Templates").getDocuments { snapshot, error in
            if let error = error {
                print("❌ Firestore Error:", error.localizedDescription)
                if self.retryCount < 5 {
                    self.retryCount += 1
                    DispatchQueue.global().asyncAfter(deadline: .now() + 1) {
                        self.loadTemplatesFromFirestore()
                    }
                } else {
                    print("❌ Firestore failed after 5 retries.")
                }
                return
            }
            guard let documents = snapshot?.documents else {
                print("⚠️ No templates found. Retrying in 2 seconds...")
                DispatchQueue.global().asyncAfter(deadline: .now() + 2) {
                    self.loadTemplatesFromFirestore()
                }
                return
            }
            var loadedTemplates: [MealPlanTemplate] = []
            let group = DispatchGroup()
            for doc in documents {
                do {
                    var template = try doc.data(as: MealPlanTemplate.self)
                    group.enter()
                    self.loadImageURL(for: template) { updatedTemplate in
                        loadedTemplates.append(updatedTemplate)
                        group.leave()
                    }
                } catch {
                    print("⚠️ Error decoding template \(doc.documentID): \(error.localizedDescription)")
                }
            }
            group.notify(queue: .main) {
                DispatchQueue.main.async {
                    self.templates = loadedTemplates
                    self.hasLoadedOnce = true
                    self.retryCount = 0
                    self.isLoading = false
                    print("✅ Fully loaded templates:", self.templates)
                }
            }
        }
    }
    private func loadImageURL(for template: MealPlanTemplate, completion: @escaping (MealPlanTemplate) -> Void) {
        let storageRef = Storage.storage().reference(withPath: template.img)
        storageRef.downloadURL { url, error in
            if let error = error {
                print("⚠️ Error fetching image URL for \(template.title): \(error.localizedDescription)")
                completion(template)
                return
            }
            if let url = url {
                var updatedTemplate = template
                updatedTemplate.img = url.absoluteString
                completion(updatedTemplate)
            }
        }
    }
}
struct Templates: View {
    @StateObject var viewModel: TemplateViewModel
    @State var selectedTemplate: MealPlanTemplate?
    @Binding var selectedTrip: Trip?
    @State private var isShowingPreview = false
    @Binding var selectedTab: Int
    @State private var hasAttemptedFirstLoad = false

    init(selectedTrip: Binding<Trip?>, selectedTab: Binding<Int>, fetchMeals: @escaping () -> Void) {
        _selectedTrip = selectedTrip
        _selectedTab = selectedTab
        _viewModel = StateObject(wrappedValue: TemplateViewModel(fetchMeals: fetchMeals))
    }
    var body: some View {
        NavigationStack {
            if viewModel.isLoading {
                VStack {
                    ProgressView("Loading Templates...")
                        .progressViewStyle(CircularProgressViewStyle())
                        .padding()
                }
                .onAppear {
                    if !hasAttemptedFirstLoad {
                        viewModel.loadTemplatesFromFirestore()
                        hasAttemptedFirstLoad = true
                    }
                }
            } else {
                ScrollView {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 150))], spacing: 16) {
                        ForEach(viewModel.templates) { template in
                            Button {
                                selectedTemplate = template
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                    isShowingPreview = true
                                }
                            } label: {
                                VStack {
                                    AsyncImage(url: URL(string: template.img)) { phase in
                                        if let image = phase.image {
                                            image.resizable()
                                                .scaledToFit()
                                                .frame(height: 100)
                                                .cornerRadius(10)
                                        } else if phase.error != nil {
                                            Image(systemName: "photo")
                                                .resizable()
                                                .scaledToFit()
                                                .frame(height: 100)
                                                .cornerRadius(10)
                                        } else {
                                            ProgressView()
                                        }
                                    }
                                    Text(template.title)
                                        .font(.headline)
                                }
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(10)
                            }
                        }
                    }
                    .padding()
                }
                .navigationTitle("Meal Plan Templates")
                .onAppear {
                    print("🔄 Ensuring Firestore loads (First Attempt: \(hasAttemptedFirstLoad))")
                    if !hasAttemptedFirstLoad || !viewModel.hasLoadedOnce {
                        viewModel.loadTemplatesFromFirestore()
                        hasAttemptedFirstLoad = true
                    }
                }
                .onChange(of: selectedTab) { newValue in
                    if newValue == 1 {
                        print("🔄 Reloading Templates because tab switched")
                        viewModel.loadTemplatesFromFirestore()
                    }
                }
                .sheet(isPresented: Binding(
                    get: { isShowingPreview && selectedTemplate != nil },
                    set: { isShowingPreview = $0 }
                )) {
                    if var selectedTemplate = selectedTemplate {
                        TemplatePreviewView(
                            template: selectedTemplate,
                            selectedTrip: $selectedTrip,
                            selectedTab: $selectedTab,
                            dismissTemplates: {
                                isShowingPreview = false
                                selectedTemplate = MealPlanTemplate(id: "", title: "", img: "", mealTemplates: [:])
                            }
                        )
                        .id(selectedTemplate.id)
                    }
                }
            }
        }
    }
}
struct TemplatePreviewView: View {
    var template: MealPlanTemplate
    @State private var mealNames: [String: [String: String]] = [:]
    @State private var showPlanSelection = false
    @Binding var selectedTrip: Trip?
    @Binding var selectedTab: Int
    @Environment(\.modelContext) private var modelContext
    var dismissTemplates: () -> Void
    var body: some View {
        VStack {
            Text(template.title)
                .font(.largeTitle)
                .padding()
            
            List {
                ForEach(template.mealTemplates.keys.sorted(), id: \.self) { day in
                    Section(header: Text(day.capitalized)) {
                        ForEach(template.mealTemplates[day]!.keys.sorted(), id: \.self) { mealType in
                            Text("\(mealType.capitalized): \(mealNames[day]?[mealType] ?? "Loading...")")
                        }
                    }
                }
            }
            Button {
                showPlanSelection = true
            } label: {
                Label("Use This Template", systemImage: "checkmark.circle")
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .padding()
        }
        .onAppear {
            fetchMealNames()
            print("🔍 TemplatePreviewView Appeared")
            print("📝 Meal Templates Loaded:", template.mealTemplates)
            
            if template.mealTemplates.isEmpty {
                print("⚠️ mealTemplates is EMPTY! Firebase might not have returned data yet.")
            }
        }
        .sheet(isPresented: $showPlanSelection) {
            PlanSelectionView(
                template: template,
                selectedTrip: $selectedTrip,
                fetchMeals: {},
                dismissTemplates: {
                    showPlanSelection = false
                    dismissTemplates()},
                selectedTab: $selectedTab
            )
        }
    }
        // Fetches meal names from Firestore based on meal IDs
        func fetchMealNames() {
            let db = Firestore.firestore()
            var updatedMealNames = mealNames
            let group = DispatchGroup()
            for (day, meals) in template.mealTemplates {
                for (mealType, mealIDs) in meals {
                    for mealID in mealIDs {
                        let mealIDString = String(mealID)
                        group.enter()
                        db.collection("Recipes").document(mealIDString).getDocument { snapshot, error in
                            if let document = snapshot, document.exists {
                                let mealTitle = document.data()?["title"] as? String ?? "Unknown"
                                if updatedMealNames[day] == nil {
                                    updatedMealNames[day] = [:]
                                }
                                updatedMealNames[day]?[mealType] = mealTitle
                            } else {
                                print("⚠️ Meal ID \(mealID) not found in Recipes collection.")
                                if updatedMealNames[day] == nil {
                                    updatedMealNames[day] = [:]
                                }
                                updatedMealNames[day]?[mealType] = "Not Found"
                            }
                            group.leave()
                        }
                    }
                }
            }
            group.notify(queue: .main) {
                mealNames = updatedMealNames
            }
        }
    }
