import Foundation
import FirebaseFirestore

/// Repository for Contribution subcollection operations in Firestore
///
/// Collection: /couples/{coupleId}/goals/{goalId}/contributions/{contributionId}
///
/// This repository uses the `FirestoreProviding` protocol for database access,
/// enabling dependency injection for testing.
///
/// ## Production Usage
/// ```swift
/// let repository = ContributionRepository()  // Uses real Firestore
/// ```
///
/// ## Test Usage
/// ```swift
/// let mock = MockFirestoreService()
/// let repository = ContributionRepository(db: mock)
/// ```
final class ContributionRepository {

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

    /// Get reference to contributions subcollection for a goal
    private func contributionsCollection(coupleID: String, goalID: String) -> CollectionProviding {
        db.collection("couples")
            .document(coupleID)
            .collection("goals")
            .document(goalID)
            .collection("contributions")
    }

    // MARK: - Create

    /// Create a new contribution for a goal
    func createContribution(_ contribution: Contribution, coupleID: String, goalID: String) async throws {
        let dto = ContributionDTO(from: contribution)
        try await contributionsCollection(coupleID: coupleID, goalID: goalID)
            .document(contribution.id)
            .setData(dto.dictionary)
    }

    // MARK: - Read

    /// Fetch a single contribution by ID
    func fetchContribution(id: String, coupleID: String, goalID: String) async throws -> Contribution {
        let document = try await contributionsCollection(coupleID: coupleID, goalID: goalID)
            .document(id)
            .getDocument()

        guard document.exists else {
            throw FirestoreError.documentNotFound
        }

        guard let dto = try? document.data(as: ContributionDTO.self) else {
            throw FirestoreError.decodingFailed
        }

        return dto.toContribution()
    }

    /// Fetch all contributions for a goal, ordered by date (newest first)
    func fetchContributions(coupleID: String, goalID: String) async throws -> [Contribution] {
        let snapshot = try await contributionsCollection(coupleID: coupleID, goalID: goalID)
            .order(by: "date", descending: true)
            .getDocuments()

        return snapshot.documents.compactMap { document in
            guard let dto = try? document.data(as: ContributionDTO.self) else { return nil }
            return dto.toContribution()
        }
    }

    /// Fetch contributions for a specific user on a goal
    func fetchContributions(byUserID userID: String, coupleID: String, goalID: String) async throws -> [Contribution] {
        let snapshot = try await contributionsCollection(coupleID: coupleID, goalID: goalID)
            .whereField("userId", isEqualTo: userID)
            .order(by: "date", descending: true)
            .getDocuments()

        return snapshot.documents.compactMap { document in
            guard let dto = try? document.data(as: ContributionDTO.self) else { return nil }
            return dto.toContribution()
        }
    }

    /// Fetch recent contributions (limited)
    func fetchRecentContributions(coupleID: String, goalID: String, limit: Int = 5) async throws -> [Contribution] {
        let snapshot = try await contributionsCollection(coupleID: coupleID, goalID: goalID)
            .order(by: "date", descending: true)
            .limit(to: limit)
            .getDocuments()

        return snapshot.documents.compactMap { document in
            guard let dto = try? document.data(as: ContributionDTO.self) else { return nil }
            return dto.toContribution()
        }
    }

    // MARK: - Update

    /// Update an entire contribution document
    func updateContribution(_ contribution: Contribution, coupleID: String, goalID: String) async throws {
        let dto = ContributionDTO(from: contribution)
        try await contributionsCollection(coupleID: coupleID, goalID: goalID)
            .document(contribution.id)
            .setData(dto.dictionary, merge: true)
    }

    /// Update only the amount of a contribution
    func updateContributionAmount(
        contributionID: String,
        amount: Decimal,
        coupleID: String,
        goalID: String
    ) async throws {
        let doubleAmount = NSDecimalNumber(decimal: amount).doubleValue
        try await contributionsCollection(coupleID: coupleID, goalID: goalID)
            .document(contributionID)
            .updateData([
                "amount": doubleAmount,
                "lastSyncedAt": Timestamp(date: Date())
            ])
    }

    // MARK: - Delete

    /// Delete a single contribution
    func deleteContribution(id: String, coupleID: String, goalID: String) async throws {
        try await contributionsCollection(coupleID: coupleID, goalID: goalID)
            .document(id)
            .delete()
    }

    /// Delete all contributions for a goal (used when deleting a goal)
    func deleteAllContributions(coupleID: String, goalID: String) async throws {
        let snapshot = try await contributionsCollection(coupleID: coupleID, goalID: goalID)
            .getDocuments()

        guard !snapshot.documents.isEmpty else { return }

        let batch = db.batch()
        for document in snapshot.documents {
            batch.deleteDocument(contributionsCollection(coupleID: coupleID, goalID: goalID).document(document.documentID))
        }
        try await batch.commit()
    }

    // MARK: - Real-time Listeners

    /// Listen to all contributions for a goal
    func listenToContributions(
        coupleID: String,
        goalID: String,
        onChange: @escaping ([Contribution]) -> Void
    ) -> ListenerRegistrationProviding {
        return contributionsCollection(coupleID: coupleID, goalID: goalID)
            .order(by: "date", descending: true)
            .addSnapshotListener { snapshot, error in
                guard let snapshot else {
                    onChange([])
                    return
                }

                let contributions = snapshot.documents.compactMap { document -> Contribution? in
                    guard let dto = try? document.data(as: ContributionDTO.self) else { return nil }
                    return dto.toContribution()
                }

                onChange(contributions)
            }
    }
}
