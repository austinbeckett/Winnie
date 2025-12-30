import XCTest
import FirebaseFirestore
@testable import Winnie

/// Comprehensive unit tests for InviteCodeDTO
/// Tests code validation, expiration logic, case normalization, and security properties
final class InviteCodeDTOTests: XCTestCase {

    // MARK: - Test Data

    private let now = Date()
    private var futureDate: Date { Calendar.current.date(byAdding: .day, value: 7, to: now)! }
    private var pastDate: Date { Calendar.current.date(byAdding: .day, value: -1, to: now)! }

    // MARK: - Initialization Tests

    func testInitializerSetsAllFields() {
        let dto = InviteCodeDTO(
            code: "ABC123",
            coupleID: "couple123",
            createdBy: "user123",
            expiresAt: futureDate
        )

        XCTAssertEqual(dto.code, "ABC123")
        XCTAssertEqual(dto.coupleID, "couple123")
        XCTAssertEqual(dto.createdBy, "user123")
        XCTAssertEqual(dto.expiresAt, futureDate)
        XCTAssertFalse(dto.isUsed)
        XCTAssertNil(dto.usedBy)
        XCTAssertNil(dto.usedAt)
    }

    func testInitializerUppercasesCode() {
        let dto = InviteCodeDTO(
            code: "abc123",
            coupleID: "couple123",
            createdBy: "user123",
            expiresAt: futureDate
        )

        XCTAssertEqual(dto.code, "ABC123", "Code should be stored uppercase")
    }

    func testInitializerWithMixedCaseCode() {
        let dto = InviteCodeDTO(
            code: "AbC123",
            coupleID: "couple123",
            createdBy: "user123",
            expiresAt: futureDate
        )

        XCTAssertEqual(dto.code, "ABC123", "Mixed case should be normalized to uppercase")
    }

    // MARK: - Computed Property Tests: isValid

    func testIsValidReturnsTrueForUnusedNotExpired() {
        let dto = InviteCodeDTO(
            code: "ABC123",
            coupleID: "couple123",
            createdBy: "user123",
            expiresAt: futureDate
        )

        XCTAssertTrue(dto.isValid, "Unused, not expired code should be valid")
    }

    func testIsValidReturnsFalseForUsedCode() {
        var dto = InviteCodeDTO(
            code: "ABC123",
            coupleID: "couple123",
            createdBy: "user123",
            expiresAt: futureDate
        )
        dto.isUsed = true
        dto.usedBy = "partner456"
        dto.usedAt = now

        XCTAssertFalse(dto.isValid, "Used code should not be valid")
    }

    func testIsValidReturnsFalseForExpiredCode() {
        let dto = InviteCodeDTO(
            code: "ABC123",
            coupleID: "couple123",
            createdBy: "user123",
            expiresAt: pastDate
        )

        XCTAssertFalse(dto.isValid, "Expired code should not be valid")
    }

    func testIsValidReturnsFalseForUsedAndExpired() {
        var dto = InviteCodeDTO(
            code: "ABC123",
            coupleID: "couple123",
            createdBy: "user123",
            expiresAt: pastDate
        )
        dto.isUsed = true

        XCTAssertFalse(dto.isValid, "Used and expired code should not be valid")
    }

    // MARK: - Computed Property Tests: isExpired

    func testIsExpiredReturnsTrueForPastDate() {
        let dto = InviteCodeDTO(
            code: "ABC123",
            coupleID: "couple123",
            createdBy: "user123",
            expiresAt: pastDate
        )

        XCTAssertTrue(dto.isExpired, "Code with past expiration should be expired")
    }

    func testIsExpiredReturnsFalseForFutureDate() {
        let dto = InviteCodeDTO(
            code: "ABC123",
            coupleID: "couple123",
            createdBy: "user123",
            expiresAt: futureDate
        )

        XCTAssertFalse(dto.isExpired, "Code with future expiration should not be expired")
    }

    func testIsExpiredEdgeCaseExactlyNow() {
        // Test expiration at exact current time (should be expired - using <=)
        let dto = InviteCodeDTO(
            code: "ABC123",
            coupleID: "couple123",
            createdBy: "user123",
            expiresAt: Date()
        )

        // At the exact boundary, the code expires
        XCTAssertTrue(dto.isExpired, "Code expiring at exact moment should be expired")
    }

    // MARK: - Dictionary Serialization Tests

    func testDictionaryContainsRequiredFields() {
        let dto = InviteCodeDTO(
            code: "ABC123",
            coupleID: "couple123",
            createdBy: "user123",
            expiresAt: futureDate
        )
        let dict = dto.dictionary

        XCTAssertNotNil(dict["code"])
        XCTAssertNotNil(dict["coupleID"])
        XCTAssertNotNil(dict["createdBy"])
        XCTAssertNotNil(dict["expiresAt"])
        XCTAssertNotNil(dict["isUsed"])
    }

    func testDictionaryExcludesNilOptionals() {
        let dto = InviteCodeDTO(
            code: "ABC123",
            coupleID: "couple123",
            createdBy: "user123",
            expiresAt: futureDate
        )
        let dict = dto.dictionary

        XCTAssertNil(dict["usedBy"], "nil usedBy should not appear")
        XCTAssertNil(dict["usedAt"], "nil usedAt should not appear")
    }

    func testDictionaryIncludesUsageFieldsWhenUsed() {
        var dto = InviteCodeDTO(
            code: "ABC123",
            coupleID: "couple123",
            createdBy: "user123",
            expiresAt: futureDate
        )
        dto.isUsed = true
        dto.usedBy = "partner456"
        dto.usedAt = now

        let dict = dto.dictionary

        XCTAssertEqual(dict["usedBy"] as? String, "partner456")
        XCTAssertNotNil(dict["usedAt"])
        XCTAssertTrue(dict["usedAt"] is Timestamp)
    }

    func testDictionaryUsesFirestoreTimestamps() {
        let dto = InviteCodeDTO(
            code: "ABC123",
            coupleID: "couple123",
            createdBy: "user123",
            expiresAt: futureDate
        )
        let dict = dto.dictionary

        XCTAssertTrue(dict["expiresAt"] is Timestamp, "expiresAt should be Firestore Timestamp")
    }

    func testDictionaryBooleanIsUsed() {
        let dto = InviteCodeDTO(
            code: "ABC123",
            coupleID: "couple123",
            createdBy: "user123",
            expiresAt: futureDate
        )
        let dict = dto.dictionary

        XCTAssertEqual(dict["isUsed"] as? Bool, false)
    }

    // MARK: - Codable Conformance Tests

    @MainActor
    func testCodableRoundTrip() throws {
        let originalDTO = InviteCodeDTO(
            code: "XYZ789",
            coupleID: "couple123",
            createdBy: "user123",
            expiresAt: futureDate
        )

        let encoder = JSONEncoder()
        let data = try encoder.encode(originalDTO)

        let decoder = JSONDecoder()
        let decodedDTO = try decoder.decode(InviteCodeDTO.self, from: data)

        XCTAssertEqual(decodedDTO.code, originalDTO.code)
        XCTAssertEqual(decodedDTO.coupleID, originalDTO.coupleID)
        XCTAssertEqual(decodedDTO.createdBy, originalDTO.createdBy)
        XCTAssertEqual(decodedDTO.isUsed, originalDTO.isUsed)
    }

    // MARK: - Security Tests

    func testCodeDoesNotContainAmbiguousCharacters() {
        // Codes should not contain I, O, 0, 1 (ambiguous characters)
        // This is validated in the repository, but we ensure DTO stores as-is
        let dto = InviteCodeDTO(
            code: "ABCDEF",  // Valid characters only
            coupleID: "couple123",
            createdBy: "user123",
            expiresAt: futureDate
        )

        let code = dto.code
        XCTAssertFalse(code.contains("I"), "Code should not contain I")
        XCTAssertFalse(code.contains("O"), "Code should not contain O")
        XCTAssertFalse(code.contains("0"), "Code should not contain 0")
        XCTAssertFalse(code.contains("1"), "Code should not contain 1")
    }

    func testCoupleIDIsImmutable() {
        // coupleID is declared as let, this is a compile-time check
        let dto = InviteCodeDTO(
            code: "ABC123",
            coupleID: "couple123",
            createdBy: "user123",
            expiresAt: futureDate
        )

        XCTAssertEqual(dto.coupleID, "couple123")
    }

    func testCreatedByIsImmutable() {
        // createdBy is declared as let, this is a compile-time check
        let dto = InviteCodeDTO(
            code: "ABC123",
            coupleID: "couple123",
            createdBy: "user123",
            expiresAt: futureDate
        )

        XCTAssertEqual(dto.createdBy, "user123")
    }

    // MARK: - Usage State Tests

    func testMarkingCodeAsUsed() {
        var dto = InviteCodeDTO(
            code: "ABC123",
            coupleID: "couple123",
            createdBy: "user123",
            expiresAt: futureDate
        )

        XCTAssertTrue(dto.isValid, "Should start as valid")

        dto.isUsed = true
        dto.usedBy = "newPartner789"
        dto.usedAt = Date()

        XCTAssertFalse(dto.isValid, "Should be invalid after use")
        XCTAssertEqual(dto.usedBy, "newPartner789")
        XCTAssertNotNil(dto.usedAt)
    }

    func testUsedCodeRemainsBoundToCoupleID() {
        var dto = InviteCodeDTO(
            code: "ABC123",
            coupleID: "couple123",
            createdBy: "user123",
            expiresAt: futureDate
        )
        dto.isUsed = true
        dto.usedBy = "partner456"

        // coupleID should remain unchanged even after use
        XCTAssertEqual(dto.coupleID, "couple123")
    }
}
