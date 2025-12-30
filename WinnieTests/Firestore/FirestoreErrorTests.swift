import XCTest
@testable import Winnie

/// Comprehensive unit tests for FirestoreError
/// Tests error descriptions and LocalizedError conformance
final class FirestoreErrorTests: XCTestCase {

    // MARK: - Error Description Tests

    func testDocumentNotFoundDescription() {
        let error = FirestoreError.documentNotFound
        XCTAssertEqual(
            error.errorDescription,
            "Document not found.",
            "documentNotFound should have clear message"
        )
    }

    func testEncodingFailedDescription() {
        let error = FirestoreError.encodingFailed
        XCTAssertEqual(
            error.errorDescription,
            "Failed to encode data.",
            "encodingFailed should describe encoding issue"
        )
    }

    func testDecodingFailedDescription() {
        let error = FirestoreError.decodingFailed
        XCTAssertEqual(
            error.errorDescription,
            "Failed to decode data.",
            "decodingFailed should describe decoding issue"
        )
    }

    func testTransactionFailedDescription() {
        let error = FirestoreError.transactionFailed
        XCTAssertEqual(
            error.errorDescription,
            "Transaction failed. Please try again.",
            "transactionFailed should guide user to retry"
        )
    }

    func testInvalidDataDescription() {
        let message = "Email format is invalid"
        let error = FirestoreError.invalidData(message)
        XCTAssertEqual(
            error.errorDescription,
            "Invalid data: \(message)",
            "invalidData should include the specific validation message"
        )
    }

    func testInviteCodeExpiredDescription() {
        let error = FirestoreError.inviteCodeExpired
        XCTAssertEqual(
            error.errorDescription,
            "This invite code has expired.",
            "inviteCodeExpired should inform user code is no longer valid"
        )
    }

    func testInviteCodeAlreadyUsedDescription() {
        let error = FirestoreError.inviteCodeAlreadyUsed
        XCTAssertEqual(
            error.errorDescription,
            "This invite code has already been used.",
            "inviteCodeAlreadyUsed should inform user code was consumed"
        )
    }

    func testCoupleAlreadyCompleteDescription() {
        let error = FirestoreError.coupleAlreadyComplete
        XCTAssertEqual(
            error.errorDescription,
            "This couple already has two members.",
            "coupleAlreadyComplete should explain member limit"
        )
    }

    func testUnauthorizedDescription() {
        let error = FirestoreError.unauthorized
        XCTAssertEqual(
            error.errorDescription,
            "You don't have permission to perform this action.",
            "unauthorized should explain permission issue"
        )
    }

    func testUnknownErrorDescription() {
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

    func testLocalizedErrorConformance() {
        // Verify that errorDescription is accessible through LocalizedError protocol
        let error: LocalizedError = FirestoreError.documentNotFound
        XCTAssertNotNil(error.errorDescription)
        XCTAssertFalse(error.errorDescription?.isEmpty ?? true)
    }

    func testAllErrorsHaveDescriptions() {
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

    func testInvalidDataDoesNotExposeInternalDetails() {
        // Ensure invalidData message is user-facing appropriate
        let error = FirestoreError.invalidData("field_value_too_long")
        let description = error.errorDescription ?? ""

        // Should prefix with "Invalid data:" not expose raw error
        XCTAssertTrue(description.hasPrefix("Invalid data:"))
    }

    func testUnauthorizedDoesNotExposeSecurityDetails() {
        // The unauthorized error should not expose internal security details
        let error = FirestoreError.unauthorized
        let description = error.errorDescription ?? ""

        // Should be generic, not expose rules or paths
        XCTAssertFalse(description.contains("rules"))
        XCTAssertFalse(description.contains("/"))
        XCTAssertFalse(description.contains("firestore"))
    }
}
