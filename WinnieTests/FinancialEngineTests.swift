import XCTest
@testable import Winnie

final class FinancialEngineTests: XCTestCase {

    var engine: FinancialEngine!

    override func setUp() {
        super.setUp()
        engine = FinancialEngine()
    }

    override func tearDown() {
        engine = nil
        super.tearDown()
    }

    // MARK: - Helper Methods

    private func makeProfile(
        income: Decimal = 10000,
        expenses: Decimal = 6000,
        savings: Decimal = 5000
    ) -> FinancialProfile {
        FinancialProfile(
            monthlyIncome: income,
            monthlyExpenses: expenses,
            currentSavings: savings
        )
    }

    private func makeGoal(
        id: String = UUID().uuidString,
        type: GoalType = .house,
        name: String = "Test Goal",
        target: Decimal = 50000,
        current: Decimal = 10000
    ) -> Goal {
        Goal(
            id: id,
            type: type,
            name: name,
            targetAmount: target,
            currentAmount: current
        )
    }

    // MARK: - Basic Calculation Tests

    func test_calculate_singleGoal_returnsValidProjection() {
        let profile = makeProfile()
        let goal = makeGoal()

        var allocations = Allocation()
        allocations[goal.id] = Decimal(2000)

        let input = EngineInput(
            profile: profile,
            goals: [goal],
            allocations: allocations
        )

        let output = engine.calculate(input: input)

        XCTAssertNotNil(output.projections[goal.id])
        XCTAssertTrue(output.projections[goal.id]!.isReachable)
        XCTAssertNotNil(output.projections[goal.id]!.monthsToComplete)
        XCTAssertEqual(output.totalAllocated, Decimal(2000))
        XCTAssertEqual(output.remainingDisposable, Decimal(2000))  // 4000 - 2000
    }

    func test_calculate_multipleGoals_calculatesAllProjections() {
        let profile = makeProfile()
        let houseGoal = makeGoal(id: "house", type: .house, name: "House", target: 60000, current: 10000)
        let vacationGoal = makeGoal(id: "vacation", type: .vacation, name: "Vacation", target: 5000, current: 1000)

        var allocations = Allocation()
        allocations["house"] = Decimal(2000)
        allocations["vacation"] = Decimal(500)

        let input = EngineInput(
            profile: profile,
            goals: [houseGoal, vacationGoal],
            allocations: allocations
        )

        let output = engine.calculate(input: input)

        XCTAssertEqual(output.projections.count, 2)
        XCTAssertNotNil(output.projections["house"])
        XCTAssertNotNil(output.projections["vacation"])
        XCTAssertEqual(output.totalAllocated, Decimal(2500))
    }

    func test_calculate_completedGoal_returnsZeroMonths() {
        let profile = makeProfile()
        let goal = makeGoal(target: 10000, current: 15000)  // Already exceeded

        var allocations = Allocation()
        allocations[goal.id] = Decimal(500)

        let input = EngineInput(
            profile: profile,
            goals: [goal],
            allocations: allocations
        )

        let output = engine.calculate(input: input)
        let projection = output.projections[goal.id]!

        XCTAssertEqual(projection.monthsToComplete, 0)
        XCTAssertTrue(projection.isReachable)
    }

    func test_calculate_inactiveGoal_isExcluded() {
        let profile = makeProfile()
        var goal = makeGoal()
        goal.isActive = false

        var allocations = Allocation()
        allocations[goal.id] = Decimal(1000)

        let input = EngineInput(
            profile: profile,
            goals: [goal],
            allocations: allocations
        )

        let output = engine.calculate(input: input)

        XCTAssertTrue(output.projections.isEmpty)
    }

    // MARK: - Warning Tests

    func test_calculate_overAllocation_generatesWarning() {
        let profile = makeProfile(income: 5000, expenses: 4000)  // Only $1000 disposable
        let goal = makeGoal()

        var allocations = Allocation()
        allocations[goal.id] = Decimal(2000)  // Over-allocating by $1000

        let input = EngineInput(
            profile: profile,
            goals: [goal],
            allocations: allocations
        )

        let output = engine.calculate(input: input)

        XCTAssertTrue(output.hasWarnings)
        let overAllocatedWarning = output.warnings.first { warning in
            if case .overAllocated = warning { return true }
            return false
        }
        XCTAssertNotNil(overAllocatedWarning)
    }

    func test_calculate_negativeDisposable_generatesWarning() {
        let profile = makeProfile(income: 4000, expenses: 5000)  // Expenses > Income
        let goal = makeGoal()

        var allocations = Allocation()
        allocations[goal.id] = Decimal(100)

        let input = EngineInput(
            profile: profile,
            goals: [goal],
            allocations: allocations
        )

        let output = engine.calculate(input: input)

        let negativeWarning = output.warnings.contains { warning in
            if case .negativeDisposable = warning { return true }
            return false
        }
        XCTAssertTrue(negativeWarning)
    }

    func test_calculate_noContribution_generatesWarning() {
        let profile = makeProfile()
        let goal = makeGoal()

        let allocations = Allocation()  // No allocations set

        let input = EngineInput(
            profile: profile,
            goals: [goal],
            allocations: allocations
        )

        let output = engine.calculate(input: input)

        let noContributionWarning = output.warnings.contains { warning in
            if case .noContributionForGoal(_, _) = warning { return true }
            return false
        }
        XCTAssertTrue(noContributionWarning)
    }

    func test_calculate_unreachableGoal_generatesWarning() {
        let profile = makeProfile()
        let goal = makeGoal(target: 10_000_000, current: 0)  // Very large target

        var allocations = Allocation()
        allocations[goal.id] = Decimal(10)  // Tiny contribution

        let input = EngineInput(
            profile: profile,
            goals: [goal],
            allocations: allocations
        )

        let output = engine.calculate(input: input)
        let projection = output.projections[goal.id]!

        XCTAssertFalse(projection.isReachable)

        let unreachableWarning = output.warnings.contains { warning in
            if case .goalUnreachable(_, _) = warning { return true }
            return false
        }
        XCTAssertTrue(unreachableWarning)
    }

    // MARK: - Return Rate Tests

    func test_calculate_usesGoalTypeReturnRate() {
        let profile = makeProfile()
        let houseGoal = makeGoal(type: .house)  // 4.5% rate
        let retirementGoal = makeGoal(id: "retirement", type: .retirement)  // 7% rate

        var allocations = Allocation()
        allocations[houseGoal.id] = Decimal(1000)
        allocations[retirementGoal.id] = Decimal(1000)

        let input = EngineInput(
            profile: profile,
            goals: [houseGoal, retirementGoal],
            allocations: allocations
        )

        let output = engine.calculate(input: input)

        // Retirement should complete faster due to higher return rate
        let houseMonths = output.projections[houseGoal.id]!.monthsToComplete!
        let retirementMonths = output.projections[retirementGoal.id]!.monthsToComplete!

        XCTAssertLessThan(retirementMonths, houseMonths)
    }

    func test_calculate_customReturnRateOverridesDefault() {
        let profile = makeProfile()
        var goal = makeGoal(type: .house)
        goal.customReturnRate = Decimal(string: "0.10")!  // Override to 10%

        var allocations = Allocation()
        allocations[goal.id] = Decimal(1000)

        let input = EngineInput(
            profile: profile,
            goals: [goal],
            allocations: allocations
        )

        let output = engine.calculate(input: input)

        // With higher custom rate, should complete faster
        XCTAssertNotNil(output.projections[goal.id])
        XCTAssertTrue(output.projections[goal.id]!.isReachable)
    }

    // MARK: - Utility Method Tests

    func test_requiredMonthlyContribution_calculatesCorrectly() {
        let goal = makeGoal(target: 50000, current: 10000)
        let targetDate = Calendar.current.date(byAdding: .year, value: 3, to: Date())!

        let required = engine.requiredMonthlyContribution(for: goal, by: targetDate)

        XCTAssertNotNil(required)
        XCTAssertGreaterThan(required!, Decimal(0))
    }

    func test_compareScenarios_returnsBothOutputs() {
        let profile = makeProfile()
        let goal = makeGoal()

        var allocationsA = Allocation()
        allocationsA[goal.id] = Decimal(1000)

        var allocationsB = Allocation()
        allocationsB[goal.id] = Decimal(2000)

        let scenarioA = Scenario(name: "Conservative", allocations: allocationsA, createdBy: "user1")
        let scenarioB = Scenario(name: "Aggressive", allocations: allocationsB, createdBy: "user1")

        let (outputA, outputB) = engine.compareScenarios(
            scenarioA,
            scenarioB,
            profile: profile,
            goals: [goal]
        )

        XCTAssertEqual(outputA.totalAllocated, Decimal(1000))
        XCTAssertEqual(outputB.totalAllocated, Decimal(2000))

        // Aggressive should complete faster
        let monthsA = outputA.projections[goal.id]!.monthsToComplete!
        let monthsB = outputB.projections[goal.id]!.monthsToComplete!
        XCTAssertLessThan(monthsB, monthsA)
    }

    func test_simulateAllocationChange_updatesProjection() {
        let profile = makeProfile()
        let goal = makeGoal()

        var allocations = Allocation()
        allocations[goal.id] = Decimal(1000)

        let input = EngineInput(
            profile: profile,
            goals: [goal],
            allocations: allocations
        )

        let originalOutput = engine.calculate(input: input)
        let originalMonths = originalOutput.projections[goal.id]!.monthsToComplete!

        // Simulate doubling the contribution
        let updatedOutput = engine.simulateAllocationChange(
            goalID: goal.id,
            newAmount: Decimal(2000),
            input: input
        )
        let updatedMonths = updatedOutput.projections[goal.id]!.monthsToComplete!

        XCTAssertLessThan(updatedMonths, originalMonths)
        XCTAssertEqual(updatedOutput.totalAllocated, Decimal(2000))
    }

    // MARK: - GoalProjection Tests

    func test_goalProjection_timeToCompletionText_complete() {
        let projection = GoalProjection(
            goalID: "test",
            monthsToComplete: 0,
            completionDate: Date(),
            projectedFinalValue: Decimal(50000),
            monthlyContribution: Decimal(1000),
            isReachable: true
        )

        XCTAssertEqual(projection.timeToCompletionText, "Complete!")
    }

    func test_goalProjection_timeToCompletionText_monthsOnly() {
        let projection = GoalProjection(
            goalID: "test",
            monthsToComplete: 8,
            completionDate: Date(),
            projectedFinalValue: Decimal(50000),
            monthlyContribution: Decimal(1000),
            isReachable: true
        )

        XCTAssertEqual(projection.timeToCompletionText, "8 months")
    }

    func test_goalProjection_timeToCompletionText_yearsOnly() {
        let projection = GoalProjection(
            goalID: "test",
            monthsToComplete: 36,
            completionDate: Date(),
            projectedFinalValue: Decimal(50000),
            monthlyContribution: Decimal(1000),
            isReachable: true
        )

        XCTAssertEqual(projection.timeToCompletionText, "3 years")
    }

    func test_goalProjection_timeToCompletionText_yearsAndMonths() {
        let projection = GoalProjection(
            goalID: "test",
            monthsToComplete: 26,
            completionDate: Date(),
            projectedFinalValue: Decimal(50000),
            monthlyContribution: Decimal(1000),
            isReachable: true
        )

        XCTAssertEqual(projection.timeToCompletionText, "2y 2m")
    }

    func test_goalProjection_timeToCompletionText_unreachable() {
        let projection = GoalProjection(
            goalID: "test",
            monthsToComplete: nil,
            completionDate: nil,
            projectedFinalValue: Decimal(50000),
            monthlyContribution: Decimal(1000),
            isReachable: false
        )

        XCTAssertEqual(projection.timeToCompletionText, "50+ years")
    }

    // MARK: - Edge Cases

    func test_calculate_zeroIncome_handlesGracefully() {
        let profile = makeProfile(income: 0, expenses: 0, savings: 10000)
        let goal = makeGoal()

        var allocations = Allocation()
        allocations[goal.id] = Decimal(0)

        let input = EngineInput(
            profile: profile,
            goals: [goal],
            allocations: allocations
        )

        let output = engine.calculate(input: input)

        XCTAssertEqual(output.remainingDisposable, Decimal(0))
    }

    func test_calculate_largeAmounts_handlesWithoutOverflow() {
        let profile = makeProfile(income: 100000, expenses: 50000, savings: 1_000_000)
        let goal = makeGoal(target: 10_000_000, current: 1_000_000)

        var allocations = Allocation()
        allocations[goal.id] = Decimal(40000)

        let input = EngineInput(
            profile: profile,
            goals: [goal],
            allocations: allocations
        )

        let output = engine.calculate(input: input)

        XCTAssertNotNil(output.projections[goal.id])
        XCTAssertTrue(output.projections[goal.id]!.isReachable)
    }
}
