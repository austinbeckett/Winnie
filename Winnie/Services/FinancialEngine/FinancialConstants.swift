import Foundation

/// Centralized constants for financial calculations
enum FinancialConstants {

    // MARK: - Return Rates (Annual)

    /// High-yield savings account rate
    static let hysaRate: Decimal = Decimal(string: "0.045")!

    /// Stock market real returns (after inflation)
    static let stockMarketRealReturn: Decimal = Decimal(string: "0.07")!

    /// Stock market nominal returns (before inflation)
    static let stockMarketNominalReturn: Decimal = Decimal(string: "0.10")!

    /// Conservative rate for short-term goals
    static let conservativeRate: Decimal = Decimal(string: "0.04")!

    // MARK: - Inflation

    /// Default annual inflation rate
    static let defaultInflationRate: Decimal = Decimal(string: "0.03")!

    // MARK: - Time Thresholds

    /// Months threshold for "long-term" classification (5 years)
    static let longTermThresholdMonths: Int = 60

    // MARK: - Calculation Limits

    /// Maximum months to project (prevents infinite loops) - 50 years
    static let maxProjectionMonths: Int = 600

    /// Minimum monthly contribution considered meaningful
    static let minimumContribution: Decimal = Decimal(string: "1.0")!

    // MARK: - Compounding

    /// Standard compounding periods per year (monthly)
    static let compoundingPeriodsPerYear: Int = 12
}
