//
//  ScenarioEditorViewModel.swift
//  Winnie
//
//  Created by Claude Code on 2026-01-08.
//

import SwiftUI

/// ViewModel for the Scenario Editor - manages allocations and real-time projections.
///
/// This ViewModel handles:
/// - Loading goals and financial profile from Firestore
/// - Managing working allocations (local state before saving)
/// - Triggering debounced Financial Engine calculations
/// - Saving scenarios to Firestore
///
/// ## Usage
/// ```swift
/// @State private var viewModel = ScenarioEditorViewModel(coupleID: "abc123")
///
/// // For editing an existing scenario:
/// viewModel.loadForEditing(scenario: existingScenario)
///
/// // For creating a new scenario:
/// viewModel.loadData()
/// ```
@Observable
@MainActor
final class ScenarioEditorViewModel: ErrorHandlingViewModel {

    // MARK: - Published State

    /// Goals available for allocation
    var goals: [Goal] = []

    /// The working allocations (modified as user drags sliders)
    var workingAllocations: Allocation = Allocation()

    /// Scenario name (user-editable)
    var scenarioName: String = ""

    /// Optional notes for the scenario
    var scenarioNotes: String = ""

    /// The financial profile containing budget info
    var financialProfile: FinancialProfile?

    /// Engine output with projections for all goals
    var engineOutput: EngineOutput?

    /// Whether the engine is currently calculating
    var isCalculating: Bool = false

    /// Loading state for async operations
    var isLoading: Bool = false

    /// Error message to display
    var errorMessage: String?

    /// Whether to show error alert
    var showError: Bool = false

    /// Whether we're editing an existing scenario (vs creating new)
    var isEditingExisting: Bool = false

    /// Selected goal IDs for this scenario (goals with checkmarks)
    var selectedGoalIDs: Set<String> = []

    // MARK: - Private State

    /// The scenario being edited (if any)
    private var existingScenario: Scenario?

    /// Debounce task for engine calculations
    private var debounceTask: Task<Void, Never>?

    /// Debounce delay in nanoseconds (300ms)
    private let debounceDelay: UInt64 = 300_000_000

    // MARK: - Dependencies

    private let coupleID: String
    private let userID: String
    private let goalRepository: GoalRepository
    private let scenarioRepository: ScenarioRepository
    private let coupleRepository: CoupleRepository
    private let financialEngine: FinancialEngine

    // MARK: - Computed Properties

    /// Total amount allocated across all goals
    var totalAllocated: Decimal {
        workingAllocations.totalAllocated
    }

    /// Monthly disposable income (savings pool)
    var disposableIncome: Decimal {
        financialProfile?.monthlyDisposable ?? 0
    }

    /// Remaining budget after allocations
    var remainingBudget: Decimal {
        max(disposableIncome - totalAllocated, 0)
    }

    /// Whether user has over-allocated beyond their budget
    var isOverAllocated: Bool {
        totalAllocated > disposableIncome
    }

    /// Amount over budget (if over-allocated)
    var overAllocationAmount: Decimal {
        max(totalAllocated - disposableIncome, 0)
    }

    /// Progress of allocation (0.0 to 1.0+)
    var allocationProgress: Double {
        guard disposableIncome > 0 else { return 0 }
        let progress = totalAllocated / disposableIncome
        return Double(truncating: progress as NSNumber)
    }

    /// Whether the scenario can be saved
    var canSave: Bool {
        !scenarioName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && !goals.isEmpty
            && hasSelectedGoals
            && !isOverAllocated
    }

    /// Get projection for a specific goal
    func projection(for goalID: String) -> GoalProjection? {
        engineOutput?.projection(for: goalID)
    }

    /// Calculate required monthly contribution to hit a goal's target date.
    /// Returns nil if the goal has no target date or is already complete.
    func requiredContribution(for goal: Goal) -> Decimal? {
        guard let targetDate = goal.desiredDate else { return nil }
        guard goal.currentAmount < goal.targetAmount else { return nil }
        return financialEngine.requiredMonthlyContribution(for: goal, by: targetDate)
    }

    /// Get the full allocation context for a goal (used by enhanced allocation row).
    func allocationContext(for goal: Goal) -> GoalAllocationContext {
        let allocation = workingAllocations[goal.id]
        let projection = projection(for: goal.id)
        let required = requiredContribution(for: goal)

        // Calculate months delta between projected and target date
        var monthsDelta: Int?
        var isOnTrack = true

        if let targetDate = goal.desiredDate,
           let projectedDate = projection?.completionDate {
            let calendar = Calendar.current
            let projectedComponents = calendar.dateComponents([.year, .month], from: projectedDate)
            let targetComponents = calendar.dateComponents([.year, .month], from: targetDate)

            let projectedMonths = (projectedComponents.year ?? 0) * 12 + (projectedComponents.month ?? 0)
            let targetMonths = (targetComponents.year ?? 0) * 12 + (targetComponents.month ?? 0)

            // Positive = early, negative = late
            monthsDelta = targetMonths - projectedMonths
            isOnTrack = projectedMonths <= targetMonths
        }

        return GoalAllocationContext(
            goal: goal,
            allocation: allocation,
            projection: projection,
            requiredContribution: required,
            targetDate: goal.desiredDate,
            isOnTrack: isOnTrack,
            monthsDelta: monthsDelta
        )
    }

    /// Goals that are selected for this scenario (filtered by checkmarks)
    var selectedGoals: [Goal] {
        goals.filter { selectedGoalIDs.contains($0.id) }
    }

    /// Whether any goals are selected
    var hasSelectedGoals: Bool {
        !selectedGoalIDs.isEmpty
    }

    // MARK: - Goal Selection

    /// Toggle a goal's selection status.
    /// When deselected, the allocation is removed from the dictionary.
    /// When selected, an allocation entry is created (even if $0) so it's saved with the scenario.
    /// - Parameter goalID: The goal to toggle
    func toggleGoalSelection(_ goalID: String) {
        if selectedGoalIDs.contains(goalID) {
            selectedGoalIDs.remove(goalID)
            workingAllocations.removeAllocation(for: goalID)  // Remove from dictionary when deselected
        } else {
            selectedGoalIDs.insert(goalID)
            // Ensure goal has an allocation entry (even if $0) so it's saved with the scenario
            workingAllocations[goalID] = workingAllocations[goalID]  // Creates entry if missing
        }
        recalculate()
    }

    /// Select all goals and ensure each has an allocation entry
    func selectAllGoals() {
        selectedGoalIDs = Set(goals.map { $0.id })
        // Ensure all selected goals have allocation entries
        for goal in goals {
            workingAllocations[goal.id] = workingAllocations[goal.id]
        }
    }

    /// Deselect all goals and clear allocations
    func deselectAllGoals() {
        selectedGoalIDs.removeAll()
        clearAllAllocations()
    }

    // MARK: - Initialization

    /// Create a ViewModel for a new or existing scenario.
    /// - Parameters:
    ///   - coupleID: The couple's Firestore document ID
    ///   - userID: The current user's ID (for tracking who created the scenario)
    ///   - goalRepository: Repository for fetching goals
    ///   - scenarioRepository: Repository for scenario persistence
    ///   - coupleRepository: Repository for financial profile
    ///   - financialEngine: Engine for projections (defaults to standard engine)
    init(
        coupleID: String,
        userID: String,
        goalRepository: GoalRepository? = nil,
        scenarioRepository: ScenarioRepository? = nil,
        coupleRepository: CoupleRepository? = nil,
        financialEngine: FinancialEngine? = nil
    ) {
        self.coupleID = coupleID
        self.userID = userID
        self.goalRepository = goalRepository ?? GoalRepository()
        self.scenarioRepository = scenarioRepository ?? ScenarioRepository()
        self.coupleRepository = coupleRepository ?? CoupleRepository()
        self.financialEngine = financialEngine ?? FinancialEngine()
    }

    // MARK: - Data Loading

    /// Load goals and financial profile for a new scenario.
    func loadData() async {
        isLoading = true
        errorMessage = nil

        do {
            // Load goals and profile in parallel
            async let goalsTask = goalRepository.fetchAllGoals(coupleID: coupleID)
            async let profileTask = coupleRepository.fetchFinancialProfile(coupleID: coupleID)

            let (loadedGoals, loadedProfile) = try await (goalsTask, profileTask)

            goals = loadedGoals.filter { $0.isActive }
            financialProfile = loadedProfile

            // Initialize all goals as selected (user can uncheck ones they don't want)
            selectedGoalIDs = Set(goals.map { $0.id })

            // Initialize allocations to zero for all goals
            for goal in goals {
                workingAllocations[goal.id] = 0
            }

            // Generate a default scenario name
            scenarioName = "New Plan \(Date().formatted(date: .abbreviated, time: .omitted))"

            // Calculate initial projections
            recalculate()

        } catch {
            handleError(error, context: "loading data")
        }

        isLoading = false
    }

    /// Load an existing scenario for editing.
    /// - Parameter scenario: The scenario to edit
    func loadForEditing(scenario: Scenario) async {
        isLoading = true
        errorMessage = nil
        isEditingExisting = true
        existingScenario = scenario

        do {
            // Load goals and profile
            async let goalsTask = goalRepository.fetchAllGoals(coupleID: coupleID)
            async let profileTask = coupleRepository.fetchFinancialProfile(coupleID: coupleID)

            let (loadedGoals, loadedProfile) = try await (goalsTask, profileTask)

            goals = loadedGoals.filter { $0.isActive }
            financialProfile = loadedProfile

            // Restore allocations from scenario
            workingAllocations = scenario.allocations
            scenarioName = scenario.name
            scenarioNotes = scenario.notes ?? ""

            // Remove allocations for goals that no longer exist
            let validGoalIDs = Set(goals.map { $0.id })
            for goalID in workingAllocations.goalIDs {
                if !validGoalIDs.contains(goalID) {
                    workingAllocations.removeAllocation(for: goalID)
                }
            }

            // Pre-select goals that have entries in the allocations dictionary (including $0)
            selectedGoalIDs = Set(
                goals
                    .filter { workingAllocations.goalIDs.contains($0.id) }
                    .map { $0.id }
            )

            // If no goals have allocations, select all by default and create entries
            if selectedGoalIDs.isEmpty {
                selectedGoalIDs = Set(goals.map { $0.id })
                for goal in goals {
                    workingAllocations[goal.id] = 0
                }
            }

            // Calculate projections
            recalculate()

        } catch {
            handleError(error, context: "loading scenario")
        }

        isLoading = false
    }

    // MARK: - Allocation Updates

    /// Update allocation for a specific goal.
    /// Triggers debounced recalculation.
    /// - Parameters:
    ///   - goalID: The goal to update
    ///   - amount: New monthly allocation amount
    func updateAllocation(goalID: String, amount: Decimal) {
        workingAllocations[goalID] = max(amount, 0)
        scheduleRecalculation()
    }

    /// Distribute remaining budget evenly across goals with zero allocation.
    func allocateRemainingEvenly() {
        let unallocatedGoals = goals.filter { workingAllocations[$0.id] == 0 }
        guard !unallocatedGoals.isEmpty, remainingBudget > 0 else { return }

        let amountPerGoal = remainingBudget / Decimal(unallocatedGoals.count)

        // Round to nearest $50
        let roundedAmount = (amountPerGoal / 50).rounded() * 50

        for goal in unallocatedGoals {
            workingAllocations[goal.id] = roundedAmount
        }

        recalculate()
    }

    /// Clear all allocations to zero.
    func clearAllAllocations() {
        workingAllocations.clearAll()
        for goal in goals {
            workingAllocations[goal.id] = 0
        }
        recalculate()
    }

    // MARK: - Engine Calculations

    /// Schedule a debounced recalculation.
    private func scheduleRecalculation() {
        // Cancel any pending calculation
        debounceTask?.cancel()

        isCalculating = true

        debounceTask = Task { [weak self] in
            // Wait for debounce delay
            try? await Task.sleep(nanoseconds: self?.debounceDelay ?? 0)

            // Check if cancelled
            guard !Task.isCancelled else { return }

            self?.performCalculation()
        }
    }

    /// Perform the actual engine calculation.
    private func performCalculation() {
        recalculate()
        isCalculating = false
    }

    /// Recalculate projections immediately (no debounce).
    func recalculate() {
        guard let profile = financialProfile else { return }

        let input = EngineInput(
            profile: profile,
            goals: goals,
            allocations: workingAllocations
        )

        engineOutput = financialEngine.calculate(input: input)
    }

    // MARK: - Persistence

    /// Save the scenario to Firestore.
    /// Creates a new scenario or updates the existing one.
    func saveScenario() async -> Bool {
        guard canSave else { return false }

        isLoading = true
        errorMessage = nil

        do {
            let scenario: Scenario

            if let existing = existingScenario {
                // Update existing scenario
                scenario = Scenario(
                    id: existing.id,
                    name: scenarioName.trimmingCharacters(in: .whitespacesAndNewlines),
                    allocations: workingAllocations,
                    notes: scenarioNotes.isEmpty ? nil : scenarioNotes,
                    isActive: existing.isActive,
                    decisionStatus: existing.decisionStatus,
                    createdAt: existing.createdAt,
                    lastModified: Date(),
                    createdBy: existing.createdBy
                )
                try await scenarioRepository.updateScenario(scenario, coupleID: coupleID)
            } else {
                // Create new scenario
                scenario = Scenario(
                    id: UUID().uuidString,
                    name: scenarioName.trimmingCharacters(in: .whitespacesAndNewlines),
                    allocations: workingAllocations,
                    notes: scenarioNotes.isEmpty ? nil : scenarioNotes,
                    isActive: false,
                    decisionStatus: .draft,
                    createdAt: Date(),
                    lastModified: Date(),
                    createdBy: userID
                )
                try await scenarioRepository.createScenario(scenario, coupleID: coupleID)

                // Auto-activate if this is the user's first/only scenario
                let allScenarios = try await scenarioRepository.fetchAllScenarios(coupleID: coupleID)
                if allScenarios.count == 1 {
                    try await scenarioRepository.setActiveScenario(scenarioID: scenario.id, coupleID: coupleID)
                }
            }

            isLoading = false
            return true

        } catch {
            handleError(error, context: "saving scenario")
            isLoading = false
            return false
        }
    }

    /// Delete the current scenario (only if editing existing).
    func deleteScenario() async -> Bool {
        guard let existing = existingScenario else { return false }

        isLoading = true
        errorMessage = nil

        do {
            try await scenarioRepository.deleteScenario(id: existing.id, coupleID: coupleID)
            isLoading = false
            return true
        } catch {
            handleError(error, context: "deleting scenario")
            isLoading = false
            return false
        }
    }
}

// MARK: - Goal Allocation Context

/// Context object containing all information needed to display an enhanced allocation row.
/// Bundles the goal, current allocation, projection, and comparison data.
struct GoalAllocationContext {
    /// The goal being allocated
    let goal: Goal

    /// Current allocation amount (from slider)
    let allocation: Decimal

    /// Engine projection for this goal
    let projection: GoalProjection?

    /// Required contribution to hit target date (nil if no target date)
    let requiredContribution: Decimal?

    /// Target date from goal (nil if not set)
    let targetDate: Date?

    /// Whether current allocation puts goal on track to hit target
    let isOnTrack: Bool

    /// Months difference: positive = early, negative = late, nil = no comparison possible
    let monthsDelta: Int?

    // MARK: - Computed Properties

    /// Whether this goal has a target date to compare against
    var hasTargetDate: Bool {
        targetDate != nil
    }

    /// Projected completion date based on current allocation
    var projectedDate: Date? {
        projection?.completionDate
    }

    /// Whether allocation needs to be increased to hit target
    var needsMoreAllocation: Bool {
        guard let required = requiredContribution else { return false }
        return allocation < required
    }

    /// How much more is needed per month to hit target
    var allocationDeficit: Decimal {
        guard let required = requiredContribution else { return 0 }
        return max(required - allocation, 0)
    }

    /// Formatted text for months delta (e.g., "4 months early" or "3 months late")
    var monthsDeltaText: String? {
        guard let delta = monthsDelta else { return nil }
        let absMonths = abs(delta)
        let monthWord = absMonths == 1 ? "month" : "months"

        if delta > 0 {
            return "\(absMonths) \(monthWord) early"
        } else if delta < 0 {
            return "\(absMonths) \(monthWord) late"
        } else {
            return "On target"
        }
    }
}

// MARK: - Helper Extension

extension Decimal {
    /// Round to nearest value (used for $50 increments)
    func rounded() -> Decimal {
        var result = Decimal()
        var copy = self
        NSDecimalRound(&result, &copy, 0, .plain)
        return result
    }
}
