# WinnieTests

Unit test suite for the Winnie iOS app.

---

## Directory Structure

```
WinnieTests/
├── README.md                    # This file
├── Authentication/              # Auth-related tests
│   └── AuthenticationErrorTests.swift
├── Firestore/                   # Firestore layer tests
│   ├── DTOs/                    # Data Transfer Object tests
│   │   ├── UserDTOTests.swift
│   │   ├── CoupleDTOTests.swift
│   │   ├── GoalDTOTests.swift
│   │   ├── ScenarioDTOTests.swift
│   │   ├── FinancialProfileDTOTests.swift
│   │   └── InviteCodeDTOTests.swift
│   ├── FirestoreErrorTests.swift
│   ├── UserRepositoryTests.swift
│   ├── CoupleRepositoryTests.swift
│   ├── GoalRepositoryTests.swift
│   ├── ScenarioRepositoryTests.swift
│   └── InviteCodeRepositoryTests.swift
└── TestHelpers/                 # Shared test utilities
    ├── Mocks/
    │   └── MockFirestoreService.swift
    └── Fixtures/
        └── TestFixtures.swift
```

---

## Test Naming Convention

Use **snake_case** with three parts: `test_<what>_<expectedBehavior>`

```swift
// Good examples:
func test_fetchUser_returnsUserWhenDocumentExists() async throws { }
func test_createUser_throwsOnFirestoreError() async { }
func test_listenToUser_callbackFiresWithInitialData() { }

// Pattern breakdown:
// test_<methodOrScenario>_<expectedOutcome>
```

---

## Why `@MainActor` on Repository Tests?

All repository test classes use `@MainActor`:

```swift
@MainActor
final class UserRepositoryTests: XCTestCase { ... }
```

**Why it's needed:**

1. **Swift Concurrency Isolation**: Swift 6's strict concurrency requires that mutable state
   accessed from async contexts has clear isolation boundaries.

2. **MockFirestoreService State**: Our mock stores data in `var documents: [String: [String: Any]]`.
   Without `@MainActor`, accessing this from async test methods would require `Sendable`
   conformance or explicit synchronization.

3. **XCTest + async/await**: When tests use `async throws`, XCTest runs them in a Task.
   `@MainActor` ensures all test code (setup, execution, assertions) runs on the same actor,
   preventing data races.

4. **Simpler than Alternatives**: Other options (making MockFirestoreService `Sendable`,
   using locks, or actor isolation) add complexity. `@MainActor` on the test class is the
   simplest solution that keeps tests readable.

**When to use it:**
- Any test class that uses MockFirestoreService
- Any test class with `async` test methods that share mutable state

**When NOT needed:**
- Pure synchronous tests with no shared state (e.g., simple DTO tests)

---

## Test Helpers

### MockFirestoreService

In-memory Firestore mock for testing repositories without Firebase.

```swift
// Setup
let mockFirestore = MockFirestoreService()
let repository = UserRepository(db: mockFirestore)

// Stub data
mockFirestore.stubDocument(
    path: "users/user-123",
    data: TestFixtures.makeUserData(id: "user-123")
)

// Verify calls
XCTAssertTrue(mockFirestore.didSetData(at: "users/user-123"))
XCTAssertTrue(mockFirestore.getDocumentCalls.contains("users/user-123"))

// Simulate errors
mockFirestore.errorToThrow = FirestoreError.unauthorized

// Simulate real-time updates
mockFirestore.simulateDocumentChange(
    path: "users/user-123",
    data: TestFixtures.makeUserData(id: "user-123", displayName: "Updated")
)
```

### TestFixtures

Factory methods for creating test data. **Two types of methods:**

| Method Type | Returns | Use When |
|-------------|---------|----------|
| `makeUser()`, `makeGoal()` | Domain model (User, Goal) | Creating repository inputs, testing business logic |
| `makeUserData()`, `makeGoalData()` | `[String: Any]` dictionary | Stubbing MockFirestoreService |

```swift
// Domain model (Decimal for money, Date objects)
let user = TestFixtures.makeUser(id: "user-123", email: "test@example.com")

// Data dictionary (Double for money, ISO8601 strings for dates)
mockFirestore.stubDocument(
    path: "users/user-123",
    data: TestFixtures.makeUserData(id: "user-123")
)
```

**Date encoding note:** Test fixtures use ISO8601 strings because MockFirestoreService
uses JSONDecoder. Production code uses Firestore `Timestamp`. This is a known limitation.

---

## Adding New Tests

### 1. Create the Test File

```swift
import XCTest
@testable import Winnie

@MainActor  // Add if using MockFirestoreService or async methods
final class MyNewTests: XCTestCase {

    // MARK: - Properties

    var mockFirestore: MockFirestoreService!
    var repository: MyRepository!

    // MARK: - Setup & Teardown

    override func setUp() {
        super.setUp()
        mockFirestore = MockFirestoreService()
        repository = MyRepository(db: mockFirestore)
    }

    override func tearDown() {
        mockFirestore = nil
        repository = nil
        super.tearDown()
    }

    // MARK: - Tests

    func test_myMethod_expectedBehavior() async throws {
        // Arrange
        mockFirestore.stubDocument(path: "...", data: [...])

        // Act
        let result = try await repository.myMethod()

        // Assert
        XCTAssertEqual(result.id, "expected-id")
    }
}
```

### 2. Follow AAA Pattern

Every test should have three clear sections:

```swift
func test_fetchUser_returnsUserWhenExists() async throws {
    // Arrange - Set up preconditions
    mockFirestore.stubDocument(
        path: "users/user-123",
        data: TestFixtures.makeUserData(id: "user-123")
    )

    // Act - Execute the code under test
    let user = try await repository.fetchUser(id: "user-123")

    // Assert - Verify the results
    XCTAssertEqual(user.id, "user-123")
}
```

### 3. Test Error Cases

```swift
func test_fetchUser_throwsDocumentNotFoundWhenMissing() async {
    // Arrange - Don't stub any data

    // Act & Assert
    do {
        _ = try await repository.fetchUser(id: "nonexistent")
        XCTFail("Expected documentNotFound error")
    } catch FirestoreError.documentNotFound {
        // Expected
    } catch {
        XCTFail("Wrong error type: \(error)")
    }
}
```

---

## Running Tests

In Xcode:
- **All tests**: `Cmd + U`
- **Single test**: Click the diamond next to the test method
- **Test file**: Click the diamond next to the class name

---

## Test Environment Isolation

When unit tests run, **Firebase is completely disabled**. This is intentional.

### Why Firebase is Disabled

Xcode's test runner "hosts" tests inside the app, meaning `WinnieApp.init()` runs before tests start. Without isolation:
1. `FirebaseApp.configure()` would initialize the real Firebase SDK
2. `AuthenticationService` would set up real auth listeners
3. If signed in, `GoalsListView` would create real Firestore listeners
4. These real listeners would run **alongside** your mock-based tests, causing conflicts and crashes

### How It Works

Both `WinnieApp` and `AuthenticationService` detect the test environment:

```swift
private static var isRunningTests: Bool {
    NSClassFromString("XCTestCase") != nil
}
```

When running tests:
- `WinnieApp` skips `FirebaseApp.configure()`
- `AuthenticationService` uses `NoOpAuthProvider` instead of `FirebaseAuthProvider`

### Why This Doesn't Affect Production

In production, the `XCTestCase` class doesn't exist, so `isRunningTests` returns `false` and Firebase initializes normally.

### What This Means for Your Tests

- **Unit tests**: Use `MockFirestoreService` and `MockAuthProvider` as usual. Real Firebase never runs.
- **UI tests**: If you need real Firebase for integration/UI tests, you'd use a different detection method (e.g., launch arguments).

### Files Involved

| File | What It Does |
|------|--------------|
| `WinnieApp.swift` | Skips `FirebaseApp.configure()` during tests |
| `AuthenticationService.swift` | Uses `NoOpAuthProvider` during tests |

---

## Test Organization by Phase

| Phase | Scope | Files |
|-------|-------|-------|
| 1 | Error types + DTOs | `AuthenticationErrorTests`, `FirestoreErrorTests`, 6 DTO test files |
| 2A | Protocol architecture + UserRepository | `UserRepositoryTests` |
| 2B | Remaining repositories | `CoupleRepositoryTests`, `GoalRepositoryTests`, `ScenarioRepositoryTests`, `InviteCodeRepositoryTests` |
| 2C | Authentication protocols | (Coming next) |
| 3 | AuthenticationService | (Future) |
