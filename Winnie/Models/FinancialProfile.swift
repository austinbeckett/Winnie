import Foundation

/// Shared financial baseline for a couple
/// Contains income, expenses, and assets that form the basis for all calculations
struct FinancialProfile: Codable, Equatable {

    /// Combined monthly take-home income (after taxes)
    var monthlyIncome: Decimal

    /// Total monthly fixed expenses (rent, utilities, subscriptions, etc.)
    var monthlyExpenses: Decimal

    /// Current liquid savings balance
    var currentSavings: Decimal

    /// Current retirement account balance (401k, IRA, etc.)
    var retirementBalance: Decimal?

    /// Timestamp of last update
    var lastUpdated: Date

    // MARK: - Computed Properties

    /// Available monthly amount for goal allocation (income minus expenses)
    var monthlyDisposable: Decimal {
        max(monthlyIncome - monthlyExpenses, 0)
    }

    /// Whether the profile has valid, non-negative values
    var isValid: Bool {
        monthlyIncome >= 0 && monthlyExpenses >= 0 && currentSavings >= 0
    }

    /// Whether there's positive disposable income
    var hasDisposableIncome: Bool {
        monthlyDisposable > 0
    }

    // MARK: - Initializer

    init(
        monthlyIncome: Decimal = 0,
        monthlyExpenses: Decimal = 0,
        currentSavings: Decimal = 0,
        retirementBalance: Decimal? = nil,
        lastUpdated: Date = Date()
    ) {
        self.monthlyIncome = monthlyIncome
        self.monthlyExpenses = monthlyExpenses
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
        monthlyExpenses: Decimal(6000),
        currentSavings: Decimal(25000),
        retirementBalance: Decimal(50000)
    )

    /// Empty profile for new users
    static let empty = FinancialProfile()
}
