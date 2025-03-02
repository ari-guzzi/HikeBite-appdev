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

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case description
        case filter
        case ingredients
        case imageURL = "image" // Assuming the API key for images is "image"
    }

    static func == (lhs: Result, rhs: Result) -> Bool {
        return lhs.id == rhs.id
    }
}
