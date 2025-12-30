# Winnie App - Development Progress

**Last Updated:** December 30, 2024

---

## Current Focus

**Active:** Phase 2C Complete - AuthenticationService now testable with protocol DI

**Next Up:** UI Development - Design System components or Onboarding flow

---

## Feature Status

### Infrastructure
| Feature | Status | Notes |
|---------|--------|-------|
| Firebase project setup | Done | Project: `winnie-65941` |
| Xcode project configuration | Done | Bundle ID: `com.AustinBeckett.Winnie` |
| Firebase SDK integration | Done | FirebaseAuth, FirebaseFirestore via SPM |
| Firestore Database | Done | Created in Firebase Console (test mode) |
| Firestore security rules | Not Started | Need to deploy before production |

### Authentication
| Feature | Status | Notes |
|---------|--------|-------|
| Email/Password sign in | Done | Enabled in Firebase Console, **protocol DI** |
| Email/Password sign up | Done | Enabled in Firebase Console, **protocol DI** |
| Apple Sign-In | Done | Enabled in Firebase Console, **protocol DI** |
| Sign out | Done | **protocol DI**, testable |
| Auth state routing | Done | Routes to login/content based on state |
| Account deletion | Done | **protocol DI**, testable |
| Password reset | Done | **protocol DI**, testable |

### Data Layer - Firestore
| Feature | Status | Notes |
|---------|--------|-------|
| UserDTO | Done | Basic fields |
| UserRepository | Done | CRUD for users, **protocol DI** |
| FirestoreError | Done | Shared error enum, **Equatable** for test assertions |
| CoupleDTO | Done | Couple document mapping (profile stored separately) |
| GoalDTO | Done | Goal subcollection documents, Decimal→Double conversion |
| ScenarioDTO | Done | Allocation unwrapping, DecisionStatus enum |
| FinancialProfileDTO | Done | Single doc at /couples/{id}/financialProfile/profile |
| InviteCodeDTO | Done | Standalone collection for quick lookups |
| CoupleRepository | Done | Batch writes, transactions, **protocol DI** |
| GoalRepository | Done | Subcollection CRUD + listeners, **protocol DI** |
| ScenarioRepository | Done | Active scenario management, **protocol DI** |
| InviteCodeRepository | Done | Code generation/validation, **protocol DI** |

### Data Layer - Local (SwiftData)
| Feature | Status | Notes |
|---------|--------|-------|
| LocalUser model | Not Started | |
| LocalCouple model | Not Started | |
| LocalGoal model | Not Started | |
| LocalScenario model | Not Started | |
| LocalDataService | Not Started | |
| SyncService | Not Started | |
| NetworkMonitor | Not Started | |

### Partner System
| Feature | Status | Notes |
|---------|--------|-------|
| Generate invite code | Not Started | |
| Join via invite code | Not Started | |
| Couple linking | Not Started | |
| Partner display in UI | Not Started | |

### Financial Engine
| Feature | Status | Notes |
|---------|--------|-------|
| Core calculation logic | Not Started | Already have domain models |
| Goal timeline projection | Not Started | |
| Scenario comparison | Not Started | |
| Allocation modeling | Not Started | |

### UI - Onboarding
| Feature | Status | Notes |
|---------|--------|-------|
| Welcome screen | Not Started | |
| Partner invite/skip | Not Started | |
| Financial baseline input | Not Started | |
| First goal creation | Not Started | |
| Timeline reveal | Not Started | |

### UI - Main App
| Feature | Status | Notes |
|---------|--------|-------|
| Dashboard | Not Started | |
| Goals list | Not Started | |
| Goal detail | Not Started | |
| Scenario editor (sliders) | Not Started | |
| Scenario comparison | Not Started | |
| Settings | Not Started | |

### Design System
| Feature | Status | Notes |
|---------|--------|-------|
| WinnieColors | Not Started | |
| WinnieTypography | Not Started | |
| WinnieSpacing | Not Started | |
| WinnieButton | Not Started | |
| WinnieCard | Not Started | |
| WinnieSlider | Not Started | |
| WinnieInput | Not Started | |

### Unit Tests - Phase 1 (Error Types + DTOs) ✅
| Feature | Status | Notes |
|---------|--------|-------|
| AuthenticationErrorTests | Done | ~22 tests, snake_case naming |
| FirestoreErrorTests | Done | ~15 tests, snake_case naming |
| UserDTOTests | Done | ~18 tests, snake_case naming |
| CoupleDTOTests | Done | ~21 tests, snake_case naming |
| GoalDTOTests | Done | ~22 tests, snake_case naming |
| ScenarioDTOTests | Done | ~18 tests, snake_case naming |
| FinancialProfileDTOTests | Done | ~20 tests, snake_case naming |
| InviteCodeDTOTests | Done | ~21 tests, snake_case naming |

### Unit Tests - Phase 2A (Protocol Architecture + UserRepository) ✅
| Feature | Status | Notes |
|---------|--------|-------|
| Firestore Protocols (6 files) | Done | FirestoreProviding, Collection, Document, Query, WriteBatch, Snapshots |
| FirestoreService | Done | Production wrapper for real Firestore SDK |
| MockFirestoreService | Done | In-memory mock with stubbing + call recording |
| TestFixtures | Done | Factory methods for User, Couple, Goal, Scenario test data |
| UserRepository refactored | Done | Uses FirestoreProviding protocol, testable init |
| UserRepositoryTests | Done | 20 tests: CRUD, listeners, error handling |

### Unit Tests - Phase 2B (Remaining Repository Tests) ✅
| Feature | Status | Notes |
|---------|--------|-------|
| CoupleRepository refactored | Done | Protocol DI, updated transaction API |
| GoalRepository refactored | Done | Protocol DI, CollectionProviding helper |
| ScenarioRepository refactored | Done | Protocol DI, batch operations |
| InviteCodeRepository refactored | Done | Protocol DI, added isLessThan query support |
| CoupleRepositoryTests | Done | ~25 tests: CRUD, transactions, profile management |
| GoalRepositoryTests | Done | ~25 tests: CRUD, batch ops, filtering, listeners |
| ScenarioRepositoryTests | Done | ~25 tests: CRUD, active management, allocations |
| InviteCodeRepositoryTests | Done | ~20 tests: code generation, validation, expiration |

### Unit Tests - Phase 2C (Auth Protocol Architecture) ✅
| Feature | Status | Notes |
|---------|--------|-------|
| Auth Protocols (5 files) | Done | AuthProviding, AuthUserProviding, AuthResultProviding, AuthCredentialProviding, AppleCredentialData |
| FirebaseAuthProvider | Done | Production wrapper for Firebase Auth SDK |
| FirebaseAuthWrappers | Done | User, Result, Credential wrappers for Firebase types |
| MockAuthProvider | Done | In-memory mock with stubbing + call recording |
| MockAuthTypes | Done | MockAuthUser, MockAuthResult, MockAuthCredential |
| AuthenticationService refactored | Done | Uses AuthProviding protocol, testable init |
| AuthenticationServiceTests | Done | 30 tests: state observation, sign in/up, Apple Sign-In, sign out, deletion |

### Unit Tests - Remaining Phases
| Phase | Scope | Notes |
|-------|-------|-------|
| Phase 3 | Additional edge case tests | Optional: more comprehensive Apple Sign-In mocking |

---

## Files Created

| File | Description |
|------|-------------|
| `Services/Authentication/AuthenticationError.swift` | Custom error types for auth failures |
| `Services/Authentication/AuthenticationService.swift` | Firebase Auth wrapper (sign in, sign up, sign out) |
| `Services/Authentication/AppleSignInCoordinator.swift` | Apple Sign-In flow handler |
| `Services/Firestore/FirestoreError.swift` | Shared error enum for all Firestore operations |
| `Services/Firestore/DTOs/UserDTO.swift` | Firestore DTO for User |
| `Services/Firestore/DTOs/CoupleDTO.swift` | Firestore DTO for Couple |
| `Services/Firestore/DTOs/FinancialProfileDTO.swift` | Firestore DTO for FinancialProfile |
| `Services/Firestore/DTOs/GoalDTO.swift` | Firestore DTO for Goal (Decimal→Double) |
| `Services/Firestore/DTOs/ScenarioDTO.swift` | Firestore DTO for Scenario (Allocation unwrap) |
| `Services/Firestore/DTOs/InviteCodeDTO.swift` | Firestore DTO for invite codes |
| `Services/Firestore/UserRepository.swift` | User CRUD operations |
| `Services/Firestore/CoupleRepository.swift` | Couple CRUD + financial profile management |
| `Services/Firestore/GoalRepository.swift` | Goal subcollection operations |
| `Services/Firestore/ScenarioRepository.swift` | Scenario subcollection + active scenario |
| `Services/Firestore/InviteCodeRepository.swift` | Invite code generation/validation |
| `WinnieApp.swift` | App entry point with Firebase init + auth routing |
| **Unit Tests** | |
| `WinnieTests/Authentication/AuthenticationErrorTests.swift` | Tests for AuthenticationError enum |
| `WinnieTests/Firestore/FirestoreErrorTests.swift` | Tests for FirestoreError enum |
| `WinnieTests/Firestore/DTOs/UserDTOTests.swift` | Tests for UserDTO conversion |
| `WinnieTests/Firestore/DTOs/CoupleDTOTests.swift` | Tests for CoupleDTO conversion |
| `WinnieTests/Firestore/DTOs/GoalDTOTests.swift` | Tests for GoalDTO + Decimal precision |
| `WinnieTests/Firestore/DTOs/ScenarioDTOTests.swift` | Tests for ScenarioDTO + Allocation |
| `WinnieTests/Firestore/DTOs/FinancialProfileDTOTests.swift` | Tests for FinancialProfileDTO |
| `WinnieTests/Firestore/DTOs/InviteCodeDTOTests.swift` | Tests for InviteCodeDTO validation |
| **Phase 2A: Protocol Architecture** | |
| `Services/Firestore/Protocols/FirestoreProviding.swift` | Main database protocol |
| `Services/Firestore/Protocols/CollectionProviding.swift` | Collection operations protocol |
| `Services/Firestore/Protocols/DocumentProviding.swift` | Document operations protocol |
| `Services/Firestore/Protocols/QueryProviding.swift` | Query building protocol |
| `Services/Firestore/Protocols/WriteBatchProviding.swift` | Batch write protocol |
| `Services/Firestore/Protocols/SnapshotProviding.swift` | Snapshot, Listener, Transaction protocols |
| `Services/Firestore/Implementations/FirestoreService.swift` | Production Firestore wrapper |
| `WinnieTests/TestHelpers/Mocks/MockFirestoreService.swift` | In-memory mock for tests |
| `WinnieTests/TestHelpers/Fixtures/TestFixtures.swift` | Factory methods for test data |
| `WinnieTests/Firestore/UserRepositoryTests.swift` | 20 tests for UserRepository |
| **Phase 2B: Repository Refactoring & Tests** | |
| `WinnieTests/Firestore/CoupleRepositoryTests.swift` | ~25 tests for CoupleRepository |
| `WinnieTests/Firestore/GoalRepositoryTests.swift` | ~25 tests for GoalRepository |
| `WinnieTests/Firestore/ScenarioRepositoryTests.swift` | ~25 tests for ScenarioRepository |
| `WinnieTests/Firestore/InviteCodeRepositoryTests.swift` | ~20 tests for InviteCodeRepository |
| **Phase 2C: Auth Protocol Architecture** | |
| `Services/Authentication/Protocols/AuthProviding.swift` | Main auth protocol |
| `Services/Authentication/Protocols/AuthUserProviding.swift` | User abstraction protocol |
| `Services/Authentication/Protocols/AuthResultProviding.swift` | Sign-in result protocol |
| `Services/Authentication/Protocols/AuthCredentialProviding.swift` | Credential marker protocol |
| `Services/Authentication/Protocols/AppleCredentialData.swift` | Testable struct for Apple Sign-In data |
| `Services/Authentication/Implementations/FirebaseAuthProvider.swift` | Production Firebase Auth wrapper |
| `Services/Authentication/Implementations/FirebaseAuthWrappers.swift` | User, Result, Credential wrappers |
| `WinnieTests/TestHelpers/Mocks/MockAuthProvider.swift` | In-memory mock for auth tests |
| `WinnieTests/TestHelpers/Mocks/MockAuthTypes.swift` | Mock user, result, credential types |
| `WinnieTests/Authentication/AuthenticationServiceTests.swift` | 30 tests for AuthenticationService |
| **Code Audit Fixes** | |
| `WinnieTests/README.md` | Test suite documentation: structure, naming, @MainActor rationale |

---

## Recent Sessions

### December 30, 2024 (Session 11) - Phase 2C Complete: Auth DI & Tests
- **Phase 2C Complete**: AuthenticationService now fully testable with protocol-based DI
- Created 5 protocol files in `Services/Authentication/Protocols/`:
  - `AuthProviding` - Main auth interface (sign in/out, listeners, etc.)
  - `AuthUserProviding` - Abstracts FirebaseAuth.User
  - `AuthResultProviding` - Abstracts sign-in results with `isNewUser` detection
  - `AuthCredentialProviding` - Marker protocol for OAuth credentials
  - `AppleCredentialData` - Testable struct for Apple Sign-In (bypasses non-instantiable `ASAuthorizationAppleIDCredential`)
- Created 2 production wrapper files in `Services/Authentication/Implementations/`:
  - `FirebaseAuthProvider` - Production wrapper with `shared` singleton
  - `FirebaseAuthWrappers` - User, Result, Credential wrapper classes
- Created 2 mock files in `WinnieTests/TestHelpers/Mocks/`:
  - `MockAuthProvider` - In-memory mock with call recording + state simulation
  - `MockAuthTypes` - MockAuthUser, MockAuthResult, MockAuthCredential
- Refactored `AuthenticationService` to use constructor injection (`init(authProvider:)`)
- Added auth fixtures to `TestFixtures.swift`
- Created `AuthenticationServiceTests.swift` with 30 comprehensive tests:
  - Initial state (2), Auth state listener (2), Email sign up (4), Email sign in (4)
  - Password reset (2), Apple Sign-In (7), Sign out (2), Delete account (3), Computed properties (4)
- Fixed Swift 6 concurrency issues: `nonisolated` for listener removal, `@unchecked Sendable` for test helper
- **Total test count**: ~260+ tests (230 existing + 30 new)

### December 30, 2024 (Session 10) - Progress File Sync Fix
- Reverted Phase 2C changes that were not properly saved
- Updated PROGRESS.md to reflect actual codebase state
- Phase 2B is complete, Phase 2C not yet started
- Moved docs folder into git tracking to prevent future sync issues

### December 30, 2024 (Session 9) - First Login Test
- **Firebase Console Setup Complete**: All auth methods and Firestore database enabled
- **Successful first login**: Apple Sign-In working end-to-end on test iPhone
- User created in Firebase Auth console
- App correctly routes to authenticated "Hello World" placeholder view
- Ready to begin UI development when done with IA (Design System or Onboarding)

### December 30, 2024 (Session 8) - Test Naming Convention & Documentation
- **Created WinnieTests/README.md**: Comprehensive test suite documentation
  - Explains directory structure and organization
  - Documents snake_case naming convention with examples
  - Explains why `@MainActor` is required for repository tests
  - Documents TestFixtures pattern (domain vs data methods)
  - Provides instructions for adding new tests
- **Renamed ~112 Phase 1 tests to snake_case** across 8 test files:
  - AuthenticationErrorTests.swift (~22 tests)
  - FirestoreErrorTests.swift (~15 tests)
  - UserDTOTests.swift (~18 tests)
  - CoupleDTOTests.swift (~21 tests)
  - GoalDTOTests.swift (~22 tests)
  - FinancialProfileDTOTests.swift (~20 tests)
  - ScenarioDTOTests.swift (~18 tests)
  - InviteCodeDTOTests.swift (~21 tests)
- Naming pattern: `test_<methodOrScenario>_<expectedBehavior>()`
- All tests verified passing in Xcode

### December 30, 2024 (Session 7) - Code Audit & Fixes
- **Comprehensive Code Audit**: Reviewed Phase 1 through Phase 2B testing implementation
- Identified 22 issues (2 critical, 5 high, 9 medium, 6 low severity)
- Fixed all 7 critical + high severity issues:
  1. **MockFirestoreService equality comparison** - Replaced fragile string interpolation with type-safe `isEqual()`, `isLessThan()`, `compare()` helper methods
  2. **MockWriteBatch atomicity** - Rewrote to validate all operations before applying, ensuring atomic behavior
  3. **Duplicate test helper** - Removed `makeUserDictionary()` from UserRepositoryTests, now uses `TestFixtures.makeUserData()`
  4. **MockQuery multi-ordering** - Extended sorting to support multiple order-by clauses
  5. **FirestoreError Equatable** - Added manual Equatable conformance for precise test assertions
  6. **Date encoding documentation** - Added comprehensive docs to TestFixtures explaining Domain vs Data patterns
  7. **Listener callback tests** - Added 5 new tests verifying callback behavior, updates, and cleanup
- Total new tests: 5 listener tests in UserRepositoryTests
- Audit report saved to: `/Users/austinbeckett/.claude/plans/resilient-beaming-hoare.md`

### December 30, 2024 (Session 6)
- **Phase 2B Tests Verified & Passing**: All ~230 tests now pass in Xcode
- Added `reference` property to `DocumentSnapshotProviding` protocol (needed for batch operations)
- Implemented `reference` in both `FirestoreService` and `MockFirestoreService`
- Added `@MainActor` to all 5 repository test classes to fix Swift concurrency isolation issues
- Fixed test fixtures missing required DTO fields:
  - Added `createdAt` to `makeGoalData()` and `makeCoupleData()`
  - Added `lastUpdated` to `makeFinancialProfileData()`
- Fixed `FirestoreError.networkError` references (doesn't exist) → `FirestoreError.unknown()`
- Fixed argument order in `makeGoalData()` calls (`priority` before `isActive`)
- All repository tests now compile and pass

### December 29, 2024 (Session 5)
- **Phase 2B Complete**: All repositories refactored with protocol-based DI
- Refactored 4 repositories (Couple, Goal, Scenario, InviteCode) to use `FirestoreProviding`
- Updated transaction methods in CoupleRepository to use new Swift-style API (no errorPointer)
- Added `whereField(isLessThan:)` to query protocols for InviteCodeRepository
- Wrote ~95 new tests across 4 repository test files
- Extended TestFixtures with data dictionary helpers for stubbing
- All repositories now testable with MockFirestoreService injection
- Total estimated tests: 230+ (112 Phase 1 + 20 Phase 2A + ~95 Phase 2B)

### December 29, 2024 (Session 4)
- **Phase 2A Complete**: Full protocol-based architecture for testable Firestore layer
- Created 6 protocol files defining the Firestore abstraction layer
- Created FirestoreService (production wrapper) with wrapper classes for Collection, Document, Query, etc.
- Created MockFirestoreService with in-memory storage, stubbing, and call recording
- Created TestFixtures with factory methods for all domain models
- Refactored UserRepository to use `FirestoreProviding` protocol with dependency injection
- Wrote 20 UserRepository tests covering CRUD, listeners, and error handling
- All 132+ tests passing (112 Phase 1 + 20 new Phase 2A tests)

### December 29, 2024 (Session 3)
- Created comprehensive Phase 1 unit tests (8 files, ~112 tests)
- Test coverage for: AuthenticationError, FirestoreError, all 6 DTOs
- Key test categories: error descriptions, Firebase error mapping, Decimal precision, enum serialization
- Security tests: nonce handling, member limits, invite code validation
- Tests require adding WinnieTests target to Xcode project scheme

### December 29, 2024 (Session 2)
- Completed full Firestore data layer implementation
- Created 5 DTOs: CoupleDTO, FinancialProfileDTO, GoalDTO, ScenarioDTO, InviteCodeDTO
- Created 4 Repositories: CoupleRepository, GoalRepository, ScenarioRepository, InviteCodeRepository
- Extracted FirestoreError to shared file with new error cases
- Technical decisions: Decimal→Double for Firestore, enum rawValue serialization
- All repositories support async/await and real-time listeners

### December 29, 2024 (Session 1)
- Added Learning Mode to CLAUDE.md (explains code before implementing)
- Added Progress Tracking to CLAUDE.md (auto-updates this file)
- Restructured PROGRESS.md to be feature-based instead of week-based

### December 28, 2024
- Completed Firebase setup and authentication
- Apple Sign-In working end-to-end
- Email/Password auth working
- Basic auth state routing in place

---

## Blockers & Decisions Needed

*None currently*

---

## Firestore Schema (Reference)

```
/users/{userId}
    - id, displayName, email, partnerID, coupleID
    - createdAt, lastLoginAt, hasCompletedOnboarding

/couples/{coupleId}
    - id, memberIDs[], inviteCode?, inviteCodeExpiresAt?

    /couples/{coupleId}/financialProfile/{doc}
        - monthlyIncome, monthlyExpenses, currentSavings, retirementBalance?

    /couples/{coupleId}/goals/{goalId}
        - id, type, name, targetAmount, currentAmount, priority, isActive

    /couples/{coupleId}/scenarios/{scenarioId}
        - id, name, allocations, decisionStatus

/inviteCodes/{code}
    - code, coupleID, createdBy, expiresAt, isUsed
```

---

## Quick Start

1. Open: `Winnie App/Winnie/Winnie.xcodeproj`
2. Build: `Cmd + B`
3. Run: `Cmd + R`

---

## Notes

- **All 5 Firestore repositories** now use protocol-based dependency injection
- **AuthenticationService** now uses protocol-based dependency injection
- Pattern: `init()` uses production service (`FirestoreService.shared` or `FirebaseAuthProvider.shared`)
- Pattern: `init(db:)` or `init(authProvider:)` allows test injection
- Transaction methods updated to use Swift-native throwing API (no more `errorPointer`)
- Query protocols support: `isEqualTo`, `isLessThan`, `order`, `limit`
- Domain models exist in `Models/` folder - DTOs are separate for Firestore
- Money values use Decimal in domain models, Double in DTOs (Firestore limitation)
- Enums (GoalType, DecisionStatus) serialize via rawValue strings
- Apple Sign-In testing uses `AppleCredentialData` struct (ASAuthorizationAppleIDCredential cannot be instantiated)
- **All backend services are now testable** - ready for UI development
