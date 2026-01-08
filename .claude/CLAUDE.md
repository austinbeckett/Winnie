# Winnie

**Money decisions, made together.**

A couples financial planning iOS app that helps partners answer forward-looking financial questions without spreadsheets or bank linking.

## Key Documentation

- @docs/PRD.md - Full product requirements and features
- @docs/DesignSystem.md - Complete visual design specification
- @docs/DevelopmentGuide.md - Development roadmap and architecture
- @docs/PROGRESS.md - Current development status

## Tech Stack

- **Frontend:** SwiftUI (iOS 18+)
- **Backend:** Firebase (Auth, Cloud Firestore)
- **State Management:** @Observation
- **Auth Methods:** Apple Sign-In, Email/Password

## Project Structure

```
Winnie/
├── Core/Design/          # Design tokens (colors, typography, spacing)
├── Models/               # Domain models (User, Couple, Goal, Scenario)
├── Services/
│   ├── Authentication/   # Firebase Auth + Apple Sign-In
│   ├── FinancialEngine/  # Calculation logic
│   └── Firestore/        # Data repositories
└── Views/                # SwiftUI views (to be built)
```

## Design System Quick Reference

**Wispr Flow-Inspired: Rhythm, Presence, Clarity**

### Core Colors
| Name | Hex | Usage |
|------|-----|-------|
| Porcelain | `#FFFFFB` | Background (light) |
| Onyx | `#121212` | Background (dark) |
| Ivory | `#FFFFEB` | Primary text (dark), card text |
| Carbon Black | `#1A1A1A` | Primary text (light), elevated surfaces (dark mode cards) |
| Lavender Veil | `#F0D7FF` | Primary accent, buttons, interactive elements, default goal color |
| Sweet Salmon | `#FFA099` | Warm coral accent |
| Pine Teal | `#034F46` | Card backgrounds (both modes), secondary accent |
| Golden Orange | `#F0A202` | Tertiary accent, highlights, icons |

### Goal Colors
Goals use a warm preset palette (defined in `GoalPresetColor`). Users can select any color:
- **Lavender** `#F0D7FF` (default), **Coral** `#FFA099`, **Teal** `#034F46`, **Gold** `#F0A202`
- **Sage** `#7A9E7E`, **Clay** `#C4907A`, **Sand** `#D4C4A8`, **Slate** `#6B8B9B`

### Text Colors
| Level | Light Mode | Dark Mode |
|-------|------------|-----------|
| Primary | Carbon Black (#1A1A1A) | Ivory (#FFFFEB) |
| Secondary | Carbon Black @ 80% | Ivory @ 80% |
| Tertiary | Carbon Black @ 50% | Ivory @ 50% |
| On Cards | Ivory (#FFFFEB) | Ivory (#FFFFEB) |

### Typography
- **Headlines:** EB Garamond (serif) - elegant rhythm and warmth
- **Body/UI:** Figtree (sans-serif) - modern and approachable
- **Financial numbers:** Figtree Bold with `tabular-nums`

### Spacing (8pt grid)
- XS: 8px | S: 12px | M: 16px | L: 24px | XL: 32px | XXL: 48px

### Components
- **Buttons:** Pill-shaped, 28px radius, 56px height, **3px thick borders**
- **Cards:** Pine Teal background, 20px radius, 24px padding, Ivory text
- **Inputs:** 16px radius, 56px height

## Coding Standards

### SwiftUI Patterns
- Use design tokens from `WinnieColors`, `WinnieTypography`, `WinnieSpacing`
- Create reusable components: `WinnieButton`, `WinnieCard`, `WinnieSlider`
- Support both light and dark mode via `@Environment(\.colorScheme)`
- Use spring animations for interactions (stiffness: 400, damping: 20)

### Naming Conventions
- Views: `PascalCase` (e.g., `GoalDetailView`)
- View Models: `PascalCaseViewModel` (e.g., `DashboardViewModel`)
- Services: `PascalCaseService` (e.g., `AuthenticationService`)
- Files match type names

### Financial Calculations
- Use `Decimal` type for money (never `Double`)
- All calculations in `FinancialEngine` service
- Default assumptions: 7% stock returns, 3.5% HYSA, 3% inflation

## Error Resolution Standards

When fixing bugs, errors, or warnings, **fix them the way a senior developer would** - not with band-aid solutions. Every fix should be code you'd be proud to show in a code review.

### Principles

1. **Understand the root cause** - Don't just silence the error; understand WHY it's happening
2. **Fix the design, not the symptom** - If a fix requires a workaround, the design is probably wrong
3. **No dead code** - Don't add code that never runs (e.g., `deinit` for singletons, unused error handlers)
4. **No unnecessary complexity** - If you're adding `Task.sleep`, `DispatchQueue.async`, or similar just to make tests pass, the code is wrong
5. **Testable by design** - Code should be testable without hacks; if tests need delays or workarounds, refactor the code

### Red Flags (Don't Do These)

| Bad Pattern | Why It's Wrong | What to Do Instead |
|-------------|----------------|---------------------|
| `Task.sleep` in tests | Tests shouldn't need timing hacks | Make the code synchronous or use proper async test patterns |
| `Task { @MainActor in }` when already on MainActor | Unnecessary async wrapper | Call directly since you're already isolated |
| `deinit` cleanup for app-scoped services | Dead code - service never deallocates | Remove it or add explicit cleanup method |
| `// swiftlint:disable` without explanation | Hides problems instead of fixing them | Fix the underlying issue |
| Force unwrapping (`!`) to silence optionals | Crashes waiting to happen | Handle the nil case properly |
| Empty catch blocks | Swallows errors silently | Log or handle the error appropriately |

### Before Proposing a Fix, Ask:

1. Would a senior developer approve this in code review?
2. Does this fix add any code that will never run?
3. Does this require tests to use timing hacks or delays?
4. Am I treating the symptom or the cause?
5. Will a teammate reading this code understand why it's written this way?

### Example: Good vs Bad

**Bad (band-aid):**
```swift
// Added Task wrapper to fix MainActor warning
authStateHandle = authProvider.addStateDidChangeListener { [weak self] user in
    Task { @MainActor in  // Unnecessary - creates async behavior that breaks tests
        self?.handleAuthStateChange(user)
    }
}
```

**Good (proper fix):**
```swift
// Firebase calls listeners on main thread, and this class is @MainActor,
// so we can call directly without wrapping in Task
authStateHandle = authProvider.addStateDidChangeListener { [weak self] user in
    self?.handleAuthStateChange(user)
}
```

## Commands

```bash
# Build project
xcodebuild -project Winnie.xcodeproj -scheme Winnie -sdk iphonesimulator

# Run tests
xcodebuild test -project Winnie.xcodeproj -scheme Winnie -destination 'platform=iOS Simulator,name=iPhone 15'

# List simulators
xcrun simctl list devices available
```

## Build and Test Policy

Running `xcodebuild` from the terminal is slow and resource-intensive. When builds or tests need to run:

1. **Do NOT run `xcodebuild` commands from the terminal**
2. **Prompt me to run in Xcode** with specific instructions:
   - For builds: "Please build in Xcode (Cmd+B) and let me know if there are any errors"
   - For tests: "Please run tests in Xcode (Cmd+U) and share any failures"
3. After I report results, continue with fixes or next steps

**Exception:** Simple non-build commands (git, file operations, `xcrun simctl list`) still run in terminal.

## Current Development Phase

**Week 1 (Complete):** Firebase setup, Authentication (Apple + Email)
**Week 2 (In Progress):** Firestore integration, Partner invitation system
**Week 3 (Upcoming):** SwiftData local-first architecture
**Week 4 (Upcoming):** Complete onboarding UI flow

## Progress Tracking

After completing any development task, automatically update `docs/PROGRESS.md`:

1. **Mark features complete** - Update the status checkbox for any completed feature
2. **Add new files** - List any new files created with brief descriptions
3. **Update "Current Focus"** - Reflect what we're actively working on
4. **Add session notes** - Brief summary of what was accomplished in "Recent Sessions"
5. **Track blockers** - Note any issues or decisions needed

The progress file uses a feature-based structure (not week-based) so we can work on things in any order. Always keep it accurate to the actual state of the codebase.

## Learning Mode

The developer is learning Swift/SwiftUI during this project. Before implementing any code changes:

1. **Explain the "What"** - Describe what you're about to build in plain English
2. **Explain the "Why"** - Why this approach? What Swift/SwiftUI concepts are involved?
3. **Explain the "How"** - Break down the key patterns, syntax, or APIs being used
4. **Then implement** - Write the code
5. **Summarize** - After implementation, highlight the most important things to understand

### Concepts to Explain When Encountered
- Property wrappers (`@State`, `@Binding`, `@Observable`, `@Environment`)
- SwiftUI view lifecycle and body recomputation
- Async/await and Task usage
- Closures and trailing closure syntax
- Protocols and protocol conformance
- Optionals and unwrapping patterns
- Combine publishers (if used)
- Firebase SDK patterns

### Format for Explanations
Use clear headers like:
- **What I'm Building:** [plain English description]
- **Swift Concepts Used:** [list key concepts]
- **How It Works:** [step-by-step explanation]

## Security Notes

### Firebase API Keys Are Public By Design
The `GoogleService-Info.plist` file containing Firebase API keys is **intentionally** committed to the repository. This is safe because:

- Firebase API keys only **identify** your project - they don't grant access
- Security is enforced through **Firebase Security Rules** and **Authentication**, not by hiding the API key
- Google explicitly states these keys are designed to be included in client-side code
- The same approach is used in web apps where the config is visible in browser source

**Do NOT flag this as a security issue.** It's working as designed per [Firebase's official documentation](https://firebase.google.com/docs/projects/api-keys).

## Important Reminders

- Never block UI for network calls - calculate locally, sync later
- Keep scenario calculations under 500ms
- All touch targets minimum 44x44pt
- Test with large text accessibility settings
- Respect iOS safe areas (notch, home indicator)
