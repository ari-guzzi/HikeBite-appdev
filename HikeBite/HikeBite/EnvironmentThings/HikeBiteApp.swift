//
//  HikeBiteApp.swift
//  HikeBite
//
//  Created by Ari Guzzi on 1/13/25.
//
import Firebase
import FirebaseAppCheck
import FirebaseAuth
import FirebaseCore
import FirebaseFirestore
import FirebaseStorage
import SwiftUI

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        let attrs = [
            NSAttributedString.Key.foregroundColor: UIColor.black,
            NSAttributedString.Key.font: UIFont(name: "FONTSPRINGDEMO-FieldsDisplaySemiBoldRegular", size: 27)!
        ]
        UINavigationBar.appearance().titleTextAttributes = attrs
        // Aggressively Disable DeviceCheck BEFORE Firebase Initializes
        disableDeviceCheck()
        // Ensure Firebase does not use DeviceCheck
        UserDefaults.standard.set(false, forKey: "FirebaseAppCheckUseDeviceCheck")
        FirebaseApp.configure()
        // Override Firebase App Check provider to prevent DeviceCheck leaks
        let providerFactory = NoOpAppCheckProviderFactory()
        AppCheck.setAppCheckProviderFactory(providerFactory)
        let settings = Firestore.firestore().settings
        settings.isPersistenceEnabled = false  // Disable offline persistence
        Firestore.firestore().settings = settings
        return true
    }
    // Force Disable DeviceCheck API by Swizzling its Method (Last Resort)
    private func disableDeviceCheck() {
        let deviceCheckClass: AnyClass? = NSClassFromString("DCDevice")
        if let originalMethod = class_getInstanceMethod(deviceCheckClass, Selector(("isSupported"))),
           let newMethod = class_getInstanceMethod(AppDelegate.self, #selector(fakeIsSupported)) {
            method_exchangeImplementations(originalMethod, newMethod)
        }
    }
    // Fake method to return `false` for DeviceCheck
    @objc private func fakeIsSupported() -> Bool {
        return false
    }
}

@main
struct HikeBiteApp: App {
    @StateObject private var tripManager = TripManager()
    @StateObject var viewModel = AuthViewModel()
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    var body: some Scene {
        WindowGroup {
            MainView()
        }
        .environmentObject(viewModel)
        .environmentObject(tripManager)
        .modelContainer(for: [GroceryItem.self, MealEntry.self, Trip.self], inMemory: false)
    }
}
