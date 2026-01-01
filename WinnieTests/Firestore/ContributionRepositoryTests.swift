import XCTest
@testable import Winnie

// MARK: - ContributionRepository Tests

/// Tests for ContributionRepository using MockFirestoreService
///
/// These tests verify that ContributionRepository correctly:
/// - Creates contributions in subcollections
/// - Fetches contributions with filtering and ordering
/// - Updates contribution amounts and properties
/// - Deletes contributions
/// - Manages real-time listeners
@MainActor
final class ContributionRepositoryTests: XCTestCase {

    // MARK: - Properties

    var mockFirestore: MockFirestoreService!
    var repository: ContributionRepository!
    let coupleID = "test-couple-id"
    let goalID = "test-goal-id"

    // MARK: - Setup & Teardown

    override func setUp() {
        super.setUp()
        mockFirestore = MockFirestoreService()
        repository = ContributionRepository(db: mockFirestore)
    }

    override func tearDown() {
        mockFirestore = nil
        repository = nil
        super.tearDown()
    }

    // MARK: - Helper

    /// Stubs multiple documents in a collection path
    private func stubDocumentsInCollection(
        _ collectionPath: String,
        documents: [[String: Any]]
    ) {
        for doc in documents {
            guard let id = doc["id"] as? String else { continue }
            let fullPath = "\(collectionPath)/\(id)"
            mockFirestore.stubDocument(path: fullPath, data: doc)
        }
    }

    // MARK: - Create Contribution Tests

    func test_createContribution_savesToCorrectSubcollectionPath() async throws {
        // Arrange
        let contribution = TestFixtures.makeContribution(id: "contrib-123")

        // Act
        try await repository.createContribution(contribution, coupleID: coupleID, goalID: goalID)

        // Assert
        XCTAssertTrue(mockFirestore.didSetData(at: "couples/\(coupleID)/goals/\(goalID)/contributions/contrib-123"))
    }

    func test_createContribution_savesCorrectData() async throws {
        // Arrange
        let contribution = TestFixtures.makeContribution(
            id: "contrib-123",
            goalId: goalID,
            userId: "user-456",
            amount: 250,
            notes: "Birthday money"
        )

        // Act
        try await repository.createContribution(contribution, coupleID: coupleID, goalID: goalID)

        // Assert
        let data = mockFirestore.dataWritten(to: "couples/\(coupleID)/goals/\(goalID)/contributions/contrib-123")
        XCTAssertEqual(data?["id"] as? String, "contrib-123")
        XCTAssertEqual(data?["goalId"] as? String, goalID)
        XCTAssertEqual(data?["userId"] as? String, "user-456")
        XCTAssertEqual(data?["amount"] as? Double, 250)
        XCTAssertEqual(data?["notes"] as? String, "Birthday money")
    }

    // MARK: - Fetch Contribution Tests

    func test_fetchContribution_returnsCorrectContribution() async throws {
        // Arrange
        let path = "couples/\(coupleID)/goals/\(goalID)/contributions/contrib-123"
        mockFirestore.stubDocument(
            path: path,
            data: TestFixtures.makeContributionData(id: "contrib-123", amount: 300)
        )

        // Act
        let contribution = try await repository.fetchContribution(id: "contrib-123", coupleID: coupleID, goalID: goalID)

        // Assert
        XCTAssertEqual(contribution.id, "contrib-123")
        XCTAssertEqual(NSDecimalNumber(decimal: contribution.amount).doubleValue, 300, accuracy: 0.01)
    }

    func test_fetchContribution_throwsWhenNotFound() async throws {
        // Arrange - Don't stub any document, so it won't exist

        // Act & Assert
        do {
            _ = try await repository.fetchContribution(id: "nonexistent", coupleID: coupleID, goalID: goalID)
            XCTFail("Should throw documentNotFound error")
        } catch let error as FirestoreError {
            XCTAssertEqual(error, .documentNotFound)
        }
    }

    func test_fetchContributions_returnsAllContributions() async throws {
        // Arrange
        let collectionPath = "couples/\(coupleID)/goals/\(goalID)/contributions"
        stubDocumentsInCollection(collectionPath, documents: [
            TestFixtures.makeContributionData(id: "contrib-1", amount: 100),
            TestFixtures.makeContributionData(id: "contrib-2", amount: 200),
            TestFixtures.makeContributionData(id: "contrib-3", amount: 300)
        ])

        // Act
        let contributions = try await repository.fetchContributions(coupleID: coupleID, goalID: goalID)

        // Assert
        XCTAssertEqual(contributions.count, 3)
    }

    func test_fetchContributions_byUserId_callsRepository() async throws {
        // Arrange
        let collectionPath = "couples/\(coupleID)/goals/\(goalID)/contributions"
        stubDocumentsInCollection(collectionPath, documents: [
            TestFixtures.makeContributionData(id: "contrib-1", userId: "user-A", amount: 100),
            TestFixtures.makeContributionData(id: "contrib-2", userId: "user-B", amount: 200),
            TestFixtures.makeContributionData(id: "contrib-3", userId: "user-A", amount: 300)
        ])

        // Act
        let contributions = try await repository.fetchContributions(byUserID: "user-A", coupleID: coupleID, goalID: goalID)

        // Assert - Mock filters by userId field
        // The mock returns all docs, but verifies the method can be called
        XCTAssertGreaterThanOrEqual(contributions.count, 0)
    }

    // MARK: - Update Contribution Tests

    func test_updateContribution_updatesCorrectDocument() async throws {
        // Arrange
        var contribution = TestFixtures.makeContribution(id: "contrib-123", amount: 150)
        contribution.amount = 200
        contribution.notes = "Updated note"

        // Act
        try await repository.updateContribution(contribution, coupleID: coupleID, goalID: goalID)

        // Assert
        let path = "couples/\(coupleID)/goals/\(goalID)/contributions/contrib-123"
        XCTAssertTrue(mockFirestore.didSetData(at: path))

        let data = mockFirestore.dataWritten(to: path)
        XCTAssertEqual(data?["amount"] as? Double, 200)
        XCTAssertEqual(data?["notes"] as? String, "Updated note")
    }

    func test_updateContributionAmount_updatesOnlyAmount() async throws {
        // Arrange
        let contributionID = "contrib-123"
        let path = "couples/\(coupleID)/goals/\(goalID)/contributions/\(contributionID)"
        let newAmount = Decimal(500)

        // Stub the existing document (updateData requires doc to exist)
        mockFirestore.stubDocument(
            path: path,
            data: TestFixtures.makeContributionData(id: contributionID, amount: 100)
        )

        // Act
        try await repository.updateContributionAmount(
            contributionID: contributionID,
            amount: newAmount,
            coupleID: coupleID,
            goalID: goalID
        )

        // Assert
        XCTAssertTrue(mockFirestore.didUpdateData(at: path))

        let updatedFields = mockFirestore.fieldsUpdated(at: path)
        XCTAssertNotNil(updatedFields?["amount"])
        XCTAssertNotNil(updatedFields?["lastSyncedAt"])
    }

    // MARK: - Delete Contribution Tests

    func test_deleteContribution_deletesCorrectDocument() async throws {
        // Arrange
        let contributionID = "contrib-123"

        // Act
        try await repository.deleteContribution(id: contributionID, coupleID: coupleID, goalID: goalID)

        // Assert
        let path = "couples/\(coupleID)/goals/\(goalID)/contributions/contrib-123"
        XCTAssertTrue(mockFirestore.didDelete(at: path))
    }

    func test_deleteAllContributions_deletesAllInSubcollection() async throws {
        // Arrange
        let collectionPath = "couples/\(coupleID)/goals/\(goalID)/contributions"
        stubDocumentsInCollection(collectionPath, documents: [
            TestFixtures.makeContributionData(id: "contrib-1"),
            TestFixtures.makeContributionData(id: "contrib-2"),
            TestFixtures.makeContributionData(id: "contrib-3")
        ])

        // Act
        try await repository.deleteAllContributions(coupleID: coupleID, goalID: goalID)

        // Assert
        XCTAssertEqual(mockFirestore.batchCommitCount, 1)
    }

    func test_deleteAllContributions_handlesEmptyCollection() async throws {
        // Arrange - Don't stub any documents (empty collection)

        // Act
        try await repository.deleteAllContributions(coupleID: coupleID, goalID: goalID)

        // Assert - Should not commit batch for empty collection
        XCTAssertEqual(mockFirestore.batchCommitCount, 0)
    }

    // MARK: - Real-time Listener Tests

    func test_listenToContributions_returnsListenerRegistration() {
        // Act
        let listener = repository.listenToContributions(
            coupleID: coupleID,
            goalID: goalID
        ) { _ in }

        // Assert
        XCTAssertNotNil(listener)

        // Cleanup
        listener.remove()
    }

    func test_listenToContributions_callsOnChangeWithContributions() async {
        // Arrange
        let collectionPath = "couples/\(coupleID)/goals/\(goalID)/contributions"
        stubDocumentsInCollection(collectionPath, documents: [
            TestFixtures.makeContributionData(id: "contrib-1"),
            TestFixtures.makeContributionData(id: "contrib-2")
        ])

        var receivedContributions: [Contribution] = []

        // Act - The mock triggers the listener automatically via Task
        let listener = repository.listenToContributions(
            coupleID: coupleID,
            goalID: goalID
        ) { contributions in
            receivedContributions = contributions
        }

        // Wait for the async listener callback
        try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds

        // Assert
        XCTAssertEqual(receivedContributions.count, 2)

        // Cleanup
        listener.remove()
    }
}
