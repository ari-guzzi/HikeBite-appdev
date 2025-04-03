//
//  DiscoverMealIdeas.swift
//  HikeBite
//
//  Created by Ari Guzzi on 4/2/25.
//

import SwiftUI

struct DiscoverMealIdeas: View {
    let results: [Result]
    let entries: [MealEntry]
    
    let validIDs: Set<String> = ["19", "35", "18"]
    
    var body: some View {
        let filteredResults = results.filter { validIDs.contains($0.id ?? "") }
        ScrollView {
            ZStack {
                Image("wood")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 442, height: 449)
                    .clipped()
                    .opacity(0.3)
                    .background(.white)
                VStack(spacing: 16) {
                    HStack {
                        Text("Discover new meal ideas")
                            .font(Font.custom("FONTSPRINGDEMO-FieldsDisplaySemiBoldRegular", size: 24))
                            .foregroundColor(.black)
                        Spacer()
                    }
                    .padding(.horizontal)
                    if filteredResults.isEmpty {
                        Text("No meal ideas found.")
                            .foregroundColor(.gray)
                            .padding()
                    }
                    ForEach(filteredResults) { result in
                        let entry = entries.first(where: { $0.recipeTitle == result.title })
                        MealIdeaBox(result: result, entry: entry) {
                            print("Add tapped for \(result.title)")
                        }
                    }
                    
                    .frame(width: UIScreen.main.bounds.width - 25)
                    Spacer()
                }
                .padding()
            }
            .background(Color.clear)
            .scrollIndicators(.hidden)
        }
    }
}

struct MealIdeaBox: View {
    let result: Result
    let entry: MealEntry?
    let onAdd: () -> Void

    var body: some View {
        HStack(alignment: .center) {
            
            // Meal image
            if let imgURL = result.img, let url = URL(string: imgURL) {
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 60, height: 60)
                        .clipped()
                        .cornerRadius(8)
                } placeholder: {
                    Color.gray.frame(width: 60, height: 60).cornerRadius(8)
                }
            }

            // Title + calories
            VStack(alignment: .leading, spacing: 4) {
                Text(result.title)
                    .font(.headline)
                    .foregroundColor(.black)

//                if let calories = entry?.totalCalories {
//                    Text("\(calories) cal")
//                        .font(.subheadline)
//                        .foregroundColor(.gray)
//                } else {
//                    Text("— cal")
//                        .font(.subheadline)
//                        .foregroundColor(.gray)
//                }
            }

            Spacer()

            // Plus button
            Button(action: onAdd) {
                Image(systemName: "plus.circle")
                    .font(.title)
                    .foregroundColor(.accentColor)
                    .frame(width: 44, height: 44)
                    .clipShape(Circle())
            }
        }
        .padding()
        .foregroundColor(.clear)
        .frame(width: 353, height: 80)
        .background(Color.white)
        .cornerRadius(15)
        .shadow(color: .black.opacity(0.25), radius: 2, x: 0, y: 4)
    }
}
