//
//  User.swift
//  HikeBite
//
//  Created by Ari Guzzi on 3/2/25.
//

import Foundation
import SwiftUI

struct User: Identifiable, Codable {
    let id: String
    let fullname: String
    let email: String
    var initials: String {
        let formatter = PersonNameComponentsFormatter()
        if let components = formatter.personNameComponents(from: fullname) {
            formatter.style = .abbreviated
            return formatter.string(from: components)
        }
        return ""
    }
}

extension User {
    static var mockUser = User(id: NSUUID().uuidString, fullname: "Ari Guzzi", email: "ari@ari.com")
}
