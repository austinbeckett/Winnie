//
//  WinnieApp.swift
//  Winnie
//
//  Created by Austin Beckett on 2025-12-29.
//

import SwiftUI
import FirebaseCore
import AuthenticationServices

@main
struct WinnieApp: App {

    // MARK: - Services

    @StateObject private var authService = AuthenticationService()

    // MARK: - Initialization

    init() {
        // Skip Firebase initialization when running unit tests
        // Tests use mocked services and don't need real Firebase
        guard !Self.isRunningTests else { return }

        FirebaseApp.configure()
        configureGlobalAppearance()
    }

    /// Detect if we're running in a unit test environment
    private static var isRunningTests: Bool {
        NSClassFromString("XCTestCase") != nil
    }

    /// Configures global UIKit appearance for the app.
    /// Called once at app startup. Uses dynamic UIColors for automatic dark/light mode support.
    /// Note: SwiftUI views use WinnieColors with @Environment(\.colorScheme) instead.
    private func configureGlobalAppearance() {
        // Serif fonts for navigation titles (matches Winnie design system)
        let largeTitleFont: UIFont = {
            let descriptor = UIFont.systemFont(ofSize: 34, weight: .bold).fontDescriptor.withDesign(.serif)
            return descriptor.map { UIFont(descriptor: $0, size: 34) } ?? UIFont.systemFont(ofSize: 34, weight: .bold)
        }()

        let inlineTitleFont: UIFont = {
            let descriptor = UIFont.systemFont(ofSize: 17, weight: .semibold).fontDescriptor.withDesign(.serif)
            return descriptor.map { UIFont(descriptor: $0, size: 17) } ?? UIFont.systemFont(ofSize: 17, weight: .semibold)
        }()

        // Configure navigation bar
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.largeTitleTextAttributes = [
            .font: largeTitleFont,
            .foregroundColor: WinnieColors.primaryTextUIColor
        ]
        appearance.titleTextAttributes = [
            .font: inlineTitleFont,
            .foregroundColor: WinnieColors.primaryTextUIColor
        ]

        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
    }

    // MARK: - Body

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(authService)
        }
    }
}

// MARK: - Root View

/// Root view that handles authentication state routing
struct RootView: View {

    @EnvironmentObject var authService: AuthenticationService

    var body: some View {
        Group {
            switch authService.authState {
            case .unknown:
                // Loading state while checking auth
                ProgressView()
                    .scaleEffect(1.5)

            case .signedOut:
                // Show authentication flow
                AuthenticationView()

            case .signedIn:
                // Show main app content
                ContentView()
            }
        }
        .animation(.easeInOut(duration: 0.3), value: authService.authState)
    }
}

// MARK: - Authentication View (Placeholder)

/// Placeholder authentication view - will be replaced with full onboarding
struct AuthenticationView: View {

    @EnvironmentObject var authService: AuthenticationService
    @State private var email = ""
    @State private var password = ""
    @State private var isSignUp = false
    @State private var showError = false

    private let appleSignInCoordinator = AppleSignInCoordinator()

    var body: some View {
        NavigationStack {
            VStack(spacing: 32) {
                Spacer()

                // Logo/Title
                VStack(spacing: 8) {
                    Text("Winnie")
                        .font(.system(size: 44, weight: .regular, design: .serif))

                    Text("Money decisions, made together.")
                        .font(.system(size: 16))
                        .foregroundStyle(.secondary)
                }

                Spacer()

                // Sign in with Apple
                SignInWithAppleButton(
                    onRequest: { request in
                        let hashedNonce = authService.prepareAppleSignIn()
                        request.requestedScopes = [.fullName, .email]
                        request.nonce = hashedNonce
                    },
                    onCompletion: { result in
                        Task {
                            await handleAppleSignIn(result)
                        }
                    }
                )
                .signInWithAppleButtonStyle(.black)
                .frame(height: 56)
                .clipShape(RoundedRectangle(cornerRadius: 28))

                // Divider
                HStack {
                    Rectangle()
                        .frame(height: 1)
                        .foregroundStyle(.secondary.opacity(0.3))
                    Text("or")
                        .font(.system(size: 14))
                        .foregroundStyle(.secondary)
                    Rectangle()
                        .frame(height: 1)
                        .foregroundStyle(.secondary.opacity(0.3))
                }

                // Email/Password form
                VStack(spacing: 16) {
                    TextField("Email", text: $email)
                        .textFieldStyle(.roundedBorder)
                        .textContentType(.emailAddress)
                        .autocapitalization(.none)
                        .keyboardType(.emailAddress)

                    SecureField("Password", text: $password)
                        .textFieldStyle(.roundedBorder)
                        .textContentType(isSignUp ? .newPassword : .password)

                    Button {
                        Task {
                            await handleEmailAuth()
                        }
                    } label: {
                        if authService.isLoading {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Text(isSignUp ? "Create Account" : "Sign In")
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(Color.accentColor)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 28))
                    .disabled(authService.isLoading || email.isEmpty || password.isEmpty)
                }

                // Toggle sign up / sign in
                Button {
                    isSignUp.toggle()
                } label: {
                    Text(isSignUp ? "Already have an account? Sign In" : "Don't have an account? Sign Up")
                        .font(.system(size: 14))
                }

                Spacer()
            }
            .padding(.horizontal, 24)
            .alert("Error", isPresented: $showError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(authService.error?.localizedDescription ?? "An error occurred")
            }
            .onChange(of: authService.error) { _, newError in
                showError = newError != nil
            }
        }
    }

    // MARK: - Actions

    private func handleAppleSignIn(_ result: Result<ASAuthorization, Error>) async {
        switch result {
        case .success(let authorization):
            guard let credential = authorization.credential as? ASAuthorizationAppleIDCredential else {
                authService.error = .invalidCredential
                return
            }
            do {
                try await authService.signInWithApple(credential: credential)
            } catch {
                if !(error is CancellationError) {
                    authService.error = error as? AuthenticationError ?? .unknown(error.localizedDescription)
                }
            }

        case .failure(let error):
            // Ignore cancellation
            if (error as? ASAuthorizationError)?.code != .canceled {
                authService.error = .unknown(error.localizedDescription)
            }
        }
    }

    private func handleEmailAuth() async {
        do {
            if isSignUp {
                try await authService.signUp(email: email, password: password)
            } else {
                try await authService.signIn(email: email, password: password)
            }
        } catch {
            authService.error = error as? AuthenticationError ?? .unknown(error.localizedDescription)
        }
    }
}
