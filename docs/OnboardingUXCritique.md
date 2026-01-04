# Onboarding UX Critique

> Created: January 3, 2026
> Status: To be implemented incrementally

---

## Executive Summary

This document captures UX friction points in the Winnie onboarding flow, organized by priority. Issues range from content/copy problems to structural flow issues.

---

## 🔴 Critical Issues

### 1. Goal Selection Before Establishing Value

**Problem:** User picks a goal immediately after the carousel, before experiencing any personalized value.

**Current Flow:**
```
Splash → Carousel (features) → Goal Picker
```

**Recommendation:** Show a personalized glimpse of value before asking for details. Consider:
- Light goal selection → Personalized carousel → Details
- Or: Show "Here's what your finances could look like" before goal picker

---

### 2. Savings Question Feels Like a Test

**Current Copy:**
> "Do you know how much you currently save each month?"
> - "Yes, I know how much I save"
> - "No, please help me figure it out"

**Problems:**
- Feels like a quiz, not a helping hand
- "No" path = 4 extra screens (punishes honesty)
- Makes users feel financially illiterate

**Recommended Rewrite:**
> "How would you like to set up your savings?"
> - "I'll enter my monthly savings" *(Quick setup)*
> - "Help me calculate from my budget" *(Guided setup)*

---

### 3. Needs/Wants Slider Experience is Tedious

**Problem:** 5 sliders × 2 screens = 10 slider interactions

**Issues:**
- Sliders are imprecise for financial data
- Range caps may not fit all users (needs: $5K, wants: $2K)
- No way to type exact amounts
- All default to $0 — user must touch every slider

**Options:**
1. Single input per screen: "About how much do you spend on fixed bills?"
2. Smart defaults based on income percentages
3. Optional breakdown: "Want to break this down by category?"

---

### 4. Partner Assumptions for Solo Users

**Problem:** Multiple screens mention partners even for solo users:
- "Only enter yours, we will add your partner's later"
- Partner invite is mandatory-feeling (8/8 or 12/12)

**Recommendation:**
- Ask early: "Are you planning finances with a partner?"
- Remove partner mentions for solo flow
- Move partner invite to post-onboarding prompt

---

## 🟠 Moderate Issues

### 5. Goal Date Asked Before Showing Feasibility

**Current Order:**
```
Goal Picker → ... → Nest Egg → Goal Detail (amount + date) → Projection
```

**Problem:** Asks "When do you want to buy?" BEFORE showing if it's realistic. Projection might show 2031 for a user who said 2026.

**Better Order:**
```
Goal Picker → ... → Goal Amount → Projection → "Want to adjust timeline?"
```

---

### 6. "Nest Egg" Term May Confuse Users

**Current:**
> "Your nest egg"
> "How much cash do you have saved up right now..."

**Problem:** "Nest egg" often means retirement savings specifically.

**Recommended Rewrite:**
> "Your starting balance"
> "How much do you already have saved that you want to count toward this goal?"

---

### 7. Projection Screen Edge Cases

**Current:** Shows projected date assuming positive savings.

**Not Handled:**
- Savings pool is $0 or negative
- Projection is 20+ years away
- Projected date is past user's desired date

**Recommendation:** Add graceful messaging for each edge case.

---

## 🟡 Quick Wins

### 8. Typo in Carousel

**Current:** "Find the optimal savings path to **acheive** all of your goals."

**Fix:** Change to "achieve"

---

### 9. Inconsistent Tone Across Screens

| Screen | Current Tone |
|--------|--------------|
| Splash | Philosophical |
| Carousel | Feature-focused |
| Goal Picker | Friendly |
| Savings Question | Quiz-like |
| Projection | Celebratory |

**Recommendation:** Unify to warm, expert tone throughout.

---

## Progress Bar Issues (Separate Implementation)

### 10. Progress Confusion at Branching Point

User sees "2/8" then taps "help me calculate" and suddenly sees "4/12".

### 11. Partner Invite in Progress Count

Shows as 8/8 or 12/12 but user can skip — feels arbitrary.

### 12. Animation Timing

Progress bar animation doesn't match iOS nav transition timing.

---

## Implementation Priority

| Priority | Issue | Effort | Impact |
|----------|-------|--------|--------|
| 1 | Reframe savings question (#2) | Low | High |
| 2 | Fix typo (#8) | Trivial | Low |
| 3 | Simplify expense input (#3) | Medium | High |
| 4 | Handle solo users (#4) | Medium | Medium |
| 5 | Nest egg terminology (#6) | Low | Medium |
| 6 | Goal order logic (#5) | High | High |
| 7 | Unify tone (#9) | Medium | Medium |
| 8 | Edge case handling (#7) | Medium | Medium |
| 9 | Progress bar fixes (#10-12) | Medium | Medium |

---

## What the Onboarding Gets Right

| Strength | Why It Works |
|----------|--------------|
| Goal-first approach | Makes it personal, not generic budgeting |
| Needs/Wants/Savings model | Simpler than category budgets |
| Branching based on knowledge | Respects user's existing awareness |
| Projection "magic moment" | Clear value delivery |
| Clean visual design | Matches premium app expectations |
