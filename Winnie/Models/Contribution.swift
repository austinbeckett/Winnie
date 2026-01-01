import Foundation

/// A single contribution to a goal made by a user
struct Contribution: Codable, Identifiable, Equatable, Sendable {

    /// Unique identifier (UUID locally, Firestore doc ID when synced)
    let id: String

    /// The goal this contribution belongs to
    let goalId: String

    /// The user who made this contribution
    let userId: String

    /// Amount contributed
    var amount: Decimal

    /// Date of the contribution (when the money was added)
    var date: Date

    /// Optional notes about the contribution
    var notes: String?

    /// Creation timestamp (when the record was created)
    let createdAt: Date

    // MARK: - Initializer

    init(
        id: String = UUID().uuidString,
        goalId: String,
        userId: String,
        amount: Decimal,
        date: Date = Date(),
        notes: String? = nil,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.goalId = goalId
        self.userId = userId
        self.amount = amount
        self.date = date
        self.notes = notes
        self.createdAt = createdAt
    }
}

// MARK: - Sample Data

extension Contribution {

    /// Sample contribution for previews
    static let sample = Contribution(
        goalId: "goal-1",
        userId: "user-1",
        amount: Decimal(150),
        date: Date(),
        notes: nil
    )

    /// Sample contributions for a goal
    static func samples(goalId: String, userIds: [String]) -> [Contribution] {
        guard userIds.count >= 2 else { return [] }

        return [
            Contribution(
                goalId: goalId,
                userId: userIds[0],
                amount: Decimal(150),
                date: Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date()
            ),
            Contribution(
                goalId: goalId,
                userId: userIds[1],
                amount: Decimal(146),
                date: Calendar.current.date(byAdding: .day, value: -3, to: Date()) ?? Date()
            ),
            Contribution(
                goalId: goalId,
                userId: userIds[0],
                amount: Decimal(50),
                date: Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date(),
                notes: "Birthday money"
            )
        ]
    }
}
