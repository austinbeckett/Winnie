//
//  ScenarioDetailViewModel.swift
//  Winnie
//
//  Created by Claude Code on 2026-01-08.
//

import SwiftUI

/// ViewModel for the Scenario Detail view - displays plan goals with status.
///
/// This ViewModel handles:
/// - Loading goals and financial profile
/// - Calculating projections and tracking status for each goal
/// - Adjusting target dates for behind goals
/// - Updating allocations for individual goals
///
/// ## Usage
/// ```swift
/// @State private var viewModel = ScenarioDetailViewModel(
///     scenario: scenario,
///     coupleID: "abc123",
///     userID: "user1"
/// )
/// ```
@Observable
@MainActor
final class ScenarioDetailViewModel: ErrorHandlingViewModel {

    // MARK: - Published State

    /// The scenario being viewed
    var scenario: Scenario

    /// Goals included in this scenario (goals with entries in allocations, including $0)
    var goals: [Goal] = []

    /// All goals (including those not in this plan)
    private var allGoals: [Goal] = []

    /// The financial profile containing budget info
    var financialProfile: FinancialProfile?

    /// Engine output with projections for all goals
    var engineOutput: EngineOutput?

    /// Loading state for async operations
    var isLoading: Bool = false

    /// Error message to display
    var errorMessage: String?

    /// Whether to show error alert
    var showError: Bool = false

    /// Goal being edited for allocation
    var goalToEditAllocation: Goal?

    // MARK: - Dependencies

    private let coupleID: String
    private let userID: String
    private let goalRepository: GoalRepository
    private let scenarioRepository: ScenarioRepository
    private let coupleRepository: CoupleRepository
    private let financialEngine: FinancialEngine

    // MARK: - Computed Properties

    /// Total amount allocated across all goals in this scenario
    var totalAllocated: Decimal {
        scenario.allocations.totalAllocated
    }

    /// Monthly disposable income (savings pool)
    var disposableIncome: Decimal {
        financialProfile?.monthlyDisposable ?? 0
    }

    /// Remaining budget after allocations
    var remainingBudget: Decimal {
        max(disposableIncome - totalAllocated, 0)
    }

    /// Get projection for a specific goal
    func projection(for goalID: String) -> GoalProjection? {
        engineOutput?.projection(for: goalID)
    }

    /// Calculate tracking status for a specific goal.
    /// Uses the same logic as GoalDetailViewModel.
    func trackingStatus(for goal: Goal) -> GoalTrackingStatus {
        calculateTrackingStatus(for: goal)
    }

    /// Get allocation amount for a goal in this scenario
    func allocation(for goalID: String) -> Decimal {
        scenario.allocations[goalID]
    }

    // MARK: - Initialization

    init(
        scenario: Scenario,
        coupleID: String,
        userID: String,
        goalRepository: GoalRepository? = nil,
        scenarioRepository: ScenarioRepository? = nil,
        coupleRepository: CoupleRepository? = nil,
        financialEngine: FinancialEngine? = nil
    ) {
        self.scenario = scenario
        self.coupleID = coupleID
        self.userID = userID
        self.goalRepository = goalRepository ?? GoalRepository()
        self.scenarioRepository = scenarioRepository ?? ScenarioRepository()
        self.coupleRepository = coupleRepository ?? CoupleRepository()
        self.financialEngine = financialEngine ?? FinancialEngine()
    }

    // MARK: - Data Loading

    /// Load goals and financial profile.
    func loadData() async {
        isLoading = true
        errorMessage = nil

        do {
            // Load goals and profile in parallel
            async let goalsTask = goalRepository.fetchAllGoals(coupleID: coupleID)
            async let profileTask = coupleRepository.fetchFinancialProfile(coupleID: coupleID)

            let (loadedGoals, loadedProfile) = try await (goalsTask, profileTask)

            allGoals = loadedGoals.filter { $0.isActive }
            financialProfile = loadedProfile

            // Filter to goals included in this scenario (any entry in allocations, including $0)
            goals = allGoals.filter { scenario.allocations.goalIDs.contains($0.id) }

            // Calculate projections
            recalculate()

        } catch {
            handleError(error, context: "loading data")
        }

        isLoading = false
    }

    /// Reload scenario data (after edit)
    func reloadScenario() async {
        do {
            let updated = try await scenarioRepository.fetchScenario(id: scenario.id, coupleID: coupleID)
            scenario = updated
            // Recalculate goals in plan after reload
            goals = allGoals.filter { scenario.allocations.goalIDs.contains($0.id) }
            recalculate()
        } catch {
            handleError(error, context: "reloading scenario")
        }
    }

    // MARK: - Projections

    /// Recalculate projections based on current allocations.
    private func recalculate() {
        guard let profile = financialProfile else { return }

        let input = EngineInput(
            profile: profile,
            goals: allGoals,
            allocations: scenario.allocations
        )

        engineOutput = financialEngine.calculate(input: input)
    }

    // MARK: - Status Calculation

    /// Calculate tracking status for a goal (same logic as GoalDetailViewModel).
    private func calculateTrackingStatus(for goal: Goal) -> GoalTrackingStatus {
        // 1. Check if goal is completed
        if goal.currentAmount >= goal.targetAmount {
            return .completed
        }

        // 2. Check if there's a target date
        guard let targetDate = goal.desiredDate else {
            return .noTargetDate(projectedDate: projection(for: goal.id)?.completionDate)
        }

        // 3. Check if goal has a projection with allocation
        guard let projection = projection(for: goal.id),
              projection.monthlyContribution > 0 else {
            return .notInPlan(targetDate: targetDate)
        }

        // 4. Check if projection is reachable
        guard let projectedDate = projection.completionDate else {
            let required = financialEngine.requiredMonthlyContribution(for: goal, by: targetDate)
            return .behind(
                GoalTrackingStatus.TrackingDetails(
                    projectedDate: Date.distantFuture,
                    targetDate: targetDate,
                    monthsDifference: -999,
                    currentContribution: projection.monthlyContribution
                ),
                requiredContribution: required ?? 0
            )
        }

        // 5. Calculate months difference
        let calendar = Calendar.current
        let monthsDiff = calendar.dateComponents([.month], from: projectedDate, to: targetDate).month ?? 0

        let details = GoalTrackingStatus.TrackingDetails(
            projectedDate: projectedDate,
            targetDate: targetDate,
            monthsDifference: monthsDiff,
            currentContribution: projection.monthlyContribution
        )

        // 6. Determine if on track or behind (compare at month granularity)
        let projectedComponents = calendar.dateComponents([.year, .month], from: projectedDate)
        let targetComponents = calendar.dateComponents([.year, .month], from: targetDate)

        let projectedMonths = (projectedComponents.year ?? 0) * 12 + (projectedComponents.month ?? 0)
        let targetMonths = (targetComponents.year ?? 0) * 12 + (targetComponents.month ?? 0)

        if projectedMonths <= targetMonths {
            return .onTrack(details)
        } else {
            let required = financialEngine.requiredMonthlyContribution(for: goal, by: targetDate)
            return .behind(details, requiredContribution: required ?? 0)
        }
    }

    // MARK: - Actions

    /// Adjust a goal's target date to match its projected completion date.
    func adjustTargetDate(for goal: Goal) async {
        let status = trackingStatus(for: goal)
        guard case .behind(let details, _) = status else { return }

        isLoading = true

        // Set target to END of the projected month for margin of safety
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: details.projectedDate)

        var updatedGoal = goal
        if let startOfMonth = calendar.date(from: components),
           let endOfMonth = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: startOfMonth) {
            updatedGoal.desiredDate = endOfMonth
        } else {
            updatedGoal.desiredDate = details.projectedDate
        }

        do {
            try await goalRepository.updateGoal(updatedGoal, coupleID: coupleID)

            // Update local goal array
            if let index = goals.firstIndex(where: { $0.id == goal.id }) {
                goals[index] = updatedGoal
            }
            if let index = allGoals.firstIndex(where: { $0.id == goal.id }) {
                allGoals[index] = updatedGoal
            }

            recalculate()
        } catch {
            handleError(error, context: "adjusting target date")
        }

        isLoading = false
    }

    /// Update allocation for a specific goal in this scenario.
    func updateAllocation(for goalID: String, amount: Decimal) async {
        isLoading = true

        var updatedScenario = scenario
        updatedScenario.allocations[goalID] = amount
        updatedScenario.lastModified = Date()

        do {
            try await scenarioRepository.updateScenario(updatedScenario, coupleID: coupleID)
            scenario = updatedScenario

            // Update goals list based on allocations dictionary entries
            goals = allGoals.filter { scenario.allocations.goalIDs.contains($0.id) }

            recalculate()
        } catch {
            handleError(error, context: "updating allocation")
        }

        isLoading = false
    }

    /// Get the maximum allocation for a goal (remaining budget + current allocation)
    func maxAllocation(for goalID: String) -> Decimal {
        let currentAllocation = scenario.allocations[goalID]
        let availableBudget = disposableIncome - totalAllocated + currentAllocation
        return max(availableBudget, currentAllocation)
    }
}
