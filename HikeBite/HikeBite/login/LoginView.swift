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
    @Binding var isAuthenticated: Bool
    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    stops: [
                        Gradient.Stop(color: Color(red: 0.15, green: 0.6, blue: 0.38), location: 0.00),
                        Gradient.Stop(color: .white, location: 1.00),
                    ],
                    startPoint: UnitPoint(x: 0.5, y: 1),
                    endPoint: UnitPoint(x: 0.5, y: 0)
                )
                .opacity(0.2)
                .edgesIgnoringSafeArea(.all)
                VStack {
                    Image("logo")
                        .resizable()
                        .scaledToFill()
                        .frame(width: UIScreen.main.bounds.width, height: 120)
                    VStack(spacing: 24) {
                        InputView(text: $email,
                                  title: "Email Address",
                                  placeholder: "name@example.com")
                        .autocapitalization(.none)
                        InputView(text: $password, title: "Password", placeholder: "Enter your password", isSecureField: true)
                    }
                    .padding(.horizontal)
                    .padding(.top, 12)
                    // sign in button
                    Button {
                        Task {
                            try await viewModel.signIn(withEmail: email, password: password)
                            // Wait for Firebase Auth to fully update the user
                            while viewModel.currentUser == nil {
                                try? await Task.sleep(nanoseconds: 200_000_000) // 0.2 sec
                            }
                            // Then update UI state
                            showLogin = false
                            isAuthenticated = true
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
                    .background(Color("AccentColor"))
                    .disabled(!formIsValid)
                    .opacity(formIsValid ? 1 : 0.5)
                    .cornerRadius(10)
                    .padding(.top,24)
                    Spacer()
                    // sign up button
                    NavigationLink {
                        RegistrationView(showLogin: $showLogin, isAuthenticated: $isAuthenticated)
                            .navigationBarBackButtonHidden()
                    } label: {
                        HStack(spacing: 3) {
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
}
// MARK: - AuthenticationFormProtocol
extension LoginView: AuthenticationFormProtocol {
    var formIsValid: Bool {
        return !email.isEmpty && email.contains("@") && !password.isEmpty && password.count > 5 // firebase requires it >= 6, we can make it better
    }
}
