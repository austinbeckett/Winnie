import Foundation
import FirebaseFirestore

/// Data Transfer Object for Goal documents in Firestore
/// Stored at: /couples/{coupleId}/goals/{goalId}
struct GoalDTO: Codable {

    /// Unique goal identifier
    let id: String

    /// Goal type as string (GoalType.rawValue)
    var type: String

    /// User-defined name
    var name: String

    /// Target amount (stored as Double for Firestore)
    var targetAmount: Double

    /// Current progress toward goal
    var currentAmount: Double

    /// Optional desired completion date
    var desiredDate: Date?

    /// Custom annual return rate override (nil uses type default)
    var customReturnRate: Double?

    /// Priority order (lower = higher priority)
    var priority: Int

    /// Creation timestamp
    let createdAt: Date

    /// Whether goal is currently active
    var isActive: Bool

    /// Optional notes or description
    var notes: String?

    /// Custom color hex code (e.g., "#A393BF")
    var colorHex: String?

    /// Custom SF Symbol icon name (e.g., "heart.fill")
    var iconName: String?

    /// User-specified account name (e.g., "Chase Savings", "Ally HYSA")
    var accountName: String?

    /// Last sync timestamp for cache invalidation
    var lastSyncedAt: Date?

    // MARK: - Coding Keys

    enum CodingKeys: String, CodingKey {
        case id
        case type
        case name
        case targetAmount
        case currentAmount
        case desiredDate
        case customReturnRate
        case priority
        case createdAt
        case isActive
        case notes
        case colorHex
        case iconName
        case accountName
        case lastSyncedAt
    }

    // MARK: - Initializers

    /// Create from domain model
    init(from goal: Goal) {
        self.id = goal.id
        self.type = goal.type.rawValue
        self.name = goal.name
        self.targetAmount = NSDecimalNumber(decimal: goal.targetAmount).doubleValue
        self.currentAmount = NSDecimalNumber(decimal: goal.currentAmount).doubleValue
        self.desiredDate = goal.desiredDate
        self.customReturnRate = goal.customReturnRate.map {
            NSDecimalNumber(decimal: $0).doubleValue
        }
        self.priority = goal.priority
        self.createdAt = goal.createdAt
        self.isActive = goal.isActive
        self.notes = goal.notes
        self.colorHex = goal.colorHex
        self.iconName = goal.iconName
        self.accountName = goal.accountName
        self.lastSyncedAt = Date()
    }

    // MARK: - Conversion to Domain Model

    /// Convert to domain model
    /// Returns nil if the type string is not a valid GoalType
    func toGoal() -> Goal? {
        // Validate that the type string maps to a valid GoalType
        guard let goalType = GoalType(rawValue: type) else {
            return nil
        }

        return Goal(
            id: id,
            type: goalType,
            name: name,
            targetAmount: Decimal(targetAmount),
            currentAmount: Decimal(currentAmount),
            desiredDate: desiredDate,
            customReturnRate: customReturnRate.map { Decimal($0) },
            priority: priority,
            createdAt: createdAt,
            isActive: isActive,
            notes: notes,
            colorHex: colorHex,
            iconName: iconName,
            accountName: accountName
        )
    }

    // MARK: - Firestore Dictionary

    /// Convert to dictionary for Firestore write operations
    var dictionary: [String: Any] {
        var dict: [String: Any] = [
            "id": id,
            "type": type,
            "name": name,
            "targetAmount": targetAmount,
            "currentAmount": currentAmount,
            "priority": priority,
            "createdAt": Timestamp(date: createdAt),
            "isActive": isActive
        ]

        if let desiredDate {
            dict["desiredDate"] = Timestamp(date: desiredDate)
        }

        if let customReturnRate {
            dict["customReturnRate"] = customReturnRate
        }

        if let notes {
            dict["notes"] = notes
        }

        if let colorHex {
            dict["colorHex"] = colorHex
        }

        if let iconName {
            dict["iconName"] = iconName
        }

        if let accountName {
            dict["accountName"] = accountName
        }

        if let lastSyncedAt {
            dict["lastSyncedAt"] = Timestamp(date: lastSyncedAt)
        }

        return dict
    }
}
