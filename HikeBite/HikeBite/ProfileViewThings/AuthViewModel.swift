//
//  AuthViewModel.swift
//  HikeBite
//
//  Created by Ari Guzzi on 3/2/25.
//
import FirebaseAuth
import FirebaseFirestore
import Foundation
import Firebase
import SwiftUI

protocol AuthenticationFormProtocol {
    var formIsValid: Bool { get }
    
}
@MainActor
class AuthViewModel: ObservableObject {
    @Published var userSession: FirebaseAuth.User?
    @Published var currentUser: User?
    
    init() {
        self.userSession = Auth.auth().currentUser
        
        Task {
            await fetchUser()
        }
    }
    func signIn(withEmail email: String, password: String) async throws {
        do {
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            self.userSession = result.user
            await fetchUser()
        } catch {
            print("Debug: failed to login with error \(error.localizedDescription)")
        }
    }
    func createUser(withEmail email: String, password: String, fullname: String) async throws {
        do {
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            self.userSession = result.user
            let user = User(id: result.user.uid, fullname: fullname, email: email)
            let encodedUser = try Firestore.Encoder().encode(user)
            try await Firestore.firestore().collection("users").document(user.id).setData(encodedUser)
            await fetchUser()
        } catch {
            print("Debug: failed to create user with error \(error.localizedDescription)")
            Auth.auth().createUser(withEmail: email, password: password) { result, error in
                if let error = error as NSError? {
                    print("❌ Firebase Auth Error: \(error.localizedDescription)")
                    print("Error Code: \(error.code)")
                    return
                }
                print("✅ User created successfully: \(result?.user.uid ?? "No User ID")")
            }
        }
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
