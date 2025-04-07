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
    @Binding var selectedTrip: Trip?
    @Binding var selectedTab: Int
    @State private var hasAttemptedFirstLoad = false
    @Binding var externalSelectedTemplate: MealPlanTemplate?
    @Binding var externalShowPreview: Bool
    init(
        selectedTrip: Binding<Trip?>,
        selectedTab: Binding<Int>,
        fetchMeals: @escaping () -> Void,
        externalSelectedTemplate: Binding<MealPlanTemplate?>,
        externalShowPreview: Binding<Bool>
    ) {
        _selectedTrip = selectedTrip
        _selectedTab = selectedTab
        _externalSelectedTemplate = externalSelectedTemplate
        _externalShowPreview = externalShowPreview
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
                            viewModel.loadTemplatesIfNeeded();                            hasAttemptedFirstLoad = true
                        }
                    }
                } else {
                    ZStack {
                        LinearGradient(gradient: Gradient(colors: [.white, Color("AccentLight")]),
                                       startPoint: .top,
                                       endPoint: .bottom)
                            .edgesIgnoringSafeArea([.top, .leading, .trailing])

                        ScrollView {
                            ZStack {
                                FunnyLines()
                                    .edgesIgnoringSafeArea(.all)
                                LazyVGrid(columns: [GridItem(.adaptive(minimum: 150))], spacing: 16) {
                                    ForEach(viewModel.templates) { template in
                                        Button {
                                            externalSelectedTemplate = template
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                                externalShowPreview = true
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
                                            .frame(width: 179, height: 200)
                                            .background(Color(.systemGray6))
                                            .cornerRadius(10)
                                        }
                                    }
                                }
                                .padding()
                            }
                        }
                    .navigationTitle("Templates")
                    .onAppear {
                        let attrs = [
                           NSAttributedString.Key.foregroundColor: UIColor.black,
                           NSAttributedString.Key.font: UIFont(name: "FONTSPRINGDEMO-FieldsDisplaySemiBoldRegular", size: 48)!
                       ]
                       UINavigationBar.appearance().titleTextAttributes = attrs
                       UINavigationBar.appearance().largeTitleTextAttributes = attrs
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
                        get: { externalShowPreview && externalSelectedTemplate != nil },
                        set: { externalShowPreview = $0 }
                    )) {
                        if var selectedTemplate = externalSelectedTemplate {
                            TemplatePreviewView(
                                template: selectedTemplate,
                                selectedTrip: $selectedTrip,
                                selectedTab: $selectedTab,
                                dismissTemplates: {
                                    externalShowPreview = false
                                    externalSelectedTemplate = MealPlanTemplate(id: "", title: "", img: "", mealTemplates: [:])
                                }
                            )
                            .id(selectedTemplate.id)
                        }
                    }
                }
            }
        }
    }
}
