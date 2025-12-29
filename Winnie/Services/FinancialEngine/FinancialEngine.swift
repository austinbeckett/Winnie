import Foundation

// MARK: - Engine Types

/// Projection result for a single goal
struct GoalProjection: Equatable {
    /// The goal ID this projection is for
    let goalID: String

    /// Months needed to reach the goal (nil if unreachable)
    let monthsToComplete: Int?

    /// Projected completion date (nil if unreachable)
    let completionDate: Date?

    /// Projected final value at completion or max projection
    let projectedFinalValue: Decimal

    /// Monthly contribution allocated to this goal
    let monthlyContribution: Decimal

    /// Whether the goal can be reached within projection limits
    let isReachable: Bool

    /// Human-readable time to completion
    var timeToCompletionText: String {
        guard let months = monthsToComplete else {
            return "50+ years"
        }

        if months == 0 {
            return "Complete!"
        }

        let years = months / 12
        let remainingMonths = months % 12

        if years == 0 {
            return "\(remainingMonths) month\(remainingMonths == 1 ? "" : "s")"
        } else if remainingMonths == 0 {
            return "\(years) year\(years == 1 ? "" : "s")"
        } else {
            return "\(years)y \(remainingMonths)m"
        }
    }
}

/// Input container for engine calculations
struct EngineInput {
    let profile: FinancialProfile
    let goals: [Goal]
    let allocations: Allocation

    init(profile: FinancialProfile, goals: [Goal], allocations: Allocation) {
        self.profile = profile
        self.goals = goals
        self.allocations = allocations
    }
}

/// Output container from engine calculations
struct EngineOutput: Equatable {
    /// Projections keyed by goal ID
    let projections: [String: GoalProjection]

    /// Total amount allocated across all goals
    let totalAllocated: Decimal

    /// Remaining disposable income after allocations
    let remainingDisposable: Decimal

    /// Warnings generated during calculation
    let warnings: [EngineWarning]

    /// Timestamp of calculation
    let calculatedAt: Date

    /// Whether any warnings were generated
    var hasWarnings: Bool {
        !warnings.isEmpty
    }

    /// Get projection for a specific goal
    func projection(for goalID: String) -> GoalProjection? {
        projections[goalID]
    }

    /// Get all projections sorted by completion date (soonest first)
    var projectionsByCompletionDate: [GoalProjection] {
        projections.values.sorted { lhs, rhs in
            switch (lhs.completionDate, rhs.completionDate) {
            case (nil, nil): return false
            case (nil, _): return false
            case (_, nil): return true
            case let (lhsDate?, rhsDate?): return lhsDate < rhsDate
            }
        }
    }
}

/// Warnings generated during calculation
enum EngineWarning: Equatable {
    /// Total allocations exceed disposable income
    case overAllocated(excess: Decimal)

    /// Goal cannot be reached within projection limits
    case goalUnreachable(goalID: String, goalName: String)

    /// Goal has no monthly contribution assigned
    case noContributionForGoal(goalID: String, goalName: String)

    /// Disposable income is negative (expenses > income)
    case negativeDisposable

    var message: String {
        switch self {
        case .overAllocated(let excess):
            return "Over-allocated by $\(excess)"
        case .goalUnreachable(_, let name):
            return "\(name) may take over 50 years to reach"
        case .noContributionForGoal(_, let name):
            return "No monthly contribution set for \(name)"
        case .negativeDisposable:
            return "Expenses exceed income"
        }
    }

    var isBlocker: Bool {
        switch self {
        case .overAllocated, .negativeDisposable: return true
        default: return false
        }
    }
}

// MARK: - Financial Engine

/// The core financial calculation engine
/// Runs client-side for instant feedback, pure Swift with no UI dependencies
struct FinancialEngine {

    // MARK: - Configuration

    /// Inflation rate for long-term projections
    var inflationRate: Decimal

    /// Whether to adjust target amounts for inflation
    var adjustForInflation: Bool

    // MARK: - Initializer

    init(
        inflationRate: Decimal = FinancialConstants.defaultInflationRate,
        adjustForInflation: Bool = false
    ) {
        self.inflationRate = inflationRate
        self.adjustForInflation = adjustForInflation
    }

    // MARK: - Main Calculation Method

    /// Calculate projections for all goals given allocations
    ///
    /// - Parameter input: Engine input containing profile, goals, and allocations
    /// - Returns: Engine output with projections and warnings
    func calculate(input: EngineInput) -> EngineOutput {
        var projections: [String: GoalProjection] = [:]
        var warnings: [EngineWarning] = []

        let totalAllocated = input.allocations.totalAllocated
        let disposable = input.profile.monthlyDisposable

        // Check for negative disposable income
        if input.profile.monthlyIncome < input.profile.monthlyExpenses {
            warnings.append(.negativeDisposable)
        }

        // Check for over-allocation
        if totalAllocated > disposable {
            warnings.append(.overAllocated(excess: totalAllocated - disposable))
        }

        // Calculate projection for each active goal
        for goal in input.goals where goal.isActive {
            let monthlyContribution = input.allocations.amount(for: goal.id)

            // Warn if no contribution assigned
            if monthlyContribution <= 0 {
                warnings.append(.noContributionForGoal(goalID: goal.id, goalName: goal.name))
            }

            let projection = calculateGoalProjection(
                goal: goal,
                monthlyContribution: monthlyContribution
            )

            projections[goal.id] = projection

            // Warn if goal is unreachable
            if !projection.isReachable {
                warnings.append(.goalUnreachable(goalID: goal.id, goalName: goal.name))
            }
        }

        return EngineOutput(
            projections: projections,
            totalAllocated: totalAllocated,
            remainingDisposable: max(disposable - totalAllocated, 0),
            warnings: warnings,
            calculatedAt: Date()
        )
    }

    // MARK: - Single Goal Projection

    /// Calculate projection for a single goal
    ///
    /// - Parameters:
    ///   - goal: The goal to project
    ///   - monthlyContribution: Monthly amount allocated
    /// - Returns: Goal projection result
    func calculateGoalProjection(
        goal: Goal,
        monthlyContribution: Decimal
    ) -> GoalProjection {
        let annualRate = goal.effectiveReturnRate
        let targetAmount = goal.targetAmount
        let currentAmount = goal.currentAmount

        // Already completed
        if currentAmount >= targetAmount {
            return GoalProjection(
                goalID: goal.id,
                monthsToComplete: 0,
                completionDate: Date(),
                projectedFinalValue: currentAmount,
                monthlyContribution: monthlyContribution,
                isReachable: true
            )
        }

        // Calculate months to reach target
        let months = FinancialCalculations.monthsToReachTarget(
            targetAmount: targetAmount,
            presentValue: currentAmount,
            monthlyContribution: monthlyContribution,
            annualRate: annualRate
        )

        // Calculate projected final value
        let projectedValue: Decimal
        if months != nil {
            projectedValue = targetAmount
        } else {
            // Show value after max projection period for unreachable goals
            projectedValue = FinancialCalculations.futureValue(
                presentValue: currentAmount,
                monthlyContribution: monthlyContribution,
                annualRate: annualRate,
                months: FinancialConstants.maxProjectionMonths
            )
        }

        let completionDate = months.map {
            FinancialCalculations.completionDate(months: $0)
        }

        return GoalProjection(
            goalID: goal.id,
            monthsToComplete: months,
            completionDate: completionDate,
            projectedFinalValue: projectedValue,
            monthlyContribution: monthlyContribution,
            isReachable: months != nil
        )
    }

    // MARK: - Utility Methods

    /// Calculate what monthly contribution is needed to reach goal by date
    ///
    /// - Parameters:
    ///   - goal: The goal
    ///   - targetDate: Desired completion date
    /// - Returns: Required monthly contribution, or nil if already complete
    func requiredMonthlyContribution(
        for goal: Goal,
        by targetDate: Date
    ) -> Decimal? {
        FinancialCalculations.requiredMonthlyContribution(
            targetAmount: goal.targetAmount,
            presentValue: goal.currentAmount,
            by: targetDate,
            annualRate: goal.effectiveReturnRate
        )
    }

    /// Compare two scenarios side-by-side
    ///
    /// - Parameters:
    ///   - scenarioA: First scenario
    ///   - scenarioB: Second scenario
    ///   - profile: Financial profile
    ///   - goals: List of goals
    /// - Returns: Tuple of outputs for comparison
    func compareScenarios(
        _ scenarioA: Scenario,
        _ scenarioB: Scenario,
        profile: FinancialProfile,
        goals: [Goal]
    ) -> (outputA: EngineOutput, outputB: EngineOutput) {
        let inputA = EngineInput(
            profile: profile,
            goals: goals,
            allocations: scenarioA.allocations
        )
        let inputB = EngineInput(
            profile: profile,
            goals: goals,
            allocations: scenarioB.allocations
        )

        return (calculate(input: inputA), calculate(input: inputB))
    }

    /// Calculate impact of changing one goal's allocation
    ///
    /// - Parameters:
    ///   - goalID: Goal to modify
    ///   - newAmount: New monthly contribution
    ///   - input: Current engine input
    /// - Returns: Updated engine output
    func simulateAllocationChange(
        goalID: String,
        newAmount: Decimal,
        input: EngineInput
    ) -> EngineOutput {
        var modifiedAllocations = input.allocations
        modifiedAllocations[goalID] = newAmount

        let modifiedInput = EngineInput(
            profile: input.profile,
            goals: input.goals,
            allocations: modifiedAllocations
        )

        return calculate(input: modifiedInput)
    }
}
