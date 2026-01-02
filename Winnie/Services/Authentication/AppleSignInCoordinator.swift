import Foundation
import AuthenticationServices
import SwiftUI

/// Coordinates Apple Sign In flow with ASAuthorizationController
final class AppleSignInCoordinator: NSObject, ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {

    private var continuation: CheckedContinuation<ASAuthorizationAppleIDCredential, Error>?

    /// Request Apple Sign In and return the credential
    @MainActor
    func signIn(hashedNonce: String) async throws -> ASAuthorizationAppleIDCredential {
        return try await withCheckedThrowingContinuation { continuation in
            self.continuation = continuation

            let appleIDProvider = ASAuthorizationAppleIDProvider()
            let request = appleIDProvider.createRequest()
            request.requestedScopes = [.fullName, .email]
            request.nonce = hashedNonce

            let authorizationController = ASAuthorizationController(authorizationRequests: [request])
            authorizationController.delegate = self
            authorizationController.presentationContextProvider = self
            authorizationController.performRequests()
        }
    }

    // MARK: - ASAuthorizationControllerDelegate

    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential else {
            continuation?.resume(throwing: AuthenticationError.invalidCredential)
            continuation = nil
            return
        }

        continuation?.resume(returning: appleIDCredential)
        continuation = nil
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        // Check if user cancelled
        if let authError = error as? ASAuthorizationError,
           authError.code == .canceled {
            continuation?.resume(throwing: CancellationError())
        } else {
            continuation?.resume(throwing: error)
        }
        continuation = nil
    }

    // MARK: - ASAuthorizationControllerPresentationContextProviding

    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        // Get the first window scene - required for UIWindow in iOS 26+
        // In a running SwiftUI app, there is always at least one connected scene
        let scene = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first!

        // Return existing key window, or any window, or create a new one
        if let window = scene.windows.first(where: { $0.isKeyWindow }) ?? scene.windows.first {
            return window
        }

        // Create a new window attached to the scene
        let fallbackWindow = UIWindow(windowScene: scene)
        fallbackWindow.makeKeyAndVisible()
        return fallbackWindow
    }
}

// MARK: - SwiftUI View Extension for Apple Sign In

extension View {

    /// Add Apple Sign In button that integrates with AuthenticationService
    func appleSignInButton(
        authService: AuthenticationService,
        onSuccess: @escaping () -> Void,
        onError: @escaping (Error) -> Void
    ) -> some View {
        self.overlay {
            SignInWithAppleButton(
                onRequest: { request in
                    let hashedNonce = authService.prepareAppleSignIn()
                    request.requestedScopes = [.fullName, .email]
                    request.nonce = hashedNonce
                },
                onCompletion: { result in
                    Task {
                        switch result {
                        case .success(let authorization):
                            guard let credential = authorization.credential as? ASAuthorizationAppleIDCredential else {
                                onError(AuthenticationError.invalidCredential)
                                return
                            }
                            do {
                                try await authService.signInWithApple(credential: credential)
                                onSuccess()
                            } catch {
                                onError(error)
                            }
                        case .failure(let error):
                            onError(error)
                        }
                    }
                }
            )
            .signInWithAppleButtonStyle(.black)
            .frame(height: 56)
        }
    }
}
