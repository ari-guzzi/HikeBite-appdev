//
//  Amount.swift
//  DataFramework
//
//  Created by Ari Guzzi on 12/7/24.
//

import SwiftUI

struct Amount: Codable {
    let metric: Measurement
    let us: Measurement // swiftlint:disable:this identifier_name
}
