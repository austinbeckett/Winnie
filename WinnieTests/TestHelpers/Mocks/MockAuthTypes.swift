import Foundation
@testable import Winnie

// MARK: - Mock Auth User

/// Mock implementation of `AuthUserProviding` for testing.
///
/// ## Usage
/// ```swift
/// let user = MockAuthUser(uid: "test-123", email: "test@example.com")
/// mockAuthProvider.mockCurrentUser = user
/// ```
final class MockAuthUser: AuthUserProviding {

    let uid: String
    var email: String?
    var displayName: String?

    /// Error to throw when `delete()` is called (nil = success)
    var deleteError: Error?

    /// Whether `delete()` was called (for verification)
    var deleteWasCalled = false

    init(uid: String, email: String? = nil, displayName: String? = nil) {
        self.uid = uid
        self.email = email
        self.displayName = displayName
    }

    func delete() async throws {
        deleteWasCalled = true
        if let error = deleteError {
            throw error
        }
    }
}

// MARK: - Mock Auth Result

/// Mock implementation of `AuthResultProviding` for testing.
///
/// Returned from mock sign-in operations.
final class MockAuthResult: AuthResultProviding {

    let user: AuthUserProviding
    let additionalUserInfo: AdditionalUserInfoProviding?

    /// Create a mock result with a user and new-user flag.
    /// - Parameters:
    ///   - user: The signed-in user
    ///   - isNewUser: Whether this is a first-time sign-in
    init(user: AuthUserProviding, isNewUser: Bool) {
        self.user = user
        self.additionalUserInfo = MockAdditionalUserInfo(isNewUser: isNewUser)
    }

    /// Create a mock result with a user and no additional info.
    init(user: AuthUserProviding) {
        self.user = user
        self.additionalUserInfo = nil
    }
}

// MARK: - Mock Additional User Info

/// Mock implementation of `AdditionalUserInfoProviding` for testing.
final class MockAdditionalUserInfo: AdditionalUserInfoProviding {

    let isNewUser: Bool

    init(isNewUser: Bool) {
        self.isNewUser = isNewUser
    }
}

// MARK: - Mock Auth Credential

/// Mock implementation of `AuthCredentialProviding` for testing.
///
/// Holds mock credential data that tests can verify.
final class MockAuthCredential: AuthCredentialProviding {

    let idToken: String
    let rawNonce: String
    let fullName: PersonNameComponents?
    let email: String?

    init(
        idToken: String = "mock-id-token",
        rawNonce: String = "mock-nonce",
        fullName: PersonNameComponents? = nil,
        email: String? = nil
    ) {
        self.idToken = idToken
        self.rawNonce = rawNonce
        self.fullName = fullName
        self.email = email
    }
}

// MARK: - Mock Listener Handle

/// Simple object to serve as a listener handle in tests.
///
/// Allows verification that the listener was removed.
final class MockListenerHandle {
    var wasRemoved = false
}
