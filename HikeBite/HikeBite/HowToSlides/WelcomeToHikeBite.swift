import SwiftUI

struct WelcomeToHikeBite: View {
    @State private var currentPage = 0
    @State private var showRegistrationSheet = false
    @State private var showLoginSheet = false
    @State private var showLogin = false
    var body: some View {
        TabView(selection: $currentPage) {
            OnboardingPageView(
                title: "Welcome to HikeBite!",
                subtitle: "Two week thru hike? \nOne night car camping trip?\n\nWe’ll get you fueled.",
                description: nil,
                backgroundImage: "trees",
                textColor: .white
            )
            .tag(0)

            OnboardingPageView(
                title: "Not sure where to start?",
                subtitle: "Use a HikeBite HikeBite Template \nto help plan meals for your trip",
                description: " ",
                backgroundImage: "campsite",
                textColor: .white,
                buttonText: "See more on our website",
                buttonAction: {
                    if let url = URL(string: "https://hikebitetrail.com/") {
                        UIApplication.shared.open(url)
                    }
                }
            )
            .tag(1)

            OnboardingPageView(
                title: "New to backpacking?",
                subtitle: "Read tips from our certified experts \n to help plan your next adventure",
                description: " ",
                backgroundImage: "stovepeople",
                textColor: .white,
                buttonText: "HikeBite expert tips",
                buttonAction: {
                    if let url = URL(string: "https://hikebitetrail.com/") {
                        UIApplication.shared.open(url)
                    }
                }
            )
            .tag(2)

            OnboardingPageView(
                title: " ",
                subtitle: nil,
                description: nil,
                backgroundImage: "backgroundimage",
                textColor: .black,
                buttonText: "Create a HikeBite account",
                buttonAction: {
                    showRegistrationSheet = true // link to signup HERE
                },
                secondaryButtonText: "I already have an account",
                secondaryButtonAction: {
                    showLoginSheet = true
                }
            )
            .tag(3)
            .sheet(isPresented: $showRegistrationSheet) {
                RegistrationView(showLogin: $showLogin)
            }
            .sheet(isPresented: $showLoginSheet) {
                LoginView(showLogin: $showLogin)
            }
        }
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
        .ignoresSafeArea()
    }
}

struct OnboardingPageView: View {
    var title: String
    var subtitle: String?
    var description: String?
    var backgroundImage: String
    var textColor: Color
    var buttonText: String? = nil
    var buttonAction: (() -> Void)? = nil
    var secondaryButtonText: String? = nil
    var secondaryButtonAction: (() -> Void)? = nil

    var body: some View {
        ZStack {

            Image(backgroundImage)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .clipped()
                .ignoresSafeArea()

            VStack {
                Spacer()

                if backgroundImage == "backgroundimage" {
                                    Image("logo")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 400)
                                }

                VStack(spacing: 12) {
                    if backgroundImage == "stovepeople" {
                        LinearGradient(
                            gradient: Gradient(colors: [Color.white.opacity(    0.8), Color("279A62").opacity(0.8)]),
                            startPoint: .bottomLeading,
                            endPoint: .top
                        )
                        .frame(height: 200)
                        .cornerRadius(10)
                        .padding(.horizontal, 20)
                        .overlay(
                            VStack(spacing: 12) {
                                Text(title)
                                    .font(.largeTitle)
                                    .bold()
                                    .multilineTextAlignment(.leading)
                                    .foregroundColor(textColor)

                                if let subtitle = subtitle {
                                    Text(subtitle)
                                        .font(Font.custom("FONTSPRINGDEMO-FieldsDisplayMediumRegular", size: 24))
                                        .multilineTextAlignment(.leading)
                                        .foregroundColor(textColor)
                                }
                            }
                            .padding()
                        )
                    } else {
                        Text(title)
                            .font(.largeTitle)
                            .bold()
                            .multilineTextAlignment(.leading)
                            .foregroundColor(textColor)

                        if let subtitle = subtitle {
                            Text(subtitle)
                                .font(Font.custom("FONTSPRINGDEMO-FieldsDisplayMediumRegular", size: 24))
                                .multilineTextAlignment(.leading)
                                .foregroundColor(textColor)
                        }
                    }
                }
                .padding(.horizontal, 20)

                Spacer()

                if let buttonText = buttonText, let buttonAction = buttonAction {
                    VStack(spacing: 8) {
                        Button(action: buttonAction) {
                            Text(buttonText)
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: 340)
                                .background(Color.accentColor)
                                .cornerRadius(10)
                        }
                        .padding(.horizontal, 20)

                        if let secondaryText = secondaryButtonText, let secondaryAction = secondaryButtonAction {
                            Button(action: secondaryAction) {
                                Text(secondaryText)
                                    .font(.subheadline)
                                    .foregroundColor(Color.accentColor)
                            }
                        }
                    }
                }

                Spacer(minLength: 40)
            }
            .padding(.vertical, 30)
        }
    }
}

#Preview {
    WelcomeToHikeBite()
}
