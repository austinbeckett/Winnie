import Foundation
import FirebaseFirestore

/// Data Transfer Object for Contribution documents in Firestore
/// Stored at: /couples/{coupleId}/goals/{goalId}/contributions/{contributionId}
struct ContributionDTO: Codable {

    /// Unique contribution identifier
    let id: String

    /// The goal this contribution belongs to
    let goalId: String

    /// The user who made this contribution
    let userId: String

    /// Amount contributed (stored as Double for Firestore)
    var amount: Double

    /// Date of the contribution
    var date: Date

    /// Optional notes about the contribution
    var notes: String?

    /// Creation timestamp
    let createdAt: Date

    /// Last sync timestamp for cache invalidation
    var lastSyncedAt: Date?

    // MARK: - Coding Keys

    enum CodingKeys: String, CodingKey {
        case id
        case goalId
        case userId
        case amount
        case date
        case notes
        case createdAt
        case lastSyncedAt
    }

    // MARK: - Initializers

    /// Create from domain model
    init(from contribution: Contribution) {
        self.id = contribution.id
        self.goalId = contribution.goalId
        self.userId = contribution.userId
        self.amount = NSDecimalNumber(decimal: contribution.amount).doubleValue
        self.date = contribution.date
        self.notes = contribution.notes
        self.createdAt = contribution.createdAt
        self.lastSyncedAt = Date()
    }

    // MARK: - Conversion to Domain Model

    /// Convert to domain model
    func toContribution() -> Contribution {
        Contribution(
            id: id,
            goalId: goalId,
            userId: userId,
            amount: Decimal(amount),
            date: date,
            notes: notes,
            createdAt: createdAt
        )
    }

    // MARK: - Firestore Dictionary

    /// Convert to dictionary for Firestore write operations
    var dictionary: [String: Any] {
        var dict: [String: Any] = [
            "id": id,
            "goalId": goalId,
            "userId": userId,
            "amount": amount,
            "date": Timestamp(date: date),
            "createdAt": Timestamp(date: createdAt)
        ]

        if let notes {
            dict["notes"] = notes
        }

        if let lastSyncedAt {
            dict["lastSyncedAt"] = Timestamp(date: lastSyncedAt)
        }

        return dict
    }
}
