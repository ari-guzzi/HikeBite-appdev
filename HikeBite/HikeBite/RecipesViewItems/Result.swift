//
//  Result.swift
//  HikeBite
//
//  Created by Ari Guzzi on 2/13/25.
//
import FirebaseFirestore
import SwiftUI

//struct Result: Codable, Identifiable, Equatable {
//    @DocumentID var id: String?
//    let title: String
//    var description: String
//    let filter: [String]
//    var ingredients: [IngredientPlain]
//    var imageURL: String?
//    static func == (lhs: Result, rhs: Result) -> Bool {
//        return lhs.id == rhs.id
//    }
//}
struct Result: Codable, Identifiable, Equatable {
    @DocumentID var id: String?
    let title: String
    var description: String
    let filter: [String]
    var ingredients: [IngredientPlain]
    var imageURL: String?
    let createdBy: String? // User ID of the recipe creator
    let timestamp: Date? // To store when it was created

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case description
        case filter
        case ingredients
        case imageURL = "image" // Assuming the API key for images is "image"
        case createdBy
        case timestamp
    }

    static func == (lhs: Result, rhs: Result) -> Bool {
        return lhs.id == rhs.id
    }
}
