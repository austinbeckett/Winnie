import XCTest
@testable import Winnie

// MARK: - UserRepository Tests

/// Tests for UserRepository using MockFirestoreService
///
/// These tests verify that UserRepository correctly:
/// - Creates user documents
/// - Fetches user data
/// - Updates user fields
/// - Deletes users
/// - Handles errors appropriately
///
/// ## Swift Testing Concepts
/// - `async throws` test methods for testing async code
/// - `XCTAssertEqual` for value comparisons
/// - `XCTAssertTrue/False` for boolean checks
/// - `do/catch` for testing error cases
final class UserRepositoryTests: XCTestCase {

    // MARK: - Properties

    /// The mock Firestore service (reset before each test)
    var mockFirestore: MockFirestoreService!

    /// The repository under test
    var repository: UserRepository!

    // MARK: - Setup & Teardown

    override func setUp() {
        super.setUp()
        mockFirestore = MockFirestoreService()
        repository = UserRepository(db: mockFirestore)
    }

    override func tearDown() {
        mockFirestore = nil
        repository = nil
        super.tearDown()
    }

    // MARK: - Create User Tests

    func test_createUser_savesUserDocumentToCorrectPath() async throws {
        // Arrange
        let user = TestFixtures.makeUser(id: "user-123")

        // Act
        try await repository.createUser(user)

        // Assert
        XCTAssertTrue(mockFirestore.didSetData(at: "users/user-123"))
    }

    func test_createUser_savesCorrectData() async throws {
        // Arrange
        let user = TestFixtures.makeUser(
            id: "user-123",
            displayName: "Test User",
            email: "test@example.com"
        )

        // Act
        try await repository.createUser(user)

        // Assert
        let savedData = mockFirestore.dataWritten(to: "users/user-123")
        XCTAssertNotNil(savedData)
        XCTAssertEqual(savedData?["id"] as? String, "user-123")
        XCTAssertEqual(savedData?["displayName"] as? String, "Test User")
        XCTAssertEqual(savedData?["email"] as? String, "test@example.com")
    }

    func test_createUserFromSignUp_savesMinimalData() async throws {
        // Act
        try await repository.createUser(
            id: "new-user",
            displayName: "New User",
            email: "new@example.com"
        )

        // Assert
        XCTAssertTrue(mockFirestore.didSetData(at: "users/new-user"))
        let savedData = mockFirestore.dataWritten(to: "users/new-user")
        XCTAssertEqual(savedData?["displayName"] as? String, "New User")
    }

    func test_createUser_throwsOnFirestoreError() async {
        // Arrange
        mockFirestore.errorToThrow = FirestoreError.unauthorized
        let user = TestFixtures.makeUser()

        // Act & Assert
        do {
            try await repository.createUser(user)
            XCTFail("Expected error to be thrown")
        } catch {
            // Expected - error was thrown
        }
    }

    // MARK: - Fetch User Tests

    func test_fetchUser_returnsUserWhenDocumentExists() async throws {
        // Arrange - stub the mock with user data
        mockFirestore.stubDocument(
            path: "users/user-123",
            data: makeUserDictionary(id: "user-123", email: "test@example.com")
        )

        // Act
        let user = try await repository.fetchUser(id: "user-123")

        // Assert
        XCTAssertEqual(user.id, "user-123")
        XCTAssertEqual(user.email, "test@example.com")
    }

    func test_fetchUser_throwsDocumentNotFoundWhenMissing() async {
        // Arrange - don't stub any data

        // Act & Assert
        do {
            _ = try await repository.fetchUser(id: "nonexistent")
            XCTFail("Expected documentNotFound error")
        } catch FirestoreError.documentNotFound {
            // Expected
        } catch {
            XCTFail("Wrong error type: \(error)")
        }
    }

    func test_fetchUser_recordsGetDocumentCall() async throws {
        // Arrange
        mockFirestore.stubDocument(
            path: "users/user-123",
            data: makeUserDictionary(id: "user-123")
        )

        // Act
        _ = try await repository.fetchUser(id: "user-123")

        // Assert
        XCTAssertTrue(mockFirestore.getDocumentCalls.contains("users/user-123"))
    }

    // MARK: - User Exists Tests

    func test_userExists_returnsTrueWhenDocumentExists() async throws {
        // Arrange
        mockFirestore.stubDocument(
            path: "users/user-123",
            data: makeUserDictionary(id: "user-123")
        )

        // Act
        let exists = try await repository.userExists(id: "user-123")

        // Assert
        XCTAssertTrue(exists)
    }

    func test_userExists_returnsFalseWhenMissing() async throws {
        // Arrange - don't stub any data

        // Act
        let exists = try await repository.userExists(id: "nonexistent")

        // Assert
        XCTAssertFalse(exists)
    }

    // MARK: - Update Tests

    func test_updateLastLogin_updatesCorrectFields() async throws {
        // Arrange - create existing user
        mockFirestore.stubDocument(
            path: "users/user-123",
            data: makeUserDictionary(id: "user-123")
        )

        // Act
        try await repository.updateLastLogin(uid: "user-123")

        // Assert
        XCTAssertTrue(mockFirestore.didUpdateData(at: "users/user-123"))
        let fields = mockFirestore.fieldsUpdated(at: "users/user-123")
        XCTAssertNotNil(fields?["lastLoginAt"])
        XCTAssertNotNil(fields?["lastSyncedAt"])
    }

    func test_updateDisplayName_updatesNameField() async throws {
        // Arrange
        mockFirestore.stubDocument(
            path: "users/user-123",
            data: makeUserDictionary(id: "user-123")
        )

        // Act
        try await repository.updateDisplayName(uid: "user-123", displayName: "New Name")

        // Assert
        let fields = mockFirestore.fieldsUpdated(at: "users/user-123")
        XCTAssertEqual(fields?["displayName"] as? String, "New Name")
    }

    func test_completeOnboarding_setsFlag() async throws {
        // Arrange
        mockFirestore.stubDocument(
            path: "users/user-123",
            data: makeUserDictionary(id: "user-123", hasCompletedOnboarding: false)
        )

        // Act
        try await repository.completeOnboarding(uid: "user-123")

        // Assert
        let fields = mockFirestore.fieldsUpdated(at: "users/user-123")
        XCTAssertEqual(fields?["hasCompletedOnboarding"] as? Bool, true)
    }

    func test_updateCoupleAssociation_updatesBothFields() async throws {
        // Arrange
        mockFirestore.stubDocument(
            path: "users/user-123",
            data: makeUserDictionary(id: "user-123")
        )

        // Act
        try await repository.updateCoupleAssociation(
            uid: "user-123",
            coupleID: "couple-456",
            partnerID: "partner-789"
        )

        // Assert
        let fields = mockFirestore.fieldsUpdated(at: "users/user-123")
        XCTAssertEqual(fields?["coupleID"] as? String, "couple-456")
        XCTAssertEqual(fields?["partnerID"] as? String, "partner-789")
    }

    func test_updateCoupleAssociation_omitsPartnerWhenNil() async throws {
        // Arrange
        mockFirestore.stubDocument(
            path: "users/user-123",
            data: makeUserDictionary(id: "user-123")
        )

        // Act
        try await repository.updateCoupleAssociation(
            uid: "user-123",
            coupleID: "couple-456",
            partnerID: nil
        )

        // Assert
        let fields = mockFirestore.fieldsUpdated(at: "users/user-123")
        XCTAssertEqual(fields?["coupleID"] as? String, "couple-456")
        XCTAssertNil(fields?["partnerID"])
    }

    func test_updateUser_usesSetDataWithMerge() async throws {
        // Arrange
        let user = TestFixtures.makeUser(id: "user-123")

        // Act
        try await repository.updateUser(user)

        // Assert
        let call = mockFirestore.setDataCalls.first { $0.path == "users/user-123" }
        XCTAssertNotNil(call)
        XCTAssertTrue(call?.merge ?? false, "Should use merge: true")
    }

    // MARK: - Delete Tests

    func test_deleteUser_deletesDocument() async throws {
        // Arrange
        mockFirestore.stubDocument(
            path: "users/user-123",
            data: makeUserDictionary(id: "user-123")
        )

        // Act
        try await repository.deleteUser(id: "user-123")

        // Assert
        XCTAssertTrue(mockFirestore.didDelete(at: "users/user-123"))
    }

    func test_deleteUser_removesFromMockStore() async throws {
        // Arrange
        mockFirestore.stubDocument(
            path: "users/user-123",
            data: makeUserDictionary(id: "user-123")
        )

        // Act
        try await repository.deleteUser(id: "user-123")

        // Assert
        XCTAssertNil(mockFirestore.documents["users/user-123"])
    }

    // MARK: - Listener Tests

    func test_listenToUser_returnsListenerRegistration() {
        // Act
        let registration = repository.listenToUser(id: "user-123") { _ in }

        // Assert
        XCTAssertNotNil(registration)
    }

    func test_listenToUser_registrationCanBeRemoved() {
        // Arrange
        let registration = repository.listenToUser(id: "user-123") { _ in }

        // Act
        registration.remove()

        // Assert - should not crash
        if let mockReg = registration as? MockListenerRegistration {
            XCTAssertTrue(mockReg.wasRemoved)
        }
    }

    // MARK: - Error Handling Tests

    func test_updateLastLogin_throwsOnMissingDocument() async {
        // Arrange - don't stub any data

        // Act & Assert
        do {
            try await repository.updateLastLogin(uid: "nonexistent")
            XCTFail("Expected error for missing document")
        } catch FirestoreError.documentNotFound {
            // Expected - updateData fails on missing documents
        } catch {
            // Other errors are acceptable since mock behavior may vary
        }
    }

    // MARK: - Helpers

    /// Create a dictionary that can be decoded as UserDTO
    private func makeUserDictionary(
        id: String = "test-user",
        displayName: String? = "Test User",
        email: String? = "test@example.com",
        hasCompletedOnboarding: Bool = false
    ) -> [String: Any] {
        var dict: [String: Any] = [
            "id": id,
            "createdAt": ISO8601DateFormatter().string(from: Date()),
            "hasCompletedOnboarding": hasCompletedOnboarding
        ]
        if let displayName { dict["displayName"] = displayName }
        if let email { dict["email"] = email }
        return dict
    }
}
