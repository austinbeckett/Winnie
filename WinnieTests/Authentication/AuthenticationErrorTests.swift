import XCTest
@testable import Winnie

/// Comprehensive unit tests for AuthenticationError
/// Tests error descriptions, Firebase error code mapping, and Equatable conformance
final class AuthenticationErrorTests: XCTestCase {

    // MARK: - Error Description Tests

    func test_invalidCredential_hasCorrectDescription() {
        let error = AuthenticationError.invalidCredential
        XCTAssertEqual(
            error.errorDescription,
            "Invalid credentials. Please try again.",
            "invalidCredential should have user-friendly message"
        )
    }

    func test_missingNonce_hasCorrectDescription() {
        let error = AuthenticationError.missingNonce
        XCTAssertEqual(
            error.errorDescription,
            "Authentication failed. Please try again.",
            "missingNonce should have generic message (security: don't expose nonce details)"
        )
    }

    func test_userNotFound_hasCorrectDescription() {
        let error = AuthenticationError.userNotFound
        XCTAssertEqual(
            error.errorDescription,
            "No account found with this email.",
            "userNotFound should guide user to sign up"
        )
    }

    func test_emailAlreadyInUse_hasCorrectDescription() {
        let error = AuthenticationError.emailAlreadyInUse
        XCTAssertEqual(
            error.errorDescription,
            "An account already exists with this email.",
            "emailAlreadyInUse should guide user to sign in"
        )
    }

    func test_weakPassword_hasCorrectDescription() {
        let error = AuthenticationError.weakPassword
        XCTAssertEqual(
            error.errorDescription,
            "Password must be at least 8 characters.",
            "weakPassword should provide actionable guidance"
        )
    }

    func test_networkError_hasCorrectDescription() {
        let error = AuthenticationError.networkError
        XCTAssertEqual(
            error.errorDescription,
            "Network error. Please check your connection.",
            "networkError should guide user to check connectivity"
        )
    }

    func test_userDisabled_hasCorrectDescription() {
        let error = AuthenticationError.userDisabled
        XCTAssertEqual(
            error.errorDescription,
            "This account has been disabled.",
            "userDisabled should inform user of account status"
        )
    }

    func test_invalidEmail_hasCorrectDescription() {
        let error = AuthenticationError.invalidEmail
        XCTAssertEqual(
            error.errorDescription,
            "Please enter a valid email address.",
            "invalidEmail should guide user to fix input"
        )
    }

    func test_signOutFailed_hasCorrectDescription() {
        let error = AuthenticationError.signOutFailed
        XCTAssertEqual(
            error.errorDescription,
            "Failed to sign out. Please try again.",
            "signOutFailed should provide retry guidance"
        )
    }

    func test_unknownError_hasCorrectDescription() {
        let customMessage = "Custom error message from Firebase"
        let error = AuthenticationError.unknown(customMessage)
        XCTAssertEqual(
            error.errorDescription,
            customMessage,
            "unknown error should pass through the original message"
        )
    }

    // MARK: - Firebase Error Code Mapping Tests

    func test_firebaseErrorCode17004_mapsToInvalidCredential() {
        // Firebase ERROR_INVALID_CREDENTIAL
        let nsError = NSError(domain: "FIRAuthErrorDomain", code: 17004, userInfo: nil)
        let mapped = AuthenticationError.from(nsError)
        XCTAssertEqual(mapped, .invalidCredential)
    }

    func test_firebaseErrorCode17011_mapsToUserNotFound() {
        // Firebase ERROR_USER_NOT_FOUND
        let nsError = NSError(domain: "FIRAuthErrorDomain", code: 17011, userInfo: nil)
        let mapped = AuthenticationError.from(nsError)
        XCTAssertEqual(mapped, .userNotFound)
    }

    func test_firebaseErrorCode17007_mapsToEmailAlreadyInUse() {
        // Firebase ERROR_EMAIL_ALREADY_IN_USE
        let nsError = NSError(domain: "FIRAuthErrorDomain", code: 17007, userInfo: nil)
        let mapped = AuthenticationError.from(nsError)
        XCTAssertEqual(mapped, .emailAlreadyInUse)
    }

    func test_firebaseErrorCode17026_mapsToWeakPassword() {
        // Firebase ERROR_WEAK_PASSWORD
        let nsError = NSError(domain: "FIRAuthErrorDomain", code: 17026, userInfo: nil)
        let mapped = AuthenticationError.from(nsError)
        XCTAssertEqual(mapped, .weakPassword)
    }

    func test_firebaseErrorCode17020_mapsToNetworkError() {
        // Firebase ERROR_NETWORK_REQUEST_FAILED
        let nsError = NSError(domain: "FIRAuthErrorDomain", code: 17020, userInfo: nil)
        let mapped = AuthenticationError.from(nsError)
        XCTAssertEqual(mapped, .networkError)
    }

    func test_firebaseErrorCode17005_mapsToUserDisabled() {
        // Firebase ERROR_USER_DISABLED
        let nsError = NSError(domain: "FIRAuthErrorDomain", code: 17005, userInfo: nil)
        let mapped = AuthenticationError.from(nsError)
        XCTAssertEqual(mapped, .userDisabled)
    }

    func test_firebaseErrorCode17008_mapsToInvalidEmail() {
        // Firebase ERROR_INVALID_EMAIL
        let nsError = NSError(domain: "FIRAuthErrorDomain", code: 17008, userInfo: nil)
        let mapped = AuthenticationError.from(nsError)
        XCTAssertEqual(mapped, .invalidEmail)
    }

    func test_unknownErrorCode_mapsToUnknown() {
        let nsError = NSError(
            domain: "FIRAuthErrorDomain",
            code: 99999,
            userInfo: [NSLocalizedDescriptionKey: "Unknown Firebase error"]
        )
        let mapped = AuthenticationError.from(nsError)

        if case .unknown(let message) = mapped {
            XCTAssertEqual(message, "Unknown Firebase error")
        } else {
            XCTFail("Expected .unknown case but got \(mapped)")
        }
    }

    // MARK: - Equatable Conformance Tests

    func test_sameErrors_areEqual() {
        XCTAssertEqual(AuthenticationError.invalidCredential, AuthenticationError.invalidCredential)
        XCTAssertEqual(AuthenticationError.missingNonce, AuthenticationError.missingNonce)
        XCTAssertEqual(AuthenticationError.userNotFound, AuthenticationError.userNotFound)
        XCTAssertEqual(AuthenticationError.emailAlreadyInUse, AuthenticationError.emailAlreadyInUse)
        XCTAssertEqual(AuthenticationError.weakPassword, AuthenticationError.weakPassword)
        XCTAssertEqual(AuthenticationError.networkError, AuthenticationError.networkError)
        XCTAssertEqual(AuthenticationError.userDisabled, AuthenticationError.userDisabled)
        XCTAssertEqual(AuthenticationError.invalidEmail, AuthenticationError.invalidEmail)
        XCTAssertEqual(AuthenticationError.signOutFailed, AuthenticationError.signOutFailed)
    }

    func test_differentErrors_areNotEqual() {
        XCTAssertNotEqual(AuthenticationError.invalidCredential, AuthenticationError.userNotFound)
        XCTAssertNotEqual(AuthenticationError.weakPassword, AuthenticationError.networkError)
        XCTAssertNotEqual(AuthenticationError.invalidEmail, AuthenticationError.emailAlreadyInUse)
    }

    func test_unknownErrorsWithSameMessage_areEqual() {
        let error1 = AuthenticationError.unknown("Test message")
        let error2 = AuthenticationError.unknown("Test message")
        XCTAssertEqual(error1, error2)
    }

    func test_unknownErrorsWithDifferentMessages_areNotEqual() {
        let error1 = AuthenticationError.unknown("Message 1")
        let error2 = AuthenticationError.unknown("Message 2")
        XCTAssertNotEqual(error1, error2)
    }

    func test_unknownError_notEqualToOtherErrors() {
        let unknownError = AuthenticationError.unknown("Some message")
        XCTAssertNotEqual(unknownError, AuthenticationError.invalidCredential)
        XCTAssertNotEqual(unknownError, AuthenticationError.networkError)
    }

    // MARK: - LocalizedError Protocol Tests

    func test_localizedError_conformance() {
        // Verify that errorDescription is accessible through LocalizedError protocol
        let error: LocalizedError = AuthenticationError.invalidCredential
        XCTAssertNotNil(error.errorDescription)
        XCTAssertFalse(error.errorDescription?.isEmpty ?? true)
    }

    func test_allErrors_haveDescriptions() {
        // Ensure no error returns nil for errorDescription
        let allErrors: [AuthenticationError] = [
            .invalidCredential,
            .missingNonce,
            .userNotFound,
            .emailAlreadyInUse,
            .weakPassword,
            .networkError,
            .userDisabled,
            .invalidEmail,
            .signOutFailed,
            .unknown("Test")
        ]

        for error in allErrors {
            XCTAssertNotNil(
                error.errorDescription,
                "\(error) should have a non-nil errorDescription"
            )
            XCTAssertFalse(
                error.errorDescription?.isEmpty ?? true,
                "\(error) should have a non-empty errorDescription"
            )
        }
    }
}
