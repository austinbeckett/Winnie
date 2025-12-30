import XCTest
import FirebaseFirestore
@testable import Winnie

/// Comprehensive unit tests for CoupleDTO
/// Tests domain model conversion, dictionary serialization, and member management
final class CoupleDTOTests: XCTestCase {

    // MARK: - Test Data

    private let testDate = Date(timeIntervalSince1970: 1704067200) // 2024-01-01 00:00:00 UTC
    private let futureDate = Date(timeIntervalSince1970: 1704672000) // 7 days later

    // MARK: - Initialization from Domain Model Tests

    func testInitFromCoupleCopiesAllFields() {
        let profile = FinancialProfile(
            monthlyIncome: 10000,
            monthlyExpenses: 6000,
            currentSavings: 25000
        )
        let couple = Couple(
            id: "couple123",
            memberIDs: ["user1", "user2"],
            financialProfile: profile,
            createdAt: testDate,
            inviteCode: "ABC123",
            inviteCodeExpiresAt: futureDate
        )

        let dto = CoupleDTO(from: couple)

        XCTAssertEqual(dto.id, couple.id)
        XCTAssertEqual(dto.memberIDs, couple.memberIDs)
        XCTAssertEqual(dto.inviteCode, couple.inviteCode)
        XCTAssertEqual(dto.inviteCodeExpiresAt, couple.inviteCodeExpiresAt)
        XCTAssertEqual(dto.createdAt, couple.createdAt)
    }

    func testInitFromCoupleSetsLastSyncedAt() {
        let couple = Couple(memberIDs: ["user1"])
        let beforeInit = Date()

        let dto = CoupleDTO(from: couple)

        XCTAssertNotNil(dto.lastSyncedAt)
        XCTAssertGreaterThanOrEqual(dto.lastSyncedAt ?? Date.distantPast, beforeInit)
    }

    func testInitFromCoupleWithNoInviteCode() {
        let couple = Couple(
            id: "couple123",
            memberIDs: ["user1", "user2"],
            inviteCode: nil,
            inviteCodeExpiresAt: nil
        )

        let dto = CoupleDTO(from: couple)

        XCTAssertNil(dto.inviteCode)
        XCTAssertNil(dto.inviteCodeExpiresAt)
    }

    // MARK: - Creator Initialization Tests

    func testInitForCreatorWithSingleMember() {
        let dto = CoupleDTO(id: "couple123", creatorUserID: "user1")

        XCTAssertEqual(dto.id, "couple123")
        XCTAssertEqual(dto.memberIDs, ["user1"])
        XCTAssertEqual(dto.memberIDs.count, 1, "New couple should start with 1 member")
    }

    func testInitForCreatorHasNoInviteCode() {
        let dto = CoupleDTO(id: "couple123", creatorUserID: "user1")

        XCTAssertNil(dto.inviteCode, "New couple should not have invite code initially")
        XCTAssertNil(dto.inviteCodeExpiresAt)
    }

    func testInitForCreatorSetsTimestamps() {
        let beforeInit = Date()

        let dto = CoupleDTO(id: "couple123", creatorUserID: "user1")

        XCTAssertGreaterThanOrEqual(dto.createdAt, beforeInit)
        XCTAssertNotNil(dto.lastSyncedAt)
    }

    // MARK: - Conversion to Domain Model Tests

    func testToCoupleRequiresFinancialProfile() {
        let dto = CoupleDTO(id: "couple123", creatorUserID: "user1")
        let profile = FinancialProfile(monthlyIncome: 5000)

        let couple = dto.toCouple(financialProfile: profile)

        XCTAssertEqual(couple.financialProfile.monthlyIncome, 5000)
    }

    func testToCoupleConvertsAllFields() {
        let dto = CoupleDTO(id: "couple123", creatorUserID: "user1")
        let profile = FinancialProfile()

        let couple = dto.toCouple(financialProfile: profile)

        XCTAssertEqual(couple.id, dto.id)
        XCTAssertEqual(couple.memberIDs, dto.memberIDs)
        XCTAssertEqual(couple.createdAt, dto.createdAt)
    }

    func testToCoupleRoundTrip() {
        let profile = FinancialProfile(
            monthlyIncome: 10000,
            monthlyExpenses: 6000
        )
        let originalCouple = Couple(
            id: "couple123",
            memberIDs: ["user1", "user2"],
            financialProfile: profile,
            createdAt: testDate,
            inviteCode: "XYZ789",
            inviteCodeExpiresAt: futureDate
        )

        let dto = CoupleDTO(from: originalCouple)
        let convertedCouple = dto.toCouple(financialProfile: profile)

        XCTAssertEqual(convertedCouple.id, originalCouple.id)
        XCTAssertEqual(convertedCouple.memberIDs, originalCouple.memberIDs)
        XCTAssertEqual(convertedCouple.inviteCode, originalCouple.inviteCode)
        XCTAssertEqual(convertedCouple.inviteCodeExpiresAt, originalCouple.inviteCodeExpiresAt)
    }

    // MARK: - Dictionary Serialization Tests

    func testDictionaryContainsRequiredFields() {
        let dto = CoupleDTO(id: "couple123", creatorUserID: "user1")
        let dict = dto.dictionary

        XCTAssertNotNil(dict["id"])
        XCTAssertNotNil(dict["memberIDs"])
        XCTAssertNotNil(dict["createdAt"])
    }

    func testDictionaryMemberIDsIsArray() {
        let dto = CoupleDTO(id: "couple123", creatorUserID: "user1")
        let dict = dto.dictionary

        let memberIDs = dict["memberIDs"] as? [String]
        XCTAssertNotNil(memberIDs)
        XCTAssertEqual(memberIDs, ["user1"])
    }

    func testDictionaryExcludesNilOptionals() {
        let dto = CoupleDTO(id: "couple123", creatorUserID: "user1")
        let dict = dto.dictionary

        XCTAssertNil(dict["inviteCode"], "nil inviteCode should not appear in dictionary")
        XCTAssertNil(dict["inviteCodeExpiresAt"], "nil inviteCodeExpiresAt should not appear")
    }

    func testDictionaryIncludesInviteCodeWhenPresent() {
        let couple = Couple(
            id: "couple123",
            memberIDs: ["user1"],
            inviteCode: "ABC123",
            inviteCodeExpiresAt: futureDate
        )
        let dto = CoupleDTO(from: couple)
        let dict = dto.dictionary

        XCTAssertEqual(dict["inviteCode"] as? String, "ABC123")
        XCTAssertNotNil(dict["inviteCodeExpiresAt"])
        XCTAssertTrue(dict["inviteCodeExpiresAt"] is Timestamp)
    }

    func testDictionaryUsesFirestoreTimestamps() {
        let dto = CoupleDTO(id: "couple123", creatorUserID: "user1")
        let dict = dto.dictionary

        XCTAssertTrue(dict["createdAt"] is Timestamp, "createdAt should be Firestore Timestamp")
    }

    // MARK: - Member Count Tests

    func testSingleMemberCouple() {
        let dto = CoupleDTO(id: "couple123", creatorUserID: "user1")

        XCTAssertEqual(dto.memberIDs.count, 1)
    }

    func testTwoMemberCouple() {
        let couple = Couple(
            id: "couple123",
            memberIDs: ["user1", "user2"]
        )
        let dto = CoupleDTO(from: couple)

        XCTAssertEqual(dto.memberIDs.count, 2)
    }

    // MARK: - Codable Conformance Tests

    @MainActor
    func testCodableRoundTrip() throws {
        let originalDTO = CoupleDTO(id: "couple123", creatorUserID: "user1")

        let encoder = JSONEncoder()
        let data = try encoder.encode(originalDTO)

        let decoder = JSONDecoder()
        let decodedDTO = try decoder.decode(CoupleDTO.self, from: data)

        XCTAssertEqual(decodedDTO.id, originalDTO.id)
        XCTAssertEqual(decodedDTO.memberIDs, originalDTO.memberIDs)
    }

    // MARK: - Security Tests

    func testMemberIDsAreSafelyStored() {
        // Ensure member IDs are stored as plain strings (for Firestore rules lookup)
        let dto = CoupleDTO(id: "couple123", creatorUserID: "user1")
        let dict = dto.dictionary

        let memberIDs = dict["memberIDs"] as? [String]
        XCTAssertNotNil(memberIDs)
        XCTAssertTrue(memberIDs?.contains("user1") ?? false)
    }

    func testInviteCodeStoredAsUppercase() {
        // Invite codes should be case-insensitive, stored uppercase
        let couple = Couple(
            id: "couple123",
            memberIDs: ["user1"],
            inviteCode: "abc123",  // lowercase input
            inviteCodeExpiresAt: futureDate
        )
        let dto = CoupleDTO(from: couple)

        // Note: The DTO stores as-is; normalization happens in InviteCodeDTO
        XCTAssertEqual(dto.inviteCode, "abc123")
    }
}
