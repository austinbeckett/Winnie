import Foundation

/// Shared financial baseline for a couple
/// Contains income, expenses, and assets that form the basis for all calculations
struct FinancialProfile: Codable, Equatable {

    /// Combined monthly take-home income (after taxes)
    var monthlyIncome: Decimal

    /// Monthly fixed expenses (rent, loans, utilities, etc.) - "Needs"
    var monthlyNeeds: Decimal

    /// Monthly discretionary spending (entertainment, dining, etc.) - "Wants"
    var monthlyWants: Decimal

    /// Current liquid savings balance (the "Nest Egg")
    var currentSavings: Decimal

    /// Current retirement account balance (401k, IRA, etc.)
    var retirementBalance: Decimal?

    /// Direct savings pool entry (used when user skips income/expense breakdown)
    /// When set, this takes precedence over the calculated savingsPool
    var directSavingsPool: Decimal?

    /// Timestamp of last update
    var lastUpdated: Date

    // MARK: - Computed Properties

    /// Total monthly expenses (needs + wants) - backwards compatible
    var monthlyExpenses: Decimal {
        monthlyNeeds + monthlyWants
    }

    /// The "Savings Pool" - money available for goals after needs and wants
    var savingsPool: Decimal {
        // If user entered savings directly, use that
        if let direct = directSavingsPool, direct > 0 {
            return direct
        }
        // Otherwise calculate from income - needs - wants
        return max(monthlyIncome - monthlyNeeds - monthlyWants, 0)
    }

    /// Available monthly amount for goal allocation (alias for savingsPool)
    var monthlyDisposable: Decimal {
        savingsPool
    }

    /// Whether the profile has valid, non-negative values
    var isValid: Bool {
        monthlyIncome >= 0 && monthlyNeeds >= 0 && monthlyWants >= 0 && currentSavings >= 0
    }

    /// Whether there's positive disposable income
    var hasDisposableIncome: Bool {
        savingsPool > 0
    }

    // MARK: - Initializer

    init(
        monthlyIncome: Decimal = 0,
        monthlyNeeds: Decimal = 0,
        monthlyWants: Decimal = 0,
        currentSavings: Decimal = 0,
        retirementBalance: Decimal? = nil,
        directSavingsPool: Decimal? = nil,
        lastUpdated: Date = Date()
    ) {
        self.monthlyIncome = monthlyIncome
        self.monthlyNeeds = monthlyNeeds
        self.monthlyWants = monthlyWants
        self.currentSavings = currentSavings
        self.retirementBalance = retirementBalance
        self.directSavingsPool = directSavingsPool
        self.lastUpdated = lastUpdated
    }

    /// Convenience initializer for backwards compatibility
    init(
        monthlyIncome: Decimal,
        monthlyExpenses: Decimal,
        currentSavings: Decimal,
        retirementBalance: Decimal? = nil,
        lastUpdated: Date = Date()
    ) {
        self.monthlyIncome = monthlyIncome
        // Split legacy expenses 70/30 between needs/wants as default
        self.monthlyNeeds = monthlyExpenses * Decimal(string: "0.7")!
        self.monthlyWants = monthlyExpenses * Decimal(string: "0.3")!
        self.currentSavings = currentSavings
        self.retirementBalance = retirementBalance
        self.lastUpdated = lastUpdated
    }
}

// MARK: - Sample Data

extension FinancialProfile {

    /// Sample profile for previews and testing
    static let sample = FinancialProfile(
        monthlyIncome: Decimal(10000),
        monthlyNeeds: Decimal(4000),
        monthlyWants: Decimal(2000),
        currentSavings: Decimal(25000),
        retirementBalance: Decimal(50000)
    )

    /// Empty profile for new users
    static let empty = FinancialProfile()
}
