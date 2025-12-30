import Foundation

/// Abstracts Firebase AuthDataResult for dependency injection and testing.
///
/// ## Why This Exists
/// Firebase's `AuthDataResult` is returned from sign-in operations and contains:
/// 1. The signed-in user
/// 2. Additional info like whether this is a new user (first sign-in)
///
/// This protocol allows us to mock sign-in results in tests.
protocol AuthResultProviding {
    /// The user that signed in
    var user: AuthUserProviding { get }

    /// Additional info about the sign-in (e.g., whether user is new)
    var additionalUserInfo: AdditionalUserInfoProviding? { get }
}

/// Abstracts additional user info from sign-in results.
///
/// ## Primary Use Case
/// Detecting new users during Apple Sign-In:
/// - `isNewUser == true`: First time signing in, we need to create user document
/// - `isNewUser == false`: Returning user, user document already exists
protocol AdditionalUserInfoProviding {
    /// Whether this is a newly created user (first sign-in ever)
    var isNewUser: Bool { get }
}
