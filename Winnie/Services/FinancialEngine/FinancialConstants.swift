import Foundation

/// Centralized constants for financial calculations
enum FinancialConstants {

    // MARK: - Return Rates (Annual)

    /// High-yield savings account rate (4.5%)
    static let hysaRate = Decimal(45) / Decimal(1000)

    /// Stock market real returns (after inflation) (7%)
    static let stockMarketRealReturn = Decimal(7) / Decimal(100)

    /// Stock market nominal returns (before inflation) (10%)
    static let stockMarketNominalReturn = Decimal(10) / Decimal(100)

    /// Conservative rate for short-term goals (4%)
    static let conservativeRate = Decimal(4) / Decimal(100)

    // MARK: - Inflation

    /// Default annual inflation rate (3%)
    static let defaultInflationRate = Decimal(3) / Decimal(100)

    // MARK: - Time Thresholds

    /// Months threshold for "long-term" classification (5 years)
    static let longTermThresholdMonths: Int = 60

    // MARK: - Calculation Limits

    /// Maximum months to project (prevents infinite loops) - 50 years
    static let maxProjectionMonths: Int = 600

    /// Minimum monthly contribution considered meaningful
    static let minimumContribution = Decimal(1)

    // MARK: - Compounding

    /// Standard compounding periods per year (monthly)
    static let compoundingPeriodsPerYear: Int = 12
}
