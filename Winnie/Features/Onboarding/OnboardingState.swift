import Foundation

/// Observable state container for the onboarding wizard flow.
///
/// Manages all user inputs across the wizard steps and provides computed
/// properties for real-time projections. Data is persisted to `FinancialProfile`
/// and `Goal` on completion.
@Observable
@MainActor
final class OnboardingState {

    // MARK: - Step 0.2: Goal Selection

    /// The user's selected primary goal type
    var selectedGoalType: GoalType?

    // MARK: - Step 2: Income

    /// User's monthly take-home pay
    var monthlyIncome: Decimal = 0

    // MARK: - Step 3: Needs (Fixed Bills)

    /// Monthly fixed expenses (rent, loans, utilities, etc.)
    var monthlyNeeds: Decimal = 0

    // MARK: - Step 4: Wants (Discretionary)

    /// Monthly discretionary spending (entertainment, dining, etc.)
    var monthlyWants: Decimal = 0

    // MARK: - Step 5: Savings Question

    /// Whether the user knows their monthly savings amount (true = skip Needs/Wants)
    var knowsSavingsAmount: Bool = false

    /// Direct savings pool input (used when knowsSavingsAmount is true)
    var directSavingsPool: Decimal = 0

    // MARK: - Step 6: Starting Balance

    /// Current liquid savings balance
    var startingBalance: Decimal = 0

    // MARK: - Step 5/6: Goal Details

    /// Target amount for the primary goal
    var goalTargetAmount: Decimal = 0

    /// Desired completion date for the goal
    var goalDesiredDate: Date?

    /// Custom goal name (optional override)
    var goalName: String?

    // MARK: - Computed Properties

    /// The "Savings Pool" - monthly amount available for goals
    var savingsPool: Decimal {
        if knowsSavingsAmount {
            return directSavingsPool
        }
        return max(monthlyIncome - monthlyNeeds - monthlyWants, 0)
    }

    /// Whether the user has positive savings pool
    var hasSavingsPool: Bool {
        savingsPool > 0
    }

    /// Projected months to reach the goal (simple linear projection)
    var projectedMonthsToGoal: Int? {
        guard savingsPool > 0, goalTargetAmount > startingBalance else { return nil }

        let remaining = goalTargetAmount - startingBalance
        let months = remaining / savingsPool

        // Round up to nearest month
        return Int(NSDecimalNumber(decimal: months).doubleValue.rounded(.up))
    }

    /// Projected completion date based on current savings rate
    var projectedDate: Date? {
        guard let months = projectedMonthsToGoal else { return nil }
        return Calendar.current.date(byAdding: .month, value: months, to: Date())
    }

    /// Formatted projected date string (e.g., "March 2026")
    var projectedDateFormatted: String? {
        guard let date = projectedDate else { return nil }
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: date)
    }

    /// Percentage of income going to needs
    var needsPercentage: Double {
        guard monthlyIncome > 0 else { return 0 }
        return NSDecimalNumber(decimal: monthlyNeeds / monthlyIncome).doubleValue * 100
    }

    /// Percentage of income going to wants
    var wantsPercentage: Double {
        guard monthlyIncome > 0 else { return 0 }
        return NSDecimalNumber(decimal: monthlyWants / monthlyIncome).doubleValue * 100
    }

    /// Percentage of income going to savings pool
    var savingsPercentage: Double {
        guard monthlyIncome > 0 else { return 0 }
        return NSDecimalNumber(decimal: savingsPool / monthlyIncome).doubleValue * 100
    }

    // MARK: - Validation

    /// Whether income step is valid
    var isIncomeValid: Bool {
        monthlyIncome > 0
    }

    /// Whether needs step is valid
    var isNeedsValid: Bool {
        monthlyNeeds >= 0
    }

    /// Whether wants step is valid
    var isWantsValid: Bool {
        monthlyWants >= 0
    }

    /// Whether goal details are valid
    var isGoalValid: Bool {
        goalTargetAmount > 0 && selectedGoalType != nil
    }

    /// Whether all required onboarding data is complete
    var isComplete: Bool {
        selectedGoalType != nil &&
        monthlyIncome > 0 &&
        goalTargetAmount > 0
    }

    // MARK: - Conversion Methods

    /// Create a FinancialProfile from the current onboarding state
    func toFinancialProfile() -> FinancialProfile {
        FinancialProfile(
            monthlyIncome: monthlyIncome,
            monthlyNeeds: monthlyNeeds,
            monthlyWants: monthlyWants,
            currentSavings: startingBalance
        )
    }

    /// Create a Goal from the current onboarding state
    func toGoal() -> Goal? {
        guard let type = selectedGoalType else { return nil }

        return Goal(
            type: type,
            name: goalName ?? type.displayName,
            targetAmount: goalTargetAmount,
            currentAmount: 0,
            desiredDate: goalDesiredDate,
            priority: 1
        )
    }
}
