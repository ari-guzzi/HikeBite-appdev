//
//  Trip.swift
//  HikeBite
//
//  Created by Ari Guzzi on 2/9/25.
//

import Foundation
import SwiftData

@Model
class Trip {
    var name: String
    var days: Int
    var date: Date

    init(name: String, days: Int, date: Date) {
        self.name = name
        self.days = days
        self.date = date
    }
}
