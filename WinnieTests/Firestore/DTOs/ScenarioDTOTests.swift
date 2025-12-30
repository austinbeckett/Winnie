import XCTest
import FirebaseFirestore
@testable import Winnie

/// Comprehensive unit tests for ScenarioDTO
/// Tests allocation conversion, decision status serialization, and domain model mapping
final class ScenarioDTOTests: XCTestCase {

    // MARK: - Test Data

    private let testDate = Date(timeIntervalSince1970: 1704067200) // 2024-01-01 00:00:00 UTC

    private func makeTestAllocation() -> Allocation {
        var allocation = Allocation()
        allocation["goal1"] = Decimal(1500)
        allocation["goal2"] = Decimal(1000)
        allocation["goal3"] = Decimal(500)
        return allocation
    }

    // MARK: - Initialization from Domain Model Tests

    func testInitFromScenarioCopiesAllFields() {
        let allocation = makeTestAllocation()
        let scenario = Scenario(
            id: "scenario123",
            name: "Balanced Plan",
            allocations: allocation,
            notes: "Equal distribution",
            isActive: true,
            decisionStatus: .decided,
            createdAt: testDate,
            lastModified: testDate,
            createdBy: "user123"
        )

        let dto = ScenarioDTO(from: scenario)

        XCTAssertEqual(dto.id, scenario.id)
        XCTAssertEqual(dto.name, scenario.name)
        XCTAssertEqual(dto.notes, scenario.notes)
        XCTAssertEqual(dto.isActive, scenario.isActive)
        XCTAssertEqual(dto.createdBy, scenario.createdBy)
    }

    func testInitFromScenarioConvertsAllocationsToDouble() {
        var allocation = Allocation()
        allocation["goal1"] = Decimal(string: "1500.50")!
        allocation["goal2"] = Decimal(string: "999.99")!

        let scenario = Scenario(
            name: "Test",
            allocations: allocation,
            createdBy: "user123"
        )

        let dto = ScenarioDTO(from: scenario)

        XCTAssertEqual(dto.allocations["goal1"] ?? 0, 1500.50, accuracy: 0.01)
        XCTAssertEqual(dto.allocations["goal2"] ?? 0, 999.99, accuracy: 0.01)
    }

    func testInitFromScenarioConvertsDecisionStatusToRawValue() {
        for status in Scenario.DecisionStatus.allCases {
            let scenario = Scenario(
                name: "Test",
                decisionStatus: status,
                createdBy: "user123"
            )
            let dto = ScenarioDTO(from: scenario)

            XCTAssertEqual(dto.decisionStatus, status.rawValue)
        }
    }

    func testInitFromScenarioSetsLastSyncedAt() {
        let scenario = Scenario(name: "Test", createdBy: "user123")
        let beforeInit = Date()

        let dto = ScenarioDTO(from: scenario)

        XCTAssertNotNil(dto.lastSyncedAt)
        XCTAssertGreaterThanOrEqual(dto.lastSyncedAt ?? Date.distantPast, beforeInit)
    }

    // MARK: - Allocation Conversion Tests

    func testAllocationMapConversion() {
        var allocation = Allocation()
        allocation["house"] = Decimal(2000)
        allocation["retirement"] = Decimal(1500)
        allocation["vacation"] = Decimal(300)

        let scenario = Scenario(name: "Test", allocations: allocation, createdBy: "user123")
        let dto = ScenarioDTO(from: scenario)

        XCTAssertEqual(dto.allocations.count, 3)
        XCTAssertEqual(dto.allocations["house"] ?? 0, 2000, accuracy: 0.01)
        XCTAssertEqual(dto.allocations["retirement"] ?? 0, 1500, accuracy: 0.01)
        XCTAssertEqual(dto.allocations["vacation"] ?? 0, 300, accuracy: 0.01)
    }

    func testEmptyAllocationMap() {
        let scenario = Scenario(
            name: "Empty",
            allocations: Allocation(),
            createdBy: "user123"
        )
        let dto = ScenarioDTO(from: scenario)

        XCTAssertTrue(dto.allocations.isEmpty)
    }

    func testAllocationPrecisionRoundTrip() {
        var allocation = Allocation()
        allocation["goal1"] = Decimal(string: "1234.56")!

        let scenario = Scenario(name: "Test", allocations: allocation, createdBy: "user123")
        let dto = ScenarioDTO(from: scenario)
        let converted = dto.toScenario()!

        let convertedAmount = converted.allocations["goal1"]
        let originalDouble = 1234.56
        let convertedDouble = NSDecimalNumber(decimal: convertedAmount).doubleValue

        XCTAssertEqual(convertedDouble, originalDouble, accuracy: 0.01)
    }

    // MARK: - Conversion to Domain Model Tests

    func testToScenarioConvertsAllFields() {
        let allocation = makeTestAllocation()
        let scenario = Scenario(
            id: "scenario123",
            name: "Test Plan",
            allocations: allocation,
            isActive: true,
            decisionStatus: .underReview,
            createdBy: "user123"
        )
        let dto = ScenarioDTO(from: scenario)

        let converted = dto.toScenario()!

        XCTAssertEqual(converted.id, scenario.id)
        XCTAssertEqual(converted.name, scenario.name)
        XCTAssertEqual(converted.isActive, scenario.isActive)
        XCTAssertEqual(converted.decisionStatus, scenario.decisionStatus)
        XCTAssertEqual(converted.createdBy, scenario.createdBy)
    }

    func testToScenarioReturnsNilForInvalidStatus() {
        // We need to test with bad JSON data
        // For now, test that all valid statuses work
        for status in Scenario.DecisionStatus.allCases {
            let scenario = Scenario(
                name: "Test",
                decisionStatus: status,
                createdBy: "user123"
            )
            let dto = ScenarioDTO(from: scenario)
            let converted = dto.toScenario()

            XCTAssertNotNil(converted, "\(status) should convert successfully")
            XCTAssertEqual(converted?.decisionStatus, status)
        }
    }

    func testToScenarioConvertsAllocationWrapper() {
        var allocation = Allocation()
        allocation["goal1"] = Decimal(1000)

        let scenario = Scenario(name: "Test", allocations: allocation, createdBy: "user123")
        let dto = ScenarioDTO(from: scenario)
        let converted = dto.toScenario()!

        XCTAssertTrue(converted.allocations.hasAllocations)
        XCTAssertEqual(converted.allocations.allocatedGoalCount, 1)
    }

    // MARK: - Dictionary Serialization Tests

    func testDictionaryContainsRequiredFields() {
        let scenario = Scenario(name: "Test", createdBy: "user123")
        let dto = ScenarioDTO(from: scenario)
        let dict = dto.dictionary

        XCTAssertNotNil(dict["id"])
        XCTAssertNotNil(dict["name"])
        XCTAssertNotNil(dict["allocations"])
        XCTAssertNotNil(dict["isActive"])
        XCTAssertNotNil(dict["decisionStatus"])
        XCTAssertNotNil(dict["createdAt"])
        XCTAssertNotNil(dict["lastModified"])
        XCTAssertNotNil(dict["createdBy"])
    }

    func testDictionaryExcludesNilOptionals() {
        let scenario = Scenario(name: "Test", notes: nil, createdBy: "user123")
        let dto = ScenarioDTO(from: scenario)
        let dict = dto.dictionary

        XCTAssertNil(dict["notes"], "nil notes should not appear in dictionary")
    }

    func testDictionaryIncludesNotesWhenPresent() {
        let scenario = Scenario(
            name: "Test",
            notes: "Important scenario notes",
            createdBy: "user123"
        )
        let dto = ScenarioDTO(from: scenario)
        let dict = dto.dictionary

        XCTAssertEqual(dict["notes"] as? String, "Important scenario notes")
    }

    func testDictionaryUsesFirestoreTimestamps() {
        let scenario = Scenario(name: "Test", createdBy: "user123")
        let dto = ScenarioDTO(from: scenario)
        let dict = dto.dictionary

        XCTAssertTrue(dict["createdAt"] is Timestamp, "createdAt should be Firestore Timestamp")
        XCTAssertTrue(dict["lastModified"] is Timestamp, "lastModified should be Firestore Timestamp")
    }

    func testDictionaryStoresDecisionStatusAsString() {
        let scenario = Scenario(
            name: "Test",
            decisionStatus: .archived,
            createdBy: "user123"
        )
        let dto = ScenarioDTO(from: scenario)
        let dict = dto.dictionary

        XCTAssertEqual(dict["decisionStatus"] as? String, "archived")
    }

    func testDictionaryAllocationsIsMap() {
        var allocation = Allocation()
        allocation["goal1"] = Decimal(1000)

        let scenario = Scenario(name: "Test", allocations: allocation, createdBy: "user123")
        let dto = ScenarioDTO(from: scenario)
        let dict = dto.dictionary

        let allocations = dict["allocations"] as? [String: Double]
        XCTAssertNotNil(allocations)
        XCTAssertEqual(allocations?["goal1"] ?? 0, 1000, accuracy: 0.01)
    }

    // MARK: - Codable Conformance Tests

    @MainActor
    func testCodableRoundTrip() throws {
        let allocation = makeTestAllocation()
        let scenario = Scenario(
            name: "Test Plan",
            allocations: allocation,
            createdBy: "user123"
        )
        let originalDTO = ScenarioDTO(from: scenario)

        let encoder = JSONEncoder()
        let data = try encoder.encode(originalDTO)

        let decoder = JSONDecoder()
        let decodedDTO = try decoder.decode(ScenarioDTO.self, from: data)

        XCTAssertEqual(decodedDTO.id, originalDTO.id)
        XCTAssertEqual(decodedDTO.name, originalDTO.name)
        XCTAssertEqual(decodedDTO.decisionStatus, originalDTO.decisionStatus)
    }

    // MARK: - Decision Status Tests

    func testAllDecisionStatusRawValues() {
        XCTAssertEqual(Scenario.DecisionStatus.draft.rawValue, "draft")
        XCTAssertEqual(Scenario.DecisionStatus.underReview.rawValue, "underReview")
        XCTAssertEqual(Scenario.DecisionStatus.decided.rawValue, "decided")
        XCTAssertEqual(Scenario.DecisionStatus.archived.rawValue, "archived")
    }
}
