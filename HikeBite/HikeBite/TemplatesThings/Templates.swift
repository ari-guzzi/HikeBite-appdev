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
