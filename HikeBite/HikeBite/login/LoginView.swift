//
//  LoginView.swift
//  HikeBite
//
//  Created by Ari Guzzi on 3/2/25.
//

import SwiftUI

struct LoginView: View {
    @State private var selectedTrip: Trip? {
        didSet {
            if selectedTrip != nil {
                selectedTab = 2
            }
        }
    }
    @StateObject private var tripManager = TripManager()
    @State private var selectedTab: Int = 0
    @State private var email: String = ""
    @State private var password: String = ""
    @Binding var showLogin: Bool
    @EnvironmentObject var viewModel: AuthViewModel
    var body: some View {
        NavigationStack {
            VStack {
                //image
                Image("hikebite")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 100, height: 120)
                //form fields
                VStack(spacing: 24) {
                    InputView(text: $email,
                              title: "Email Address",
                              placeholder: "name@example.com")
                    .autocapitalization(.none)
                    InputView(text: $password, title: "Password", placeholder: "Enter your password", isSecureField: true)
                }
                .padding(.horizontal)
                .padding(.top, 12)
                
                //sign in button
                Button {
                    Task {
                        try await viewModel.signIn(withEmail: email, password: password)
                        showLogin = false
                    }
                } label: {
                    HStack {
                        Text("Sign In")
                            .fontWeight(.semibold)
                        Image(systemName: "arrow.right")
                    }
                    .foregroundColor(.white)
                    .frame(width: UIScreen.main.bounds.width - 32, height: 48)
                }
                .background(Color(.systemBlue))
                .disabled(!formIsValid)
                .opacity(formIsValid ? 1 : 0.5)
                .cornerRadius(10)
                .padding(.top,24)
                Spacer()
                //sign up button
                NavigationLink {
                    RegistrationView(showLogin: $showLogin)
                        .navigationBarBackButtonHidden()
                } label: {
                    HStack(spacing:3) {
                        Text("Don't have an account?")
                        Text("Sign up")
                            .fontWeight(.bold)
                    }
                    .font(.system(size: 14))
                }
            }
        }
    }
}
// MARK: - AuthenticationFormProtocol
extension LoginView: AuthenticationFormProtocol {
    var formIsValid: Bool {
        return !email.isEmpty && email.contains("@") && !password.isEmpty && password.count > 5 //firebase requires it >= 6, we can make it better
    }
}
