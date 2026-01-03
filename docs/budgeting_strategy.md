# Product Strategy: Budgeting vs. Planning

## The Core Question
**"Does it make sense to require a budget, or can we skip it?"**

The core value proposition of Winnie is the **Planning Engine** (Trade-offs, Scenarios, Goals). However, the Planning Engine requires fuel to run. That fuel is the **Savings Pool** (Investable Income).

Without a "Savings Pool" number, the engine cannot calculate trade-offs. Therefore, gaining this number is a **requirement**, but the **method** of getting it should be flexible.

## The Proposal: "The Hybrid Input" (Two-Way Workflow)

You initially proposed a flow: **Income - Needs - Wants = Savings Pool**.
This is the "Bottom-Up" approach. It is accurate but high-friction.

The alternative is the "Top-Down" approach: **"I save $500/month."**
This is low-friction but prone to user estimation error.

### Recommendation: Support Both
We should implement the "Two-Way Workflow" you suggested. This accommodates both meticulous planners and "big picture" users.

### User Flow
1. **Onboarding / Financial Setup**: "What is your savings pool?"
2. **The Fork**:
   - **Path A: "I know my number"** (Quick Start)
     - User enters: "I can save $1,000 / month."
     - *Result*: Immediate access to Planning Engine.
   - **Path B: "Help me figure it out"** (Budget Wizard)
     - Winnie provides **Pre-populated Categories** for common expenses (Rent, Groceries, Utilities, etc.)
     - User review/edits: Fixed Expenses -> *Needs*
     - User review/edits: Flex Expenses -> *Wants*
     - *Result*: Winnie calculates: "It looks like you can save ~$450/month. Does that sound right?"

## Integration with "Three Buckets" Model

Your model: **Budget -> Goals -> Planning**

### 1. The Budget Bucket (The Source)
*Purpose*: Define the constraints.
*Output*: A single variable: `monthlySavingsCapacity`.

**Design Note**: Don't build a full-blown budgeting app (like YNAB or Mint) where users track every coffee. Keep it high-level:
- Monthly Income
- "Needs" (Fixed)
- "Wants" (Variable estimate)
- **Result**: `Savings Pool`

### 2. The Goals Bucket (The Destination)
*Purpose*: Define the desires.
*Inputs*: Car, Wedding, House.
*Status*: You have already built this! (Goals Vertical Slice).

### 3. The Planning Engine (The Magic)
*Purpose*: Connect Source to Destination.
*Logic*:
- `Savings Pool` allocates to `Goals` based on `Priority/Timeline`.
- **Scenario A**: "Buy car now" -> `Savings Pool` drains by $500/mo -> House delayed.
- **Scenario B**: "Buy car later" -> `Savings Pool` accumulates -> House on time.

## Advantages of this Approach
1.  **Low Friction Entry**: Users who just want to see "Can I afford the house?" can skip the budget tedium.
2.  **Educational**: Users who don't know their savings potential get guided help.
3.  **Focus on Differentiation**: Winnie isn't a "Budget Tracker" (looking backward at what you spent). It is a "Future Planner" (looking forward at what you can do). The Budgeting features should strictly serve the Planning engine.

## Next Steps
1.  **Backend**: We need a `FinancialProfile` model update to store `monthlyIncome`, `monthlyNeeds`, `monthlyWants`, and the calculated `monthlySavingspool`.
2.  **UI**: Build the "Financial Baseline" onboarding screens with the split path.
