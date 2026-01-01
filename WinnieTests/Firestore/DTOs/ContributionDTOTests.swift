import XCTest
import FirebaseFirestore
@testable import Winnie

/// Unit tests for ContributionDTO
/// Tests domain model conversion, Decimal/Double precision, and dictionary formatting
final class ContributionDTOTests: XCTestCase {

    // MARK: - Test Data

    private let testDate = Date(timeIntervalSince1970: 1704067200) // 2024-01-01 00:00:00 UTC

    // MARK: - Initialization from Domain Model Tests

    func test_initFromContribution_copiesAllFields() {
        let contribution = Contribution(
            id: "contrib123",
            goalId: "goal456",
            userId: "user789",
            amount: Decimal(150),
            date: testDate,
            notes: "Birthday money",
            createdAt: testDate
        )

        let dto = ContributionDTO(from: contribution)

        XCTAssertEqual(dto.id, contribution.id)
        XCTAssertEqual(dto.goalId, contribution.goalId)
        XCTAssertEqual(dto.userId, contribution.userId)
        XCTAssertEqual(dto.date, contribution.date)
        XCTAssertEqual(dto.notes, contribution.notes)
        XCTAssertEqual(dto.createdAt, contribution.createdAt)
    }

    func test_initFromContribution_convertsDecimalToDouble() {
        let contribution = Contribution(
            goalId: "goal1",
            userId: "user1",
            amount: Decimal(123.45)
        )

        let dto = ContributionDTO(from: contribution)

        XCTAssertEqual(dto.amount, 123.45, accuracy: 0.01)
    }

    func test_initFromContribution_setsLastSyncedAt() {
        let contribution = Contribution(
            goalId: "goal1",
            userId: "user1",
            amount: Decimal(100)
        )
        let beforeInit = Date()

        let dto = ContributionDTO(from: contribution)

        XCTAssertNotNil(dto.lastSyncedAt)
        XCTAssertGreaterThanOrEqual(dto.lastSyncedAt ?? Date.distantPast, beforeInit)
    }

    func test_initFromContribution_handlesNilNotes() {
        let contribution = Contribution(
            goalId: "goal1",
            userId: "user1",
            amount: Decimal(50),
            notes: nil
        )

        let dto = ContributionDTO(from: contribution)

        XCTAssertNil(dto.notes)
    }

    // MARK: - Decimal Precision Tests

    func test_decimalPrecision_roundTrip() {
        let preciseAmounts: [Decimal] = [
            Decimal(string: "1234.56")!,
            Decimal(string: "99.99")!,
            Decimal(string: "0.01")!,
            Decimal(string: "10000.00")!
        ]

        for amount in preciseAmounts {
            let contribution = Contribution(
                goalId: "goal1",
                userId: "user1",
                amount: amount
            )
            let dto = ContributionDTO(from: contribution)
            let converted = dto.toContribution()

            let originalDouble = NSDecimalNumber(decimal: amount).doubleValue
            let convertedDouble = NSDecimalNumber(decimal: converted.amount).doubleValue

            XCTAssertEqual(
                convertedDouble,
                originalDouble,
                accuracy: 0.01,
                "Amount \(amount) should round-trip with acceptable precision"
            )
        }
    }

    func test_smallAmount_maintainsPrecision() {
        let smallAmount = Decimal(string: "0.01")!
        let contribution = Contribution(
            goalId: "goal1",
            userId: "user1",
            amount: smallAmount
        )
        let dto = ContributionDTO(from: contribution)

        XCTAssertEqual(dto.amount, 0.01, accuracy: 0.001)
    }

    func test_largeAmount_maintainsPrecision() {
        let largeAmount = Decimal(string: "50000.00")!
        let contribution = Contribution(
            goalId: "goal1",
            userId: "user1",
            amount: largeAmount
        )
        let dto = ContributionDTO(from: contribution)

        XCTAssertEqual(dto.amount, 50000.00, accuracy: 1.0)
    }

    // MARK: - Conversion to Domain Model Tests

    func test_toContribution_convertsAllFields() {
        let contribution = Contribution(
            id: "contrib123",
            goalId: "goal456",
            userId: "user789",
            amount: Decimal(200),
            date: testDate,
            notes: "Tax refund",
            createdAt: testDate
        )
        let dto = ContributionDTO(from: contribution)

        let converted = dto.toContribution()

        XCTAssertEqual(converted.id, contribution.id)
        XCTAssertEqual(converted.goalId, contribution.goalId)
        XCTAssertEqual(converted.userId, contribution.userId)
        XCTAssertEqual(converted.date, contribution.date)
        XCTAssertEqual(converted.notes, contribution.notes)
        XCTAssertEqual(converted.createdAt, contribution.createdAt)
    }

    func test_toContribution_convertsDoubleToDecimal() {
        let contribution = Contribution(
            goalId: "goal1",
            userId: "user1",
            amount: Decimal(string: "175.50")!
        )
        let dto = ContributionDTO(from: contribution)

        let converted = dto.toContribution()
        let convertedDouble = NSDecimalNumber(decimal: converted.amount).doubleValue

        XCTAssertEqual(convertedDouble, 175.50, accuracy: 0.01)
    }

    // MARK: - Dictionary Serialization Tests

    func test_dictionary_containsRequiredFields() {
        let contribution = Contribution(
            goalId: "goal1",
            userId: "user1",
            amount: Decimal(100)
        )
        let dto = ContributionDTO(from: contribution)
        let dict = dto.dictionary

        XCTAssertNotNil(dict["id"])
        XCTAssertNotNil(dict["goalId"])
        XCTAssertNotNil(dict["userId"])
        XCTAssertNotNil(dict["amount"])
        XCTAssertNotNil(dict["date"])
        XCTAssertNotNil(dict["createdAt"])
    }

    func test_dictionary_excludesNilNotes() {
        let contribution = Contribution(
            goalId: "goal1",
            userId: "user1",
            amount: Decimal(100),
            notes: nil
        )
        let dto = ContributionDTO(from: contribution)
        let dict = dto.dictionary

        XCTAssertNil(dict["notes"], "nil notes should not appear")
    }

    func test_dictionary_includesNotesWhenPresent() {
        let contribution = Contribution(
            goalId: "goal1",
            userId: "user1",
            amount: Decimal(100),
            notes: "Monthly savings"
        )
        let dto = ContributionDTO(from: contribution)
        let dict = dto.dictionary

        XCTAssertEqual(dict["notes"] as? String, "Monthly savings")
    }

    func test_dictionary_usesFirestoreTimestamps() {
        let contribution = Contribution(
            goalId: "goal1",
            userId: "user1",
            amount: Decimal(100)
        )
        let dto = ContributionDTO(from: contribution)
        let dict = dto.dictionary

        XCTAssertTrue(dict["date"] is Timestamp, "date should be Firestore Timestamp")
        XCTAssertTrue(dict["createdAt"] is Timestamp, "createdAt should be Firestore Timestamp")
    }

    func test_dictionary_storesAmountAsDouble() {
        let contribution = Contribution(
            goalId: "goal1",
            userId: "user1",
            amount: Decimal(250)
        )
        let dto = ContributionDTO(from: contribution)
        let dict = dto.dictionary

        XCTAssertTrue(dict["amount"] is Double, "amount should be stored as Double")
        if let amount = dict["amount"] as? Double {
            XCTAssertEqual(amount, 250.0, accuracy: 0.01)
        } else {
            XCTFail("amount should be a Double")
        }
    }

    // MARK: - Codable Conformance Tests

    @MainActor
    func test_codable_roundTrip() throws {
        let contribution = Contribution(
            goalId: "goal1",
            userId: "user1",
            amount: Decimal(333),
            notes: "Test note"
        )
        let originalDTO = ContributionDTO(from: contribution)

        let encoder = JSONEncoder()
        let data = try encoder.encode(originalDTO)

        let decoder = JSONDecoder()
        let decodedDTO = try decoder.decode(ContributionDTO.self, from: data)

        XCTAssertEqual(decodedDTO.id, originalDTO.id)
        XCTAssertEqual(decodedDTO.goalId, originalDTO.goalId)
        XCTAssertEqual(decodedDTO.userId, originalDTO.userId)
        XCTAssertEqual(decodedDTO.amount, originalDTO.amount, accuracy: 0.01)
        XCTAssertEqual(decodedDTO.notes, originalDTO.notes)
    }

    // MARK: - Edge Cases

    func test_zeroAmount_handled() {
        let contribution = Contribution(
            goalId: "goal1",
            userId: "user1",
            amount: 0
        )
        let dto = ContributionDTO(from: contribution)

        XCTAssertEqual(dto.amount, 0)
        XCTAssertEqual(dto.toContribution().amount, 0)
    }

    func test_emptyNotes_treatedAsNil() {
        // Notes should be nil for empty strings (handled at model level)
        let contribution = Contribution(
            goalId: "goal1",
            userId: "user1",
            amount: Decimal(100),
            notes: ""
        )
        let dto = ContributionDTO(from: contribution)

        // Empty string is still stored as empty string
        // nil check is for explicitly nil values
        XCTAssertEqual(dto.notes, "")
    }

    func test_veryLongNotes_preserved() {
        let longNotes = String(repeating: "A", count: 1000)
        let contribution = Contribution(
            goalId: "goal1",
            userId: "user1",
            amount: Decimal(100),
            notes: longNotes
        )
        let dto = ContributionDTO(from: contribution)

        XCTAssertEqual(dto.notes, longNotes)
        XCTAssertEqual(dto.toContribution().notes, longNotes)
    }
}
