//
//  NoOpAppCheckProvider.swift
//  HikeBite
//
//  Created by Ari Guzzi on 2/21/25.
//
import Firebase
import FirebaseAppCheck
import SwiftUI

class NoOpAppCheckProvider: NSObject, AppCheckProvider {
    func getToken(completion: @escaping (AppCheckToken?, Error?) -> Void) {
        let fakeToken = AppCheckToken(token: "fake_app_check_token", expirationDate: Date().addingTimeInterval(3600))
        completion(fakeToken, nil)
    }
}

class NoOpAppCheckProviderFactory: NSObject, AppCheckProviderFactory {
    func createProvider(with app: FirebaseApp) -> AppCheckProvider? {
        return NoOpAppCheckProvider()
    }
}
