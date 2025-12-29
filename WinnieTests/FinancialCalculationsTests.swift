import XCTest
@testable import Winnie

final class FinancialCalculationsTests: XCTestCase {

    // MARK: - Future Value Tests

    func test_futureValue_withZeroMonths_returnsPresent() {
        let result = FinancialCalculations.futureValue(
            presentValue: Decimal(1000),
            monthlyContribution: Decimal(100),
            annualRate: Decimal(string: "0.07")!,
            months: 0
        )

        XCTAssertEqual(result, Decimal(1000))
    }

    func test_futureValue_withZeroInterest_returnsSimpleAddition() {
        let result = FinancialCalculations.futureValue(
            presentValue: Decimal(1000),
            monthlyContribution: Decimal(100),
            annualRate: Decimal(0),
            months: 12
        )

        // 1000 + (100 * 12) = 2200
        XCTAssertEqual(result, Decimal(2200))
    }

    func test_futureValue_withCompoundInterest_calculatesCorrectly() {
        // $10,000 initial, $500/month, 7% annual, 12 months
        let result = FinancialCalculations.futureValue(
            presentValue: Decimal(10000),
            monthlyContribution: Decimal(500),
            annualRate: Decimal(string: "0.07")!,
            months: 12
        )

        // Expected ~$16,900 (compound interest + contributions)
        // Verify it's in reasonable range
        XCTAssertGreaterThan(result, Decimal(16500))
        XCTAssertLessThan(result, Decimal(17500))
    }

    func test_futureValue_withNoContributions_onlyCompounds() {
        let result = FinancialCalculations.futureValue(
            presentValue: Decimal(10000),
            monthlyContribution: Decimal(0),
            annualRate: Decimal(string: "0.12")!,  // 12% annual = 1% monthly
            months: 12
        )

        // Should be roughly 10000 * (1.01)^12 ≈ 11268
        XCTAssertGreaterThan(result, Decimal(11200))
        XCTAssertLessThan(result, Decimal(11300))
    }

    // MARK: - Months to Target Tests

    func test_monthsToReachTarget_alreadyReached_returnsZero() {
        let result = FinancialCalculations.monthsToReachTarget(
            targetAmount: Decimal(5000),
            presentValue: Decimal(10000),
            monthlyContribution: Decimal(100),
            annualRate: Decimal(string: "0.05")!
        )

        XCTAssertEqual(result, 0)
    }

    func test_monthsToReachTarget_exactlyReached_returnsZero() {
        let result = FinancialCalculations.monthsToReachTarget(
            targetAmount: Decimal(5000),
            presentValue: Decimal(5000),
            monthlyContribution: Decimal(100),
            annualRate: Decimal(string: "0.05")!
        )

        XCTAssertEqual(result, 0)
    }

    func test_monthsToReachTarget_noContributionNoInterest_returnsNil() {
        let result = FinancialCalculations.monthsToReachTarget(
            targetAmount: Decimal(10000),
            presentValue: Decimal(5000),
            monthlyContribution: Decimal(0),
            annualRate: Decimal(0)
        )

        XCTAssertNil(result)
    }

    func test_monthsToReachTarget_simpleCase_calculatesCorrectly() {
        // Need $5000 more, saving $500/month with no interest
        let result = FinancialCalculations.monthsToReachTarget(
            targetAmount: Decimal(10000),
            presentValue: Decimal(5000),
            monthlyContribution: Decimal(500),
            annualRate: Decimal(0)
        )

        // Should be exactly 10 months
        XCTAssertEqual(result, 10)
    }

    func test_monthsToReachTarget_withInterest_fasterThanSimple() {
        let withoutInterest = FinancialCalculations.monthsToReachTarget(
            targetAmount: Decimal(50000),
            presentValue: Decimal(10000),
            monthlyContribution: Decimal(1000),
            annualRate: Decimal(0)
        )

        let withInterest = FinancialCalculations.monthsToReachTarget(
            targetAmount: Decimal(50000),
            presentValue: Decimal(10000),
            monthlyContribution: Decimal(1000),
            annualRate: Decimal(string: "0.07")!
        )

        XCTAssertNotNil(withoutInterest)
        XCTAssertNotNil(withInterest)
        XCTAssertLessThan(withInterest!, withoutInterest!)
    }

    // MARK: - Completion Date Tests

    func test_completionDate_zeroMonths_returnsStartDate() {
        let startDate = Date()
        let result = FinancialCalculations.completionDate(months: 0, from: startDate)

        XCTAssertEqual(result, startDate)
    }

    func test_completionDate_12Months_returnsOneYearLater() {
        let startDate = Date()
        let result = FinancialCalculations.completionDate(months: 12, from: startDate)

        let expectedDate = Calendar.current.date(byAdding: .month, value: 12, to: startDate)!
        XCTAssertEqual(result, expectedDate)
    }

    // MARK: - Inflation Adjustment Tests

    func test_inflationAdjusted_zeroYears_returnsSameAmount() {
        let result = FinancialCalculations.inflationAdjusted(
            amount: Decimal(10000),
            years: 0
        )

        XCTAssertEqual(result, Decimal(10000))
    }

    func test_inflationAdjusted_reducesValue() {
        let result = FinancialCalculations.inflationAdjusted(
            amount: Decimal(10000),
            years: 10,
            inflationRate: Decimal(string: "0.03")!
        )

        // After 10 years of 3% inflation, $10000 is worth less today
        XCTAssertLessThan(result, Decimal(10000))
        XCTAssertGreaterThan(result, Decimal(7000))  // Reasonable range
    }

    // MARK: - Required Monthly Contribution Tests

    func test_requiredMonthlyContribution_alreadyComplete_returnsZero() {
        let futureDate = Calendar.current.date(byAdding: .year, value: 2, to: Date())!

        let result = FinancialCalculations.requiredMonthlyContribution(
            targetAmount: Decimal(10000),
            presentValue: Decimal(15000),
            by: futureDate,
            annualRate: Decimal(string: "0.05")!
        )

        XCTAssertEqual(result, Decimal(0))
    }

    func test_requiredMonthlyContribution_pastDate_returnsNil() {
        let pastDate = Calendar.current.date(byAdding: .month, value: -1, to: Date())!

        let result = FinancialCalculations.requiredMonthlyContribution(
            targetAmount: Decimal(10000),
            presentValue: Decimal(5000),
            by: pastDate,
            annualRate: Decimal(string: "0.05")!
        )

        XCTAssertNil(result)
    }

    func test_requiredMonthlyContribution_validCase_returnsReasonableAmount() {
        let futureDate = Calendar.current.date(byAdding: .year, value: 2, to: Date())!

        let result = FinancialCalculations.requiredMonthlyContribution(
            targetAmount: Decimal(50000),
            presentValue: Decimal(10000),
            by: futureDate,
            annualRate: Decimal(string: "0.05")!
        )

        XCTAssertNotNil(result)
        // Need $40k in 24 months, should be roughly $1600-1700/month with 5% return
        XCTAssertGreaterThan(result!, Decimal(1500))
        XCTAssertLessThan(result!, Decimal(1800))
    }

    // MARK: - Edge Cases

    func test_futureValue_largeAmounts_handlesCorrectly() {
        let result = FinancialCalculations.futureValue(
            presentValue: Decimal(1_000_000),
            monthlyContribution: Decimal(10_000),
            annualRate: Decimal(string: "0.07")!,
            months: 120
        )

        // Should handle millions without overflow
        XCTAssertGreaterThan(result, Decimal(2_000_000))
    }

    func test_monthsToReachTarget_verySmallContribution_eventuallyReaches() {
        let result = FinancialCalculations.monthsToReachTarget(
            targetAmount: Decimal(1000),
            presentValue: Decimal(0),
            monthlyContribution: Decimal(10),
            annualRate: Decimal(string: "0.05")!
        )

        XCTAssertNotNil(result)
        XCTAssertLessThan(result!, 200)  // Should be reachable
    }
}
