# Plan: Connect Goal Target Dates with Plan Projections

## Overview

Change goal "on track" status to be based on **plan projections** rather than linear time progress. When a goal's projected completion date (from the active plan) is later than the user's target date, flag it as "behind" and provide actionable solutions.

## Key Insight

The pattern already exists in `DashboardViewModel` - it listens to the active scenario and calculates projections. We need to extend this to `GoalDetailViewModel`.

---

## Implementation Steps

### Step 1: Create `GoalTrackingInfo` Struct

**File:** `/Winnie/Features/Goals/GoalDetailViewModel.swift`

Add a new struct that provides rich tracking data beyond just a status:

```swift
/// Rich on-track status with actionable data
struct GoalTrackingInfo: Equatable {
    let status: OnTrackStatus
    let projectedCompletionDate: Date?      // From active plan
    let desiredDate: Date?                   // User's target
    let currentMonthlyContribution: Decimal  // From active plan
    let requiredMonthlyContribution: Decimal? // To hit target date
    let monthsDifference: Int?               // Negative = behind
    let hasActivePlanAllocation: Bool

    var canProvideRecommendation: Bool {
        status == .behind && requiredMonthlyContribution != nil
    }
}
```

### Step 2: Add Dependencies to GoalDetailViewModel

**File:** `/Winnie/Features/Goals/GoalDetailViewModel.swift`

Add:
- `scenarioRepository: ScenarioRepository` - to listen for active scenario
- `coupleRepository: CoupleRepository` - to fetch financial profile
- `financialEngine: FinancialEngine` - to calculate projections
- `activeScenario: Scenario?` - current active plan
- `financialProfile: FinancialProfile?` - needed for calculations
- `trackingInfo: GoalTrackingInfo?` - computed tracking status
- `scenarioListener` - for real-time updates

### Step 3: Listen to Active Scenario

**File:** `/Winnie/Features/Goals/GoalDetailViewModel.swift`

In `startListening()`:
1. Add listener to active scenario via `scenarioRepository.listenToActiveScenario()`
2. Load financial profile via `coupleRepository.fetchFinancialProfile()`
3. Call `recalculateTrackingInfo()` when data changes

In `stopListening()`:
- Remove the scenario listener

### Step 4: Replace On-Track Calculation

**File:** `/Winnie/Features/Goals/GoalDetailViewModel.swift`

Replace `calculateOnTrackStatus()` with new `calculateTrackingInfo()`:

**Logic:**
1. If goal is completed → `.completed`
2. If no target date → `.noTarget` (but still show projected date if plan exists)
3. If has target date:
   - Get allocation from active scenario
   - Calculate projected completion using `financialEngine.calculateGoalProjection()`
   - Calculate required contribution using `financialEngine.requiredMonthlyContribution()`
   - Compare projected date vs desired date
   - If projected > desired (or no allocation) → `.behind`
   - If projected <= desired → `.onTrack`

### Step 5: Update Goal Detail UI

**File:** `/Winnie/Features/Goals/GoalDetailView.swift`

Enhance the status display when goal is "behind":

1. **Show why behind:**
   - "No plan allocating to this goal" (if no allocation)
   - "Current plan projects X months late" (if behind)

2. **Show solutions with actionable buttons:**
   - "Save $X/month to reach your target" (required contribution - informational)
   - "Adjust target to [projected date]" - **tappable button** that updates the goal's target date

3. **Update Monthly Contribution row:**
   - Show actual allocation from plan instead of hardcoded value
   - Show "Not in plan" if no allocation

### Step 6: Add Target Date Update Method

**File:** `/Winnie/Features/Goals/GoalDetailViewModel.swift`

Add method to update goal's target date:

```swift
/// Update the goal's target date to match the projected completion date
func adjustTargetDateToProjection() async {
    guard let projectedDate = trackingInfo?.projectedCompletionDate else { return }
    var updatedGoal = goal
    updatedGoal.desiredDate = projectedDate
    await updateGoal(updatedGoal)
    recalculateTrackingInfo()
}
```

This allows users to accept the projected date with one tap, resolving the "behind" status.

---

## Edge Cases

| Scenario | Behavior |
|----------|----------|
| No active plan | Show "behind" with "No plan allocating to this goal" |
| Plan exists, no allocation to this goal | Same as above |
| No target date | Show "No Target Date", still show projected date if available |
| Goal completed | Show "Complete" |
| Target date in past | Show "behind" |

---

## Files to Modify

| File | Changes |
|------|---------|
| `Winnie/Features/Goals/GoalDetailViewModel.swift` | Add `GoalTrackingInfo`, dependencies, scenario listener, new calculation logic |
| `Winnie/Features/Goals/GoalDetailView.swift` | Update status section UI to show rich tracking info and recommendations |

---

## Verification

1. **Build in Xcode** (Cmd+B) - verify no compile errors
2. **Manual testing:**
   - Create a goal with a target date
   - Create a plan with allocation to that goal
   - Verify status shows "On Track" or "Behind" based on projection vs target
   - Verify recommendations display when behind
   - Tap "Adjust target" button and verify goal's target date updates
   - Verify status changes to "On Track" after adjusting
   - Test with no plan / no allocation
   - Test changing active plan while viewing goal
3. **Run tests** (Cmd+U) - verify existing tests pass
