//
//  AuthViewModel.swift
//  HikeBite
//
//  Created by Ari Guzzi on 3/2/25.
//
import Firebase
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage
import Foundation
import SwiftUI

protocol AuthenticationFormProtocol {
    var formIsValid: Bool { get }
}
@MainActor
class AuthViewModel: ObservableObject {
    @Published var userSession: FirebaseAuth.User?
    @Published var currentUser: User?
    @Published var isAuthenticated = false
    init() {
        self.userSession = Auth.auth().currentUser
        Task {
            await fetchUser()
        }
    }
    deinit {
        print("AuthViewModel is being deinitialized")
    }
    func signIn(withEmail email: String, password: String) async throws {
        do {
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            self.userSession = result.user
            await fetchUser()
            DispatchQueue.main.async {
                self.isAuthenticated = true
            }
        } catch {
            print("Debug: failed to login with error \(error.localizedDescription)")
        }
    }
    func createUser(withEmail email: String, password: String, fullname: String, image: UIImage?) async throws {
        let authResult = try await Auth.auth().createUser(withEmail: email, password: password)
        let userID = authResult.user.uid
        var profileImageURL: String? = nil
        if let image = image {
            profileImageURL = try await uploadProfileImage(image, userID: userID)
        }
        let newUser = User(id: userID, fullname: fullname, email: email, profileImgeURL: profileImageURL)
        let userRef = Firestore.firestore().collection("users").document(userID)
        try userRef.setData(from: newUser)
        self.currentUser = newUser
        DispatchQueue.main.async {
            self.isAuthenticated = true
        }
    }

        private func uploadProfileImage(_ image: UIImage, userID: String) async throws -> String {
            let storageRef = Storage.storage().reference().child("profile_images/\(userID).jpg")
            guard let imageData = image.jpegData(compressionQuality: 0.4) else { throw URLError(.badServerResponse) }
            let metadata = StorageMetadata()
            metadata.contentType = "image/jpeg"
            _ = try await storageRef.putDataAsync(imageData, metadata: metadata)
            let url = try await storageRef.downloadURL()
            return url.absoluteString
        }
    func signOut() {
        do {
            try Auth.auth().signOut() // signs out user on backend
            self.userSession = nil // wipes out user session and takes us back to login screen (if logic is set up like that which its currently not
            self.currentUser = nil // wipes out out old data model
        } catch {
            print("Debug: failed to sign out with error \(error.localizedDescription)")
        }
    }
    func deleteAccount() {
        
    }
    func fetchUser() async {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        guard let snapshot = try? await Firestore.firestore().collection("users").document(uid).getDocument() else { return }
        self.currentUser = try? snapshot.data(as: User.self)
        
        print("Debug: current user is \(self.currentUser)")
    }
}
