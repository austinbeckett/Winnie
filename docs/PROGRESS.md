# Winnie App - Development Progress

**Last Updated:** January 8, 2026

---

## Current Focus

**In Progress:** Goal-Plan UX Redesign (making the relationship between target dates, allocations, and projected dates clearer)

**Next Up:** Partner System, Local-first architecture (SwiftData), or additional polish

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
| Core calculation logic | Done | FinancialEngine.swift with compound interest |
| Goal timeline projection | Done | calculateGoalProjection() with interest rates |
| Scenario comparison | Done | compareScenarios() side-by-side analysis |
| Allocation modeling | Done | simulateAllocationChange() what-if scenarios |

### UI - Onboarding
| Feature | Status | Notes |
|---------|--------|-------|
| Splash screen | Done | Logo + tagline animation |
| Value proposition carousel | Done | 3 slides with Next/Continue pattern |
| Goal picker | Done | Select primary goal type |
| Income input | Done | Monthly income with WinnieCurrencyInput |
| Savings question (branching) | Done | Yes/No choice determines flow path |
| Budgeting explainer | Done | Explains Needs/Wants/Savings philosophy |
| Needs input | Done | Fixed monthly expenses |
| Wants input | Done | Discretionary spending |
| Savings pool reveal | Done | Shows calculated or direct savings |
| Nest egg input | Done | Current savings balance |
| Goal detail | Done | Target amount + date |
| Projection | Done | Wired to Financial Engine with compound interest |
| Tune-up | Placeholder | Allocation adjustments |
| Partner invite/skip | Placeholder | Partner system not started |
| Name input | Done | "What should we call you?" screen |
| Avatar creation | Not Started | Future: customize illustrated avatar |

### UI - Main App
| Feature | Status | Notes |
|---------|--------|-------|
| Tab bar navigation | Done | 4 tabs: Dashboard, Goals, Scenarios, Me |
| Dashboard | Done | Welcome card, active plan, goal progress cards |
| Goals list | Done | GoalsListView with empty state |
| Goal detail | Done | GoalDetailView with edit/delete |
| Goal creation | Done | GoalCreationView (two-phase flow with suggestions) |
| Goal edit | Done | GoalEditView (matches Phase 2 of creation) |
| Scenarios list | Done | ScenarioListView with status grouping |
| Scenario editor (sliders) | Done | Real-time timeline updates with WinnieSlider |
| Scenario comparison | Done | Side-by-side comparison with difference indicators |
| Me view | Done | Profile tab with name editing and sign out |
| Settings | Placeholder | Cogwheel icon in Me view (functionality coming) |

### Design System
| Feature | Status | Notes |
|---------|--------|-------|
| WinnieColors | Done | Theme-aware color functions |
| WinnieTypography | Done | Playfair Display + Lato fonts |
| WinnieSpacing | Done | 8pt grid spacing scale |
| WinnieButton | Done | Primary/secondary/text variants |
| WinnieCard | Done | Accent border support |
| WinnieTextField | Done | Text input with label/validation |
| WinnieCurrencyInput | Done | Contained card style currency field |
| WinnieProgressBar | Done | Goal progress indicator |
| GoalCard | Done | Specialized goal summary card |
| WinnieSlider | Done | Custom slider for allocation controls with haptics |

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
| **Goals Vertical Slice** | |
| `Core/Components/WinnieButton.swift` | Primary/secondary/text button variants |
| `Core/Components/WinnieCard.swift` | Styled card with optional accent border |
| `Core/Components/WinnieTextField.swift` | Text input with label and validation |
| `Core/Components/WinnieProgressBar.swift` | Animated progress bar |
| `Core/Components/GoalCard.swift` | Goal summary card with progress |
| `Features/Goals/GoalsViewModel.swift` | @Observable state management for goals |
| `Features/Goals/GoalsListView.swift` | Main goals list screen |
| `Features/Goals/GoalDetailView.swift` | Single goal detail view |
| `Features/Goals/GoalEditView.swift` | Edit goal form (matches Phase 2 of creation) |
| **Goal Creation Flow** | |
| `Features/Goals/GoalCreation/GoalCreationView.swift` | Two-phase goal creation modal |
| `Features/Goals/GoalCreation/GoalCreationHeaderView.swift` | Colored header with tappable icon |
| `Features/Goals/GoalCreation/GoalDetailsFormView.swift` | Form fields (amounts, category, date, notes) |
| `Features/Goals/GoalCreation/GoalSuggestionsView.swift` | Goal name suggestions in Phase 1 |
| `Features/Goals/GoalCreation/GoalAppearanceSheet.swift` | Icon and color picker sheet |
| `Features/Goals/GoalCreation/GoalIconPicker.swift` | Icon selection with Auto option |
| `Features/Goals/GoalCreation/GoalCategoryDropdown.swift` | Category selection dropdown |
| **Code Audit Fixes** | |
| `WinnieTests/README.md` | Test suite documentation: structure, naming, @MainActor rationale |
| **Avatar System** | |
| `Core/Components/UserProfileAvatar.swift` | Illustrated avatar component (placeholder for customization) |
| `Assets.xcassets/MaleAvatarCircle.imageset` | Male avatar SVG asset |
| `Assets.xcassets/FemaleAvatarCircle.imageset` | Female avatar SVG asset |
| **User Data & Onboarding** | |
| `Core/AppState.swift` | Central state container for user/couple data (updated with saveOnboardingData) |
| `Features/Onboarding/NameInputView.swift` | "What should we call you?" onboarding screen |
| `Features/Onboarding/OnboardingProjectionView.swift` | Updated to use Financial Engine for projections |
| **Tab Bar Navigation** | |
| `Features/Dashboard/DashboardView.swift` | Dashboard with welcome card, active plan, goal progress |
| `Features/Me/MeView.swift` | Profile tab with name editing and sign out |
| `Features/Me/EditNameSheet.swift` | Bottom sheet for editing display name |
| **Scenarios System** | |
| `Features/Scenarios/ScenariosView.swift` | Wrapper for ScenarioListView |
| `Features/Scenarios/ScenarioListView.swift` | List of scenarios with status grouping |
| `Features/Scenarios/ScenarioEditorView.swift` | Create/edit scenarios with allocation sliders |
| `Features/Scenarios/ScenarioEditorViewModel.swift` | State management with debounced calculations |
| `Features/Scenarios/ScenarioComparisonView.swift` | Side-by-side scenario comparison |
| `Features/Scenarios/Components/ScenarioCard.swift` | Scenario summary card for list |
| `Features/Scenarios/Components/GoalAllocationRow.swift` | Goal row with slider and timeline |
| `Features/Scenarios/Components/BudgetSummaryCard.swift` | Budget overview with allocation progress |
| `Core/Components/WinnieSlider.swift` | Custom slider with haptics and step increments |
| `Core/Components/MainTabView.swift` | Custom tab container (updated with coupleID/userID params) |

---

## Recent Sessions

### January 8, 2026 (Session 19) - Goal-Plan UX Redesign (In Progress)
- **Goal-Plan Integration**: Building clearer UX for the relationship between target dates, allocations, and projected dates
- **Enhanced GoalAllocationRow**: Complete rewrite with two variants:
  - Goals WITH target date: Two-column "Required vs Your Allocation" comparison, slider with marker at required amount, status indicator ("X months early/late"), "Match Required" one-tap button
  - Goals WITHOUT target date: Simpler UI with just allocation and projected completion date
- **ScenarioEditorViewModel**: Added `requiredContribution(for:)` using FinancialEngine calculations, added `GoalAllocationContext` struct to bundle allocation data
- **GoalDetailView Enhancement**: Enhanced allocation section showing plan name, target vs projected date comparison, "Edit in Plan" navigation button
- **GoalDetailViewModel**: Added `activePlanName` and `activeScenario` computed properties, exposed `coupleID` for navigation
- **ScenarioEditorView**: Updated to use new context-based GoalAllocationRow with "Match Required" callback
- **Files created**: GoalTrackingStatus.swift, ScenarioDetailView.swift, ScenarioDetailViewModel.swift, ScenarioGoalRow.swift, AllocationEditSheet.swift, GoalSelectionView.swift
- **Files modified**: GoalAllocationRow.swift (rewritten), ScenarioEditorViewModel.swift, ScenarioEditorView.swift, GoalDetailView.swift, GoalDetailViewModel.swift, Scenario.swift, Allocation.swift
- **Documentation**: Created docs/GoalPlanIntegrationSummary.md explaining architecture and patterns

### January 8, 2026 (Session 18) - Financial Engine Integration + Scenarios UI
- **Complete Scenarios System Built**: Full "What-If" planning feature now functional
- **WinnieSlider Component**: Custom slider with 8px track, thick-bordered thumb, haptic feedback, $50 steps
- **Scenario Editor**: Budget summary card, goal allocation rows with real-time timeline updates, 300ms debouncing
- **Scenario List**: Cards grouped by status (Active, Under Review, Drafts, Archived), swipe actions for edit/delete/archive
- **Scenario Comparison**: Side-by-side timeline comparison with green/orange difference indicators
- **Dashboard Content**: Replaced placeholder with real content (welcome card, active plan summary, goal progress cards)
- **Onboarding Projection Wiring**: Updated to use Financial Engine for compound interest calculations (was simple linear math)
- **AppState.saveOnboardingData()**: Now creates couple, saves financial profile, saves first goal to Firestore
- **Files created**: WinnieSlider.swift, ScenarioListView.swift, ScenarioEditorView.swift, ScenarioEditorViewModel.swift, ScenarioComparisonView.swift, ScenarioCard.swift, GoalAllocationRow.swift, BudgetSummaryCard.swift
- **Files updated**: DashboardView.swift, ScenariosView.swift, MainTabView.swift, OnboardingProjectionView.swift, AppState.swift
- Uses Ivory Bordered card style throughout (per user preference)

### January 3, 2026 (Session 17) - Onboarding Flow Redesign
- **Branching Flow After Income**: Added decision point for users who know vs don't know their monthly savings
  - Created `OnboardingSavingsQuestionView` with two choice buttons
  - "Yes" path skips Needs/Wants, goes directly to Savings Pool with editable input
  - "No" path goes through Budgeting Explainer → Needs → Wants → Savings Pool (calculated)
- **Budgeting Explainer Screen**: New screen explaining Needs/Wants/Savings philosophy
  - Created `OnboardingBudgetingExplainerView` with category breakdown
  - Shown only on "No, help me figure it out" path before expense collection
- **Currency Input Redesign (Style A: Contained Card)**:
  - Created reusable `WinnieCurrencyInput` component in Core/Components
  - Card container with proper $, number, suffix alignment
  - Focus states with accent border, subtle shadow
  - Updated 4 views: Income, Savings Pool, Nest Egg, Goal Detail
- **OnboardingCarouselView Enhancement**: Next/Continue button pattern
  - "Next" on slides 1-2 (animates to next slide)
  - "Continue" on slide 3 (proceeds to Goal Picker)
- **OnboardingState Updates**:
  - Added `knowsSavingsAmount: Bool` and `directSavingsPool: Decimal`
  - Updated `savingsPool` computed property for conditional calculation
- **OnboardingCoordinator Updates**:
  - Added `.savingsQuestion` and `.budgetingExplainer` steps to enum
  - Implemented branching navigation logic
- **Text/UI Fixes**:
  - Fixed text truncation with `.fixedSize(horizontal: false, vertical: true)`
  - Fixed text centering when keyboard opens
  - Removed redundant body text from savings question screen
- **New files**: OnboardingSavingsQuestionView.swift, OnboardingBudgetingExplainerView.swift, WinnieCurrencyInput.swift
- **Modified files**: OnboardingCoordinator.swift, OnboardingState.swift, OnboardingCarouselView.swift, OnboardingIncomeView.swift, OnboardingSavingsPoolView.swift, OnboardingNestEggView.swift, OnboardingGoalDetailView.swift

### January 2, 2026 (Session 16) - Tab Bar Navigation
- **Tab Bar Implementation**: Added native iOS 18 TabView with 4 tabs
- Created `DashboardView` and `ScenariosView` as placeholders with "Coming Soon" message
- Created `MeView` profile tab with user's first name in toolbar (tappable to edit)
- Created `EditNameSheet` bottom sheet for editing display name (follows NameInputView pattern)
- Moved sign out button from ContentView overlay to MeView
- Settings cogwheel placeholder in MeView toolbar
- Refactored `ContentView` to use TabView instead of direct GoalsListView
- Tab order: Dashboard (default), Goals, Scenarios, Me
- Uses SF Symbols: chart.pie.fill, target, chart.line.uptrend.xyaxis, person.fill

### January 2, 2026 (Session 15) - Code Audit Medium Priority Fixes
- **Completed all 9 medium priority issues** from code audit
- **Task.sleep Removal**: Replaced `Task.sleep` timing hack in GoalCreationView with `.onAppear`
- **Safe Area Standardization**: Updated 5 files to use explicit `.ignoresSafeArea(edges: .all)`
- **@unchecked Sendable**: Added documentation explaining why usage is intentional (Firebase SDK thread-safe)
- **Listener Cleanup**: Added `deinit` to GoalsViewModel for automatic listener removal
- **Repository Caching**: AppState now uses lazy cached UserRepository instead of creating per-call
- **Design Tokens**: Added `iconSizeL/M/S` to WinnieSpacing, updated views to use design tokens
- **Password Security**: Strengthened to 10+ chars with uppercase, lowercase, and number requirements
- **NotificationCenter Refactor**:
  - Removed fire-and-forget notification pattern for new Apple Sign-In users
  - `signInWithApple()` now returns `NewUserInfo?` for proper data flow
  - `AppState.loadUser()` accepts optional `initialData` for new user info
  - Updated tests to verify return value instead of notification
- **Files modified**: 14 files across Services, Features, Core, and Tests
- **Code audit status**: All Immediate, High, and Medium items resolved (1 deferred for future)

### January 1, 2025 (Session 14) - Avatar Profile Pictures & User Data Flow
- **Avatar System**: Replaced initials-based avatars with illustrated profile pictures
- Created `UserProfileAvatar` component using SVG assets
- Imported avatar SVGs into Xcode asset catalog (MaleAvatarCircle, FemaleAvatarCircle)
- Updated GoalDetailView and ContributionRow to use avatars
- **User Data Flow**: Fixed hardcoded "You" placeholder to use real user data
- Created `AppState` class to hold user/partner data centrally
- Created `NameInputView` for onboarding name collection (industry standard)
- Updated WinnieApp to load user from Firestore on auth
- Updated ContentView to pass real user data to GoalsListView
- **Flow**: Sign in → Load user from Firestore → Show name input if needed → Show main app
- Users without displayName see "What should we call you?" screen

### December 31, 2024 (Session 13) - Goal Creation & Edit UI Refinements
- **GoalIconMapper Expansion**: Expanded from ~80 to 300+ keywords across 20+ categories
- Added 9 new GoalType enum cases: debt, car, education, hobby, fitness, gift, homeImprovement, investment, charity
- Fixed word boundary matching so "credit card" doesn't incorrectly match "car" icon
- Auto-populate category from goal name when entering Phase 2 of creation
- **UI Improvements**:
  - Removed X button, added native iOS drag indicator to sheets
  - Fixed header text color (snow in light mode, ink in dark mode for readability)
  - Made header icon tappable in Phase 2 with pencil badge
  - Created `GoalAppearanceSheet` for icon/color customization (color picker + icon picker)
  - Moved icon/color pickers out of form into tappable header
- **GoalEditView Created**: New edit view matching Phase 2 of goal creation
  - Reuses `GoalCreationHeaderView`, `GoalDetailsFormView`, `GoalAppearanceSheet`
  - Pre-populates from existing goal
  - "Save Changes" button at bottom
- **Deleted GoalFormView**: No longer needed (creation uses GoalCreationView, edit uses GoalEditView)
- **Test Environment Isolation**: Fixed crash when running unit tests
  - Added `isRunningTests` check using `NSClassFromString("XCTestCase")`
  - `WinnieApp` skips `FirebaseApp.configure()` during tests
  - `AuthenticationService` uses `NoOpAuthProvider` during tests
  - Prevents real Firebase from running alongside mock-based tests
- **Total files**: 7 new/modified files in GoalCreation folder + GoalEditView

### December 30, 2024 (Session 12) - Goals Vertical Slice Complete
- **Goals Vertical Slice Complete**: First full UI feature with CRUD operations working end-to-end
- Created 5 reusable components in `Core/Components/`:
  - `WinnieButton` - Primary/secondary/text button variants with press animation
  - `WinnieCard` - Styled card with optional accent border
  - `WinnieTextField` - Text input with label/validation + `WinnieCurrencyField`
  - `WinnieProgressBar` - Animated progress bar with customizable color
  - `GoalCard` - Goal summary card with type icon, amounts, and progress
- Created `GoalsViewModel` with @Observable pattern and @MainActor thread safety
- Created 3 goal views in `Features/Goals/`:
  - `GoalsListView` - Main screen with empty state, loading, and goal cards
  - `GoalDetailView` - Full goal info with progress, edit/delete actions
  - Goal creation/edit forms (later refactored into GoalCreationView and GoalEditView)
- Wired up navigation in ContentView (shows GoalsListView after sign-in)
- Added `Sendable` conformance to Goal and GoalType for async safety
- **Critical Bug Fixed**: Async closures across sheet boundaries caused memory corruption (EXC_BAD_ACCESS with 8GB allocation failure). Solution: Form views use sync callback, parent wraps in Task.
- **Pattern Established**: Sheet forms use sync `onSave` callbacks; parent views handle async operations via Task wrapper
- **Total new files**: 9 files created for vertical slice

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
