//
//  RegistrationView.swift
//  HikeBite
//
//  Created by Ari Guzzi on 3/2/25.
//

import SwiftUI

struct RegistrationView: View {
    @State private var selectedTrip: Trip? {
        didSet {
            if selectedTrip != nil {
                selectedTab = 2
            }
        }
    }
    @StateObject private var tripManager = TripManager()
    @State private var selectedTab: Int = 0
    @State private var email = ""
    @State private var fullName = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var navigateToProfile = false
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var viewModel: AuthViewModel
    var body: some View {
        VStack {
            Image("hikebite")
                .resizable()
                .scaledToFill()
                .frame(width: 100, height: 120)
            VStack(spacing: 24) {
                InputView(text: $email,
                          title: "Email Address",
                          placeholder: "name@example.com")
                .autocapitalization(.none)
                InputView(text: $fullName, title: "Full Name", placeholder: "Enter your name")
                InputView(text: $password,
                          title: "Password",
                          placeholder: "Enter your password",
                          isSecureField: true)
                ZStack(alignment: .trailing) {
                    InputView(text: $confirmPassword,
                              title: "Confirm Password",
                              placeholder: "Confirm your password",
                              isSecureField: true)
                    if !password.isEmpty && password != confirmPassword {
                        if password == confirmPassword {
                            Image(systemName: "checkmark.circle.fill")
                                .imageScale(.large)
                                .fontWeight(.bold)
                                .foregroundColor(.green)
                        } else {
                            Image(systemName: "xmark.circle.fill")
                                .imageScale(.large)
                                .fontWeight(.bold)
                                .foregroundColor(.red)
                        }
                    }
                }
            }
            .padding(.horizontal)
            .padding(.top, 12)
            Button {
                Task {
                    try await viewModel.createUser(withEmail: email,
                        password: password,
                        fullname: fullName)
                    navigateToProfile = true
                }
            } label: {
                HStack {
                    Text("Sign Up")
                        .fontWeight(.semibold)
                    Image(systemName: "arrow.right")
                }
                .foregroundColor(.white)
                .frame(width: UIScreen.main.bounds.width - 32, height: 48)
            }
            .background(Color(.systemBlue))
            .disabled(!formIsValid)
            .opacity(formIsValid ? 1:0.5)
            .cornerRadius(10)
            .padding(.top,24)
            Spacer()
            Button {
                dismiss()
            } label: {
                HStack(spacing:3) {
                    Text("Already have an account?")
                    Text("Sign In")
                        .fontWeight(.bold)
                }
                .font(.system(size: 14))
            }
            NavigationLink(destination: ProfileView(tripManager: tripManager, selectedTrip: $selectedTrip, selectedTab: $selectedTab), isActive: $navigateToProfile) {
                EmptyView()
                    .navigationBarBackButtonHidden()
            }
        }
    }
}
// MARK: - AuthenticationFormProtocol
extension RegistrationView: AuthenticationFormProtocol {
    var formIsValid: Bool {
        return !email.isEmpty && email.contains("@") && !password.isEmpty && password.count > 5 && confirmPassword == password && !fullName.isEmpty //firebase requires it >= 6, we can make it better
    }
}

#Preview {
    RegistrationView()
}
