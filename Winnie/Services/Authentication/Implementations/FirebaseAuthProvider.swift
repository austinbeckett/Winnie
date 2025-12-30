import Foundation
import FirebaseAuth

/// Production implementation of `AuthProviding` that wraps Firebase Auth SDK.
///
/// ## Why This Exists
/// This class bridges our protocol-based abstraction to Firebase's concrete types.
/// `AuthenticationService` depends on `AuthProviding`, not directly on Firebase,
/// allowing us to inject `MockAuthProvider` in tests.
///
/// ## Singleton Pattern
/// Uses `shared` instance since Firebase Auth itself is a singleton.
/// The DI constructor is available for special cases (e.g., testing with real Firebase).
///
/// ## Usage
/// ```swift
/// // Default (production)
/// let authService = AuthenticationService()  // Uses FirebaseAuthProvider.shared internally
///
/// // Explicit injection
/// let authService = AuthenticationService(authProvider: FirebaseAuthProvider.shared)
/// ```
final class FirebaseAuthProvider: AuthProviding {

    // MARK: - Shared Instance

    /// Shared instance for production use.
    /// Since Firebase Auth is itself a singleton, we mirror that pattern.
    static let shared = FirebaseAuthProvider()

    // MARK: - Properties

    private let auth: Auth

    // MARK: - Initialization

    /// Create a provider wrapping the default Firebase Auth instance.
    init() {
        self.auth = Auth.auth()
    }

    /// Create a provider wrapping a specific Auth instance.
    /// - Parameter auth: Custom Auth instance (useful for testing with real Firebase)
    init(auth: Auth) {
        self.auth = auth
    }

    // MARK: - Current User

    var currentUser: AuthUserProviding? {
        auth.currentUser.map { FirebaseAuthUserWrapper(user: $0) }
    }

    // MARK: - State Observation

    func addStateDidChangeListener(
        _ handler: @escaping (AuthUserProviding?) -> Void
    ) -> AuthStateListenerHandle {
        // Firebase's listener returns the Auth instance and the User (or nil)
        // We only need the user, wrapped in our protocol type
        let handle = auth.addStateDidChangeListener { _, firebaseUser in
            let wrappedUser = firebaseUser.map { FirebaseAuthUserWrapper(user: $0) }
            handler(wrappedUser)
        }
        return handle as AnyObject
    }

    nonisolated func removeStateDidChangeListener(_ handle: AuthStateListenerHandle) {
        // Firebase's handle type is AuthStateDidChangeListenerHandle
        // We cast back from AnyObject
        // This is safe to call from any thread - Firebase Auth is thread-safe
        if let firebaseHandle = handle as? AuthStateDidChangeListenerHandle {
            Auth.auth().removeStateDidChangeListener(firebaseHandle)
        }
    }

    // MARK: - Email/Password Authentication

    func createUser(withEmail email: String, password: String) async throws -> AuthResultProviding {
        let result = try await auth.createUser(withEmail: email, password: password)
        return FirebaseAuthResultWrapper(result: result)
    }

    func signIn(withEmail email: String, password: String) async throws -> AuthResultProviding {
        let result = try await auth.signIn(withEmail: email, password: password)
        return FirebaseAuthResultWrapper(result: result)
    }

    func sendPasswordReset(withEmail email: String) async throws {
        try await auth.sendPasswordReset(withEmail: email)
    }

    // MARK: - Credential-Based Authentication

    func signIn(with credential: AuthCredentialProviding) async throws -> AuthResultProviding {
        // We expect the credential to be our wrapper type
        guard let wrapper = credential as? FirebaseAuthCredentialWrapper else {
            throw AuthenticationError.invalidCredential
        }
        let result = try await auth.signIn(with: wrapper.credential)
        return FirebaseAuthResultWrapper(result: result)
    }

    // MARK: - Sign Out

    func signOut() throws {
        try auth.signOut()
    }
}
