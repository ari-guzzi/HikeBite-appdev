//
//  PlansView.swift
//  HikeBite
//
//  Created by Ari Guzzi on 1/17/25.
//
//

import SwiftUI
import SwiftData

struct PlansView: View {
    @Query private var mealEntries: [MealEntry]

    var body: some View {
        VStack {
            HStack {
                Spacer()
                Button {
                    print("Create a new plan")
                } label: {
                    HStack {
                        Text("Create New Plan")
                            .foregroundColor(Color.blue)
                        Image(systemName: "plus.circle")
                            .foregroundColor(.blue)
                    }
                }
                .padding()
            }
            ZStack {
                Image("backpacking")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 400)
                    .scaledToFit()
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                Text("Really Really Really Really Really Really Really Long Trip Name")
                    .font(.title)
                    .foregroundColor(Color.white)
                    .multilineTextAlignment(.center)
                    .frame(width: 350)
                    .offset(y: -90)
            }
            ScrollView {
                ForEach(["Day 1", "Day 2", "Day 3"], id: \.self) { day in
                    if mealEntries.contains(where: { $0.day == day }) {
                        Section(header: Text(day).font(.title).fontWeight(.bold).padding(.leading, 30)) {
                            DaysView(mealsForDay: mealEntries.filter { $0.day == day })
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    PlansView()
}
struct FoodListView: View {
    var meals: [MealEntry]

    var body: some View {
        HStack(alignment: .top) {
            Rectangle()
                .frame(width: 2)
                .foregroundColor(.black)
                .padding(.leading, 22.0)
                .padding(.trailing, 10)

            VStack(alignment: .leading, spacing: 10) {
                ForEach(meals, id: \.recipeTitle) { meal in
                    Text(meal.recipeTitle)
                }
            }
            .padding()
            .background(Color(red: 0.968, green: 0.957, blue: 0.957))
            .cornerRadius(10)

            Spacer()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
//struct FoodListView: View {
//    var body: some View {
//        HStack(alignment: .top) {
//            Rectangle()
//                .frame(width: 2)
//                .foregroundColor(.black)
//                .padding(.leading, 22.0)
//                .padding(.trailing, 10)
//            VStack(alignment: .leading, spacing: 10) {
//                Text("food 1")
//                Text("food 2")
//            }
//            .padding()
//            .background(Color(red: 0.9686274509803922, green: 0.9568627450980393, blue: 0.9568627450980393))
//            .cornerRadius(10)
//            Spacer()
//        }
//        .frame(maxWidth: .infinity, alignment: .leading)
//    }
//}
struct DaysView: View {
    var mealsForDay: [MealEntry]

    var body: some View {
        ForEach(["Breakfast", "Lunch", "Dinner", "Snacks"], id: \.self) { mealType in
            let mealsForThisMealType = mealsForDay.filter { $0.meal == mealType }

            if !mealsForThisMealType.isEmpty {
                HStack {
                    Image(systemName: "circlebadge.fill")
                        .foregroundColor(Color.gray)
                        .padding(.leading)

                    Text(mealType)
                        .font(.title2)

                    Spacer()
                }

                FoodListView(meals: mealsForThisMealType)
            }
        }

        Rectangle()
            .frame(width: 300, height: 1.0)
            .foregroundColor(.black)
    }
}
//struct DaysView: View {
//    var body: some View {
//        HStack {
//            Image(systemName: "circlebadge.fill")
//                .foregroundColor(Color(red: 0.6, green: 0.6, blue: 0.6))
//                .padding(.leading)
//            Text("Breakfast")
//                .font(.title2)
//            Spacer()
//            Text("x calories")
//                .font(.caption)
//            Text("x grams")
//                .font(.caption)
//        }
//        FoodListView()
//        HStack {
//            Image(systemName: "circlebadge.fill")
//                .foregroundColor(Color(red: 0.6, green: 0.6, blue: 0.6))
//                .padding(.leading)
//            Text("Lunch")
//                .font(.title2)
//            Spacer()
//            Text("x calories")
//                .font(.caption)
//            Text("x grams")
//                .font(.caption)
//        }
//        FoodListView()
//        HStack {
//            Image(systemName: "circlebadge.fill")
//                .foregroundColor(Color(red: 0.6, green: 0.6, blue: 0.6))
//                .padding(.leading)
//            Text("Dinner")
//                .font(.title2)
//            Spacer()
//            Text("x calories")
//                .font(.caption)
//            Text("x grams")
//                .font(.caption)
//        }
//        FoodListView()
//        HStack {
//            Image(systemName: "circlebadge.fill")
//                .foregroundColor(Color(red: 0.6, green: 0.6, blue: 0.6))
//                .padding(.leading)
//            Text("Snacks")
//                .font(.title2)
//            Spacer()
//            Text("x calories")
//                .font(.caption)
//            Text("x grams")
//                .font(.caption)
//        }
//        FoodListView()
//        Rectangle()
//            .frame(width: 300, height: 1.0)
//            .foregroundColor(.black)
//            
//    }
//}
