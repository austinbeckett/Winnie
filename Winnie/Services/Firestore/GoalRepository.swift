import Foundation
import FirebaseFirestore

/// Repository for Goal subcollection operations in Firestore
/// Collection: /couples/{coupleId}/goals/{goalId}
final class GoalRepository {

    private let db = Firestore.firestore()

    /// Get reference to goals subcollection for a couple
    private func goalsCollection(coupleID: String) -> CollectionReference {
        db.collection("couples").document(coupleID).collection("goals")
    }

    // MARK: - Create

    /// Create a new goal for a couple
    func createGoal(_ goal: Goal, coupleID: String) async throws {
        let dto = GoalDTO(from: goal)
        try await goalsCollection(coupleID: coupleID)
            .document(goal.id)
            .setData(dto.dictionary)
    }

    /// Create multiple goals at once (batch write)
    func createGoals(_ goals: [Goal], coupleID: String) async throws {
        guard !goals.isEmpty else { return }

        let batch = db.batch()
        let collection = goalsCollection(coupleID: coupleID)

        for goal in goals {
            let dto = GoalDTO(from: goal)
            let ref = collection.document(goal.id)
            batch.setData(dto.dictionary, forDocument: ref)
        }

        try await batch.commit()
    }

    // MARK: - Read

    /// Fetch a single goal by ID
    func fetchGoal(id: String, coupleID: String) async throws -> Goal {
        let document = try await goalsCollection(coupleID: coupleID)
            .document(id)
            .getDocument()

        guard document.exists else {
            throw FirestoreError.documentNotFound
        }

        guard let dto = try? document.data(as: GoalDTO.self),
              let goal = dto.toGoal() else {
            throw FirestoreError.decodingFailed
        }

        return goal
    }

    /// Fetch all goals for a couple, ordered by priority
    func fetchAllGoals(coupleID: String) async throws -> [Goal] {
        let snapshot = try await goalsCollection(coupleID: coupleID)
            .order(by: "priority")
            .getDocuments()

        return snapshot.documents.compactMap { document in
            guard let dto = try? document.data(as: GoalDTO.self) else { return nil }
            return dto.toGoal()
        }
    }

    /// Fetch only active goals for a couple, ordered by priority
    func fetchActiveGoals(coupleID: String) async throws -> [Goal] {
        let snapshot = try await goalsCollection(coupleID: coupleID)
            .whereField("isActive", isEqualTo: true)
            .order(by: "priority")
            .getDocuments()

        return snapshot.documents.compactMap { document in
            guard let dto = try? document.data(as: GoalDTO.self) else { return nil }
            return dto.toGoal()
        }
    }

    /// Fetch goals by type
    func fetchGoals(ofType type: GoalType, coupleID: String) async throws -> [Goal] {
        let snapshot = try await goalsCollection(coupleID: coupleID)
            .whereField("type", isEqualTo: type.rawValue)
            .order(by: "priority")
            .getDocuments()

        return snapshot.documents.compactMap { document in
            guard let dto = try? document.data(as: GoalDTO.self) else { return nil }
            return dto.toGoal()
        }
    }

    // MARK: - Update

    /// Update an entire goal document
    func updateGoal(_ goal: Goal, coupleID: String) async throws {
        let dto = GoalDTO(from: goal)
        try await goalsCollection(coupleID: coupleID)
            .document(goal.id)
            .setData(dto.dictionary, merge: true)
    }

    /// Update only the current amount (progress)
    func updateGoalProgress(
        goalID: String,
        currentAmount: Decimal,
        coupleID: String
    ) async throws {
        let doubleAmount = NSDecimalNumber(decimal: currentAmount).doubleValue
        try await goalsCollection(coupleID: coupleID)
            .document(goalID)
            .updateData([
                "currentAmount": doubleAmount,
                "lastSyncedAt": Timestamp(date: Date())
            ])
    }

    /// Update goal's active status
    func setGoalActive(goalID: String, isActive: Bool, coupleID: String) async throws {
        try await goalsCollection(coupleID: coupleID)
            .document(goalID)
            .updateData([
                "isActive": isActive,
                "lastSyncedAt": Timestamp(date: Date())
            ])
    }

    /// Update goal priority
    func updateGoalPriority(goalID: String, priority: Int, coupleID: String) async throws {
        try await goalsCollection(coupleID: coupleID)
            .document(goalID)
            .updateData([
                "priority": priority,
                "lastSyncedAt": Timestamp(date: Date())
            ])
    }

    /// Reorder goals by updating their priorities (batch)
    func reorderGoals(orderedGoalIDs: [String], coupleID: String) async throws {
        let batch = db.batch()
        let collection = goalsCollection(coupleID: coupleID)
        let timestamp = Timestamp(date: Date())

        for (index, goalID) in orderedGoalIDs.enumerated() {
            let ref = collection.document(goalID)
            batch.updateData([
                "priority": index,
                "lastSyncedAt": timestamp
            ], forDocument: ref)
        }

        try await batch.commit()
    }

    // MARK: - Delete

    /// Delete a single goal
    func deleteGoal(id: String, coupleID: String) async throws {
        try await goalsCollection(coupleID: coupleID)
            .document(id)
            .delete()
    }

    /// Delete multiple goals (batch)
    func deleteGoals(ids: [String], coupleID: String) async throws {
        guard !ids.isEmpty else { return }

        let batch = db.batch()
        let collection = goalsCollection(coupleID: coupleID)

        for id in ids {
            batch.deleteDocument(collection.document(id))
        }

        try await batch.commit()
    }

    // MARK: - Real-time Listeners

    /// Listen to all goals for a couple
    func listenToGoals(
        coupleID: String,
        onChange: @escaping ([Goal]) -> Void
    ) -> ListenerRegistration {
        return goalsCollection(coupleID: coupleID)
            .order(by: "priority")
            .addSnapshotListener { snapshot, error in
                guard let snapshot else {
                    onChange([])
                    return
                }

                let goals = snapshot.documents.compactMap { document -> Goal? in
                    guard let dto = try? document.data(as: GoalDTO.self) else { return nil }
                    return dto.toGoal()
                }

                onChange(goals)
            }
    }

    /// Listen to active goals only
    func listenToActiveGoals(
        coupleID: String,
        onChange: @escaping ([Goal]) -> Void
    ) -> ListenerRegistration {
        return goalsCollection(coupleID: coupleID)
            .whereField("isActive", isEqualTo: true)
            .order(by: "priority")
            .addSnapshotListener { snapshot, error in
                guard let snapshot else {
                    onChange([])
                    return
                }

                let goals = snapshot.documents.compactMap { document -> Goal? in
                    guard let dto = try? document.data(as: GoalDTO.self) else { return nil }
                    return dto.toGoal()
                }

                onChange(goals)
            }
    }

    /// Listen to a single goal
    func listenToGoal(
        id: String,
        coupleID: String,
        onChange: @escaping (Goal?) -> Void
    ) -> ListenerRegistration {
        return goalsCollection(coupleID: coupleID)
            .document(id)
            .addSnapshotListener { snapshot, error in
                guard let snapshot, snapshot.exists else {
                    onChange(nil)
                    return
                }

                guard let dto = try? snapshot.data(as: GoalDTO.self) else {
                    onChange(nil)
                    return
                }

                onChange(dto.toGoal())
            }
    }
}
