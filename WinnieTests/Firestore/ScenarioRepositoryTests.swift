import XCTest
@testable import Winnie

// MARK: - ScenarioRepository Tests

/// Tests for ScenarioRepository using MockFirestoreService
///
/// These tests verify that ScenarioRepository correctly:
/// - Creates scenarios in subcollections
/// - Fetches scenarios with filtering and ordering
/// - Updates scenario properties and allocations
/// - Manages active scenario state
/// - Handles batch operations for cleanup
@MainActor
final class ScenarioRepositoryTests: XCTestCase {

    // MARK: - Properties

    var mockFirestore: MockFirestoreService!
    var repository: ScenarioRepository!
    let coupleID = "test-couple-id"

    // MARK: - Setup & Teardown

    override func setUp() {
        super.setUp()
        mockFirestore = MockFirestoreService()
        repository = ScenarioRepository(db: mockFirestore)
    }

    override func tearDown() {
        mockFirestore = nil
        repository = nil
        super.tearDown()
    }

    // MARK: - Create Scenario Tests

    func test_createScenario_savesToCorrectPath() async throws {
        // Arrange
        let scenario = TestFixtures.makeScenario(id: "scenario-123")

        // Act
        try await repository.createScenario(scenario, coupleID: coupleID)

        // Assert
        XCTAssertTrue(mockFirestore.didSetData(at: "couples/\(coupleID)/scenarios/scenario-123"))
    }

    func test_createScenario_savesCorrectData() async throws {
        // Arrange
        let scenario = TestFixtures.makeScenario(
            id: "scenario-123",
            name: "Aggressive House",
            isActive: false,
            decisionStatus: .draft
        )

        // Act
        try await repository.createScenario(scenario, coupleID: coupleID)

        // Assert
        let data = mockFirestore.dataWritten(to: "couples/\(coupleID)/scenarios/scenario-123")
        XCTAssertEqual(data?["id"] as? String, "scenario-123")
        XCTAssertEqual(data?["name"] as? String, "Aggressive House")
        XCTAssertEqual(data?["isActive"] as? Bool, false)
        XCTAssertEqual(data?["decisionStatus"] as? String, "draft")
    }

    // MARK: - Fetch Scenario Tests

    func test_fetchScenario_returnsScenarioWhenExists() async throws {
        // Arrange
        mockFirestore.stubDocument(
            path: "couples/\(coupleID)/scenarios/scenario-123",
            data: TestFixtures.makeScenarioData(id: "scenario-123", name: "Test Plan")
        )

        // Act
        let scenario = try await repository.fetchScenario(id: "scenario-123", coupleID: coupleID)

        // Assert - capture values to avoid main actor isolation issues
        let id = scenario.id
        let name = scenario.name
        XCTAssertEqual(id, "scenario-123")
        XCTAssertEqual(name, "Test Plan")
    }

    func test_fetchScenario_throwsDocumentNotFoundWhenMissing() async {
        // Act & Assert
        do {
            _ = try await repository.fetchScenario(id: "nonexistent", coupleID: coupleID)
            XCTFail("Expected documentNotFound error")
        } catch FirestoreError.documentNotFound {
            // Expected
        } catch {
            XCTFail("Wrong error type: \(error)")
        }
    }

    func test_fetchAllScenarios_returnsAllScenarios() async throws {
        // Arrange
        mockFirestore.stubDocument(
            path: "couples/\(coupleID)/scenarios/scenario-1",
            data: TestFixtures.makeScenarioData(id: "scenario-1")
        )
        mockFirestore.stubDocument(
            path: "couples/\(coupleID)/scenarios/scenario-2",
            data: TestFixtures.makeScenarioData(id: "scenario-2")
        )

        // Act
        let scenarios = try await repository.fetchAllScenarios(coupleID: coupleID)

        // Assert
        XCTAssertEqual(scenarios.count, 2)
    }

    func test_fetchActiveScenario_returnsActiveScenario() async throws {
        // Arrange
        mockFirestore.stubDocument(
            path: "couples/\(coupleID)/scenarios/scenario-1",
            data: TestFixtures.makeScenarioData(id: "scenario-1", isActive: true)
        )
        mockFirestore.stubDocument(
            path: "couples/\(coupleID)/scenarios/scenario-2",
            data: TestFixtures.makeScenarioData(id: "scenario-2", isActive: false)
        )

        // Act
        let activeScenario = try await repository.fetchActiveScenario(coupleID: coupleID)

        // Assert - capture values to avoid main actor isolation issues
        XCTAssertNotNil(activeScenario)
        let id = activeScenario?.id
        let isActive = activeScenario?.isActive ?? false
        XCTAssertEqual(id, "scenario-1")
        XCTAssertTrue(isActive)
    }

    func test_fetchActiveScenario_returnsNilWhenNoActive() async throws {
        // Arrange
        mockFirestore.stubDocument(
            path: "couples/\(coupleID)/scenarios/scenario-1",
            data: TestFixtures.makeScenarioData(id: "scenario-1", isActive: false)
        )

        // Act
        let activeScenario = try await repository.fetchActiveScenario(coupleID: coupleID)

        // Assert
        XCTAssertNil(activeScenario)
    }

    func test_fetchScenariosByStatus_returnsMatchingScenarios() async throws {
        // Arrange
        mockFirestore.stubDocument(
            path: "couples/\(coupleID)/scenarios/scenario-1",
            data: TestFixtures.makeScenarioData(id: "scenario-1", decisionStatus: "draft")
        )
        mockFirestore.stubDocument(
            path: "couples/\(coupleID)/scenarios/scenario-2",
            data: TestFixtures.makeScenarioData(id: "scenario-2", decisionStatus: "decided")
        )

        // Act
        let draftScenarios = try await repository.fetchScenarios(
            withStatus: .draft,
            coupleID: coupleID
        )

        // Assert - capture values to avoid main actor isolation issues
        XCTAssertEqual(draftScenarios.count, 1)
        let decisionStatus = draftScenarios.first?.decisionStatus
        XCTAssertEqual(decisionStatus, .draft)
    }

    func test_fetchScenariosByCreator_returnsMatchingScenarios() async throws {
        // Arrange
        mockFirestore.stubDocument(
            path: "couples/\(coupleID)/scenarios/scenario-1",
            data: TestFixtures.makeScenarioData(id: "scenario-1", createdBy: "user-1")
        )
        mockFirestore.stubDocument(
            path: "couples/\(coupleID)/scenarios/scenario-2",
            data: TestFixtures.makeScenarioData(id: "scenario-2", createdBy: "user-2")
        )

        // Act
        let userScenarios = try await repository.fetchScenarios(
            createdBy: "user-1",
            coupleID: coupleID
        )

        // Assert - capture values to avoid main actor isolation issues
        XCTAssertEqual(userScenarios.count, 1)
        let createdBy = userScenarios.first?.createdBy
        XCTAssertEqual(createdBy, "user-1")
    }

    // MARK: - Update Scenario Tests

    func test_updateScenario_usesSetDataWithMerge() async throws {
        // Arrange
        let scenario = TestFixtures.makeScenario(id: "scenario-123")

        // Act
        try await repository.updateScenario(scenario, coupleID: coupleID)

        // Assert
        let call = mockFirestore.setDataCalls.first { $0.path.contains("scenario-123") }
        XCTAssertNotNil(call)
        XCTAssertTrue(call?.merge ?? false)
    }

    func test_updateScenarioStatus_updatesStatusField() async throws {
        // Arrange
        mockFirestore.stubDocument(
            path: "couples/\(coupleID)/scenarios/scenario-123",
            data: TestFixtures.makeScenarioData(id: "scenario-123", decisionStatus: "draft")
        )

        // Act
        try await repository.updateScenarioStatus(
            scenarioID: "scenario-123",
            status: .decided,
            coupleID: coupleID
        )

        // Assert
        let fields = mockFirestore.fieldsUpdated(at: "couples/\(coupleID)/scenarios/scenario-123")
        XCTAssertEqual(fields?["decisionStatus"] as? String, "decided")
    }

    func test_setActiveScenario_deactivatesOthersAndActivatesTarget() async throws {
        // Arrange
        mockFirestore.stubDocument(
            path: "couples/\(coupleID)/scenarios/scenario-1",
            data: TestFixtures.makeScenarioData(id: "scenario-1", isActive: true)
        )
        mockFirestore.stubDocument(
            path: "couples/\(coupleID)/scenarios/scenario-2",
            data: TestFixtures.makeScenarioData(id: "scenario-2", isActive: false)
        )

        // Act
        try await repository.setActiveScenario(scenarioID: "scenario-2", coupleID: coupleID)

        // Assert - Batch was committed
        XCTAssertEqual(mockFirestore.batchCommitCount, 1)
    }

    func test_clearActiveScenario_deactivatesAllActiveScenarios() async throws {
        // Arrange
        mockFirestore.stubDocument(
            path: "couples/\(coupleID)/scenarios/scenario-1",
            data: TestFixtures.makeScenarioData(id: "scenario-1", isActive: true)
        )

        // Act
        try await repository.clearActiveScenario(coupleID: coupleID)

        // Assert - Batch was committed
        XCTAssertEqual(mockFirestore.batchCommitCount, 1)
    }

    func test_updateAllocations_updatesAllocationsField() async throws {
        // Arrange
        mockFirestore.stubDocument(
            path: "couples/\(coupleID)/scenarios/scenario-123",
            data: TestFixtures.makeScenarioData(id: "scenario-123")
        )

        let newAllocations = Allocation(allocations: ["house": 2000, "retirement": 1000])

        // Act
        try await repository.updateAllocations(
            scenarioID: "scenario-123",
            allocations: newAllocations,
            coupleID: coupleID
        )

        // Assert
        let fields = mockFirestore.fieldsUpdated(at: "couples/\(coupleID)/scenarios/scenario-123")
        XCTAssertNotNil(fields?["allocations"])
    }

    // MARK: - Delete Scenario Tests

    func test_deleteScenario_deletesDocument() async throws {
        // Arrange
        mockFirestore.stubDocument(
            path: "couples/\(coupleID)/scenarios/scenario-123",
            data: TestFixtures.makeScenarioData(id: "scenario-123")
        )

        // Act
        try await repository.deleteScenario(id: "scenario-123", coupleID: coupleID)

        // Assert
        XCTAssertTrue(mockFirestore.didDelete(at: "couples/\(coupleID)/scenarios/scenario-123"))
    }

    func test_deleteArchivedScenarios_batchDeletesArchivedOnly() async throws {
        // Arrange
        mockFirestore.stubDocument(
            path: "couples/\(coupleID)/scenarios/scenario-1",
            data: TestFixtures.makeScenarioData(id: "scenario-1", decisionStatus: "archived")
        )
        mockFirestore.stubDocument(
            path: "couples/\(coupleID)/scenarios/scenario-2",
            data: TestFixtures.makeScenarioData(id: "scenario-2", decisionStatus: "draft")
        )

        // Act
        try await repository.deleteArchivedScenarios(coupleID: coupleID)

        // Assert
        XCTAssertTrue(mockFirestore.didDelete(at: "couples/\(coupleID)/scenarios/scenario-1"))
        XCTAssertFalse(mockFirestore.didDelete(at: "couples/\(coupleID)/scenarios/scenario-2"))
    }

    // MARK: - Listener Tests

    func test_listenToScenarios_returnsListenerRegistration() {
        // Act
        let registration = repository.listenToScenarios(coupleID: coupleID) { _ in }

        // Assert
        XCTAssertNotNil(registration)
    }

    func test_listenToActiveScenario_returnsListenerRegistration() {
        // Act
        let registration = repository.listenToActiveScenario(coupleID: coupleID) { _ in }

        // Assert
        XCTAssertNotNil(registration)
    }

    func test_listenToScenario_returnsListenerRegistration() {
        // Act
        let registration = repository.listenToScenario(
            id: "scenario-123",
            coupleID: coupleID
        ) { _ in }

        // Assert
        XCTAssertNotNil(registration)
    }

    // MARK: - Error Handling Tests

    func test_createScenario_throwsOnFirestoreError() async {
        // Arrange
        mockFirestore.errorToThrow = FirestoreError.unknown(NSError(domain: "Test", code: -1))
        let scenario = TestFixtures.makeScenario()

        // Act & Assert
        do {
            try await repository.createScenario(scenario, coupleID: coupleID)
            XCTFail("Expected error to be thrown")
        } catch {
            // Expected
        }
    }
}
