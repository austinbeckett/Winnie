import Foundation

/// Pure stateless math functions for financial calculations
/// All functions use Decimal for precision (never Double for money)
enum FinancialCalculations {

    // MARK: - Core Formulas

    /// Calculate future value with compound interest and regular contributions
    ///
    /// Uses the formula:
    /// FV = PV × (1 + r)^n + PMT × [((1 + r)^n - 1) / r]
    ///
    /// - Parameters:
    ///   - presentValue: Current amount saved
    ///   - monthlyContribution: Regular monthly payment
    ///   - annualRate: Annual interest rate as decimal (e.g., 0.07 for 7%)
    ///   - months: Number of months to project
    /// - Returns: Future value as Decimal
    static func futureValue(
        presentValue: Decimal,
        monthlyContribution: Decimal,
        annualRate: Decimal,
        months: Int
    ) -> Decimal {
        guard months > 0 else { return presentValue }

        let monthlyRate = annualRate / 12

        // Handle zero interest rate case (simple addition)
        if monthlyRate == 0 {
            return presentValue + (monthlyContribution * Decimal(months))
        }

        // Calculate (1 + r)^n
        let compoundFactor = pow(1 + monthlyRate, months)

        // FV of present value with compound interest
        let fvPresentValue = presentValue * compoundFactor

        // FV of annuity (regular contributions)
        let fvAnnuity = monthlyContribution * ((compoundFactor - 1) / monthlyRate)

        return fvPresentValue + fvAnnuity
    }

    /// Calculate months needed to reach a target amount
    ///
    /// - Parameters:
    ///   - targetAmount: Goal amount to reach
    ///   - presentValue: Current amount saved
    ///   - monthlyContribution: Regular monthly payment
    ///   - annualRate: Annual interest rate as decimal
    /// - Returns: Number of months needed, or nil if unreachable within limits
    static func monthsToReachTarget(
        targetAmount: Decimal,
        presentValue: Decimal,
        monthlyContribution: Decimal,
        annualRate: Decimal
    ) -> Int? {
        // Already reached
        if presentValue >= targetAmount {
            return 0
        }

        // Cannot reach without contributions or growth
        if monthlyContribution <= 0 && annualRate <= 0 {
            return nil
        }

        let monthlyRate = annualRate / 12
        var currentValue = presentValue
        var months = 0
        let maxMonths = FinancialConstants.maxProjectionMonths

        // Iterative approach for Decimal precision
        while currentValue < targetAmount && months < maxMonths {
            // Add interest for the month
            currentValue += currentValue * monthlyRate
            // Add monthly contribution
            currentValue += monthlyContribution
            months += 1
        }

        return months < maxMonths ? months : nil
    }

    /// Calculate the completion date from a number of months
    ///
    /// - Parameters:
    ///   - months: Number of months from start date
    ///   - startDate: Starting date (defaults to now)
    /// - Returns: Projected completion date
    static func completionDate(months: Int, from startDate: Date = Date()) -> Date {
        Calendar.current.date(byAdding: .month, value: months, to: startDate) ?? startDate
    }

    /// Adjust an amount for inflation over time
    ///
    /// Converts a future nominal amount to today's purchasing power
    ///
    /// - Parameters:
    ///   - amount: Nominal future amount
    ///   - years: Years of inflation
    ///   - inflationRate: Annual inflation rate (defaults to 3%)
    /// - Returns: Inflation-adjusted amount in today's dollars
    static func inflationAdjusted(
        amount: Decimal,
        years: Int,
        inflationRate: Decimal = FinancialConstants.defaultInflationRate
    ) -> Decimal {
        guard years > 0, inflationRate > 0 else { return amount }
        let inflationFactor = pow(1 + inflationRate, years)
        return amount / inflationFactor
    }

    /// Calculate required monthly contribution to reach a goal by a target date
    ///
    /// Uses binary search for Decimal precision
    ///
    /// - Parameters:
    ///   - targetAmount: Goal amount to reach
    ///   - presentValue: Current amount saved
    ///   - targetDate: Desired completion date
    ///   - annualRate: Annual interest rate as decimal
    /// - Returns: Required monthly contribution, or nil if already complete or invalid date
    static func requiredMonthlyContribution(
        targetAmount: Decimal,
        presentValue: Decimal,
        by targetDate: Date,
        annualRate: Decimal
    ) -> Decimal? {
        // Already complete
        guard presentValue < targetAmount else { return Decimal(0) }

        let months = Calendar.current.dateComponents(
            [.month],
            from: Date(),
            to: targetDate
        ).month ?? 0

        // Target date is in the past or too soon
        guard months > 0 else { return nil }

        let monthlyRate = annualRate / 12
        let remaining = targetAmount - presentValue

        // If no interest, simple division
        if monthlyRate == 0 {
            return remaining / Decimal(months)
        }

        // Binary search for required payment
        var low: Decimal = 0
        var high: Decimal = remaining  // Upper bound (worst case: no interest)
        let tolerance: Decimal = 1      // Within $1 accuracy

        for _ in 0..<50 {  // Max iterations
            let mid = (low + high) / 2
            let projected = futureValue(
                presentValue: presentValue,
                monthlyContribution: mid,
                annualRate: annualRate,
                months: months
            )

            if abs(projected - targetAmount) < tolerance {
                return mid
            } else if projected < targetAmount {
                low = mid
            } else {
                high = mid
            }
        }

        return (low + high) / 2
    }

    // MARK: - Helper Functions

    /// Calculate power for Decimal type
    ///
    /// Note: Uses iterative multiplication for Decimal precision
    /// For very large exponents, consider optimization
    private static func pow(_ base: Decimal, _ exponent: Int) -> Decimal {
        guard exponent != 0 else { return 1 }

        if exponent < 0 {
            return 1 / pow(base, -exponent)
        }

        var result: Decimal = 1
        for _ in 0..<exponent {
            result *= base
        }
        return result
    }
}
