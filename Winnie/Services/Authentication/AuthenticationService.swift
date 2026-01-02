import Foundation
import Combine
import FirebaseAuth
import AuthenticationServices
import CryptoKit

/// Manages Firebase Authentication state and operations.
///
/// ## Dependency Injection
/// This service uses constructor injection for testability:
/// - **Production**: `init()` uses `FirebaseAuthProvider.shared`
/// - **Tests**: `init(authProvider:)` accepts `MockAuthProvider`
///
/// ## Thread Safety
/// Marked `@MainActor` to ensure all published state updates happen on the main thread,
/// which is required for SwiftUI to observe changes correctly.
///
/// ## Usage
/// ```swift
/// // Production (in App)
/// @StateObject private var authService = AuthenticationService()
///
/// // Tests
/// let mock = MockAuthProvider()
/// let service = AuthenticationService(authProvider: mock)
/// ```
@MainActor
final class AuthenticationService: ObservableObject {

    // MARK: - Published State

    @Published private(set) var authState: AuthState = .unknown
    @Published private(set) var currentFirebaseUser: AuthUserProviding?
    @Published private(set) var isLoading = false
    @Published var error: AuthenticationError?

    enum AuthState: Equatable {
        case unknown
        case signedOut
        case signedIn(uid: String)
    }

    // MARK: - Private Properties

    private let authProvider: AuthProviding
    private var authStateHandle: AuthStateListenerHandle?
    private var currentNonce: String?

    // MARK: - Initialization

    /// Production initializer - uses Firebase Auth via `FirebaseAuthProvider.shared`.
    /// In test environments (when XCTestCase is loaded), this creates a no-op service
    /// that doesn't connect to Firebase.
    init() {
        // Skip Firebase Auth when running unit tests
        if Self.isRunningTests {
            self.authProvider = NoOpAuthProvider()
            // Don't start listening in test mode
        } else {
            self.authProvider = FirebaseAuthProvider.shared
            startListening()
        }
    }

    /// Detect if we're running in a unit test environment
    private static var isRunningTests: Bool {
        NSClassFromString("XCTestCase") != nil
    }

    /// Test initializer - accepts any `AuthProviding` implementation.
    /// - Parameter authProvider: The auth provider to use (e.g., `MockAuthProvider`)
    init(authProvider: AuthProviding) {
        self.authProvider = authProvider
        startListening()
    }

    deinit {
        // Clean up the auth state listener.
        // In production this is never called (service is app-scoped),
        // but it's needed for tests where multiple instances are created.
        if let handle = authStateHandle {
            authProvider.removeStateDidChangeListener(handle)
        }
    }

    // MARK: - Auth State Observation

    private func startListening() {
        // Firebase calls this listener immediately with current state,
        // then again whenever auth state changes (sign in/out).
        // The listener callback runs on the main thread (Firebase guarantee),
        // and this class is @MainActor, so we can update state directly.
        authStateHandle = authProvider.addStateDidChangeListener { [weak self] user in
            self?.handleAuthStateChange(user)
        }
    }

    private func handleAuthStateChange(_ user: AuthUserProviding?) {
        if let user {
            currentFirebaseUser = user
            authState = .signedIn(uid: user.uid)
        } else {
            currentFirebaseUser = nil
            authState = .signedOut
        }
    }

    // MARK: - Current User Info

    /// Current user's UID if signed in
    var currentUserID: String? {
        currentFirebaseUser?.uid
    }

    /// Whether user is currently authenticated
    var isAuthenticated: Bool {
        if case .signedIn = authState { return true }
        return false
    }

    // MARK: - Apple Sign In

    /// Prepare for Apple Sign In - returns the hashed nonce for the request.
    ///
    /// Call this before presenting the Apple Sign-In UI. The returned hash
    /// is passed to Apple, and we keep the raw nonce to verify the response.
    func prepareAppleSignIn() -> String {
        let nonce = randomNonceString()
        currentNonce = nonce
        return sha256(nonce)
    }

    /// Complete Apple Sign In with extracted credential data.
    ///
    /// This is the testable version that accepts `AppleCredentialData`.
    /// - Parameter data: Data extracted from `ASAuthorizationAppleIDCredential`
    /// - Returns: `NewUserInfo` if this is the user's first sign-in (for creating user document), `nil` for returning users
    /// - Throws: `AuthenticationError` on failure
    @discardableResult
    func signInWithApple(data: AppleCredentialData) async throws -> NewUserInfo? {
        guard let nonce = currentNonce else {
            throw AuthenticationError.missingNonce
        }

        guard let appleIDToken = data.identityToken,
              let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
            throw AuthenticationError.invalidCredential
        }

        isLoading = true
        defer { isLoading = false }

        do {
            let credential = FirebaseAuthCredentialWrapper.appleCredential(
                idToken: idTokenString,
                rawNonce: nonce,
                fullName: data.fullName
            )

            let result = try await authProvider.signIn(with: credential)

            // Clear nonce after successful sign-in (one-time use)
            currentNonce = nil

            // Check if this is a new user (first sign-in)
            let isNewUser = result.additionalUserInfo?.isNewUser ?? false
            if isNewUser {
                // Apple only provides name/email on first sign-in
                // Return this info so caller can create user document with it
                return NewUserInfo(
                    uid: result.user.uid,
                    displayName: formatDisplayName(from: data.fullName),
                    email: data.email
                )
            }

            return nil

        } catch {
            throw AuthenticationError.from(error)
        }
    }

    /// Complete Apple Sign In with the credential from ASAuthorizationController.
    ///
    /// Convenience method that extracts data and calls `signInWithApple(data:)`.
    /// - Parameter credential: The credential from Apple's authorization controller
    /// - Returns: `NewUserInfo` if this is a new user, `nil` for returning users
    /// - Throws: `AuthenticationError` on failure
    @discardableResult
    func signInWithApple(credential: ASAuthorizationAppleIDCredential) async throws -> NewUserInfo? {
        try await signInWithApple(data: AppleCredentialData(from: credential))
    }

    // MARK: - Email/Password Authentication

    /// Create a new account with email and password.
    func signUp(email: String, password: String) async throws {
        // Basic length check - Firebase also validates but we give a friendlier error
        guard password.count >= 6 else {
            throw AuthenticationError.weakPassword
        }

        isLoading = true
        defer { isLoading = false }

        do {
            _ = try await authProvider.createUser(withEmail: email, password: password)
        } catch {
            throw AuthenticationError.from(error)
        }
    }

    /// Sign in with existing email and password.
    func signIn(email: String, password: String) async throws {
        isLoading = true
        defer { isLoading = false }

        do {
            _ = try await authProvider.signIn(withEmail: email, password: password)
        } catch {
            throw AuthenticationError.from(error)
        }
    }

    /// Send password reset email.
    func sendPasswordReset(to email: String) async throws {
        do {
            try await authProvider.sendPasswordReset(withEmail: email)
        } catch {
            throw AuthenticationError.from(error)
        }
    }

    // MARK: - Sign Out

    func signOut() throws {
        do {
            try authProvider.signOut()
        } catch {
            throw AuthenticationError.signOutFailed
        }
    }

    // MARK: - Account Deletion

    func deleteAccount() async throws {
        guard let user = authProvider.currentUser else {
            throw AuthenticationError.userNotFound
        }

        do {
            try await user.delete()
        } catch {
            throw AuthenticationError.from(error)
        }
    }

    // MARK: - Private Helpers

    /// Generate a cryptographically secure random nonce.
    /// - Parameter length: Length of the nonce (1-256 bytes, default 32)
    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0 && length <= 256, "Nonce length must be between 1 and 256")
        var randomBytes = [UInt8](repeating: 0, count: length)
        let errorCode = SecRandomCopyBytes(kSecRandomDefault, randomBytes.count, &randomBytes)
        precondition(errorCode == errSecSuccess, "Failed to generate random bytes")

        let charset: [Character] = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        return String(randomBytes.map { charset[Int($0) % charset.count] })
    }

    /// SHA256 hash a string and return hex-encoded result.
    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        return hashedData.compactMap { String(format: "%02x", $0) }.joined()
    }

    /// Format name components into a display name string.
    private func formatDisplayName(from nameComponents: PersonNameComponents?) -> String? {
        guard let nameComponents else { return nil }
        return PersonNameComponentsFormatter.localizedString(from: nameComponents, style: .default)
    }
}

// MARK: - New User Info

/// Information about a newly signed up user from Apple Sign-In.
/// This data is only available during the first sign-in with Apple.
struct NewUserInfo {
    let uid: String
    let displayName: String?
    let email: String?
}

// MARK: - No-Op Auth Provider (for test environment)

/// A no-op auth provider used when the app runs during unit tests.
/// This prevents Firebase Auth from being initialized when tests run.
private final class NoOpAuthProvider: AuthProviding {
    var currentUser: AuthUserProviding? { nil }

    func addStateDidChangeListener(_ handler: @escaping (AuthUserProviding?) -> Void) -> AuthStateListenerHandle {
        // Return a dummy handle
        return NSObject()
    }

    nonisolated func removeStateDidChangeListener(_ handle: AuthStateListenerHandle) {
        // No-op
    }

    func createUser(withEmail email: String, password: String) async throws -> AuthResultProviding {
        throw AuthenticationError.unknown("Auth not available in test environment")
    }

    func signIn(withEmail email: String, password: String) async throws -> AuthResultProviding {
        throw AuthenticationError.unknown("Auth not available in test environment")
    }

    func sendPasswordReset(withEmail email: String) async throws {
        throw AuthenticationError.unknown("Auth not available in test environment")
    }

    func signIn(with credential: AuthCredentialProviding) async throws -> AuthResultProviding {
        throw AuthenticationError.unknown("Auth not available in test environment")
    }

    func signOut() throws {
        // No-op
    }
}
