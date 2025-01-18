//
//  PlansView.swift
//  HikeBite
//
//  Created by Ari Guzzi on 1/17/25.
//

import SwiftUI

struct PlansView: View {
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
                HStack {
                    Text("Day 1")
                        .font(.title)
                        .fontWeight(.bold)
                        .padding(.leading, 30.0)
                    Spacer()
                    Text("x calories")
                    Text("x grams")
                }
                DaysView()
                HStack {
                    Text("Day 2")
                        .font(.title)
                        .fontWeight(.bold)
                        .padding(.leading, 30.0)
                    Spacer()
                    Text("x calories")
                    Text("x grams")
                }
                DaysView()
                HStack {
                    Text("Day 3")
                        .font(.title)
                        .fontWeight(.bold)
                        .padding(.leading, 30.0)
                    Spacer()
                    Text("x calories")
                    Text("x grams")
                }
                DaysView()
            }
        }
    }
}

#Preview {
    PlansView()
}

struct FoodListView: View {
    var body: some View {
        HStack(alignment: .top) {
            Rectangle()
                .frame(width: 2)
                .foregroundColor(.black)
                .padding(.leading, 22.0)
                .padding(.trailing, 10)
            VStack(alignment: .leading, spacing: 10) {
                Text("food 1")
                Text("food 2")
            }
            .padding()
            .background(Color(red: 0.9686274509803922, green: 0.9568627450980393, blue: 0.9568627450980393))
            .cornerRadius(10)
            Spacer()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct DaysView: View {
    var body: some View {
        HStack {
            Image(systemName: "circlebadge.fill")
                .foregroundColor(Color(red: 0.6, green: 0.6, blue: 0.6))
                .padding(.leading)
            Text("Breakfast")
                .font(.title2)
            Spacer()
            Text("x calories")
                .font(.caption)
            Text("x grams")
                .font(.caption)
        }
        FoodListView()
        HStack {
            Image(systemName: "circlebadge.fill")
                .foregroundColor(Color(red: 0.6, green: 0.6, blue: 0.6))
                .padding(.leading)
            Text("Lunch")
                .font(.title2)
            Spacer()
            Text("x calories")
                .font(.caption)
            Text("x grams")
                .font(.caption)
        }
        FoodListView()
        HStack {
            Image(systemName: "circlebadge.fill")
                .foregroundColor(Color(red: 0.6, green: 0.6, blue: 0.6))
                .padding(.leading)
            Text("Dinner")
                .font(.title2)
            Spacer()
            Text("x calories")
                .font(.caption)
            Text("x grams")
                .font(.caption)
        }
        FoodListView()
        HStack {
            Image(systemName: "circlebadge.fill")
                .foregroundColor(Color(red: 0.6, green: 0.6, blue: 0.6))
                .padding(.leading)
            Text("Snacks")
                .font(.title2)
            Spacer()
            Text("x calories")
                .font(.caption)
            Text("x grams")
                .font(.caption)
        }
        FoodListView()
        Rectangle()
            .frame(width: 300, height: 1.0)
            .foregroundColor(.black)
            
    }
}
