# Goal-Plan Integration Summary

*Last updated: January 8, 2026*

This document summarizes the goal-plan integration system we've built and key concepts to keep in mind for continued development.

---

## Core Concepts

### 1. Goals vs Plans (Scenarios)

- **Goal**: A savings target (e.g., "House Down Payment - $50,000")
- **Scenario/Plan**: A monthly allocation strategy that distributes disposable income across goals
- **Allocation**: The monthly dollar amount assigned to a goal within a scenario

### 2. Tracking Status

Goals have a **tracking status** based on their relationship to the active plan:

| Status | Condition | User Action |
|--------|-----------|-------------|
| `completed` | `currentAmount >= targetAmount` | None needed |
| `noTargetDate` | Goal has no `desiredDate` set | Can still show projected date |
| `notInPlan` | Has target date but no allocation in active plan | "Add to Plan" button |
| `onTrack` | Projected completion ≤ target date | None needed |
| `behind` | Projected completion > target date | "Adjust Target" or "Change Allocation" |

### 3. Date Comparison (IMPORTANT)

**Bug we fixed**: Dates are compared at **month granularity**, not exact date/time.

```swift
// Compare year*12 + month, not exact Date values
let projectedMonths = (projectedComponents.year ?? 0) * 12 + (projectedComponents.month ?? 0)
let targetMonths = (targetComponents.year ?? 0) * 12 + (targetComponents.month ?? 0)

if projectedMonths <= targetMonths {
    return .onTrack(details)
}
```

**Why**: The `FinancialEngine` calculates `completionDate` as `Date() + X months`. Each recalculation uses a new `Date()`, causing drift. Users think in terms of "March 2027" not "March 8, 2027 at 3:15 PM".

### 4. "Adjust Target" Sets End of Month

When a user clicks "Adjust target to [Month Year]", we set the target to the **last day** of that month:

```swift
let endOfMonth = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: startOfMonth)
updatedGoal.desiredDate = endOfMonth
```

**Why**: Provides margin of safety for any future recalculation drift.

---

## Architecture

### Data Flow

```
FinancialProfile (monthly disposable income)
        +
      Goals (target amounts, current amounts, desired dates)
        +
    Scenario (allocations per goal)
        ↓
   FinancialEngine.calculate()
        ↓
   EngineOutput (projections per goal)
        ↓
   GoalProjection (monthsToComplete, completionDate, monthlyContribution)
        ↓
   GoalTrackingStatus (on track / behind / not in plan / etc.)
```

### Key Models

| Model | Purpose |
|-------|---------|
| `Goal` | Savings target with amount, date, type |
| `Scenario` | Named allocation configuration (a "plan") |
| `Allocation` | Map of goalID → monthly Decimal amount |
| `GoalProjection` | Engine output for one goal |
| `GoalTrackingStatus` | Enum with associated values for UI display |
| `FinancialProfile` | User's income/expenses/disposable |

### Key Files

| File | Purpose |
|------|---------|
| `GoalTrackingStatus.swift` | Clean enum for tracking states |
| `FinancialEngine.swift` | Projection calculations |
| `FinancialCalculations.swift` | Math functions (monthsToReachTarget, etc.) |
| `GoalDetailViewModel.swift` | Calculates tracking status for a single goal |
| `GoalsViewModel.swift` | Listens to active scenario, provides projections |
| `ScenarioDetailViewModel.swift` | Calculates status for all goals in a plan |
| `ScenarioDetailView.swift` | Read-only plan detail view |
| `ScenarioEditorView.swift` | Edit allocations, select goals |

---

## What We Built

### 1. Goal-Plan Integration (GoalDetailView)

- Goals show tracking status based on active plan's projection
- "Not in Plan" shows when goal has no allocation
- "Behind" shows with recommended monthly amount
- "Adjust target" button moves target date to projected date
- Monthly Allocation row shows actual allocation from plan

### 2. Scenario Auto-Activation

First scenario created is automatically set as active:

```swift
// In ScenarioEditorViewModel.saveScenario()
let allScenarios = try await scenarioRepository.fetchAllScenarios(coupleID: coupleID)
if allScenarios.count == 1 {
    try await scenarioRepository.setActiveScenario(scenarioID: scenario.id, coupleID: coupleID)
}
```

### 3. Goal Selection in Scenario Editor

- All goals start selected by default
- Checkbox UI to include/exclude goals from plan
- Only selected goals show allocation sliders
- Deselecting a goal clears its allocation

### 4. Plan Detail View (NEW - in progress)

- Tap a plan → Opens `ScenarioDetailView` (read-only)
- Shows all goals with their tracking status
- Action buttons: "Adjust Target", "Edit Allocation"
- "Edit" button in nav bar → Opens `ScenarioEditorView`

**Files created:**
- `ScenarioDetailView.swift`
- `ScenarioDetailViewModel.swift`
- `ScenarioGoalRow.swift`
- `AllocationEditSheet.swift`

**Modified:**
- `ScenarioListView.swift` - Changed tap to navigate to detail view
- `Scenario.swift` - Added `Hashable` conformance
- `Allocation.swift` - Added `Hashable` conformance

---

## Important Patterns

### 1. Projections Come from Parent

Don't recalculate projections in every ViewModel. Pass them from parent:

```swift
// GoalDetailViewModel gets projection from GoalsViewModel
var projection: GoalProjection? {
    goalsViewModel.projection(for: goal.id)
}
```

### 2. GoalTrackingStatus Enum

Use associated values, not optionals:

```swift
enum GoalTrackingStatus: Equatable {
    case completed
    case noTargetDate(projectedDate: Date?)
    case notInPlan(targetDate: Date)
    case onTrack(TrackingDetails)
    case behind(TrackingDetails, requiredContribution: Decimal)

    struct TrackingDetails: Equatable {
        let projectedDate: Date
        let targetDate: Date
        let monthsDifference: Int
        let currentContribution: Decimal
    }
}
```

### 3. Month-Level Date Comparison

Always compare dates by year+month for status calculations:

```swift
let projectedMonths = year * 12 + month
let targetMonths = year * 12 + month
if projectedMonths <= targetMonths { /* on track */ }
```

### 4. Active Scenario Listener

`GoalsViewModel` listens to the active scenario to provide projections:

```swift
scenarioListener = scenarioRepository.listenToActiveScenario(coupleID: coupleID) { [weak self] scenario in
    self?.activeScenario = scenario
}
```

---

## Known Issues / TODOs

1. **Build error**: Need to verify `ScenarioDetailView` and related files compile
2. **"Add to Plan" sheet**: Currently a placeholder - needs real implementation
3. **Real-time updates**: When partner changes allocation, detail view should update
4. **Testing**: Need unit tests for `GoalTrackingStatus` calculation logic

---

## Testing Checklist

When making changes to goal-plan integration:

- [ ] Goal with no target date shows "No Target Date"
- [ ] Goal not in plan shows "Not in Plan" with "Add to Plan" button
- [ ] Goal projected early shows "On Track" with months early
- [ ] Goal projected late shows "Behind" with required contribution
- [ ] Clicking "Adjust target" changes status to "On Track"
- [ ] Changing allocation updates projections immediately
- [ ] First scenario auto-activates
- [ ] Tap plan → opens detail view (not editor)
- [ ] Edit button in detail view → opens editor sheet

---

## Quick Reference: Status Calculation

```swift
private func calculateTrackingStatus(for goal: Goal) -> GoalTrackingStatus {
    // 1. Completed?
    if goal.currentAmount >= goal.targetAmount { return .completed }

    // 2. Has target date?
    guard let targetDate = goal.desiredDate else {
        return .noTargetDate(projectedDate: projection?.completionDate)
    }

    // 3. Has allocation in plan?
    guard let projection = projection, projection.monthlyContribution > 0 else {
        return .notInPlan(targetDate: targetDate)
    }

    // 4. Has valid projection?
    guard let projectedDate = projection.completionDate else {
        return .behind(...) // unreachable
    }

    // 5. Compare at month granularity
    let projectedMonths = year * 12 + month
    let targetMonths = year * 12 + month

    if projectedMonths <= targetMonths {
        return .onTrack(details)
    } else {
        return .behind(details, requiredContribution: ...)
    }
}
```
