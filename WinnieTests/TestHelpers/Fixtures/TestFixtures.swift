import Foundation
@testable import Winnie

// MARK: - Test Fixtures

/// Factory methods for creating test data with sensible defaults.
///
/// These "builders" let you create test objects with minimal boilerplate:
/// ```swift
/// // Create with all defaults
/// let user = TestFixtures.makeUser()
///
/// // Override specific fields
/// let customUser = TestFixtures.makeUser(id: "custom-id", email: "custom@test.com")
/// ```
///
/// ## Why Use Fixtures?
/// 1. **Consistency**: Same defaults across all tests
/// 2. **Readability**: Only specify what's relevant to your test
/// 3. **Maintainability**: Change model structure in one place
///
/// ## Two Types of Factory Methods
///
/// ### Domain Models (e.g., `makeUser()`, `makeGoal()`)
/// - Return strongly-typed Swift objects (User, Goal, Couple, etc.)
/// - Use **Decimal** for monetary values (precise, no floating-point errors)
/// - Use **Date** objects directly
/// - Use these when testing business logic or creating repository inputs
///
/// ### Data Dictionaries (e.g., `makeUserData()`, `makeGoalData()`)
/// - Return `[String: Any]` dictionaries for stubbing MockFirestoreService
/// - Use **Double** for monetary values (Firestore limitation)
/// - Use **ISO8601 date strings** for dates (JSON-compatible)
/// - Use these when stubbing `mockFirestore.stubDocument(path:data:)`
///
/// ## Date Encoding Note
///
/// **Production code** uses Firestore `Timestamp(date:)` for dates.
/// **Test fixtures** use ISO8601 strings because:
/// 1. MockFirestoreService uses JSONDecoder with `.iso8601` strategy
/// 2. JSON serialization doesn't support Timestamp objects
///
/// This is a known limitation. If date handling is critical to your test,
/// verify the behavior matches production by testing with actual Firestore.
///
/// ## Swift Concept: Factory Pattern
/// A factory method creates objects without exposing the creation logic.
/// Here, we provide sensible defaults so tests only override what matters.
enum TestFixtures {

    // MARK: - Dates

    /// Standard test date (Jan 1, 2024 at noon UTC)
    static let testDate = Date(timeIntervalSince1970: 1704110400)

    /// Date one day after testDate
    static let testDatePlusOneDay = testDate.addingTimeInterval(86400)

    /// Date one week after testDate
    static let testDatePlusOneWeek = testDate.addingTimeInterval(604800)

    // MARK: - User

    /// Create a User for testing
    /// - Parameters:
    ///   - id: User ID (default: "test-user-id")
    ///   - displayName: Display name (default: "Test User")
    ///   - email: Email address (default: "test@example.com")
    ///   - partnerID: Partner's user ID (default: nil)
    ///   - coupleID: Couple container ID (default: nil)
    ///   - createdAt: Account creation date (default: testDate)
    ///   - lastLoginAt: Last login date (default: testDate)
    ///   - hasCompletedOnboarding: Onboarding status (default: false)
    static func makeUser(
        id: String = "test-user-id",
        displayName: String? = "Test User",
        email: String? = "test@example.com",
        partnerID: String? = nil,
        coupleID: String? = nil,
        createdAt: Date = testDate,
        lastLoginAt: Date? = testDate,
        hasCompletedOnboarding: Bool = false
    ) -> User {
        User(
            id: id,
            displayName: displayName,
            email: email,
            partnerID: partnerID,
            coupleID: coupleID,
            createdAt: createdAt,
            lastLoginAt: lastLoginAt,
            hasCompletedOnboarding: hasCompletedOnboarding
        )
    }

    /// Create a User that has completed onboarding
    static func makeOnboardedUser(
        id: String = "test-user-id",
        displayName: String? = "Test User",
        email: String? = "test@example.com"
    ) -> User {
        makeUser(
            id: id,
            displayName: displayName,
            email: email,
            hasCompletedOnboarding: true
        )
    }

    /// Create a User connected to a partner
    static func makeConnectedUser(
        id: String = "test-user-id",
        partnerID: String = "partner-user-id",
        coupleID: String = "test-couple-id"
    ) -> User {
        makeUser(
            id: id,
            partnerID: partnerID,
            coupleID: coupleID,
            hasCompletedOnboarding: true
        )
    }

    // MARK: - User Data (Dictionary Format)

    /// Create a dictionary representation of a User for stubbing Firestore
    /// - Note: Uses ISO8601 date strings for JSON compatibility
    static func makeUserData(
        id: String = "test-user-id",
        displayName: String? = "Test User",
        email: String? = "test@example.com",
        partnerID: String? = nil,
        coupleID: String? = nil,
        createdAt: Date = testDate,
        lastLoginAt: Date? = testDate,
        hasCompletedOnboarding: Bool = false
    ) -> [String: Any] {
        var data: [String: Any] = [
            "id": id,
            "createdAt": ISO8601DateFormatter().string(from: createdAt),
            "hasCompletedOnboarding": hasCompletedOnboarding
        ]

        if let displayName { data["displayName"] = displayName }
        if let email { data["email"] = email }
        if let partnerID { data["partnerID"] = partnerID }
        if let coupleID { data["coupleID"] = coupleID }
        if let lastLoginAt {
            data["lastLoginAt"] = ISO8601DateFormatter().string(from: lastLoginAt)
        }

        return data
    }

    // MARK: - Couple

    /// Create a Couple for testing
    static func makeCouple(
        id: String = "test-couple-id",
        memberIDs: [String] = ["user-1", "user-2"],
        financialProfile: FinancialProfile = makeFinancialProfile()
    ) -> Couple {
        Couple(
            id: id,
            memberIDs: memberIDs,
            financialProfile: financialProfile
        )
    }

    /// Create a single-member Couple (waiting for partner)
    static func makeSingleMemberCouple(
        id: String = "test-couple-id",
        creatorID: String = "user-1"
    ) -> Couple {
        Couple(
            id: id,
            memberIDs: [creatorID],
            financialProfile: FinancialProfile()
        )
    }

    // MARK: - Couple Data (Dictionary Format)

    /// Create a dictionary representation of a Couple for stubbing Firestore
    static func makeCoupleData(
        id: String = "test-couple-id",
        memberIDs: [String] = ["user-1", "user-2"],
        inviteCode: String? = nil,
        inviteCodeExpiresAt: Date? = nil,
        createdAt: Date = testDate
    ) -> [String: Any] {
        var data: [String: Any] = [
            "id": id,
            "memberIDs": memberIDs,
            "createdAt": ISO8601DateFormatter().string(from: createdAt)
        ]

        if let inviteCode { data["inviteCode"] = inviteCode }
        if let inviteCodeExpiresAt {
            data["inviteCodeExpiresAt"] = ISO8601DateFormatter().string(from: inviteCodeExpiresAt)
        }

        return data
    }

    /// Create a single-member couple data
    static func makeSingleMemberCoupleData(
        id: String = "test-couple-id",
        creatorID: String = "user-1",
        inviteCode: String? = nil
    ) -> [String: Any] {
        makeCoupleData(
            id: id,
            memberIDs: [creatorID],
            inviteCode: inviteCode
        )
    }

    // MARK: - Financial Profile

    /// Create a FinancialProfile for testing
    static func makeFinancialProfile(
        monthlyIncome: Decimal = 10000,
        monthlyExpenses: Decimal = 6000,
        currentSavings: Decimal = 25000,
        retirementBalance: Decimal? = 50000
    ) -> FinancialProfile {
        FinancialProfile(
            monthlyIncome: monthlyIncome,
            monthlyExpenses: monthlyExpenses,
            currentSavings: currentSavings,
            retirementBalance: retirementBalance
        )
    }

    /// Create a dictionary representation of a FinancialProfile for stubbing Firestore
    static func makeFinancialProfileData(
        monthlyIncome: Double = 10000,
        monthlyExpenses: Double = 6000,
        currentSavings: Double = 25000,
        retirementBalance: Double? = 50000,
        lastUpdated: Date = testDate
    ) -> [String: Any] {
        var data: [String: Any] = [
            "monthlyIncome": monthlyIncome,
            "monthlyExpenses": monthlyExpenses,
            "currentSavings": currentSavings,
            "lastUpdated": ISO8601DateFormatter().string(from: lastUpdated)
        ]

        if let retirementBalance { data["retirementBalance"] = retirementBalance }

        return data
    }

    // MARK: - Goal

    /// Create a Goal for testing
    static func makeGoal(
        id: String = "test-goal-id",
        type: GoalType = .house,
        name: String = "House Down Payment",
        targetAmount: Decimal = 60000,
        currentAmount: Decimal = 15000,
        priority: Int = 0,
        isActive: Bool = true
    ) -> Goal {
        Goal(
            id: id,
            type: type,
            name: name,
            targetAmount: targetAmount,
            currentAmount: currentAmount,
            priority: priority,
            isActive: isActive
        )
    }

    /// Create a house goal
    static func makeHouseGoal(
        id: String = "house-goal-id",
        targetAmount: Decimal = 60000,
        currentAmount: Decimal = 15000
    ) -> Goal {
        makeGoal(
            id: id,
            type: .house,
            name: "House Down Payment",
            targetAmount: targetAmount,
            currentAmount: currentAmount,
            priority: 0
        )
    }

    /// Create a retirement goal
    static func makeRetirementGoal(
        id: String = "retirement-goal-id",
        targetAmount: Decimal = 1000000,
        currentAmount: Decimal = 50000
    ) -> Goal {
        makeGoal(
            id: id,
            type: .retirement,
            name: "Retirement",
            targetAmount: targetAmount,
            currentAmount: currentAmount,
            priority: 1
        )
    }

    /// Create a vacation goal
    static func makeVacationGoal(
        id: String = "vacation-goal-id",
        targetAmount: Decimal = 5000,
        currentAmount: Decimal = 1000
    ) -> Goal {
        makeGoal(
            id: id,
            type: .vacation,
            name: "Honeymoon",
            targetAmount: targetAmount,
            currentAmount: currentAmount,
            priority: 2
        )
    }

    // MARK: - Goal Data (Dictionary Format)

    /// Create a dictionary representation of a Goal for stubbing Firestore
    static func makeGoalData(
        id: String = "test-goal-id",
        type: String = "house",
        name: String = "House Down Payment",
        targetAmount: Double = 60000,
        currentAmount: Double = 15000,
        priority: Int = 0,
        isActive: Bool = true,
        createdAt: Date = testDate
    ) -> [String: Any] {
        [
            "id": id,
            "type": type,
            "name": name,
            "targetAmount": targetAmount,
            "currentAmount": currentAmount,
            "priority": priority,
            "isActive": isActive,
            "createdAt": ISO8601DateFormatter().string(from: createdAt)
        ]
    }

    // MARK: - Scenario

    /// Create a Scenario for testing
    static func makeScenario(
        id: String = "test-scenario-id",
        name: String = "Balanced Plan",
        allocations: Allocation = Allocation(allocations: ["house-goal": 1000, "retirement-goal": 500]),
        isActive: Bool = false,
        decisionStatus: Scenario.DecisionStatus = .draft,
        createdBy: String = "test-user-id",
        createdAt: Date = testDate,
        lastModified: Date = testDate
    ) -> Scenario {
        Scenario(
            id: id,
            name: name,
            allocations: allocations,
            isActive: isActive,
            decisionStatus: decisionStatus,
            createdAt: createdAt,
            lastModified: lastModified,
            createdBy: createdBy
        )
    }

    /// Create an active scenario
    static func makeActiveScenario(
        id: String = "active-scenario-id",
        name: String = "Current Plan"
    ) -> Scenario {
        makeScenario(
            id: id,
            name: name,
            isActive: true,
            decisionStatus: .decided
        )
    }

    // MARK: - Scenario Data (Dictionary Format)

    /// Create a dictionary representation of a Scenario for stubbing Firestore
    static func makeScenarioData(
        id: String = "test-scenario-id",
        name: String = "Balanced Plan",
        allocations: [String: Double] = ["house-goal": 1000, "retirement-goal": 500],
        isActive: Bool = false,
        decisionStatus: String = "draft",
        createdBy: String = "test-user-id",
        createdAt: Date = testDate,
        lastModified: Date = testDate
    ) -> [String: Any] {
        [
            "id": id,
            "name": name,
            "allocations": allocations,
            "isActive": isActive,
            "decisionStatus": decisionStatus,
            "createdBy": createdBy,
            "createdAt": ISO8601DateFormatter().string(from: createdAt),
            "lastModified": ISO8601DateFormatter().string(from: lastModified)
        ]
    }

    // MARK: - Invite Code

    /// Create an InviteCode for testing (via DTO since InviteCode is a DTO)
    static func makeInviteCodeData(
        code: String = "ABC123",
        coupleID: String = "test-couple-id",
        createdBy: String = "test-user-id",
        expiresAt: Date = testDatePlusOneWeek,
        isUsed: Bool = false,
        usedBy: String? = nil,
        usedAt: Date? = nil
    ) -> [String: Any] {
        var data: [String: Any] = [
            "code": code,
            "coupleID": coupleID,
            "createdBy": createdBy,
            "expiresAt": ISO8601DateFormatter().string(from: expiresAt),
            "isUsed": isUsed
        ]

        if let usedBy { data["usedBy"] = usedBy }
        if let usedAt {
            data["usedAt"] = ISO8601DateFormatter().string(from: usedAt)
        }

        return data
    }
}


// MARK: - Collection of Test Data

extension TestFixtures {

    /// Create a list of goals for testing
    static func makeGoalList() -> [Goal] {
        [
            makeHouseGoal(id: "goal-1"),
            makeRetirementGoal(id: "goal-2"),
            makeVacationGoal(id: "goal-3")
        ]
    }

    /// Create a complete couple with profile and goals
    static func makeCompleteCouple() -> (couple: Couple, goals: [Goal], scenario: Scenario) {
        let couple = makeCouple()
        let goals = makeGoalList()
        let scenario = makeActiveScenario()
        return (couple, goals, scenario)
    }
}


// MARK: - Authentication Test Fixtures

extension TestFixtures {

    /// Create a MockAuthUser for testing.
    ///
    /// Use this when you need to set up a signed-in state in tests:
    /// ```swift
    /// mockAuthProvider.mockCurrentUser = TestFixtures.makeAuthUser()
    /// ```
    static func makeAuthUser(
        uid: String = "test-user-id",
        email: String? = "test@example.com",
        displayName: String? = "Test User"
    ) -> MockAuthUser {
        MockAuthUser(uid: uid, email: email, displayName: displayName)
    }

    /// Create AppleCredentialData for testing Apple Sign-In.
    ///
    /// - Parameters:
    ///   - identityToken: Token string (will be converted to Data)
    ///   - givenName: First name (for first-time sign-in)
    ///   - familyName: Last name (for first-time sign-in)
    ///   - email: Email address (for first-time sign-in)
    static func makeAppleCredentialData(
        identityToken: String? = "mock-apple-id-token",
        givenName: String? = "Test",
        familyName: String? = "User",
        email: String? = "apple@test.com"
    ) -> AppleCredentialData {
        var fullName: PersonNameComponents?
        if givenName != nil || familyName != nil {
            fullName = PersonNameComponents()
            fullName?.givenName = givenName
            fullName?.familyName = familyName
        }

        return AppleCredentialData(
            identityToken: identityToken?.data(using: .utf8),
            fullName: fullName,
            email: email
        )
    }

    /// Create AppleCredentialData with no user info (returning user scenario).
    ///
    /// Apple only provides name/email on first sign-in.
    /// Subsequent sign-ins only have the identity token.
    static func makeReturningAppleCredentialData(
        identityToken: String = "mock-apple-id-token"
    ) -> AppleCredentialData {
        AppleCredentialData(
            identityToken: identityToken.data(using: .utf8),
            fullName: nil,
            email: nil
        )
    }
}
