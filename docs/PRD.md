# Winnie Product Requirements Document
**Money decisions, made together.**

| Version | Date | Author | Status |
| :--- | :--- | :--- | :--- |
| 1.0 | December 28, 2024 | Austin | Draft |

---

## Executive Summary
Winnie is a personal finance app designed specifically for couples who need quick, trustworthy answers to forward-looking financial questions. Instead of tracking every transaction or requiring bank account linking, Winnie focuses on scenario-based planning that helps couples make informed decisions about competing financial goals.

The app addresses a specific pain point: when one partner asks questions like "when can we buy a house?" or "can we afford the honeymoon we want?", couples currently have no easy way to see the tradeoffs between different financial priorities without building complex spreadsheets or hiring a financial advisor.

Winnie sits in a unique market position between sophisticated modelling tools like ProjectionLab and couples budgeting apps like Monarch Money. It offers scenario planning without complexity, and couples collaboration without requiring bank account access.

**Target market:** Engaged and married couples planning major life milestones together, with household income of $60k-$200k annually.

---

## Problem Statement

### The Core Problem
Couples face a recurring scenario: one partner asks a time-sensitive financial question that requires understanding tradeoffs between multiple competing goals. Current solutions are inadequate:
*   **Budgeting apps** track past spending but don't model future scenarios.
*   **Spreadsheets** are time-consuming to build and maintain, rarely kept up-to-date.
*   **Financial advisors** are expensive and not available for quick questions.
*   **Sophisticated planning tools** (e.g., ProjectionLab) are too complex for everyday use.

### User Pain Points
*   **Primary pain point:** "When my fiancé asks 'when can we buy a house?' I can't give them a quick, informed answer that accounts for our other goals like retirement and our honeymoon."
*   **Secondary pain points:**
    *   Decision paralysis when facing tradeoffs between goals.
    *   Misaligned expectations between partners about financial timelines.
    *   Anxiety about whether financial plans are realistic.
    *   Lack of transparency in shared financial planning.

---

## Solution Overview
Winnie is a manual-input financial planning app that enables couples to quickly model scenarios and understand tradeoffs between competing financial goals. The app uses realistic financial assumptions to project timelines for major goals like buying a house, retirement, vacations, and other milestones.

### Core Value Proposition
"Get a trustworthy answer to your financial questions in under 2 minutes, without linking your bank accounts or building spreadsheets."

### Key Differentiators
*   **No bank linking required** - privacy-first, simple manual input.
*   **Couples-native design** - shared visibility, collaborative decision-making.
*   **Forward-looking scenario planning** - not backward-looking expense tracking.
*   **Visual tradeoff modelling** - instantly see how allocation changes affect all goals.
*   **Realistic financial modelling** - uses actual market returns, inflation, and tax considerations.

---

## Target Users

### Primary Persona: Planning Couples
*   **Demographics:** Ages 28-40, engaged or married, household income $60k-$200k annually.
*   **Behaviours:** Planning major life milestones, regularly discuss money with partner, prefer systematic approaches to finances.
*   **Goals:** Home purchase, retirement planning, honeymoon/vacation savings, emergency fund building.
*   **Pain Points:** Can't quickly answer partner's financial questions, unsure about realistic timelines, anxious about tradeoffs.
*   **Tech Comfort:** Comfortable with apps, prefer privacy over automation, willing to input data manually for simplicity.

---

## Core Features

### 1. Simple Financial Profile Setup
One-time setup to establish baseline financial snapshot.
*   **Required inputs:**
    *   Monthly take-home income (combined or individual)
    *   Monthly expenses (rough estimate)
    *   Current savings balance
    *   Current retirement account balance (optional)
*   **Calculated output:**
    *   Monthly disposable income (take-home minus expenses)
    *   Available pool for goal allocation
*   **Design considerations:**
    *   Quick setup (under 3 minutes)
    *   "Roughly right" philosophy - round numbers acceptable
    *   Both partners can input separately or together

### 2. Goal Definition and Tracking
Create and prioritize multiple financial goals with target amounts and desired timelines.
*   **Supported goal types:**
    *   **House down payment** - uses conservative returns (4-5% HYSA rates) for short-term timeframe.
    *   **Retirement** - uses historical stock market returns (7% real returns) for long-term timeframe.
    *   **Vacation/honeymoon** - short-term goal with specific date.
    *   **Emergency fund** - typically 3-6 months of expenses.
    *   **Child & Family Planning** - specialized lifecycle modelling for child costs (daycare to college).
    *   **Custom goals** - car, education, etc.
*   **User specifications per goal:**
    *   Target amount needed
    *   Desired timeline (if applicable)
    *   Current progress (if any)

### 3. Interactive Allocation Modeling
The core feature: allocate disposable income across goals and instantly see timeline impacts.
*   **Key functionality:**
    *   Visual slider interface to allocate monthly disposable income.
    *   Real-time calculation of goal completion timelines.
    *   Side-by-side comparison of different allocation scenarios.
    *   "What if" capability: adjust allocation and see immediate impact.
    *   Saved scenarios for comparison (e.g., "aggressive house saving" vs "balanced approach").

### 4. Realistic Financial Projections
Transparent, conservative financial modelling using historical data.
*   **Core assumptions (visible to users):**
    *   **Stock market returns:** 7% real returns (10% nominal - 3% inflation) for goals 5+ years out.
    *   **HYSA returns:** 3.5% for goals under 5 years.
    *   **Inflation:** 3% annually, applied to purchasing power calculations.
    *   **Tax considerations:** Basic modelling for retirement account growth (pre vs post-tax).
*   **Transparency features:**
    *   Tap to expand: show assumptions behind each projection.
    *   Settings page: view and understand all default assumptions.
    *   Educational tooltips explaining financial concepts.

### 5. Couples Collaboration
Shared visibility and collaborative decision-making built into the core experience.
*   **Key features:**
    *   Shared account with individual login credentials.
    *   Both partners see the same projections and scenarios.
    *   Either partner can create/modify scenarios.
    *   Scenario naming and notes for context.
    *   "Decision mode" - mark scenarios as under consideration vs decided.

### 6. Child & Family Planning Module
Specialized forecasting tool to guide decisions on when to have children and model the financial impact across the child's lifecycle.
*   **Lifecycle Cost Modelling:** Automatically projects varying costs across key stages:
    *   **Early Years:** Diapers, formula, medical costs.
    *   **Childcare:** Daycare/nanny costs (often the largest expense).
    *   **School Age:** Sports, extracurriculars, private school tuition (optional).
    *   **College:** 529 savings projections and tuition inflation modelling.
*   **Decision Support:**
    *   **"Baby Timeline" Scenarios:** See how delaying or accelerating having a child impacts other goals (e.g., "If we have a baby in 2 years vs. 4 years, how does that change our house buying timeline?").
    *   **Cost layering:** Visualizes how child costs layer on top of existing expenses, highlighting potential cash flow crunches.

### 7. "Stress Test" Mode (Resilience Planning)
Build confidence by testing plans against negative scenarios to ensure financial security.
*   **Key Functionality:**
    *   **One-tap toggle:** Apply common adverse events (e.g., "Job Loss (3 months)", "Market Correction (-20%)", "Unexpected Expense ($5k)").
    *   **Visual Impact:** Instantly see how these events delay goal timelines (e.g., "House purchase delayed by 6 months").
    *   **Safety Score:** Provides a "Resilience Rating" for the current plan to encourage buffer building.

### 8. "Windfall" Allocator
A dedicated tool for resolving decisions about one-time cash inflows (bonuses, tax returns, wedding gifts).
*   **Key Functionality:**
    *   **Lump Sum Input:** Enter the windfall amount.
    *   **Smart Split:** Recommendations based on current goal priorities.
    *   **Comparative Modelling:** "What if we put it all toward the House?" vs. "What if we invest it?" vs. "50/50 Split".
    *   **Instant Gratification:** Shows immediate timeline acceleration (e.g., "This bonus cuts 2 months off your house wait").

### 9. Debt vs. Invest Tradeoff
Mathematical guidance on the common "pay down debt or invest" dilemma.
*   **Key Functionality:**
    *   **Comparator:** Input debt details (balance, interest rate) vs. investment potential (projected return).
    *   **Math-based Recommendation:** Compares guaranteed return of debt payoff vs. probable market returns.
    *   **Psychological Factor:** Acknowledges "Peace of Mind" benefit of debt freedom even if mathematically suboptimal.
    *   **Trajectory Visualization:** Visualizes net worth trajectory for both paths over 5/10 years.

---

## Technical Requirements

### Platform
*   **Primary platform:** iOS mobile app.
*   **Rationale:** Target demographic primarily uses iOS, mobile-first enables quick access during partner conversations.

### Data Storage and Privacy
*   No bank account linking - all data manually input by users.
*   End-to-end encryption for financial data at rest.
*   Local caching for offline access to projections.
*   SOC 2 compliance for data security.

### Performance
*   Scenario calculations must complete within 500ms.
*   Support up to 10 concurrent goals.
*   App launch to usable state within 2 seconds.

### Financial Calculations
*   Compound interest calculations for all goal projections.
*   Inflation adjustments using 3% default.
*   Risk-appropriate return assumptions (HYSA for short-term, stocks for long-term).
*   Monthly contribution modelling with accurate compounding.

---

## User Experience Requirements

### Onboarding Flow
**Goal:** Users should reach their first projection within 5 minutes of download.
1. Create account and optional partner invitation.
2. Input basic financial profile (4 fields).
3. Add first goal (e.g., house down payment).
4. See initial projection and allocation recommendation.
5. Guided tutorial of scenario modelling (optional).

### Core User Journey
**Scenario:** Partner asks "when can we buy a house?"
1. User opens app (already set up with goals).
2. Views current allocation and projected house purchase timeline.
3. Creates new scenario: adjusts allocation slider to prioritize house savings.
4. Compares new timeline (e.g., 2.5 years) against current plan (e.g., 3.5 years).
5. Reviews impact on retirement timeline.
6. Shares scenario with partner for discussion.
7. Saves scenario for later reference.
*   **Target time to answer:** Under 2 minutes.

---

## Business Model

### Pricing Strategy
*   **Subscription model:**
    *   Monthly: $8.99/month
    *   Annual: $89.99/year (save 17%)
    *   Free trial: 14 days, full feature access
*   **Rationale:**
    *   Positioned between budget trackers ($50-110/year) and complex planning tools ($144/year).
    *   Couples-focused: one subscription covers both partners.

### Revenue Model
*   **Primary:** Subscription revenue.
*   **Future consideration:** Optional upgrade tier for financial advisor access or advanced features.

---

## Competitive Analysis

| Competitor | Strengths | Weaknesses | How Winnie Wins |
| :--- | :--- | :--- | :--- |
| **ProjectionLab** | Sophisticated modelling, no bank linking, scenario planning | Complex UI, FIRE-focused niche, single-user oriented | Simple couples-first design, everyday use focus |
| **Monarch Money** | Strong couples features, shared dashboard, goal tracking | Requires bank linking, backward-looking tracking, no scenario modelling | Forward-looking planning, privacy-first, tradeoff visualization |
| **Honeydue** | Couples-specific, free, bill tracking | Basic features, requires bank linking, no goal planning | Sophisticated scenario planning, realistic projections |
| **YNAB** | Strong budgeting methodology, educational resources | Complex for beginners, bank linking required, no couples features | Couples-native, simple setup, forward-looking not backward |

---

## Success Metrics

### User Acquisition & Engagement
*   **Acquisition:** 1,000 active users within 6 months; 25% trial-to-paid conversion.
*   **Engagement:** 80% onboarding completion; 40% WAU; 3 scenarios/user/month; 60% dual-partner activation.

### Retention & Quality
*   **Retention:** 85% M1 retention; 70% M6 retention; 60% annual retention.
*   **Quality:** 4.5+ App Store rating; <5 min time to first projection; <5% support ticket rate.

---

## Development Roadmap

### Phase 1: MVP (Months 1-3)
*   Basic financial profile setup.
*   Goal creation (house, retirement, vacation).
*   Simple allocation slider with timeline projections.
*   Shared account for couples.
*   Basic financial calculations.

### Phase 2: Enhanced Features (Months 4-6)
*   Multiple scenario comparison.
*   Custom goal types.
*   Advanced transparency features.
*   Data export capabilities.
*   Onboarding tutorial and educational content.

### Phase 3: Growth and Optimization (Months 7-12)
*   Android version.
*   Advanced visualization options.
*   Historical tracking (compare actual vs projected progress).
*   Notification system for milestone achievements.

---

## Risks and Mitigation

| Risk | Impact | Mitigation Strategy |
| :--- | :--- | :--- |
| Users prefer automation over manual input | Medium | Emphasize privacy, keep input extremely simple. |
| Projections seem inaccurate to users | High | Use conservative assumptions, maintain full transparency. |
| User adoption low among couples | High | Single-user mode fallback, viral invite mechanisms. |
| Market too saturated | Medium | Focus on unique positioning: scenario planning for couples. |

---

## Conclusion
Winnie addresses a clear gap in the personal finance app market: couples need quick, trustworthy answers to forward-looking financial questions without the complexity of professional planning tools or the privacy concerns of bank-linked apps. Success depends on execution of a simple, fast user experience that delivers immediate value.
