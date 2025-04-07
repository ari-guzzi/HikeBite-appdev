////
////  TemplateViewModel.swift
////  HikeBite
////
////  Created by Ari Guzzi on 2/23/25.
////

import Firebase
import FirebaseFirestore
import FirebaseStorage
import Network
import SwiftUI

class TemplateViewModel: ObservableObject {
    @Published var templates: [MealPlanTemplate] = []
    var fetchMeals: () -> Void
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue.global(qos: .background)
    private var retryCount = 0
    @Published var isLoading = true
    var hasLoadedOnce = false
    init(fetchMeals: @escaping () -> Void) {
        self.fetchMeals = fetchMeals
        monitor.start(queue: queue)
        monitor.pathUpdateHandler = { [weak self] path in
            if path.status == .satisfied {
                print("Network is available.")
                self?.loadTemplatesFromFirestore()
            } else {
                print("Network is unavailable.")
            }
        }
    }
   func loadTemplatesIfNeeded() {
       guard !hasLoadedOnce, monitor.currentPath.status == .satisfied else { return }
       loadTemplatesFromFirestore()
   }
    func loadTemplatesFromFirestore() {
        guard monitor.currentPath.status == .satisfied else {
            print("⚠️ No network connection. Retrying in 1 second...")
            DispatchQueue.global().asyncAfter(deadline: .now() + 1) {
                self.loadTemplatesFromFirestore()
            }
            return
        }
        print("📢 Fetching templates from Firestore (Attempt \(retryCount + 1))...")
        let db = Firestore.firestore()
        DispatchQueue.main.async {
            self.isLoading = true
        }
        db.collection("Templates").getDocuments { snapshot, error in
            if let error = error {
                print("❌ Firestore Error:", error.localizedDescription)
                if self.retryCount < 5 {
                    self.retryCount += 1
                    DispatchQueue.global().asyncAfter(deadline: .now() + 1) {
                        self.loadTemplatesFromFirestore()
                    }
                } else {
                    print("❌ Firestore failed after 5 retries.")
                }
                return
            }
            guard let documents = snapshot?.documents else {
                print("⚠️ No templates found. Retrying in 2 seconds...")
                DispatchQueue.global().asyncAfter(deadline: .now() + 2) {
                    self.loadTemplatesFromFirestore()
                }
                return
            }
            var loadedTemplates: [MealPlanTemplate] = []
            let group = DispatchGroup()
            for doc in documents {
                do {
                    var template = try doc.data(as: MealPlanTemplate.self)
                    group.enter()
                    self.loadImageURL(for: template) { updatedTemplate in
                        loadedTemplates.append(updatedTemplate)
                        group.leave()
                    }
                } catch {
                    print("⚠️ Error decoding template \(doc.documentID): \(error.localizedDescription)")
                }
            }
            group.notify(queue: .main) {
                self.templates = loadedTemplates
                self.hasLoadedOnce = true
                self.retryCount = 0
                self.isLoading = false
                // print("✅ Fully loaded templates:", self.templates)
            }
        }
    }

    private func loadImageURL(for template: MealPlanTemplate, completion: @escaping (MealPlanTemplate) -> Void) {
        let storageRef = Storage.storage().reference(withPath: template.img)
        storageRef.downloadURL { url, error in
            if let error = error {
                print("⚠️ Error fetching image URL for \(template.title): \(error.localizedDescription)")
                completion(template)
                return
            }
            if let url = url {
                var updatedTemplate = template
                updatedTemplate.img = url.absoluteString
                completion(updatedTemplate)
            }
        }
    }
    deinit {
        monitor.cancel() // Stop the network monitor
        print("TemplateViewModel is being deinitialized and network monitor is cancelled.")
    }
}
