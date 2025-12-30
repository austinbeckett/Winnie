import XCTest
import FirebaseFirestore
@testable import Winnie

/// Comprehensive unit tests for UserDTO
/// Tests domain model conversion, dictionary serialization, and Codable conformance
final class UserDTOTests: XCTestCase {

    // MARK: - Test Data

    private let testDate = Date(timeIntervalSince1970: 1704067200) // 2024-01-01 00:00:00 UTC

    // MARK: - Initialization from Domain Model Tests

    func test_initFromUser_copiesAllFields() {
        let user = User(
            id: "user123",
            displayName: "John Doe",
            email: "john@example.com",
            partnerID: "partner456",
            coupleID: "couple789",
            createdAt: testDate,
            lastLoginAt: testDate,
            hasCompletedOnboarding: true
        )

        let dto = UserDTO(from: user)

        XCTAssertEqual(dto.id, user.id)
        XCTAssertEqual(dto.displayName, user.displayName)
        XCTAssertEqual(dto.email, user.email)
        XCTAssertEqual(dto.partnerID, user.partnerID)
        XCTAssertEqual(dto.coupleID, user.coupleID)
        XCTAssertEqual(dto.createdAt, user.createdAt)
        XCTAssertEqual(dto.lastLoginAt, user.lastLoginAt)
        XCTAssertEqual(dto.hasCompletedOnboarding, user.hasCompletedOnboarding)
    }

    func test_initFromUser_setsLastSyncedAt() {
        let user = User(id: "user123")
        let beforeInit = Date()

        let dto = UserDTO(from: user)

        XCTAssertNotNil(dto.lastSyncedAt)
        XCTAssertGreaterThanOrEqual(dto.lastSyncedAt ?? Date.distantPast, beforeInit)
    }

    func test_initFromUser_handlesNilOptionals() {
        let user = User(
            id: "user123",
            displayName: nil,
            email: nil,
            partnerID: nil,
            coupleID: nil,
            lastLoginAt: nil,
            hasCompletedOnboarding: false
        )

        let dto = UserDTO(from: user)

        XCTAssertNil(dto.displayName)
        XCTAssertNil(dto.email)
        XCTAssertNil(dto.partnerID)
        XCTAssertNil(dto.coupleID)
        XCTAssertNil(dto.lastLoginAt)
    }

    // MARK: - Sign-up Initialization Tests

    func test_initForSignUp_setsAllFields() {
        let dto = UserDTO(
            id: "user123",
            displayName: "Jane Doe",
            email: "jane@example.com"
        )

        XCTAssertEqual(dto.id, "user123")
        XCTAssertEqual(dto.displayName, "Jane Doe")
        XCTAssertEqual(dto.email, "jane@example.com")
        XCTAssertNil(dto.partnerID, "New users should not have partner")
        XCTAssertNil(dto.coupleID, "New users should not have couple")
        XCTAssertFalse(dto.hasCompletedOnboarding, "New users have not completed onboarding")
    }

    func test_initForSignUp_setsTimestamps() {
        let beforeInit = Date()

        let dto = UserDTO(id: "user123", displayName: nil, email: nil)

        XCTAssertGreaterThanOrEqual(dto.createdAt, beforeInit)
        XCTAssertNotNil(dto.lastLoginAt)
        XCTAssertNotNil(dto.lastSyncedAt)
    }

    func test_initForSignUp_worksWithMinimalData() {
        let dto = UserDTO(id: "user123")

        XCTAssertEqual(dto.id, "user123")
        XCTAssertNil(dto.displayName)
        XCTAssertNil(dto.email)
    }

    // MARK: - Conversion to Domain Model Tests

    func test_toUser_convertsAllFields() {
        let dto = UserDTO(
            id: "user123",
            displayName: "John Doe",
            email: "john@example.com"
        )

        let user = dto.toUser()

        XCTAssertEqual(user.id, dto.id)
        XCTAssertEqual(user.displayName, dto.displayName)
        XCTAssertEqual(user.email, dto.email)
        XCTAssertEqual(user.createdAt, dto.createdAt)
        XCTAssertEqual(user.hasCompletedOnboarding, dto.hasCompletedOnboarding)
    }

    func test_toUser_roundTrip() {
        let originalUser = User(
            id: "user123",
            displayName: "John Doe",
            email: "john@example.com",
            partnerID: "partner456",
            coupleID: "couple789",
            createdAt: testDate,
            lastLoginAt: testDate,
            hasCompletedOnboarding: true
        )

        let dto = UserDTO(from: originalUser)
        let convertedUser = dto.toUser()

        XCTAssertEqual(convertedUser.id, originalUser.id)
        XCTAssertEqual(convertedUser.displayName, originalUser.displayName)
        XCTAssertEqual(convertedUser.email, originalUser.email)
        XCTAssertEqual(convertedUser.partnerID, originalUser.partnerID)
        XCTAssertEqual(convertedUser.coupleID, originalUser.coupleID)
        XCTAssertEqual(convertedUser.hasCompletedOnboarding, originalUser.hasCompletedOnboarding)
    }

    // MARK: - Dictionary Serialization Tests

    func test_dictionary_containsRequiredFields() {
        let dto = UserDTO(id: "user123")
        let dict = dto.dictionary

        XCTAssertNotNil(dict["id"])
        XCTAssertNotNil(dict["createdAt"])
        XCTAssertNotNil(dict["hasCompletedOnboarding"])
    }

    func test_dictionary_excludesNilOptionals() {
        let dto = UserDTO(id: "user123", displayName: nil, email: nil)
        let dict = dto.dictionary

        XCTAssertNil(dict["displayName"], "nil displayName should not appear in dictionary")
        XCTAssertNil(dict["email"], "nil email should not appear in dictionary")
        XCTAssertNil(dict["partnerID"], "nil partnerID should not appear in dictionary")
        XCTAssertNil(dict["coupleID"], "nil coupleID should not appear in dictionary")
    }

    func test_dictionary_includesNonNilOptionals() {
        let user = User(
            id: "user123",
            displayName: "John Doe",
            email: "john@example.com",
            partnerID: "partner456",
            coupleID: "couple789",
            lastLoginAt: testDate
        )
        let dto = UserDTO(from: user)
        let dict = dto.dictionary

        XCTAssertEqual(dict["displayName"] as? String, "John Doe")
        XCTAssertEqual(dict["email"] as? String, "john@example.com")
        XCTAssertEqual(dict["partnerID"] as? String, "partner456")
        XCTAssertEqual(dict["coupleID"] as? String, "couple789")
        XCTAssertNotNil(dict["lastLoginAt"])
    }

    func test_dictionary_usesFirestoreTimestamps() {
        let dto = UserDTO(id: "user123")
        let dict = dto.dictionary

        XCTAssertTrue(dict["createdAt"] is Timestamp, "createdAt should be Firestore Timestamp")
    }

    func test_dictionary_hasBooleanValueCorrect() {
        let dto = UserDTO(id: "user123")
        let dict = dto.dictionary

        XCTAssertEqual(dict["hasCompletedOnboarding"] as? Bool, false)
    }

    // MARK: - Codable Conformance Tests

    @MainActor
    func test_codable_roundTrip() throws {
        let originalDTO = UserDTO(
            id: "user123",
            displayName: "John Doe",
            email: "john@example.com"
        )

        let encoder = JSONEncoder()
        let data = try encoder.encode(originalDTO)

        let decoder = JSONDecoder()
        let decodedDTO = try decoder.decode(UserDTO.self, from: data)

        XCTAssertEqual(decodedDTO.id, originalDTO.id)
        XCTAssertEqual(decodedDTO.displayName, originalDTO.displayName)
        XCTAssertEqual(decodedDTO.email, originalDTO.email)
        XCTAssertEqual(decodedDTO.hasCompletedOnboarding, originalDTO.hasCompletedOnboarding)
    }

    // MARK: - Security Tests

    func test_sensitiveData_handledCorrectly() {
        // Ensure email is properly stored (not hashed, but also not exposed inappropriately)
        let dto = UserDTO(id: "user123", email: "test@example.com")
        let dict = dto.dictionary

        // Email should be stored as-is for Firebase Auth lookup
        XCTAssertEqual(dict["email"] as? String, "test@example.com")
    }

    func test_id_isImmutable() {
        let dto = UserDTO(id: "user123")

        // The 'id' property is declared as 'let', so this is a compile-time check
        // We just verify it exists and is the expected value
        XCTAssertEqual(dto.id, "user123")
    }
}
