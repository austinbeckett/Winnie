import XCTest
@testable import Winnie

/// Comprehensive unit tests for FirestoreError
/// Tests error descriptions and LocalizedError conformance
final class FirestoreErrorTests: XCTestCase {

    // MARK: - Error Description Tests

    func test_documentNotFound_hasCorrectDescription() {
        let error = FirestoreError.documentNotFound
        XCTAssertEqual(
            error.errorDescription,
            "Document not found.",
            "documentNotFound should have clear message"
        )
    }

    func test_encodingFailed_hasCorrectDescription() {
        let error = FirestoreError.encodingFailed
        XCTAssertEqual(
            error.errorDescription,
            "Failed to encode data.",
            "encodingFailed should describe encoding issue"
        )
    }

    func test_decodingFailed_hasCorrectDescription() {
        let error = FirestoreError.decodingFailed
        XCTAssertEqual(
            error.errorDescription,
            "Failed to decode data.",
            "decodingFailed should describe decoding issue"
        )
    }

    func test_transactionFailed_hasCorrectDescription() {
        let error = FirestoreError.transactionFailed
        XCTAssertEqual(
            error.errorDescription,
            "Transaction failed. Please try again.",
            "transactionFailed should guide user to retry"
        )
    }

    func test_invalidData_hasCorrectDescription() {
        let message = "Email format is invalid"
        let error = FirestoreError.invalidData(message)
        XCTAssertEqual(
            error.errorDescription,
            "Invalid data: \(message)",
            "invalidData should include the specific validation message"
        )
    }

    func test_inviteCodeExpired_hasCorrectDescription() {
        let error = FirestoreError.inviteCodeExpired
        XCTAssertEqual(
            error.errorDescription,
            "This invite code has expired.",
            "inviteCodeExpired should inform user code is no longer valid"
        )
    }

    func test_inviteCodeAlreadyUsed_hasCorrectDescription() {
        let error = FirestoreError.inviteCodeAlreadyUsed
        XCTAssertEqual(
            error.errorDescription,
            "This invite code has already been used.",
            "inviteCodeAlreadyUsed should inform user code was consumed"
        )
    }

    func test_coupleAlreadyComplete_hasCorrectDescription() {
        let error = FirestoreError.coupleAlreadyComplete
        XCTAssertEqual(
            error.errorDescription,
            "This couple already has two members.",
            "coupleAlreadyComplete should explain member limit"
        )
    }

    func test_unauthorized_hasCorrectDescription() {
        let error = FirestoreError.unauthorized
        XCTAssertEqual(
            error.errorDescription,
            "You don't have permission to perform this action.",
            "unauthorized should explain permission issue"
        )
    }

    func test_unknownError_hasCorrectDescription() {
        let underlyingError = NSError(
            domain: "TestDomain",
            code: 500,
            userInfo: [NSLocalizedDescriptionKey: "Server error occurred"]
        )
        let error = FirestoreError.unknown(underlyingError)
        XCTAssertEqual(
            error.errorDescription,
            "Server error occurred",
            "unknown error should pass through underlying error's localizedDescription"
        )
    }

    // MARK: - LocalizedError Protocol Tests

    func test_localizedError_conformance() {
        // Verify that errorDescription is accessible through LocalizedError protocol
        let error: LocalizedError = FirestoreError.documentNotFound
        XCTAssertNotNil(error.errorDescription)
        XCTAssertFalse(error.errorDescription?.isEmpty ?? true)
    }

    func test_allErrors_haveDescriptions() {
        // Ensure no error returns nil for errorDescription
        let underlyingError = NSError(domain: "Test", code: 0, userInfo: nil)
        let allErrors: [FirestoreError] = [
            .documentNotFound,
            .encodingFailed,
            .decodingFailed,
            .transactionFailed,
            .invalidData("Test reason"),
            .inviteCodeExpired,
            .inviteCodeAlreadyUsed,
            .coupleAlreadyComplete,
            .unauthorized,
            .unknown(underlyingError)
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

    // MARK: - Security-Related Tests

    func test_invalidData_doesNotExposeInternalDetails() {
        // Ensure invalidData message is user-facing appropriate
        let error = FirestoreError.invalidData("field_value_too_long")
        let description = error.errorDescription ?? ""

        // Should prefix with "Invalid data:" not expose raw error
        XCTAssertTrue(description.hasPrefix("Invalid data:"))
    }

    func test_unauthorized_doesNotExposeSecurityDetails() {
        // The unauthorized error should not expose internal security details
        let error = FirestoreError.unauthorized
        let description = error.errorDescription ?? ""

        // Should be generic, not expose rules or paths
        XCTAssertFalse(description.contains("rules"))
        XCTAssertFalse(description.contains("/"))
        XCTAssertFalse(description.contains("firestore"))
    }
}
