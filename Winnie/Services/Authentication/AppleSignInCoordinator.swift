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
        // Apple Sign-In requires a presentation anchor. During normal app operation,
        // there's always at least one connected UIWindowScene with a window.
        // This method only gets called when the user taps Sign In, so the app is active.
        for scene in UIApplication.shared.connectedScenes {
            guard let windowScene = scene as? UIWindowScene else { continue }

            // Return the key window if available
            if let keyWindow = windowScene.windows.first(where: { $0.isKeyWindow }) {
                return keyWindow
            }

            // Otherwise return any window from this scene
            if let window = windowScene.windows.first {
                return window
            }

            // Create a window for this scene as fallback
            let newWindow = UIWindow(windowScene: windowScene)
            newWindow.makeKeyAndVisible()
            return newWindow
        }

        // This should never happen - but if it does, create a minimal window
        // The force unwrap here is acceptable because if there's truly no scene,
        // the app is in an invalid state and crashing is appropriate
        fatalError("No UIWindowScene available for Apple Sign-In presentation")
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
