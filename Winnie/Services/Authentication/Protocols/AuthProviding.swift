import Foundation

/// Handle for auth state listeners (opaque type for listener management).
///
/// This allows removing listeners without exposing implementation details.
/// In production, this wraps Firebase's `AuthStateDidChangeListenerHandle`.
/// In tests, this is a simple object we can track.
typealias AuthStateListenerHandle = AnyObject

/// Abstracts Firebase Authentication for dependency injection and testing.
///
/// ## Why This Exists
/// `AuthenticationService` needs to call Firebase Auth methods, but we can't
/// easily test code that directly calls `Auth.auth()`. This protocol allows:
/// - **Production**: `FirebaseAuthProvider` wraps the real Firebase Auth SDK
/// - **Tests**: `MockAuthProvider` provides in-memory simulation
///
/// ## Design Decisions
/// 1. **Listener callback pattern**: Firebase's `addStateDidChangeListener` uses callbacks,
///    so our protocol does too. The mock can trigger these synchronously in tests.
/// 2. **AuthUserProviding**: We don't expose `FirebaseAuth.User` directly - instead we use
///    our protocol so tests can create mock users.
/// 3. **AuthResultProviding**: Sign-in results are wrapped to expose `isNewUser` detection.
///
/// ## Usage
/// ```swift
/// // Production
/// let provider: AuthProviding = FirebaseAuthProvider.shared
///
/// // Tests
/// let mock = MockAuthProvider()
/// mock.mockCurrentUser = MockAuthUser(uid: "test-123")
/// ```
protocol AuthProviding {

    // MARK: - Current User

    /// The currently signed-in user, or nil if signed out.
    var currentUser: AuthUserProviding? { get }

    // MARK: - State Observation

    /// Register for auth state changes.
    ///
    /// Firebase calls this listener immediately with the current state, then again
    /// whenever the user signs in or out. This is how `AuthenticationService`
    /// keeps its `authState` property in sync.
    ///
    /// - Parameter handler: Called with the current user (or nil if signed out)
    /// - Returns: A handle to remove the listener later
    func addStateDidChangeListener(
        _ handler: @escaping (AuthUserProviding?) -> Void
    ) -> AuthStateListenerHandle

    /// Remove an auth state listener.
    ///
    /// This is marked `nonisolated` because it's safe to call from any thread
    /// (including `deinit` which cannot be actor-isolated) and the underlying
    /// Firebase implementation is thread-safe.
    /// - Parameter handle: The handle returned from `addStateDidChangeListener`
    nonisolated func removeStateDidChangeListener(_ handle: AuthStateListenerHandle)

    // MARK: - Email/Password Authentication

    /// Create a new user with email and password.
    /// - Returns: The result containing the new user
    /// - Throws: `AuthenticationError` mapped from Firebase errors
    func createUser(withEmail email: String, password: String) async throws -> AuthResultProviding

    /// Sign in with existing email and password.
    /// - Returns: The result containing the signed-in user
    /// - Throws: `AuthenticationError` mapped from Firebase errors
    func signIn(withEmail email: String, password: String) async throws -> AuthResultProviding

    /// Send a password reset email.
    /// - Throws: `AuthenticationError` if email is invalid or sending fails
    func sendPasswordReset(withEmail email: String) async throws

    // MARK: - Credential-Based Authentication

    /// Sign in with an OAuth credential (e.g., Apple Sign-In).
    /// - Parameter credential: The credential from the OAuth provider
    /// - Returns: The result containing the signed-in user
    /// - Throws: `AuthenticationError` mapped from Firebase errors
    func signIn(with credential: AuthCredentialProviding) async throws -> AuthResultProviding

    // MARK: - Sign Out

    /// Sign out the current user.
    /// - Throws: `AuthenticationError.signOutFailed` if sign-out fails
    func signOut() throws
}
