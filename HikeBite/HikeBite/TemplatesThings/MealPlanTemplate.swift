//
//  MealPlanTemplate.swift
//  HikeBite
//
//  Created by Ari Guzzi on 2/2/25.
//
import FirebaseFirestore
import SwiftUI

struct MealPlanTemplate: Identifiable, Codable {
    @DocumentID var id: String?
    var title: String
    var img: String
    var mealTemplates: [String: [String: [Int]]]
    var mealNames: [String: [String: String]] = [:]

    enum CodingKeys: String, CodingKey {
        case id, title, img, mealTemplates
    }
}
