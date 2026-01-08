# Fix: Direct Savings Onboarding Path

## Problem

When users select "I'll enter my monthly savings" (quick setup) during onboarding:
- They skip the Income, Needs, and Wants screens
- They enter their savings pool directly (e.g., $2,500)
- But the FinancialProfile is saved with income=0, needs=0, wants=0
- Result: `monthlyDisposable = income - needs - wants = 0 - 0 - 0 = $0`

The current data model assumes everyone goes through the guided path where income/needs/wants are calculated. Users who know their savings directly don't need to enter income - their savings IS the key number for scenario planning.

## Solution

Add a `directSavingsPool` field to FinancialProfile that stores the user's directly-entered savings amount. The `monthlyDisposable` computed property will check this field first.

This allows:
- Quick setup users to skip income/expenses entirely
- Later, users can optionally fill in their full breakdown in a settings/profile screen

---

## Files to Modify

### 1. `Models/FinancialProfile.swift`
- Add `directSavingsPool: Decimal?` property
- Update `monthlyDisposable` computed property to check `directSavingsPool` first
- Update initializers

### 2. `Services/Firestore/DTOs/FinancialProfileDTO.swift`
- Add `directSavingsPool: Double?` field
- Update `init(from profile:)` to map the new field
- Update `toFinancialProfile()` to restore the field
- Update `dictionary` to include the field

### 3. `Features/Onboarding/OnboardingState.swift`
- Update `toFinancialProfile()` to set `directSavingsPool` when `knowsSavingsAmount` is true
- Revert the earlier "implied expenses" workaround

---

## Implementation Details

### FinancialProfile.swift Changes

```swift
struct FinancialProfile {
    var monthlyIncome: Decimal
    var monthlyNeeds: Decimal
    var monthlyWants: Decimal
    var currentSavings: Decimal
    var retirementBalance: Decimal?
    var lastUpdated: Date

    /// Direct savings pool entry (used when user skips income/expense breakdown)
    /// When set, this takes precedence over the calculated savingsPool
    var directSavingsPool: Decimal?

    /// The "Savings Pool" - money available for goals
    var savingsPool: Decimal {
        // If user entered savings directly, use that
        if let direct = directSavingsPool, direct > 0 {
            return direct
        }
        // Otherwise calculate from income - needs - wants
        return max(monthlyIncome - monthlyNeeds - monthlyWants, 0)
    }

    /// Available monthly amount for goal allocation
    var monthlyDisposable: Decimal {
        savingsPool
    }
}
```

### OnboardingState.toFinancialProfile() Changes

```swift
func toFinancialProfile() -> FinancialProfile {
    if knowsSavingsAmount {
        // Quick path: user entered savings directly, skip income/expenses
        return FinancialProfile(
            monthlyIncome: 0,
            monthlyNeeds: 0,
            monthlyWants: 0,
            currentSavings: startingBalance,
            directSavingsPool: directSavingsPool
        )
    } else {
        // Guided path: user entered income/needs/wants
        return FinancialProfile(
            monthlyIncome: monthlyIncome,
            monthlyNeeds: monthlyNeeds,
            monthlyWants: monthlyWants,
            currentSavings: startingBalance,
            directSavingsPool: nil
        )
    }
}
```

---

## Verification

1. **Build** in Xcode (Cmd+B)

2. **Test Quick Setup Path:**
   - Reset onboarding
   - Select "I'll enter my monthly savings"
   - Enter $2,500 as savings pool
   - Complete onboarding
   - Go to Planning tab → New Scenario
   - Verify Monthly Budget shows **$2,500**

3. **Test Guided Path:**
   - Reset onboarding
   - Select "Help me calculate"
   - Enter income: $5,000, needs: $2,000, wants: $1,000
   - Complete onboarding
   - Go to Planning tab → New Scenario
   - Verify Monthly Budget shows **$2,000** (5000 - 2000 - 1000)

4. **Check Firestore:**
   - Verify `directSavingsPool` field is saved in `/couples/{id}/financialProfile/profile`
