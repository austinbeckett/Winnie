# Winnie Development Guide
**The North Star for Design & Development**

This guide serves as the comprehensive roadmap for building **Winnie**, taking the project from abstract requirements to a live App Store product. It is structured to guide the use of AI coding assistants (like Gemini and Claude) effectively.

---

## Phase 1: Planning
**Goal:** Create a clear mental model of how the app works, what screens exist, and how users move through them.

### 1.1 Information Architecture (The Skeleton)
The app is organized around four primary navigational pillars (Tabs):

1.  **Dashboard (Home):**
    *   **High-level Snapshot:** Total "Available for Goals" vs. Fixed Expenses.
    *   **Active Plan:** The currently agreed-upon scenario (e.g., "Buying House in 2026").
    *   **Quick Actions:** "Add Windfall", "Log Expense Check-in".
2.  **Goals (The "What"):**
    *   **List View:** All active goals (House, Retirement, Baby, Emergency Fund).
    *   **Detail View:** Specific inputs for a goal (Target amount, timeline constraints).
3.  **Scenarios (The "How"):**
    *   **The Playground:** The list of different "What-if" models.
    *   **The Editor:** The core interactive slider interface.
    *   **Comparison View:** Side-by-side view of Scenario A vs. Scenario B.
4.  **Settings & Profile:**
    *   **Couple Management:** Invite partner, manage connection.
    *   **Financial Assumptions:** View/Edit inflation rates, investment returns.
    *   **Subscription:** Manage Winnie Premium.

### 1.2 User Flow Mapping
**Flow A: Onboarding (First Run)**
1.  **Welcome Screen:** Value prop + Sign Up / Sign In.
2.  **Partner Setup:** "Invite Partner" or "Skip for Now".
3.  **Financial Baseline:** Input Income, Fixed Expenses, Assets.
4.  **First Goal:** "What is your #1 priority?" (e.g., House).
5.  **The Reveal:** Show the first calculated timeline.

**Flow B: The "What-If" Session (Core Loop)**
1.  **Trigger:** User wants to see impact of saving more for a house.
2.  **Action:** Go to "Scenarios" -> "Create New".
3.  **Interaction:** Drag "House" slider right (increasing monthly contribution).
4.  **Reaction:** See "Retirement" timeline shift later automatically.
5.  **Decision:** Save as "Aggressive House Plan" -> Share with Partner.

---

## Phase 2: Design and Wireframing
**Goal:** Create visual blueprints that show exactly what each screen looks like and how you should interact with it.

### 2.1 Wireframing
Focus on layout and hierarchy before colors.
*   **The Allocation Slider:** Needs to be large and thumb-friendly. As it moves, numbers above it should tick up/down instantly.
*   **Timeline Visualization:** A horizontal bar chart is often clearer than a line graph for "Completion Dates".
*   **Input Forms:** Use clear, big number pads. Avoid standard iOS pickers for money; custom keypads are faster.

### 2.2 Visual Design
*   **Aesthetic:** "Trustworthy, Warm, Modern." Avoid cold "bank blue" or "spreadsheet green."
*   **Palette:**
    *   *Primary:* A warm coral or sage green (growth/warmth).
    *   *Alerts:* Soft amber for "timeline delayed", not aggressive red.
*   **Typography:** Clean sans-serif (e.g., SF Pro Rounded) for numbers to make math feel friendly.

### 2.3 Interactive Prototyping
*   **Micro-interactions:** When a slider moves, give haptic feedback (vibration).
*   **Transitions:** Smoothly animate chart bars growing/shrinking. This is critical for the "Instant Answer" feeling.

---

## Phase 3: Technical Architecture
**Goal:** Define the structural foundation of the code.

### 3.1 Tech Stack Selection
*   **Frontend:** **SwiftUI (iOS Native)**. Best for animations and native feel.
*   **Backend:** **Firebase**.
    *   *Auth:* Anonymous login upgraded to Email/Link.
    *   *Database:* Cloud Firestore (NoSQL) for syncing couple data.
    *   *Functions:* For heavy scheduled tasks (notifications).
*   **State Management:** `@Observation` (iOS 17+) for simple, reactive data flow.

### 3.2 Data Modeling
**Core Entities (Firestore Collections):**
*   `users/{userID}`: Profile, partnerID reference.
*   `couples/{coupleID}`: The shared container.
    *   `financial_profile`: Income, Expenses (shared).
    *   `goals/{goalID}`: Target amount, current amount, type (House, Baby).
    *   `scenarios/{scenarioID}`: A saved configuration of allocations.
        *   *Field:* `allocations` (Map: GoalID -> MonthlyAmount).

### 3.3 Financial Calculation Logic
**Philosophy:** Logic lives on the **Device** (Client-side) for speed, synced to Cloud for storage.
*   **The Engine:** A Swift struct `FinancialEngine`.
    *   *Input:* Profile, List of Goals, Allocation Dictionary.
    *   *Output:* Dictionary of {GoalID: CompletionDate}.
*   **Math:**
    *   Use `Decimal` type for money (never `Double` to avoid floating point errors).
    *   Formula: `FutureValue = PresentValue * (1+r)^n + PMT * ...`

---

## Phase 4: Development
**Goal:** Build features using AI tools guided by our understanding of architecture and design.

### 4.1 Development Environment Setup
**Tools Required:**
1.  **Xcode:** Latest version.
2.  **Firebase CLI:** For deploying backend rules/indexes (`npm install -g firebase-tools`).
3.  **Cursor (IDE):** Your primary editor.
    *   *Extensions:* Swift support.
    *   *Integrations:* Claude Code & Gemini CLI.

**Setup Steps:**
1.  Create iOS project in Xcode ("Winnie").
2.  Create Firebase Project in Console.
3.  Download `GoogleService-Info.plist` and add to Xcode.
4.  Initialize Firebase in Cursor terminal (`firebase init`).

### 4.2 Component by Component Development
Build from the bottom up.
1.  **Core UI Kit:** Build `WinnieButton`, `WinnieSlider`, `CurrencyText` first.
2.  **Logic Layer:** Write the `FinancialEngine` purely in Swift (no UI) and test it.
3.  **Feature 1: Auth & Profile:** Sign up and save income to Firestore.
4.  **Feature 2: Goals:** Create/Read/Update goals.
5.  **Feature 3: The Engine:** Connect the UI sliders to the Logic Layer.

### 4.3 Tips and Tricks for Working with AI Tools Effectively
*   **Cursor/Claude:** Best for writing large chunks of SwiftUI code.
    *   *Prompt:* "Create a SwiftUI View for the Goal Detail screen based on this data model: [paste model]. Use the `WinnieButton` component we created."
*   **Gemini CLI:** Best for logic and architectural checks.
    *   *Prompt:* "Review this Swift function for calculating compound interest. Are there edge cases for leap years or negative returns?"
*   **Context is King:** Always paste the relevant struct/model definition before asking for a View.

### 4.4 Helping Me Understand the Code that the AI Agents Generate
*   **The "Explain" Prompt:** If AI generates a complex Combine pipeline or GeometryReader, ask: *"Explain this block line-by-line in plain English."*
*   **Refactoring:** If code looks messy, ask: *"Refactor this to be more readable and split into smaller sub-views."*

---

## Phase 5: Testing and Quality Assurance
**Goal:** Ensure the app works reliably and handles edge cases.

### 5.1 Manual Testing
*   **The "Zero" Test:** What happens if income is 0? If expenses > income?
*   **The "Rich" Test:** What if numbers are huge ($10M)? Does the UI break?
*   **The "Offline" Test:** Turn off WiFi. Can I still move sliders? (Should be YES).

### 5.2 Beta Testing
*   **TestFlight:** Distribute to 5-10 couples.
*   **Feedback Loop:** Add a simple "Send Feedback" button in the Settings menu that emails you directly.

---

## Phase 6: Deployment and Launch
**Goal:** Make Winnie available in the App Store.

### 6.1 App Store Preparation
*   **Screenshots:** Capture the "Slider" in action.
*   **Keywords:** "Couples Finance", "Budget Planner", "Wedding Saving", "House Downpayment".

### 6.2 Subscription Setup
*   **RevenueCat:** Easiest implementation for iOS Subscriptions.
*   **Entitlements:** Define "Free Tier" (1 scenario) vs "Pro Tier" (Unlimited).

### 6.3 Back-end Deployment
*   **Security Rules:** strict Firestore rules (users can only read their own/partner's data).
*   **Production Check:** specific prod database, not test.

### 6.4 App Store Review
*   **Privacy Policy:** Generate one that discloses data usage.
*   **Review Notes:** Provide a demo account credential for Apple Reviewers.

---

## Common Pitfalls to Avoid
1.  **Over-complicating the Math:** Users don't need tax-loss harvesting logic in v1. "Roughly Right" is better than "Precisely Confusing."
2.  **Blocking UI for Network:** Never show a spinner while calculating numbers. Calculate locally, sync later.
3.  **Ignoring Text Size:** Test with "Large Text" accessibility settings.

## Next Steps / Action Plan
1.  **[Immediate]** Initialize the Xcode Project and Git Repository.
2.  **[Immediate]** Set up the Firebase Console project.
3.  **[Day 1]** Implement Phase 3.2 (Data Models) as Swift Structs.
4.  **[Day 2]** Build the "Financial Engine" logic unit tests.
