import Foundation

/// Marker protocol for OAuth credentials (e.g., from Apple Sign-In).
///
/// ## Why This Is a Marker Protocol
/// OAuth credentials (like Apple's) contain sensitive token data that varies by provider.
/// Rather than exposing internal token details, this protocol simply marks a type as
/// being an auth credential that can be passed to `AuthProviding.signIn(with:)`.
///
/// ## Implementations
/// - **Production**: `FirebaseAuthCredentialWrapper` wraps Firebase's `AuthCredential`
/// - **Tests**: `MockAuthCredential` can hold any test data needed
///
/// ## Usage
/// ```swift
/// let credential: AuthCredentialProviding = FirebaseAuthCredentialWrapper.appleCredential(
///     idToken: tokenString,
///     rawNonce: nonce,
///     fullName: nameComponents
/// )
/// let result = try await authProvider.signIn(with: credential)
/// ```
protocol AuthCredentialProviding {
    // Marker protocol - implementations hold the actual credential data
    // The production implementation wraps Firebase's AuthCredential
    // Test implementations can provide mock data
}
