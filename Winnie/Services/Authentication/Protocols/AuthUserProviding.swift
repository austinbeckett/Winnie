import Foundation

/// Abstracts a Firebase Auth User for dependency injection and testing.
///
/// ## Why This Exists
/// `FirebaseAuth.User` is a concrete class that cannot be instantiated or subclassed
/// in tests. This protocol exposes only the properties we actually use, allowing us to:
/// 1. **Production**: Wrap `FirebaseAuth.User` in `FirebaseAuthUserWrapper`
/// 2. **Tests**: Create `MockAuthUser` with any values we need
///
/// ## Properties Exposed
/// We only expose what `AuthenticationService` actually uses:
/// - `uid`: For identifying the user and storing in Firestore
/// - `email`: For display and user info
/// - `displayName`: For display purposes
/// - `delete()`: For account deletion feature
protocol AuthUserProviding {
    /// The user's unique identifier (Firebase UID)
    var uid: String { get }

    /// The user's email address (may be nil for Apple Sign-In users who hide email)
    var email: String? { get }

    /// The user's display name
    var displayName: String? { get }

    /// Delete this user's account from Firebase Auth
    /// - Throws: Authentication errors if deletion fails (e.g., requires recent sign-in)
    func delete() async throws
}
