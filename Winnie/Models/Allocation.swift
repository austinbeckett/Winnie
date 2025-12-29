import Foundation

/// Type-safe wrapper for goal allocation mapping
/// Maps goal IDs to monthly contribution amounts
struct Allocation: Codable, Equatable {

    /// Internal dictionary mapping goal ID to monthly amount
    private var allocations: [String: Decimal]

    // MARK: - Initializers

    init() {
        self.allocations = [:]
    }

    init(allocations: [String: Decimal]) {
        self.allocations = allocations
    }

    // MARK: - Subscript Access

    /// Get or set allocation for a goal by ID
    subscript(goalID: String) -> Decimal {
        get { allocations[goalID] ?? 0 }
        set { allocations[goalID] = max(newValue, 0) }
    }

    // MARK: - Computed Properties

    /// Total amount allocated across all goals
    var totalAllocated: Decimal {
        allocations.values.reduce(0, +)
    }

    /// All goal IDs that have allocations
    var goalIDs: [String] {
        Array(allocations.keys)
    }

    /// Number of goals with non-zero allocation
    var allocatedGoalCount: Int {
        allocations.values.filter { $0 > 0 }.count
    }

    /// Whether any allocations exist
    var hasAllocations: Bool {
        !allocations.isEmpty && totalAllocated > 0
    }

    // MARK: - Methods

    /// Get allocation amount for a specific goal
    func amount(for goalID: String) -> Decimal {
        allocations[goalID] ?? 0
    }

    /// Set allocation amount for a specific goal
    mutating func setAmount(_ amount: Decimal, for goalID: String) {
        allocations[goalID] = max(amount, 0)
    }

    /// Remove allocation for a goal
    mutating func removeAllocation(for goalID: String) {
        allocations.removeValue(forKey: goalID)
    }

    /// Clear all allocations
    mutating func clearAll() {
        allocations.removeAll()
    }

    /// Get raw dictionary for Firestore serialization
    func toDictionary() -> [String: Decimal] {
        allocations
    }

    /// Check if remaining disposable income would be negative
    func wouldOverAllocate(adding amount: Decimal, disposableIncome: Decimal) -> Bool {
        totalAllocated + amount > disposableIncome
    }

    /// Calculate remaining disposable income after allocations
    func remainingDisposable(from disposableIncome: Decimal) -> Decimal {
        max(disposableIncome - totalAllocated, 0)
    }
}

// MARK: - Sample Data

extension Allocation {

    /// Sample allocation for previews
    static var sample: Allocation {
        var allocation = Allocation()
        allocation[Goal.sampleHouse.id] = Decimal(1500)
        allocation[Goal.sampleRetirement.id] = Decimal(1000)
        allocation[Goal.sampleVacation.id] = Decimal(300)
        allocation[Goal.sampleEmergency.id] = Decimal(500)
        return allocation
    }
}
