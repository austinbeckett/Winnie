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
            && !isOverAllocated
    }

    /// Get projection for a specific goal
    func projection(for goalID: String) -> GoalProjection? {
        engineOutput?.projection(for: goalID)
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
        goalRepository: GoalRepository = GoalRepository(),
        scenarioRepository: ScenarioRepository = ScenarioRepository(),
        coupleRepository: CoupleRepository = CoupleRepository(),
        financialEngine: FinancialEngine = FinancialEngine()
    ) {
        self.coupleID = coupleID
        self.userID = userID
        self.goalRepository = goalRepository
        self.scenarioRepository = scenarioRepository
        self.coupleRepository = coupleRepository
        self.financialEngine = financialEngine
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

            await self?.performCalculation()
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
