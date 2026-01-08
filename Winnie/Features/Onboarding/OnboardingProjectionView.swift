import SwiftUI

/// Projection reveal screen for onboarding wizard (The Magic Moment).
///
/// Shows the calculated "Winnie Projection" date based on the user's savings rate and goal.
/// Uses the Financial Engine for accurate compound interest calculations.
/// Allows optional date adjustment after seeing the projection.
struct OnboardingProjectionView: View {

    @Bindable var onboardingState: OnboardingState
    let onContinue: () -> Void

    @Environment(\.colorScheme) private var colorScheme
    @State private var hasAnimated = false
    @State private var showDatePicker = false
    @State private var selectedDate: Date = Date()

    // Use Financial Engine for accurate projections
    private let financialEngine = FinancialEngine()

    private var goalType: GoalType {
        onboardingState.selectedGoalType ?? .house
    }

    /// Create a Goal from onboarding state for engine calculation
    private var goal: Goal? {
        guard let type = onboardingState.selectedGoalType else { return nil }
        return Goal(
            id: UUID().uuidString,
            type: type,
            name: onboardingState.goalName ?? type.displayName,
            targetAmount: onboardingState.goalTargetAmount,
            currentAmount: onboardingState.startingBalance,
            desiredDate: onboardingState.goalDesiredDate,
            priority: 1,
            isActive: true
        )
    }

    /// Engine-calculated projection with proper return rates
    private var engineProjection: GoalProjection? {
        guard let goal = goal else { return nil }
        return financialEngine.calculateGoalProjection(
            goal: goal,
            monthlyContribution: onboardingState.savingsPool
        )
    }

    /// Months to complete using Financial Engine (with interest calculations)
    private var projectedMonths: Int {
        engineProjection?.monthsToComplete ?? onboardingState.projectedMonthsToGoal ?? 0
    }

    /// Projected completion date from engine
    private var projectedDate: Date? {
        engineProjection?.completionDate ?? onboardingState.projectedDate
    }

    /// Formatted projected date string
    private var projectedDateFormatted: String? {
        guard let date = projectedDate else { return nil }
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: date)
    }

    /// Whether the goal is reachable within reasonable time
    private var isReachable: Bool {
        engineProjection?.isReachable ?? false
    }

    private var projectionState: ProjectionState {
        if onboardingState.savingsPool <= 0 {
            return .noSavings
        } else if projectedMonths > 240 { // 20+ years
            return .veryLong
        } else if let desiredDate = onboardingState.goalDesiredDate,
                  let projectedDate = onboardingState.projectedDate,
                  projectedDate > desiredDate {
            return .pastDesired
        } else {
            return .normal
        }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: WinnieSpacing.xl) {
                Spacer(minLength: WinnieSpacing.xl)

                // Celebration header
                VStack(spacing: WinnieSpacing.m) {
                    Image(systemName: projectionState == .normal ? "sparkles" : "lightbulb.fill")
                        .font(.system(size: 48))
                        .foregroundColor(WinnieColors.accent)
                        .scaleEffect(hasAnimated ? 1 : 0)
                        .opacity(hasAnimated ? 1 : 0)

                    Text("Your Winnie Projection")
                        .font(WinnieTypography.headlineL())
                        .foregroundColor(WinnieColors.primaryText(for: colorScheme))
                }

                // The magic date or message
                projectionContent
                    .opacity(hasAnimated ? 1 : 0)
                    .offset(y: hasAnimated ? 0 : 20)

                // Stats card
                if projectionState == .normal || projectionState == .pastDesired {
                    statsCard
                        .padding(.horizontal, WinnieSpacing.screenMarginMobile)
                        .opacity(hasAnimated ? 1 : 0)
                        .offset(y: hasAnimated ? 0 : 20)
                }

                // Optional date adjustment section
                if hasAnimated && projectionState == .normal {
                    dateAdjustmentSection
                        .padding(.horizontal, WinnieSpacing.screenMarginMobile)
                }

                Spacer(minLength: WinnieSpacing.xxxl)
            }
        }
        .safeAreaInset(edge: .bottom) {
            WinnieButton("Continue", style: .primary) {
                onContinue()
            }
            .padding(.horizontal, WinnieSpacing.screenMarginMobile)
            .padding(.vertical, WinnieSpacing.m)
            .background(WinnieColors.background(for: colorScheme))
        }
        .background(WinnieColors.background(for: colorScheme).ignoresSafeArea())
        .onAppear {
            // Initialize with projected date
            if let projected = onboardingState.projectedDate {
                selectedDate = projected
                onboardingState.goalDesiredDate = projected
            }
            withAnimation(.spring(response: 0.7, dampingFraction: 0.6).delay(0.3)) {
                hasAnimated = true
            }
        }
    }

    // MARK: - Projection Content

    @ViewBuilder
    private var projectionContent: some View {
        switch projectionState {
        case .noSavings:
            VStack(spacing: WinnieSpacing.s) {
                Text("Let's build your savings first")
                    .font(WinnieTypography.bodyL())
                    .foregroundColor(WinnieColors.secondaryText(for: colorScheme))
                    .multilineTextAlignment(.center)

                Text("Your current budget shows no savings. With a few adjustments to your spending, you can start putting money toward this goal.")
                    .font(WinnieTypography.bodyM())
                    .foregroundColor(WinnieColors.tertiaryText(for: colorScheme))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, WinnieSpacing.screenMarginMobile)
            }

        case .veryLong:
            VStack(spacing: WinnieSpacing.s) {
                Text("This is a long-term goal")
                    .font(WinnieTypography.bodyL())
                    .foregroundColor(WinnieColors.secondaryText(for: colorScheme))

                Text("At your current rate, this goal would take \(projectedMonths / 12)+ years. Winnie can help you find ways to get there faster.")
                    .font(WinnieTypography.bodyM())
                    .foregroundColor(WinnieColors.tertiaryText(for: colorScheme))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, WinnieSpacing.screenMarginMobile)

                Text("$\(NSDecimalNumber(decimal: onboardingState.savingsPool).intValue)/mo")
                    .font(WinnieTypography.displayM())
                    .foregroundColor(WinnieColors.accent)
            }

        case .pastDesired, .normal:
            VStack(spacing: WinnieSpacing.s) {
                Text("Based on your inputs,")
                    .font(WinnieTypography.bodyL())
                    .foregroundColor(WinnieColors.secondaryText(for: colorScheme))

                Text("you'll reach your goal in")
                    .font(WinnieTypography.bodyL())
                    .foregroundColor(WinnieColors.secondaryText(for: colorScheme))

                Text(projectedDateFormatted ?? "—")
                    .font(WinnieTypography.displayM())
                    .foregroundColor(WinnieColors.accent)
                    .scaleEffect(hasAnimated ? 1 : 0.5)
            }
        }
    }

    // MARK: - Date Adjustment Section

    private var dateAdjustmentSection: some View {
        VStack(spacing: WinnieSpacing.m) {
            Button {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                    showDatePicker.toggle()
                }
            } label: {
                HStack(spacing: WinnieSpacing.xs) {
                    Image(systemName: showDatePicker ? "chevron.up" : "calendar")
                        .font(.system(size: 14, weight: .medium))
                    Text(showDatePicker ? "Hide date picker" : "Want to adjust your timeline?")
                        .font(WinnieTypography.bodyS().weight(.medium))
                }
                .foregroundColor(WinnieColors.accent)
            }

            if showDatePicker {
                VStack(spacing: WinnieSpacing.s) {
                    Text("Set a target date")
                        .font(WinnieTypography.caption())
                        .contextTertiaryText()
                        .textCase(.uppercase)

                    DatePicker(
                        "",
                        selection: $selectedDate,
                        in: Date()...,
                        displayedComponents: .date
                    )
                    .datePickerStyle(.graphical)
                    .tint(WinnieColors.accent)
                    .onChange(of: selectedDate) { _, newDate in
                        onboardingState.goalDesiredDate = newDate
                    }
                }
                .cardContext(.pineTeal)
                .padding(WinnieSpacing.m)
                .background(WinnieColors.cardBackground(for: colorScheme))
                .clipShape(RoundedRectangle(cornerRadius: WinnieSpacing.cardCornerRadius))
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
    }

    // MARK: - Stats Card

    private var statsCard: some View {
        VStack(spacing: WinnieSpacing.m) {
            HStack {
                statItem(
                    label: "Monthly Savings",
                    value: "$\(NSDecimalNumber(decimal: onboardingState.savingsPool).intValue)"
                )

                Divider()
                    .frame(height: 40)

                statItem(
                    label: "Target Amount",
                    value: "$\(NSDecimalNumber(decimal: onboardingState.goalTargetAmount).intValue)"
                )

                Divider()
                    .frame(height: 40)

                statItem(
                    label: "Months to Go",
                    value: "\(projectedMonths)"
                )
            }
        }
        .cardContext(.pineTeal)
        .padding(WinnieSpacing.l)
        .background(WinnieColors.cardBackground(for: colorScheme))
        .clipShape(RoundedRectangle(cornerRadius: WinnieSpacing.cardCornerRadius))
    }

    @ViewBuilder
    private func statItem(label: String, value: String) -> some View {
        VStack(spacing: WinnieSpacing.xxs) {
            Text(value)
                .font(WinnieTypography.financialM())
                .contextPrimaryText()
                .lineLimit(1)
                .minimumScaleFactor(0.6)

            Text(label)
                .font(WinnieTypography.caption())
                .contextTertiaryText()
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Projection State

private enum ProjectionState {
    case normal
    case noSavings
    case veryLong
    case pastDesired
}

// MARK: - Previews

#Preview("Normal Projection") {
    let state = OnboardingState()
    state.selectedGoalType = .house
    state.monthlyIncome = 7500
    state.monthlyNeeds = 3000
    state.monthlyWants = 1000
    state.startingBalance = 10000
    state.goalTargetAmount = 60000
    return OnboardingProjectionView(onboardingState: state) {
        print("Continue tapped")
    }
}

#Preview("No Savings") {
    let state = OnboardingState()
    state.selectedGoalType = .house
    state.monthlyIncome = 5000
    state.monthlyNeeds = 3000
    state.monthlyWants = 2000
    state.goalTargetAmount = 60000
    return OnboardingProjectionView(onboardingState: state) {
        print("Continue tapped")
    }
}

#Preview("Very Long Projection") {
    let state = OnboardingState()
    state.selectedGoalType = .house
    state.monthlyIncome = 5000
    state.monthlyNeeds = 3000
    state.monthlyWants = 1900
    state.goalTargetAmount = 500000
    return OnboardingProjectionView(onboardingState: state) {
        print("Continue tapped")
    }
}
