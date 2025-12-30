import XCTest
@testable import Winnie

// MARK: - GoalRepository Tests

/// Tests for GoalRepository using MockFirestoreService
///
/// These tests verify that GoalRepository correctly:
/// - Creates goals in subcollections
/// - Fetches goals with filtering and ordering
/// - Updates goal progress and properties
/// - Handles batch operations (create multiple, delete multiple)
/// - Manages real-time listeners
@MainActor
final class GoalRepositoryTests: XCTestCase {

    // MARK: - Properties

    var mockFirestore: MockFirestoreService!
    var repository: GoalRepository!
    let coupleID = "test-couple-id"

    // MARK: - Setup & Teardown

    override func setUp() {
        super.setUp()
        mockFirestore = MockFirestoreService()
        repository = GoalRepository(db: mockFirestore)
    }

    override func tearDown() {
        mockFirestore = nil
        repository = nil
        super.tearDown()
    }

    // MARK: - Create Goal Tests

    func test_createGoal_savesToCorrectSubcollectionPath() async throws {
        // Arrange
        let goal = TestFixtures.makeGoal(id: "goal-123")

        // Act
        try await repository.createGoal(goal, coupleID: coupleID)

        // Assert
        XCTAssertTrue(mockFirestore.didSetData(at: "couples/\(coupleID)/goals/goal-123"))
    }

    func test_createGoal_savesCorrectData() async throws {
        // Arrange
        let goal = TestFixtures.makeGoal(
            id: "goal-123",
            type: .house,
            name: "House Fund",
            targetAmount: 50000,
            currentAmount: 10000,
            priority: 1
        )

        // Act
        try await repository.createGoal(goal, coupleID: coupleID)

        // Assert
        let data = mockFirestore.dataWritten(to: "couples/\(coupleID)/goals/goal-123")
        XCTAssertEqual(data?["id"] as? String, "goal-123")
        XCTAssertEqual(data?["type"] as? String, "house")
        XCTAssertEqual(data?["name"] as? String, "House Fund")
        XCTAssertEqual(data?["targetAmount"] as? Double, 50000)
        XCTAssertEqual(data?["currentAmount"] as? Double, 10000)
        XCTAssertEqual(data?["priority"] as? Int, 1)
    }

    func test_createGoals_batchCreatesMultipleGoals() async throws {
        // Arrange
        let goals = [
            TestFixtures.makeGoal(id: "goal-1"),
            TestFixtures.makeGoal(id: "goal-2"),
            TestFixtures.makeGoal(id: "goal-3")
        ]

        // Act
        try await repository.createGoals(goals, coupleID: coupleID)

        // Assert
        XCTAssertEqual(mockFirestore.batchCommitCount, 1)
        XCTAssertTrue(mockFirestore.didSetData(at: "couples/\(coupleID)/goals/goal-1"))
        XCTAssertTrue(mockFirestore.didSetData(at: "couples/\(coupleID)/goals/goal-2"))
        XCTAssertTrue(mockFirestore.didSetData(at: "couples/\(coupleID)/goals/goal-3"))
    }

    func test_createGoals_emptyArrayDoesNothing() async throws {
        // Act
        try await repository.createGoals([], coupleID: coupleID)

        // Assert
        XCTAssertEqual(mockFirestore.batchCommitCount, 0)
    }

    // MARK: - Fetch Goal Tests

    func test_fetchGoal_returnsGoalWhenExists() async throws {
        // Arrange
        mockFirestore.stubDocument(
            path: "couples/\(coupleID)/goals/goal-123",
            data: TestFixtures.makeGoalData(id: "goal-123", name: "Test Goal")
        )

        // Act
        let goal = try await repository.fetchGoal(id: "goal-123", coupleID: coupleID)

        // Assert - capture values to avoid main actor isolation issues
        let id = goal.id
        let name = goal.name
        XCTAssertEqual(id, "goal-123")
        XCTAssertEqual(name, "Test Goal")
    }

    func test_fetchGoal_throwsDocumentNotFoundWhenMissing() async {
        // Act & Assert
        do {
            _ = try await repository.fetchGoal(id: "nonexistent", coupleID: coupleID)
            XCTFail("Expected documentNotFound error")
        } catch FirestoreError.documentNotFound {
            // Expected
        } catch {
            XCTFail("Wrong error type: \(error)")
        }
    }

    func test_fetchAllGoals_returnsAllGoals() async throws {
        // Arrange
        mockFirestore.stubDocument(
            path: "couples/\(coupleID)/goals/goal-1",
            data: TestFixtures.makeGoalData(id: "goal-1", priority: 0)
        )
        mockFirestore.stubDocument(
            path: "couples/\(coupleID)/goals/goal-2",
            data: TestFixtures.makeGoalData(id: "goal-2", priority: 1)
        )

        // Act
        let goals = try await repository.fetchAllGoals(coupleID: coupleID)

        // Assert
        XCTAssertEqual(goals.count, 2)
    }

    func test_fetchActiveGoals_returnsOnlyActiveGoals() async throws {
        // Arrange
        mockFirestore.stubDocument(
            path: "couples/\(coupleID)/goals/goal-1",
            data: TestFixtures.makeGoalData(id: "goal-1", priority: 0, isActive: true)
        )
        mockFirestore.stubDocument(
            path: "couples/\(coupleID)/goals/goal-2",
            data: TestFixtures.makeGoalData(id: "goal-2", priority: 1, isActive: false)
        )

        // Act
        let goals = try await repository.fetchActiveGoals(coupleID: coupleID)

        // Assert - capture value to avoid main actor isolation issues
        XCTAssertEqual(goals.count, 1)
        let firstId = goals.first?.id
        XCTAssertEqual(firstId, "goal-1")
    }

    func test_fetchGoalsByType_returnsMatchingGoals() async throws {
        // Arrange
        mockFirestore.stubDocument(
            path: "couples/\(coupleID)/goals/goal-1",
            data: TestFixtures.makeGoalData(id: "goal-1", type: "house", priority: 0)
        )
        mockFirestore.stubDocument(
            path: "couples/\(coupleID)/goals/goal-2",
            data: TestFixtures.makeGoalData(id: "goal-2", type: "retirement", priority: 1)
        )

        // Act
        let houseGoals = try await repository.fetchGoals(ofType: .house, coupleID: coupleID)

        // Assert - capture value to avoid main actor isolation issues
        XCTAssertEqual(houseGoals.count, 1)
        let goalType = houseGoals.first?.type
        XCTAssertEqual(goalType, .house)
    }

    // MARK: - Update Goal Tests

    func test_updateGoal_usesSetDataWithMerge() async throws {
        // Arrange
        let goal = TestFixtures.makeGoal(id: "goal-123")

        // Act
        try await repository.updateGoal(goal, coupleID: coupleID)

        // Assert
        let call = mockFirestore.setDataCalls.first { $0.path.contains("goal-123") }
        XCTAssertNotNil(call)
        XCTAssertTrue(call?.merge ?? false)
    }

    func test_updateGoalProgress_updatesCurrentAmount() async throws {
        // Arrange
        mockFirestore.stubDocument(
            path: "couples/\(coupleID)/goals/goal-123",
            data: TestFixtures.makeGoalData(id: "goal-123")
        )

        // Act
        try await repository.updateGoalProgress(
            goalID: "goal-123",
            currentAmount: 25000,
            coupleID: coupleID
        )

        // Assert
        let fields = mockFirestore.fieldsUpdated(at: "couples/\(coupleID)/goals/goal-123")
        XCTAssertEqual(fields?["currentAmount"] as? Double, 25000)
    }

    func test_setGoalActive_updatesActiveStatus() async throws {
        // Arrange
        mockFirestore.stubDocument(
            path: "couples/\(coupleID)/goals/goal-123",
            data: TestFixtures.makeGoalData(id: "goal-123", isActive: true)
        )

        // Act
        try await repository.setGoalActive(goalID: "goal-123", isActive: false, coupleID: coupleID)

        // Assert
        let fields = mockFirestore.fieldsUpdated(at: "couples/\(coupleID)/goals/goal-123")
        XCTAssertEqual(fields?["isActive"] as? Bool, false)
    }

    func test_updateGoalPriority_updatesPriorityField() async throws {
        // Arrange
        mockFirestore.stubDocument(
            path: "couples/\(coupleID)/goals/goal-123",
            data: TestFixtures.makeGoalData(id: "goal-123", priority: 0)
        )

        // Act
        try await repository.updateGoalPriority(goalID: "goal-123", priority: 5, coupleID: coupleID)

        // Assert
        let fields = mockFirestore.fieldsUpdated(at: "couples/\(coupleID)/goals/goal-123")
        XCTAssertEqual(fields?["priority"] as? Int, 5)
    }

    func test_reorderGoals_batchUpdatesPriorities() async throws {
        // Arrange
        mockFirestore.stubDocument(
            path: "couples/\(coupleID)/goals/goal-a",
            data: TestFixtures.makeGoalData(id: "goal-a", priority: 0)
        )
        mockFirestore.stubDocument(
            path: "couples/\(coupleID)/goals/goal-b",
            data: TestFixtures.makeGoalData(id: "goal-b", priority: 1)
        )

        // Act - Reverse the order
        try await repository.reorderGoals(orderedGoalIDs: ["goal-b", "goal-a"], coupleID: coupleID)

        // Assert
        XCTAssertEqual(mockFirestore.batchCommitCount, 1)
    }

    // MARK: - Delete Goal Tests

    func test_deleteGoal_deletesDocument() async throws {
        // Arrange
        mockFirestore.stubDocument(
            path: "couples/\(coupleID)/goals/goal-123",
            data: TestFixtures.makeGoalData(id: "goal-123")
        )

        // Act
        try await repository.deleteGoal(id: "goal-123", coupleID: coupleID)

        // Assert
        XCTAssertTrue(mockFirestore.didDelete(at: "couples/\(coupleID)/goals/goal-123"))
    }

    func test_deleteGoals_batchDeletesMultipleGoals() async throws {
        // Arrange
        mockFirestore.stubDocument(
            path: "couples/\(coupleID)/goals/goal-1",
            data: TestFixtures.makeGoalData(id: "goal-1")
        )
        mockFirestore.stubDocument(
            path: "couples/\(coupleID)/goals/goal-2",
            data: TestFixtures.makeGoalData(id: "goal-2")
        )

        // Act
        try await repository.deleteGoals(ids: ["goal-1", "goal-2"], coupleID: coupleID)

        // Assert
        XCTAssertEqual(mockFirestore.batchCommitCount, 1)
        XCTAssertTrue(mockFirestore.didDelete(at: "couples/\(coupleID)/goals/goal-1"))
        XCTAssertTrue(mockFirestore.didDelete(at: "couples/\(coupleID)/goals/goal-2"))
    }

    func test_deleteGoals_emptyArrayDoesNothing() async throws {
        // Act
        try await repository.deleteGoals(ids: [], coupleID: coupleID)

        // Assert
        XCTAssertEqual(mockFirestore.batchCommitCount, 0)
    }

    // MARK: - Listener Tests

    func test_listenToGoals_returnsListenerRegistration() {
        // Act
        let registration = repository.listenToGoals(coupleID: coupleID) { _ in }

        // Assert
        XCTAssertNotNil(registration)
    }

    func test_listenToActiveGoals_returnsListenerRegistration() {
        // Act
        let registration = repository.listenToActiveGoals(coupleID: coupleID) { _ in }

        // Assert
        XCTAssertNotNil(registration)
    }

    func test_listenToGoal_returnsListenerRegistration() {
        // Act
        let registration = repository.listenToGoal(id: "goal-123", coupleID: coupleID) { _ in }

        // Assert
        XCTAssertNotNil(registration)
    }

    // MARK: - Error Handling Tests

    func test_createGoal_throwsOnFirestoreError() async {
        // Arrange
        mockFirestore.errorToThrow = FirestoreError.unknown(NSError(domain: "Test", code: -1))
        let goal = TestFixtures.makeGoal()

        // Act & Assert
        do {
            try await repository.createGoal(goal, coupleID: coupleID)
            XCTFail("Expected error to be thrown")
        } catch {
            // Expected
        }
    }
}
