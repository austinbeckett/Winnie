import XCTest
@testable import Winnie

// MARK: - CoupleRepository Tests

/// Tests for CoupleRepository using MockFirestoreService
///
/// These tests verify that CoupleRepository correctly:
/// - Creates couples with financial profiles
/// - Fetches couple data with profiles
/// - Updates couple information and profiles
/// - Manages partner addition/removal via transactions
/// - Handles batch operations for deletion
@MainActor
final class CoupleRepositoryTests: XCTestCase {

    // MARK: - Properties

    var mockFirestore: MockFirestoreService!
    var repository: CoupleRepository!

    // MARK: - Setup & Teardown

    override func setUp() {
        super.setUp()
        mockFirestore = MockFirestoreService()
        repository = CoupleRepository(db: mockFirestore)
    }

    override func tearDown() {
        mockFirestore = nil
        repository = nil
        super.tearDown()
    }

    // MARK: - Create Couple Tests

    func test_createCouple_createsCoupleAndProfileDocuments() async throws {
        // Act
        let couple = try await repository.createCouple(for: "user-123")

        // Assert - Couple was created
        XCTAssertFalse(couple.id.isEmpty)
        XCTAssertEqual(couple.memberIDs, ["user-123"])

        // Assert - Batch was committed
        XCTAssertEqual(mockFirestore.batchCommitCount, 1)
    }

    func test_createCouple_setsCorrectMemberID() async throws {
        // Act
        let couple = try await repository.createCouple(for: "creator-user")

        // Assert
        XCTAssertEqual(couple.memberIDs.count, 1)
        XCTAssertTrue(couple.memberIDs.contains("creator-user"))
    }

    func test_createCouple_createsEmptyFinancialProfile() async throws {
        // Act
        let couple = try await repository.createCouple(for: "user-123")

        // Assert
        XCTAssertEqual(couple.financialProfile.monthlyIncome, 0)
        XCTAssertEqual(couple.financialProfile.monthlyExpenses, 0)
        XCTAssertEqual(couple.financialProfile.currentSavings, 0)
    }

    // MARK: - Fetch Couple Tests

    func test_fetchCouple_returnsCoupleWithProfile() async throws {
        // Arrange
        let coupleID = "couple-123"
        mockFirestore.stubDocument(
            path: "couples/\(coupleID)",
            data: TestFixtures.makeCoupleData(id: coupleID, memberIDs: ["user-1", "user-2"])
        )
        mockFirestore.stubDocument(
            path: "couples/\(coupleID)/financialProfile/profile",
            data: TestFixtures.makeFinancialProfileData(monthlyIncome: 8000)
        )

        // Act
        let couple = try await repository.fetchCouple(id: coupleID)

        // Assert
        XCTAssertEqual(couple.id, coupleID)
        XCTAssertEqual(couple.memberIDs, ["user-1", "user-2"])
        XCTAssertEqual(couple.financialProfile.monthlyIncome, 8000)
    }

    func test_fetchCouple_throwsDocumentNotFoundWhenMissing() async {
        // Act & Assert
        do {
            _ = try await repository.fetchCouple(id: "nonexistent")
            XCTFail("Expected documentNotFound error")
        } catch FirestoreError.documentNotFound {
            // Expected
        } catch {
            XCTFail("Wrong error type: \(error)")
        }
    }

    func test_coupleExists_returnsTrueWhenExists() async throws {
        // Arrange
        mockFirestore.stubDocument(
            path: "couples/couple-123",
            data: TestFixtures.makeCoupleData(id: "couple-123")
        )

        // Act
        let exists = try await repository.coupleExists(id: "couple-123")

        // Assert
        XCTAssertTrue(exists)
    }

    func test_coupleExists_returnsFalseWhenMissing() async throws {
        // Act
        let exists = try await repository.coupleExists(id: "nonexistent")

        // Assert
        XCTAssertFalse(exists)
    }

    // MARK: - Financial Profile Tests

    func test_fetchFinancialProfile_returnsProfileData() async throws {
        // Arrange
        mockFirestore.stubDocument(
            path: "couples/couple-123/financialProfile/profile",
            data: TestFixtures.makeFinancialProfileData(
                monthlyIncome: 12000,
                monthlyExpenses: 5000,
                currentSavings: 30000
            )
        )

        // Act
        let profile = try await repository.fetchFinancialProfile(coupleID: "couple-123")

        // Assert
        XCTAssertEqual(profile.monthlyIncome, 12000)
        XCTAssertEqual(profile.monthlyExpenses, 5000)
        XCTAssertEqual(profile.currentSavings, 30000)
    }

    func test_fetchFinancialProfile_returnsEmptyProfileWhenMissing() async throws {
        // Act
        let profile = try await repository.fetchFinancialProfile(coupleID: "couple-123")

        // Assert
        XCTAssertEqual(profile.monthlyIncome, 0)
        XCTAssertEqual(profile.monthlyExpenses, 0)
    }

    func test_updateFinancialProfile_writesToCorrectPath() async throws {
        // Arrange
        let profile = TestFixtures.makeFinancialProfile(
            monthlyIncome: 15000,
            monthlyExpenses: 8000
        )

        // Act
        try await repository.updateFinancialProfile(profile, coupleID: "couple-123")

        // Assert
        XCTAssertTrue(mockFirestore.didSetData(at: "couples/couple-123/financialProfile/profile"))

        let data = mockFirestore.dataWritten(to: "couples/couple-123/financialProfile/profile")
        XCTAssertEqual(data?["monthlyIncome"] as? Double, 15000)
        XCTAssertEqual(data?["monthlyExpenses"] as? Double, 8000)
    }

    // MARK: - Update Couple Tests

    func test_updateCouple_usesSetDataWithMerge() async throws {
        // Arrange
        let couple = TestFixtures.makeCouple(id: "couple-123")

        // Act
        try await repository.updateCouple(couple)

        // Assert
        let call = mockFirestore.setDataCalls.first { $0.path == "couples/couple-123" }
        XCTAssertNotNil(call)
        XCTAssertTrue(call?.merge ?? false)
    }

    func test_updateInviteCode_setsCodeAndExpiration() async throws {
        // Arrange
        mockFirestore.stubDocument(
            path: "couples/couple-123",
            data: TestFixtures.makeCoupleData(id: "couple-123")
        )
        let expiration = Date().addingTimeInterval(604800) // 7 days

        // Act
        try await repository.updateInviteCode(
            coupleID: "couple-123",
            code: "ABC123",
            expiresAt: expiration
        )

        // Assert
        XCTAssertTrue(mockFirestore.didUpdateData(at: "couples/couple-123"))
        let fields = mockFirestore.fieldsUpdated(at: "couples/couple-123")
        XCTAssertEqual(fields?["inviteCode"] as? String, "ABC123")
    }

    // MARK: - Add Partner Tests

    func test_addPartner_addsUserToMemberIDs() async throws {
        // Arrange
        mockFirestore.stubDocument(
            path: "couples/couple-123",
            data: TestFixtures.makeSingleMemberCoupleData(id: "couple-123", creatorID: "user-1")
        )

        // Act
        try await repository.addPartner(userID: "user-2", to: "couple-123")

        // Assert - Transaction was run
        XCTAssertEqual(mockFirestore.transactionRunCount, 1)

        // Assert - Member was added
        let fields = mockFirestore.fieldsUpdated(at: "couples/couple-123")
        let memberIDs = fields?["memberIDs"] as? [String]
        XCTAssertEqual(memberIDs?.count, 2)
        XCTAssertTrue(memberIDs?.contains("user-2") ?? false)
    }

    func test_addPartner_throwsWhenCoupleAlreadyComplete() async {
        // Arrange - Couple already has 2 members
        mockFirestore.stubDocument(
            path: "couples/couple-123",
            data: TestFixtures.makeCoupleData(id: "couple-123", memberIDs: ["user-1", "user-2"])
        )

        // Act & Assert
        do {
            try await repository.addPartner(userID: "user-3", to: "couple-123")
            XCTFail("Expected coupleAlreadyComplete error")
        } catch FirestoreError.coupleAlreadyComplete {
            // Expected
        } catch {
            XCTFail("Wrong error type: \(error)")
        }
    }

    func test_addPartner_noOpWhenUserAlreadyMember() async throws {
        // Arrange
        mockFirestore.stubDocument(
            path: "couples/couple-123",
            data: TestFixtures.makeSingleMemberCoupleData(id: "couple-123", creatorID: "user-1")
        )

        // Act
        try await repository.addPartner(userID: "user-1", to: "couple-123")

        // Assert - Transaction ran but no update
        XCTAssertEqual(mockFirestore.transactionRunCount, 1)
        // No update should have been made since user is already a member
    }

    // MARK: - Remove Partner Tests

    func test_removePartner_removesUserFromMemberIDs() async throws {
        // Arrange
        mockFirestore.stubDocument(
            path: "couples/couple-123",
            data: TestFixtures.makeCoupleData(id: "couple-123", memberIDs: ["user-1", "user-2"])
        )

        // Act
        try await repository.removePartner(userID: "user-2", from: "couple-123")

        // Assert
        XCTAssertEqual(mockFirestore.transactionRunCount, 1)
        let fields = mockFirestore.fieldsUpdated(at: "couples/couple-123")
        let memberIDs = fields?["memberIDs"] as? [String]
        XCTAssertEqual(memberIDs, ["user-1"])
    }

    // MARK: - Delete Couple Tests

    func test_deleteCouple_deletesCoupleAndProfile() async throws {
        // Arrange
        mockFirestore.stubDocument(
            path: "couples/couple-123",
            data: TestFixtures.makeCoupleData(id: "couple-123")
        )
        mockFirestore.stubDocument(
            path: "couples/couple-123/financialProfile/profile",
            data: TestFixtures.makeFinancialProfileData()
        )

        // Act
        try await repository.deleteCouple(id: "couple-123")

        // Assert
        XCTAssertEqual(mockFirestore.batchCommitCount, 1)
        XCTAssertTrue(mockFirestore.didDelete(at: "couples/couple-123/financialProfile/profile"))
        XCTAssertTrue(mockFirestore.didDelete(at: "couples/couple-123"))
    }

    // MARK: - Listener Tests

    func test_listenToCouple_returnsListenerRegistration() {
        // Act
        let registration = repository.listenToCouple(id: "couple-123") { _ in }

        // Assert
        XCTAssertNotNil(registration)
    }

    func test_listenToFinancialProfile_returnsListenerRegistration() {
        // Act
        let registration = repository.listenToFinancialProfile(coupleID: "couple-123") { _ in }

        // Assert
        XCTAssertNotNil(registration)
    }

    // MARK: - Error Handling Tests

    func test_fetchCouple_throwsOnFirestoreError() async {
        // Arrange
        mockFirestore.errorToThrow = FirestoreError.unknown(NSError(domain: "Test", code: -1))

        // Act & Assert
        do {
            _ = try await repository.fetchCouple(id: "couple-123")
            XCTFail("Expected error to be thrown")
        } catch {
            // Expected
        }
    }
}
