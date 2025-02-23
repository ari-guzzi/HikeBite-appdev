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

//class AppDelegate: NSObject, UIApplicationDelegate {
//    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
//        FirebaseApp.configure()
//
//        #if DEBUG
//        let providerFactory = AppCheckDebugProviderFactory()
//        AppCheck.setAppCheckProviderFactory(providerFactory)
//        print("✅ Firebase App Check using Debug Mode")
//        #endif
//
//        return true
//    }
//}

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        // Aggressively Disable DeviceCheck BEFORE Firebase Initializes
        disableDeviceCheck()
        // Ensure Firebase does not use DeviceCheck
        UserDefaults.standard.set(false, forKey: "FirebaseAppCheckUseDeviceCheck")
        FirebaseApp.configure()
        // Override Firebase App Check provider to prevent DeviceCheck leaks
        let providerFactory = NoOpAppCheckProviderFactory()
        AppCheck.setAppCheckProviderFactory(providerFactory)
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
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    var body: some Scene {
        WindowGroup {
            MainView()
        }
        .modelContainer(for: [GroceryItem.self, MealEntry.self, Trip.self], inMemory: false)
    }
}
