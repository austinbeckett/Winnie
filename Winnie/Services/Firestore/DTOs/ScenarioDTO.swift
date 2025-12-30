import Foundation
import FirebaseFirestore

/// Data Transfer Object for Scenario documents in Firestore
/// Stored at: /couples/{coupleId}/scenarios/{scenarioId}
struct ScenarioDTO: Codable {

    /// Unique scenario identifier
    let id: String

    /// User-defined scenario name
    var name: String

    /// Allocation map: goal ID -> monthly contribution amount (as Double)
    var allocations: [String: Double]

    /// Optional description or notes
    var notes: String?

    /// Whether this is the currently active/decided plan
    var isActive: Bool

    /// Decision status as string (DecisionStatus.rawValue)
    var decisionStatus: String

    /// Creation timestamp
    let createdAt: Date

    /// Last modified timestamp
    var lastModified: Date

    /// User ID who created this scenario
    let createdBy: String

    /// Last sync timestamp for cache invalidation
    var lastSyncedAt: Date?

    // MARK: - Coding Keys

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case allocations
        case notes
        case isActive
        case decisionStatus
        case createdAt
        case lastModified
        case createdBy
        case lastSyncedAt
    }

    // MARK: - Initializers

    /// Create from domain model
    init(from scenario: Scenario) {
        self.id = scenario.id
        self.name = scenario.name
        // Convert Allocation wrapper to [String: Double]
        // The Allocation.toDictionary() returns [String: Decimal]
        // We need to convert each Decimal to Double for Firestore
        self.allocations = scenario.allocations.toDictionary().mapValues {
            NSDecimalNumber(decimal: $0).doubleValue
        }
        self.notes = scenario.notes
        self.isActive = scenario.isActive
        self.decisionStatus = scenario.decisionStatus.rawValue
        self.createdAt = scenario.createdAt
        self.lastModified = scenario.lastModified
        self.createdBy = scenario.createdBy
        self.lastSyncedAt = Date()
    }

    // MARK: - Conversion to Domain Model

    /// Convert to domain model
    /// Returns nil if the decisionStatus string is not valid
    func toScenario() -> Scenario? {
        // Validate that the status string maps to a valid DecisionStatus
        guard let status = Scenario.DecisionStatus(rawValue: decisionStatus) else {
            return nil
        }

        // Convert [String: Double] back to Allocation wrapper
        // First convert to [String: Decimal], then wrap
        let decimalAllocations = allocations.mapValues { Decimal($0) }
        let allocation = Allocation(allocations: decimalAllocations)

        return Scenario(
            id: id,
            name: name,
            allocations: allocation,
            notes: notes,
            isActive: isActive,
            decisionStatus: status,
            createdAt: createdAt,
            lastModified: lastModified,
            createdBy: createdBy
        )
    }

    // MARK: - Firestore Dictionary

    /// Convert to dictionary for Firestore write operations
    var dictionary: [String: Any] {
        var dict: [String: Any] = [
            "id": id,
            "name": name,
            "allocations": allocations,
            "isActive": isActive,
            "decisionStatus": decisionStatus,
            "createdAt": Timestamp(date: createdAt),
            "lastModified": Timestamp(date: lastModified),
            "createdBy": createdBy
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
