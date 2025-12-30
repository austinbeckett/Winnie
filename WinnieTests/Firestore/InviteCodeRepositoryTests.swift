import XCTest
@testable import Winnie

// MARK: - InviteCodeRepository Tests

/// Tests for InviteCodeRepository using MockFirestoreService
///
/// These tests verify that InviteCodeRepository correctly:
/// - Creates and stores invite codes
/// - Validates invite codes (expiration, usage)
/// - Marks codes as used
/// - Cleans up expired codes
@MainActor
final class InviteCodeRepositoryTests: XCTestCase {

    // MARK: - Properties

    var mockFirestore: MockFirestoreService!
    var repository: InviteCodeRepository!

    // MARK: - Setup & Teardown

    override func setUp() {
        super.setUp()
        mockFirestore = MockFirestoreService()
        repository = InviteCodeRepository(db: mockFirestore)
    }

    override func tearDown() {
        mockFirestore = nil
        repository = nil
        super.tearDown()
    }

    // MARK: - Create Invite Code Tests

    func test_createInviteCode_generatesAndStoresCode() async throws {
        // Act
        let code = try await repository.createInviteCode(
            coupleID: "couple-123",
            createdBy: "user-456"
        )

        // Assert
        XCTAssertEqual(code.count, 6)  // Code should be 6 characters
        XCTAssertTrue(mockFirestore.didSetData(at: "inviteCodes/\(code)"))
    }

    func test_createInviteCode_storesCorrectData() async throws {
        // Act
        let code = try await repository.createInviteCode(
            coupleID: "couple-123",
            createdBy: "user-456",
            expirationDays: 7
        )

        // Assert
        let data = mockFirestore.dataWritten(to: "inviteCodes/\(code)")
        XCTAssertEqual(data?["code"] as? String, code)
        XCTAssertEqual(data?["coupleID"] as? String, "couple-123")
        XCTAssertEqual(data?["createdBy"] as? String, "user-456")
        XCTAssertEqual(data?["isUsed"] as? Bool, false)
    }

    func test_createInviteCode_generatesOnlyValidCharacters() async throws {
        // The code should only contain characters from the set: ABCDEFGHJKLMNPQRSTUVWXYZ23456789
        // (excludes ambiguous: I, O, 0, 1)

        // Act
        let code = try await repository.createInviteCode(
            coupleID: "couple-123",
            createdBy: "user-456"
        )

        // Assert
        let validChars = CharacterSet(charactersIn: "ABCDEFGHJKLMNPQRSTUVWXYZ23456789")
        let codeChars = CharacterSet(charactersIn: code)
        XCTAssertTrue(codeChars.isSubset(of: validChars), "Code contains invalid characters: \(code)")
    }

    // MARK: - Fetch Invite Code Tests

    func test_fetchInviteCode_returnsCodeWhenExists() async throws {
        // Arrange
        mockFirestore.stubDocument(
            path: "inviteCodes/ABC123",
            data: TestFixtures.makeInviteCodeData(code: "ABC123", coupleID: "couple-123")
        )

        // Act
        let dto = try await repository.fetchInviteCode("ABC123")

        // Assert - capture values to avoid main actor isolation issues
        let code = dto.code
        let coupleID = dto.coupleID
        XCTAssertEqual(code, "ABC123")
        XCTAssertEqual(coupleID, "couple-123")
    }

    func test_fetchInviteCode_throwsDocumentNotFoundWhenMissing() async {
        // Act & Assert
        do {
            _ = try await repository.fetchInviteCode("NONEXISTENT")
            XCTFail("Expected documentNotFound error")
        } catch FirestoreError.documentNotFound {
            // Expected
        } catch {
            XCTFail("Wrong error type: \(error)")
        }
    }

    func test_fetchInviteCode_uppercasesCodeForLookup() async throws {
        // Arrange
        mockFirestore.stubDocument(
            path: "inviteCodes/ABC123",
            data: TestFixtures.makeInviteCodeData(code: "ABC123")
        )

        // Act
        let dto = try await repository.fetchInviteCode("abc123")

        // Assert - capture value to avoid main actor isolation issues
        let code = dto.code
        XCTAssertEqual(code, "ABC123")
    }

    // MARK: - Validate Invite Code Tests

    func test_validateInviteCode_returnsCoupleIDForValidCode() async throws {
        // Arrange
        let futureDate = Date().addingTimeInterval(86400)  // 1 day from now
        mockFirestore.stubDocument(
            path: "inviteCodes/ABC123",
            data: TestFixtures.makeInviteCodeData(
                code: "ABC123",
                coupleID: "couple-123",
                expiresAt: futureDate,
                isUsed: false
            )
        )

        // Act
        let coupleID = try await repository.validateInviteCode("ABC123")

        // Assert
        XCTAssertEqual(coupleID, "couple-123")
    }

    func test_validateInviteCode_throwsWhenCodeAlreadyUsed() async {
        // Arrange
        let futureDate = Date().addingTimeInterval(86400)
        mockFirestore.stubDocument(
            path: "inviteCodes/ABC123",
            data: TestFixtures.makeInviteCodeData(
                code: "ABC123",
                expiresAt: futureDate,
                isUsed: true
            )
        )

        // Act & Assert
        do {
            _ = try await repository.validateInviteCode("ABC123")
            XCTFail("Expected inviteCodeAlreadyUsed error")
        } catch FirestoreError.inviteCodeAlreadyUsed {
            // Expected
        } catch {
            XCTFail("Wrong error type: \(error)")
        }
    }

    func test_validateInviteCode_throwsWhenCodeExpired() async {
        // Arrange
        let pastDate = Date().addingTimeInterval(-86400)  // 1 day ago
        mockFirestore.stubDocument(
            path: "inviteCodes/ABC123",
            data: TestFixtures.makeInviteCodeData(
                code: "ABC123",
                expiresAt: pastDate,
                isUsed: false
            )
        )

        // Act & Assert
        do {
            _ = try await repository.validateInviteCode("ABC123")
            XCTFail("Expected inviteCodeExpired error")
        } catch FirestoreError.inviteCodeExpired {
            // Expected
        } catch {
            XCTFail("Wrong error type: \(error)")
        }
    }

    // MARK: - Invite Code Exists Tests

    func test_inviteCodeExists_returnsTrueWhenExists() async throws {
        // Arrange
        mockFirestore.stubDocument(
            path: "inviteCodes/ABC123",
            data: TestFixtures.makeInviteCodeData(code: "ABC123")
        )

        // Act
        let exists = try await repository.inviteCodeExists("ABC123")

        // Assert
        XCTAssertTrue(exists)
    }

    func test_inviteCodeExists_returnsFalseWhenMissing() async throws {
        // Act
        let exists = try await repository.inviteCodeExists("NONEXISTENT")

        // Assert
        XCTAssertFalse(exists)
    }

    // MARK: - Mark Code As Used Tests

    func test_markCodeAsUsed_updatesCorrectFields() async throws {
        // Arrange
        mockFirestore.stubDocument(
            path: "inviteCodes/ABC123",
            data: TestFixtures.makeInviteCodeData(code: "ABC123", isUsed: false)
        )

        // Act
        try await repository.markCodeAsUsed(code: "ABC123", by: "user-789")

        // Assert
        let fields = mockFirestore.fieldsUpdated(at: "inviteCodes/ABC123")
        XCTAssertEqual(fields?["isUsed"] as? Bool, true)
        XCTAssertEqual(fields?["usedBy"] as? String, "user-789")
        XCTAssertNotNil(fields?["usedAt"])
    }

    // MARK: - Delete Invite Code Tests

    func test_deleteInviteCode_deletesDocument() async throws {
        // Arrange
        mockFirestore.stubDocument(
            path: "inviteCodes/ABC123",
            data: TestFixtures.makeInviteCodeData(code: "ABC123")
        )

        // Act
        try await repository.deleteInviteCode("ABC123")

        // Assert
        XCTAssertTrue(mockFirestore.didDelete(at: "inviteCodes/ABC123"))
    }

    func test_deleteUnusedCodesForCouple_deletesUnusedCodesOnly() async throws {
        // Arrange
        mockFirestore.stubDocument(
            path: "inviteCodes/CODE1",
            data: TestFixtures.makeInviteCodeData(
                code: "CODE1",
                coupleID: "couple-123",
                isUsed: false
            )
        )
        mockFirestore.stubDocument(
            path: "inviteCodes/CODE2",
            data: TestFixtures.makeInviteCodeData(
                code: "CODE2",
                coupleID: "couple-123",
                isUsed: true
            )
        )

        // Act
        try await repository.deleteUnusedCodesForCouple("couple-123")

        // Assert - Only unused code should be deleted
        XCTAssertTrue(mockFirestore.didDelete(at: "inviteCodes/CODE1"))
        XCTAssertFalse(mockFirestore.didDelete(at: "inviteCodes/CODE2"))
    }

    // MARK: - Error Handling Tests

    func test_createInviteCode_throwsOnFirestoreError() async {
        // Arrange
        mockFirestore.errorToThrow = FirestoreError.unknown(NSError(domain: "Test", code: -1))

        // Act & Assert
        do {
            _ = try await repository.createInviteCode(
                coupleID: "couple-123",
                createdBy: "user-456"
            )
            XCTFail("Expected error to be thrown")
        } catch {
            // Expected
        }
    }

    func test_validateInviteCode_throwsDocumentNotFoundForMissingCode() async {
        // Act & Assert
        do {
            _ = try await repository.validateInviteCode("NONEXISTENT")
            XCTFail("Expected documentNotFound error")
        } catch FirestoreError.documentNotFound {
            // Expected
        } catch {
            XCTFail("Wrong error type: \(error)")
        }
    }
}
