import Foundation
import AuthenticationServices

/// Data extracted from ASAuthorizationAppleIDCredential for testability.
///
/// ## Why This Exists
/// `ASAuthorizationAppleIDCredential` is an Apple framework type that **cannot be
/// instantiated in tests** - its initializer is unavailable. This struct captures
/// the data we need, allowing:
/// - **Production**: Extract from real Apple credential via `init(from:)`
/// - **Tests**: Create directly via memberwise initializer
///
/// ## Apple Sign-In Data Behavior
/// Apple only provides full name and email on the **first sign-in**. Subsequent
/// sign-ins return only the `identityToken`. This is by design for privacy.
///
/// ## Usage
/// ```swift
/// // Production (in ASAuthorizationControllerDelegate)
/// let data = AppleCredentialData(from: credential)
/// try await authService.signInWithApple(data: data)
///
/// // Tests
/// let data = AppleCredentialData(
///     identityToken: "test-token".data(using: .utf8),
///     fullName: nil,
///     email: nil
/// )
/// try await authService.signInWithApple(data: data)
/// ```
struct AppleCredentialData {
    /// The identity token from Apple (JWT containing user info)
    let identityToken: Data?

    /// User's full name (only provided on first sign-in)
    let fullName: PersonNameComponents?

    /// User's email (only provided on first sign-in, may be relay email)
    let email: String?

    // MARK: - Production Initializer

    /// Create from a real Apple Sign-In credential.
    /// - Parameter credential: The credential from ASAuthorizationController
    init(from credential: ASAuthorizationAppleIDCredential) {
        self.identityToken = credential.identityToken
        self.fullName = credential.fullName
        self.email = credential.email
    }

    // MARK: - Test Initializer

    /// Create directly for testing purposes.
    /// - Parameters:
    ///   - identityToken: Mock identity token data
    ///   - fullName: Mock name components
    ///   - email: Mock email address
    init(identityToken: Data?, fullName: PersonNameComponents?, email: String?) {
        self.identityToken = identityToken
        self.fullName = fullName
        self.email = email
    }
}
