import XCTest
import FirebaseFirestore
@testable import Winnie

/// Comprehensive unit tests for FinancialProfileDTO
/// Tests Decimal/Double precision, domain model conversion, and financial data integrity
final class FinancialProfileDTOTests: XCTestCase {

    // MARK: - Test Data

    private let testDate = Date(timeIntervalSince1970: 1704067200) // 2024-01-01 00:00:00 UTC

    // MARK: - Initialization from Domain Model Tests

    func testInitFromProfileCopiesAllFields() {
        let profile = FinancialProfile(
            monthlyIncome: Decimal(10000),
            monthlyExpenses: Decimal(6000),
            currentSavings: Decimal(25000),
            retirementBalance: Decimal(50000),
            lastUpdated: testDate
        )

        let dto = FinancialProfileDTO(from: profile)

        XCTAssertEqual(dto.monthlyIncome, 10000, accuracy: 0.01)
        XCTAssertEqual(dto.monthlyExpenses, 6000, accuracy: 0.01)
        XCTAssertEqual(dto.currentSavings, 25000, accuracy: 0.01)
        XCTAssertEqual(dto.retirementBalance ?? 0, 50000, accuracy: 0.01)
        XCTAssertEqual(dto.lastUpdated, testDate)
    }

    func testInitFromProfileConvertsDecimalToDouble() {
        let profile = FinancialProfile(
            monthlyIncome: Decimal(string: "8765.43")!,
            monthlyExpenses: Decimal(string: "5432.10")!,
            currentSavings: Decimal(string: "12345.67")!
        )

        let dto = FinancialProfileDTO(from: profile)

        XCTAssertEqual(dto.monthlyIncome, 8765.43, accuracy: 0.01)
        XCTAssertEqual(dto.monthlyExpenses, 5432.10, accuracy: 0.01)
        XCTAssertEqual(dto.currentSavings, 12345.67, accuracy: 0.01)
    }

    func testInitFromProfileWithNilRetirementBalance() {
        let profile = FinancialProfile(
            monthlyIncome: 5000,
            retirementBalance: nil
        )

        let dto = FinancialProfileDTO(from: profile)

        XCTAssertNil(dto.retirementBalance)
    }

    // MARK: - Empty Profile Initialization Tests

    func testEmptyInitializerCreatesZeroValues() {
        let dto = FinancialProfileDTO()

        XCTAssertEqual(dto.monthlyIncome, 0)
        XCTAssertEqual(dto.monthlyExpenses, 0)
        XCTAssertEqual(dto.currentSavings, 0)
        XCTAssertNil(dto.retirementBalance)
    }

    func testEmptyInitializerSetsLastUpdated() {
        let beforeInit = Date()

        let dto = FinancialProfileDTO()

        XCTAssertGreaterThanOrEqual(dto.lastUpdated, beforeInit)
    }

    // MARK: - Decimal Precision Tests

    func testDecimalPrecisionRoundTrip() {
        let preciseAmounts: [(Decimal, String)] = [
            (Decimal(string: "10000.50")!, "income with cents"),
            (Decimal(string: "6543.21")!, "expenses with cents"),
            (Decimal(string: "0.01")!, "minimum amount"),
            (Decimal(string: "999999.99")!, "large amount")
        ]

        for (amount, description) in preciseAmounts {
            let profile = FinancialProfile(monthlyIncome: amount)
            let dto = FinancialProfileDTO(from: profile)
            let converted = dto.toFinancialProfile()

            let originalDouble = NSDecimalNumber(decimal: amount).doubleValue
            let convertedDouble = NSDecimalNumber(decimal: converted.monthlyIncome).doubleValue

            XCTAssertEqual(
                convertedDouble,
                originalDouble,
                accuracy: 0.01,
                "\(description) should round-trip with acceptable precision"
            )
        }
    }

    func testRetirementBalancePrecision() {
        // Test with typical retirement account balances
        let largeBalance = Decimal(string: "1500000.00")!
        let profile = FinancialProfile(retirementBalance: largeBalance)
        let dto = FinancialProfileDTO(from: profile)

        XCTAssertEqual(dto.retirementBalance ?? 0, 1500000.00, accuracy: 1.0)
    }

    // MARK: - Conversion to Domain Model Tests

    func testToFinancialProfileConvertsAllFields() {
        let profile = FinancialProfile(
            monthlyIncome: 10000,
            monthlyExpenses: 6000,
            currentSavings: 25000,
            retirementBalance: 50000,
            lastUpdated: testDate
        )
        let dto = FinancialProfileDTO(from: profile)

        let converted = dto.toFinancialProfile()

        // Compare with precision tolerance
        XCTAssertEqual(
            NSDecimalNumber(decimal: converted.monthlyIncome).doubleValue,
            10000,
            accuracy: 0.01
        )
        XCTAssertEqual(
            NSDecimalNumber(decimal: converted.monthlyExpenses).doubleValue,
            6000,
            accuracy: 0.01
        )
        XCTAssertEqual(
            NSDecimalNumber(decimal: converted.currentSavings).doubleValue,
            25000,
            accuracy: 0.01
        )
    }

    func testToFinancialProfileRoundTrip() {
        let original = FinancialProfile(
            monthlyIncome: Decimal(string: "12500.75")!,
            monthlyExpenses: Decimal(string: "7500.50")!,
            currentSavings: Decimal(string: "35000.00")!,
            retirementBalance: Decimal(string: "150000.00")!,
            lastUpdated: testDate
        )

        let dto = FinancialProfileDTO(from: original)
        let converted = dto.toFinancialProfile()

        // All fields should round-trip within precision tolerance
        XCTAssertEqual(
            NSDecimalNumber(decimal: converted.monthlyIncome).doubleValue,
            NSDecimalNumber(decimal: original.monthlyIncome).doubleValue,
            accuracy: 0.01
        )
        XCTAssertEqual(converted.lastUpdated, original.lastUpdated)
    }

    func testToFinancialProfileHandlesNilRetirement() {
        let dto = FinancialProfileDTO()
        let converted = dto.toFinancialProfile()

        XCTAssertNil(converted.retirementBalance)
    }

    // MARK: - Dictionary Serialization Tests

    func testDictionaryContainsRequiredFields() {
        let dto = FinancialProfileDTO()
        let dict = dto.dictionary

        XCTAssertNotNil(dict["monthlyIncome"])
        XCTAssertNotNil(dict["monthlyExpenses"])
        XCTAssertNotNil(dict["currentSavings"])
        XCTAssertNotNil(dict["lastUpdated"])
    }

    func testDictionaryExcludesNilRetirementBalance() {
        let profile = FinancialProfile(retirementBalance: nil)
        let dto = FinancialProfileDTO(from: profile)
        let dict = dto.dictionary

        XCTAssertNil(dict["retirementBalance"], "nil retirementBalance should not appear")
    }

    func testDictionaryIncludesRetirementBalanceWhenPresent() {
        let profile = FinancialProfile(retirementBalance: 100000)
        let dto = FinancialProfileDTO(from: profile)
        let dict = dto.dictionary

        XCTAssertEqual(dict["retirementBalance"] as? Double ?? 0, 100000, accuracy: 0.01)
    }

    func testDictionaryUsesFirestoreTimestamps() {
        let dto = FinancialProfileDTO()
        let dict = dto.dictionary

        XCTAssertTrue(dict["lastUpdated"] is Timestamp, "lastUpdated should be Firestore Timestamp")
    }

    func testDictionaryStoresDoubleValues() {
        let profile = FinancialProfile(
            monthlyIncome: 10000,
            monthlyExpenses: 6000,
            currentSavings: 25000
        )
        let dto = FinancialProfileDTO(from: profile)
        let dict = dto.dictionary

        // Verify values are stored as Double (not Decimal)
        XCTAssertTrue(dict["monthlyIncome"] is Double, "monthlyIncome should be Double")
        XCTAssertTrue(dict["monthlyExpenses"] is Double, "monthlyExpenses should be Double")
        XCTAssertTrue(dict["currentSavings"] is Double, "currentSavings should be Double")
    }

    // MARK: - Codable Conformance Tests

    @MainActor
    func testCodableRoundTrip() throws {
        let profile = FinancialProfile(
            monthlyIncome: 10000,
            monthlyExpenses: 6000,
            currentSavings: 25000
        )
        let originalDTO = FinancialProfileDTO(from: profile)

        let encoder = JSONEncoder()
        let data = try encoder.encode(originalDTO)

        let decoder = JSONDecoder()
        let decodedDTO = try decoder.decode(FinancialProfileDTO.self, from: data)

        XCTAssertEqual(decodedDTO.monthlyIncome, originalDTO.monthlyIncome, accuracy: 0.01)
        XCTAssertEqual(decodedDTO.monthlyExpenses, originalDTO.monthlyExpenses, accuracy: 0.01)
        XCTAssertEqual(decodedDTO.currentSavings, originalDTO.currentSavings, accuracy: 0.01)
    }

    // MARK: - Edge Cases

    func testZeroValues() {
        let profile = FinancialProfile(
            monthlyIncome: 0,
            monthlyExpenses: 0,
            currentSavings: 0
        )
        let dto = FinancialProfileDTO(from: profile)

        XCTAssertEqual(dto.monthlyIncome, 0)
        XCTAssertEqual(dto.monthlyExpenses, 0)
        XCTAssertEqual(dto.currentSavings, 0)
    }

    func testVeryLargeValues() {
        // Test with values exceeding typical use cases
        let profile = FinancialProfile(
            monthlyIncome: Decimal(string: "9999999.99")!,
            retirementBalance: Decimal(string: "50000000.00")!
        )
        let dto = FinancialProfileDTO(from: profile)

        XCTAssertEqual(dto.monthlyIncome, 9999999.99, accuracy: 1.0)
        XCTAssertEqual(dto.retirementBalance ?? 0, 50000000.00, accuracy: 1.0)
    }

    func testFinancialCalculationsAfterConversion() {
        // Ensure converted profile can still perform calculations correctly
        let original = FinancialProfile(
            monthlyIncome: 10000,
            monthlyExpenses: 6000
        )

        let dto = FinancialProfileDTO(from: original)
        let converted = dto.toFinancialProfile()

        // monthlyDisposable should work correctly
        let disposable = converted.monthlyDisposable
        let expectedDisposable = Decimal(4000)

        XCTAssertEqual(
            NSDecimalNumber(decimal: disposable).doubleValue,
            NSDecimalNumber(decimal: expectedDisposable).doubleValue,
            accuracy: 1.0,
            "Disposable income calculation should still work after conversion"
        )
    }
}
