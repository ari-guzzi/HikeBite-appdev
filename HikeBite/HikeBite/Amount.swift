//
//  Amount.swift
//  HikeBite
//
//  Created by Ari Guzzi on 1/13/25.
//


import SwiftUI

struct Amount: Codable {
    let metric: Measurement
    let us: Measurement // swiftlint:disable:this identifier_name
}

