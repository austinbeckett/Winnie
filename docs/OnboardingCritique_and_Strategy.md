# User Onboarding Review & Redesign Strategy

## 1. Critique of Current Plan (Section 1.2)

The current onboarding flow outlined in the Development Guide is functional but missed the "Magic Moment" potential required for a modern consumer app.

**Current Flow Analysis:**
1.  **Welcome Screen:** *Standard.*
2.  **Partner Setup:** *Too early.* Asking to invite a partner before the user has seen value captures a high drop-off rate. Users want to "test drive" before committing social capital.
3.  **Financial Baseline:** *High Friction.* Asking for Income, Expenses, Assets, and Savings Pool in one step is cognitively overwhelming. It feels like a tax form.
4.  **First Goal:** *Too Late.* Goals are the *emotional hook*. Relegating them to step 4 reduces the excitement of the previous data entry steps.
5.  **The Reveal:** *Good.* This is the right payoff, but it might come too late.

**Verdict:** The current flow is "Data First, Value Later." It needs to be "Value First, Data Second."

## 2. Competitor Benchmarking (Best-in-Class)

| Feature | **YNAB** (Education First) | **Monarch** (Data First) | **Copilot** (Intelligence First) | **Winnie Opportunity** (Emotion First) |
| :--- | :--- | :--- | :--- | :--- |
| **Hook** | "Stop living paycheck to paycheck" | "See everything in one place" | "Smart money tracking" | **"Build your future together"** |
| **Data Entry** | Manual, guided by philosophy. | Automated bank syncing. | Automated & AI categorized. | **Wizard-style, focused on "Roughly Right" estimates.** |
| **Pacing** | Slow, educational. | Fast, comprehensive. | Fast, slick. | **Playful, progressive disclosure.** |
| **Visuals** | Functional. | Dashboard-heavy. | Neon, dark mode, vibrant. | **Warm, soft, tactile (as defined in Dev Guide).** |

## 3. The New Proposed "Winnie" Onboarding Flow

We will shift to a **"Goal-First, Progressive Disclosure"** model.

### Phase 1: The Emotional Hook (Before Sign Up)
*   **0. Splash Screen:** High-quality motion graphic (e.g., two paths merging into one).
*   **0.1 Value Carousel:** Three quick slides:
    *   *Your future, built together:* "Align your goals without the arguments."
    *   *Play with Scenarios:* "See how a the cost of your wedding impacts your timeline to buy a house."
    *   *Stay on Track:* "Simple monthly check-ins."
*   **0.2 The 'Why' (Micro-choice):** "Let's pick your first goal. What is your top financial priority at this stage of your life?"
    *   [options: Buying a Home, Getting Married, Freedom/Retirement, Just Starting]
    *   *Why?* This immediately biases the app to speak their language.
*   **0.3 The 'What' (Wizard-style):** "Now let's set up your financial baseline."
    *   *Why?* This immediately biases the app to speak their language.

### Phase 2: Account Creation (Low Friction)
*   **1. Sign Up:** Apple/Google Sign In only. Email later. "Save your progress."

### Phase 3: The "Wizard" (Financial Baseline)
Instead of one big form, use a **Wizard** (one question per screen, big number pad, instant feedback).

*   **2. Income:** "What is your monthly take-home pay? Only enter yours, we will add your partner's later."
    *   *UI:* Big currency text. "It’s okay to guess but try to be as close as possible."
*   **3. The 'Needs':** "How much goes to fixed bills that you need to survive/pay off debts (Rent, Loans, Utilities, Internet, Phone, etc.)?"
    *   *UI:* Shows a list of common fixed expenses with a slider next to each one and a text field for entering the amount directly.
*   **4. The 'Wants':** "How much goes to wants (Entertainment, Subscriptions, etc.)?"
    *   *UI:* Shows a list of common wants with a slider next to each one and a text field for entering the amount directly.
    **5. The 'Savings Pool':** "This leaves you with a $X "Savings Pool" that you can use to save for your goals."
    *   *UI:* *Visual:* Animated image of two line art people sitting inside a pool enjoying a drink. Represents the savings pool.
*   **6. The 'Nest Egg':** "How much cash do you have saved up right now?"
    

### Phase 4: The Goal (The "What")
*   **6. Define the Dream:** (Uses the choice from step 0.2).
    *   *If "Buying a Home":* "How much do you need for a down payment?" + "When do you want it?"
    *   *Visual:* As they type the amount, show a progress bar filling up based on their "Leftover" money calculated in Step 3.

### Phase 5: The Reveal & The Ask
*   **6. The "Winnie Projection":**
    *   "Based on your current habits, you hit this goal in **March 2026**."
*   **7. The Tune-Up:**
    *   "Want to speed that up?" -> Drag a slider.
*   **8. The "Couple" Hook:**
    *   "Finances are faster with two." -> **Invite Partner** (Now they have a chart to show off).

## Summary of Changes
1.  **Moved "Partner Invite" to the end:** Let the user build something worth sharing first.
2.  **Broken down "Financial Baseline":** Split into 3 distinct, simple calculation steps with immediate feedback.
3.  **Added "Goal Selection" to the start:** Use it as the hook to drive the data entry.
