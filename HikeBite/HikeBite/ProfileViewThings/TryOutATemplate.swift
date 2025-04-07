//
//  TryOutATemplate.swift
//  HikeBite
//
//  Created by Ari Guzzi on 4/2/25.
//

import SwiftUI

struct TryOutATemplate: View {
    @StateObject var viewModel = TemplateViewModel(fetchMeals: {})
    @Binding var selectedTemplate: MealPlanTemplate?
        @Binding var showTemplatePreview: Bool
        @Binding var selectedTab: Int
    let validIDs: Set<String> = ["2", "3", "7"]

    var body: some View {
        VStack(alignment: .leading) {
            Text("Try out a template")
                .font(Font.custom("FONTSPRINGDEMO-FieldsDisplaySemiBoldRegular", size: 24))
                .foregroundColor(.black)
                .padding(.horizontal)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(viewModel.templates.filter { validIDs.contains($0.id ?? "") }) { template in
                        TemplateBox(
                            selectedTemplate: $selectedTemplate,
                            showTemplatePreview: $showTemplatePreview,
                            selectedTab: $selectedTab,
                            template: template
                        )
                    }
                    .padding(.bottom, 10)
                    .shadow(color: .black.opacity(0.25), radius: 2, x: 0, y: 4)
                }
                .padding(.horizontal)
            }
        }
        .frame(width: UIScreen.main.bounds.width - 10)
        .onAppear {
            viewModel.loadTemplatesIfNeeded()
        }
    }
}

struct TemplateBox: View {
    @Binding var selectedTemplate: MealPlanTemplate?
        @Binding var showTemplatePreview: Bool
        @Binding var selectedTab: Int

    let template: MealPlanTemplate

    var dayCount: Int {
        template.mealTemplates.keys.count
    }

    var body: some View {
        VStack {
            Button {
                selectedTemplate = template
                selectedTab = 1
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    showTemplatePreview = true
                }
            } label: {
                VStack {
                    Text(template.title)
                        .font(.headline)
                        .foregroundColor(.black)
                        .multilineTextAlignment(.center)
                        .padding(.top, 8)
                    Spacer()
                    Text("\(dayCount) day\(dayCount > 1 ? "s" : "")")
                        .font(
                            Font.custom("FONTSPRINGDEMO-FieldsDisplayMediumRegular", size: 16)
                        )
                        .foregroundColor(.black)
                        .padding(.bottom, 8)
                }
                .frame(width: 120, height: 100)
                .background(Color.white)
                .cornerRadius(16)
                .shadow(color: .black.opacity(0.25), radius: 2, x: 0, y: 4)
            }
        }
    }
}
