import Foundation
import FirebaseFirestore

/// Repository for Scenario subcollection operations in Firestore
///
/// Collection: /couples/{coupleId}/scenarios/{scenarioId}
///
/// This repository uses the `FirestoreProviding` protocol for database access,
/// enabling dependency injection for testing.
///
/// ## Production Usage
/// ```swift
/// let repository = ScenarioRepository()  // Uses real Firestore
/// ```
///
/// ## Test Usage
/// ```swift
/// let mock = MockFirestoreService()
/// let repository = ScenarioRepository(db: mock)
/// ```
final class ScenarioRepository: Sendable {

    // MARK: - Dependencies

    private let db: FirestoreProviding

    // MARK: - Initialization

    /// Create a repository with the default Firestore service (production)
    init() {
        self.db = FirestoreService.shared
    }

    /// Create a repository with an injected database (for testing)
    /// - Parameter db: Any implementation of FirestoreProviding
    init(db: FirestoreProviding) {
        self.db = db
    }

    // MARK: - Helpers

    /// Get reference to scenarios subcollection for a couple
    private func scenariosCollection(coupleID: String) -> CollectionProviding {
        db.collection("couples").document(coupleID).collection("scenarios")
    }

    // MARK: - Create

    /// Create a new scenario for a couple
    func createScenario(_ scenario: Scenario, coupleID: String) async throws {
        let dto = ScenarioDTO(from: scenario)
        try await scenariosCollection(coupleID: coupleID)
            .document(scenario.id)
            .setData(dto.dictionary)
    }

    // MARK: - Read

    /// Fetch a single scenario by ID
    func fetchScenario(id: String, coupleID: String) async throws -> Scenario {
        let document = try await scenariosCollection(coupleID: coupleID)
            .document(id)
            .getDocument()

        guard document.exists else {
            throw FirestoreError.documentNotFound
        }

        guard let dto = try? document.data(as: ScenarioDTO.self),
              let scenario = dto.toScenario() else {
            throw FirestoreError.decodingFailed
        }

        return scenario
    }

    /// Fetch all scenarios for a couple, ordered by last modified
    func fetchAllScenarios(coupleID: String) async throws -> [Scenario] {
        let snapshot = try await scenariosCollection(coupleID: coupleID)
            .order(by: "lastModified", descending: true)
            .getDocuments()

        return snapshot.documents.compactMap { document in
            guard let dto = try? document.data(as: ScenarioDTO.self) else { return nil }
            return dto.toScenario()
        }
    }

    /// Fetch the currently active scenario (if any)
    func fetchActiveScenario(coupleID: String) async throws -> Scenario? {
        let snapshot = try await scenariosCollection(coupleID: coupleID)
            .whereField("isActive", isEqualTo: true)
            .limit(to: 1)
            .getDocuments()

        guard let document = snapshot.documents.first,
              let dto = try? document.data(as: ScenarioDTO.self) else {
            return nil
        }

        return dto.toScenario()
    }

    /// Fetch scenarios by decision status
    func fetchScenarios(
        withStatus status: Scenario.DecisionStatus,
        coupleID: String
    ) async throws -> [Scenario] {
        let snapshot = try await scenariosCollection(coupleID: coupleID)
            .whereField("decisionStatus", isEqualTo: status.rawValue)
            .order(by: "lastModified", descending: true)
            .getDocuments()

        return snapshot.documents.compactMap { document in
            guard let dto = try? document.data(as: ScenarioDTO.self) else { return nil }
            return dto.toScenario()
        }
    }

    /// Fetch scenarios created by a specific user
    func fetchScenarios(createdBy userID: String, coupleID: String) async throws -> [Scenario] {
        let snapshot = try await scenariosCollection(coupleID: coupleID)
            .whereField("createdBy", isEqualTo: userID)
            .order(by: "lastModified", descending: true)
            .getDocuments()

        return snapshot.documents.compactMap { document in
            guard let dto = try? document.data(as: ScenarioDTO.self) else { return nil }
            return dto.toScenario()
        }
    }

    // MARK: - Update

    /// Update an entire scenario document
    func updateScenario(_ scenario: Scenario, coupleID: String) async throws {
        // Automatically update lastModified
        var updatedScenario = scenario
        updatedScenario.lastModified = Date()

        let dto = ScenarioDTO(from: updatedScenario)
        try await scenariosCollection(coupleID: coupleID)
            .document(scenario.id)
            .setData(dto.dictionary)
    }

    /// Update scenario decision status
    func updateScenarioStatus(
        scenarioID: String,
        status: Scenario.DecisionStatus,
        coupleID: String
    ) async throws {
        try await scenariosCollection(coupleID: coupleID)
            .document(scenarioID)
            .updateData([
                "decisionStatus": status.rawValue,
                "lastModified": Timestamp(date: Date()),
                "lastSyncedAt": Timestamp(date: Date())
            ])
    }

    /// Set a scenario as the active plan
    /// Deactivates all other scenarios first (atomic batch operation)
    func setActiveScenario(scenarioID: String, coupleID: String) async throws {
        let batch = db.batch()
        let collection = scenariosCollection(coupleID: coupleID)
        let timestamp = Timestamp(date: Date())

        // First, deactivate all existing scenarios
        let allScenarios = try await collection.getDocuments()
        for document in allScenarios.documents {
            batch.updateData(["isActive": false], forDocument: document.reference)
        }

        // Then activate the selected scenario and mark as decided
        let targetRef = collection.document(scenarioID)
        batch.updateData([
            "isActive": true,
            "decisionStatus": Scenario.DecisionStatus.decided.rawValue,
            "lastModified": timestamp,
            "lastSyncedAt": timestamp
        ], forDocument: targetRef)

        try await batch.commit()
    }

    /// Clear the active scenario (deactivate all)
    func clearActiveScenario(coupleID: String) async throws {
        let batch = db.batch()
        let collection = scenariosCollection(coupleID: coupleID)

        let activeScenarios = try await collection
            .whereField("isActive", isEqualTo: true)
            .getDocuments()

        for document in activeScenarios.documents {
            batch.updateData([
                "isActive": false,
                "lastSyncedAt": Timestamp(date: Date())
            ], forDocument: document.reference)
        }

        try await batch.commit()
    }

    /// Update only the allocations for a scenario
    func updateAllocations(
        scenarioID: String,
        allocations: Allocation,
        coupleID: String
    ) async throws {
        // Convert Allocation to [String: Double] for Firestore
        let doubleAllocations = allocations.toDictionary().mapValues {
            NSDecimalNumber(decimal: $0).doubleValue
        }

        try await scenariosCollection(coupleID: coupleID)
            .document(scenarioID)
            .updateData([
                "allocations": doubleAllocations,
                "lastModified": Timestamp(date: Date()),
                "lastSyncedAt": Timestamp(date: Date())
            ])
    }

    // MARK: - Delete

    /// Delete a single scenario
    func deleteScenario(id: String, coupleID: String) async throws {
        try await scenariosCollection(coupleID: coupleID)
            .document(id)
            .delete()
    }

    /// Delete all archived scenarios
    func deleteArchivedScenarios(coupleID: String) async throws {
        let snapshot = try await scenariosCollection(coupleID: coupleID)
            .whereField("decisionStatus", isEqualTo: Scenario.DecisionStatus.archived.rawValue)
            .getDocuments()

        guard !snapshot.documents.isEmpty else { return }

        let batch = db.batch()
        for document in snapshot.documents {
            batch.deleteDocument(document.reference)
        }
        try await batch.commit()
    }

    // MARK: - Real-time Listeners

    /// Listen to all scenarios for a couple
    func listenToScenarios(
        coupleID: String,
        onChange: @escaping ([Scenario]) -> Void
    ) -> ListenerRegistrationProviding {
        return scenariosCollection(coupleID: coupleID)
            .order(by: "lastModified", descending: true)
            .addSnapshotListener { snapshot, error in
                guard let snapshot else {
                    onChange([])
                    return
                }

                let scenarios = snapshot.documents.compactMap { document -> Scenario? in
                    guard let dto = try? document.data(as: ScenarioDTO.self) else { return nil }
                    return dto.toScenario()
                }

                onChange(scenarios)
            }
    }

    /// Listen to the active scenario
    func listenToActiveScenario(
        coupleID: String,
        onChange: @escaping (Scenario?) -> Void
    ) -> ListenerRegistrationProviding {
        return scenariosCollection(coupleID: coupleID)
            .whereField("isActive", isEqualTo: true)
            .limit(to: 1)
            .addSnapshotListener { snapshot, error in
                guard let snapshot, let document = snapshot.documents.first else {
                    onChange(nil)
                    return
                }

                guard let dto = try? document.data(as: ScenarioDTO.self) else {
                    onChange(nil)
                    return
                }

                onChange(dto.toScenario())
            }
    }

    /// Listen to a single scenario
    func listenToScenario(
        id: String,
        coupleID: String,
        onChange: @escaping (Scenario?) -> Void
    ) -> ListenerRegistrationProviding {
        return scenariosCollection(coupleID: coupleID)
            .document(id)
            .addSnapshotListener { snapshot, error in
                guard let snapshot, snapshot.exists else {
                    onChange(nil)
                    return
                }

                guard let dto = try? snapshot.data(as: ScenarioDTO.self) else {
                    onChange(nil)
                    return
                }

                onChange(dto.toScenario())
            }
    }
}
