import XCTest
@testable import Winnie

/// Comprehensive unit tests for AuthenticationError
/// Tests error descriptions, Firebase error code mapping, and Equatable conformance
final class AuthenticationErrorTests: XCTestCase {

    // MARK: - Error Description Tests

    func testInvalidCredentialDescription() {
        let error = AuthenticationError.invalidCredential
        XCTAssertEqual(
            error.errorDescription,
            "Invalid credentials. Please try again.",
            "invalidCredential should have user-friendly message"
        )
    }

    func testMissingNonceDescription() {
        let error = AuthenticationError.missingNonce
        XCTAssertEqual(
            error.errorDescription,
            "Authentication failed. Please try again.",
            "missingNonce should have generic message (security: don't expose nonce details)"
        )
    }

    func testUserNotFoundDescription() {
        let error = AuthenticationError.userNotFound
        XCTAssertEqual(
            error.errorDescription,
            "No account found with this email.",
            "userNotFound should guide user to sign up"
        )
    }

    func testEmailAlreadyInUseDescription() {
        let error = AuthenticationError.emailAlreadyInUse
        XCTAssertEqual(
            error.errorDescription,
            "An account already exists with this email.",
            "emailAlreadyInUse should guide user to sign in"
        )
    }

    func testWeakPasswordDescription() {
        let error = AuthenticationError.weakPassword
        XCTAssertEqual(
            error.errorDescription,
            "Password must be at least 8 characters.",
            "weakPassword should provide actionable guidance"
        )
    }

    func testNetworkErrorDescription() {
        let error = AuthenticationError.networkError
        XCTAssertEqual(
            error.errorDescription,
            "Network error. Please check your connection.",
            "networkError should guide user to check connectivity"
        )
    }

    func testUserDisabledDescription() {
        let error = AuthenticationError.userDisabled
        XCTAssertEqual(
            error.errorDescription,
            "This account has been disabled.",
            "userDisabled should inform user of account status"
        )
    }

    func testInvalidEmailDescription() {
        let error = AuthenticationError.invalidEmail
        XCTAssertEqual(
            error.errorDescription,
            "Please enter a valid email address.",
            "invalidEmail should guide user to fix input"
        )
    }

    func testSignOutFailedDescription() {
        let error = AuthenticationError.signOutFailed
        XCTAssertEqual(
            error.errorDescription,
            "Failed to sign out. Please try again.",
            "signOutFailed should provide retry guidance"
        )
    }

    func testUnknownErrorDescription() {
        let customMessage = "Custom error message from Firebase"
        let error = AuthenticationError.unknown(customMessage)
        XCTAssertEqual(
            error.errorDescription,
            customMessage,
            "unknown error should pass through the original message"
        )
    }

    // MARK: - Firebase Error Code Mapping Tests

    func testFirebaseErrorCode17004MapsToInvalidCredential() {
        // Firebase ERROR_INVALID_CREDENTIAL
        let nsError = NSError(domain: "FIRAuthErrorDomain", code: 17004, userInfo: nil)
        let mapped = AuthenticationError.from(nsError)
        XCTAssertEqual(mapped, .invalidCredential)
    }

    func testFirebaseErrorCode17011MapsToUserNotFound() {
        // Firebase ERROR_USER_NOT_FOUND
        let nsError = NSError(domain: "FIRAuthErrorDomain", code: 17011, userInfo: nil)
        let mapped = AuthenticationError.from(nsError)
        XCTAssertEqual(mapped, .userNotFound)
    }

    func testFirebaseErrorCode17007MapsToEmailAlreadyInUse() {
        // Firebase ERROR_EMAIL_ALREADY_IN_USE
        let nsError = NSError(domain: "FIRAuthErrorDomain", code: 17007, userInfo: nil)
        let mapped = AuthenticationError.from(nsError)
        XCTAssertEqual(mapped, .emailAlreadyInUse)
    }

    func testFirebaseErrorCode17026MapsToWeakPassword() {
        // Firebase ERROR_WEAK_PASSWORD
        let nsError = NSError(domain: "FIRAuthErrorDomain", code: 17026, userInfo: nil)
        let mapped = AuthenticationError.from(nsError)
        XCTAssertEqual(mapped, .weakPassword)
    }

    func testFirebaseErrorCode17020MapsToNetworkError() {
        // Firebase ERROR_NETWORK_REQUEST_FAILED
        let nsError = NSError(domain: "FIRAuthErrorDomain", code: 17020, userInfo: nil)
        let mapped = AuthenticationError.from(nsError)
        XCTAssertEqual(mapped, .networkError)
    }

    func testFirebaseErrorCode17005MapsToUserDisabled() {
        // Firebase ERROR_USER_DISABLED
        let nsError = NSError(domain: "FIRAuthErrorDomain", code: 17005, userInfo: nil)
        let mapped = AuthenticationError.from(nsError)
        XCTAssertEqual(mapped, .userDisabled)
    }

    func testFirebaseErrorCode17008MapsToInvalidEmail() {
        // Firebase ERROR_INVALID_EMAIL
        let nsError = NSError(domain: "FIRAuthErrorDomain", code: 17008, userInfo: nil)
        let mapped = AuthenticationError.from(nsError)
        XCTAssertEqual(mapped, .invalidEmail)
    }

    func testUnknownErrorCodeMapsToUnknown() {
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

    func testSameErrorsAreEqual() {
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

    func testDifferentErrorsAreNotEqual() {
        XCTAssertNotEqual(AuthenticationError.invalidCredential, AuthenticationError.userNotFound)
        XCTAssertNotEqual(AuthenticationError.weakPassword, AuthenticationError.networkError)
        XCTAssertNotEqual(AuthenticationError.invalidEmail, AuthenticationError.emailAlreadyInUse)
    }

    func testUnknownErrorsWithSameMessageAreEqual() {
        let error1 = AuthenticationError.unknown("Test message")
        let error2 = AuthenticationError.unknown("Test message")
        XCTAssertEqual(error1, error2)
    }

    func testUnknownErrorsWithDifferentMessagesAreNotEqual() {
        let error1 = AuthenticationError.unknown("Message 1")
        let error2 = AuthenticationError.unknown("Message 2")
        XCTAssertNotEqual(error1, error2)
    }

    func testUnknownErrorNotEqualToOtherErrors() {
        let unknownError = AuthenticationError.unknown("Some message")
        XCTAssertNotEqual(unknownError, AuthenticationError.invalidCredential)
        XCTAssertNotEqual(unknownError, AuthenticationError.networkError)
    }

    // MARK: - LocalizedError Protocol Tests

    func testLocalizedErrorConformance() {
        // Verify that errorDescription is accessible through LocalizedError protocol
        let error: LocalizedError = AuthenticationError.invalidCredential
        XCTAssertNotNil(error.errorDescription)
        XCTAssertFalse(error.errorDescription?.isEmpty ?? true)
    }

    func testAllErrorsHaveDescriptions() {
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
