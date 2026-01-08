import Foundation

/// A saved "what-if" allocation configuration
/// Allows couples to create, compare, and decide on different savings strategies
struct Scenario: Codable, Identifiable, Equatable, Hashable {

    /// Unique identifier
    let id: String

    /// User-defined scenario name (e.g., "Aggressive House Plan")
    var name: String

    /// The allocation configuration for this scenario
    var allocations: Allocation

    /// Optional description or notes
    var notes: String?

    /// Whether this is the currently active/decided plan
    var isActive: Bool

    /// Decision status for couples workflow
    var decisionStatus: DecisionStatus

    /// Creation timestamp
    let createdAt: Date

    /// Last modified timestamp
    var lastModified: Date

    /// User ID who created this scenario
    let createdBy: String

    // MARK: - Nested Types

    /// Workflow status for scenario decisions
    enum DecisionStatus: String, Codable, CaseIterable {
        /// Still being edited by creator
        case draft
        /// Shared with partner for review
        case underReview
        /// Agreed upon by both partners
        case decided
        /// No longer in use
        case archived

        var displayName: String {
            switch self {
            case .draft: return "Draft"
            case .underReview: return "Under Review"
            case .decided: return "Decided"
            case .archived: return "Archived"
            }
        }
    }

    // MARK: - Computed Properties

    /// Whether the scenario can be edited
    var isEditable: Bool {
        decisionStatus == .draft || decisionStatus == .underReview
    }

    /// Whether the scenario is awaiting partner input
    var awaitingPartnerReview: Bool {
        decisionStatus == .underReview
    }

    // MARK: - Initializer

    init(
        id: String = UUID().uuidString,
        name: String,
        allocations: Allocation = Allocation(),
        notes: String? = nil,
        isActive: Bool = false,
        decisionStatus: DecisionStatus = .draft,
        createdAt: Date = Date(),
        lastModified: Date = Date(),
        createdBy: String
    ) {
        self.id = id
        self.name = name
        self.allocations = allocations
        self.notes = notes
        self.isActive = isActive
        self.decisionStatus = decisionStatus
        self.createdAt = createdAt
        self.lastModified = lastModified
        self.createdBy = createdBy
    }

    // MARK: - Methods

    /// Create a copy of this scenario with a new name
    func duplicate(newName: String, by userID: String) -> Scenario {
        Scenario(
            name: newName,
            allocations: allocations,
            notes: notes,
            isActive: false,
            decisionStatus: .draft,
            createdBy: userID
        )
    }
}

// MARK: - Sample Data

extension Scenario {

    /// Sample scenario for previews
    static let sample = Scenario(
        name: "Balanced Plan",
        allocations: .sample,
        notes: "Equal focus on house and retirement",
        decisionStatus: .decided,
        createdBy: "user123"
    )

    /// Sample draft scenario
    static let sampleDraft = Scenario(
        name: "Aggressive House Plan",
        allocations: .sample,
        decisionStatus: .draft,
        createdBy: "user123"
    )
}
