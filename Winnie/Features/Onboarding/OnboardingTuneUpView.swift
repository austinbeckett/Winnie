import SwiftUI

/// Tune-up screen for onboarding wizard.
///
/// Step 7 of the wizard: Allows user to adjust their savings allocation
/// with a slider to see how it affects the projected date.
struct OnboardingTuneUpView: View {

    @Bindable var onboardingState: OnboardingState
    let onContinue: () -> Void

    @Environment(\.colorScheme) private var colorScheme

    /// Adjustment percentage (100% = current savings pool, can go higher)
    @State private var savingsMultiplier: Double = 1.0

    private var adjustedSavingsPool: Decimal {
        onboardingState.savingsPool * Decimal(savingsMultiplier)
    }

    private var adjustedMonthsToGoal: Int? {
        guard adjustedSavingsPool > 0, onboardingState.goalTargetAmount > onboardingState.nestEgg else { return nil }

        let remaining = onboardingState.goalTargetAmount - onboardingState.nestEgg
        let months = remaining / adjustedSavingsPool

        return Int(NSDecimalNumber(decimal: months).doubleValue.rounded(.up))
    }

    private var adjustedCompletionDate: String? {
        guard let months = adjustedMonthsToGoal else { return nil }
        guard let date = Calendar.current.date(byAdding: .month, value: months, to: Date()) else { return nil }
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: date)
    }

    private var goalType: GoalType {
        onboardingState.selectedGoalType ?? .house
    }

    var body: some View {
        VStack(spacing: WinnieSpacing.xl) {
            Spacer()

            // Header
            VStack(spacing: WinnieSpacing.s) {
                Text("Want to speed things up?")
                    .font(WinnieTypography.headlineL())
                    .foregroundColor(WinnieColors.primaryText(for: colorScheme))

                Text("See how saving more can get you to your \(goalType.displayName.lowercased()) faster.")
                    .font(WinnieTypography.bodyL())
                    .foregroundColor(WinnieColors.secondaryText(for: colorScheme))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, WinnieSpacing.m)
            }

            // Projected date display
            VStack(spacing: WinnieSpacing.xs) {
                Text(adjustedCompletionDate ?? "—")
                    .font(WinnieTypography.displayM())
                    .foregroundColor(WinnieColors.accent)
                    .contentTransition(.numericText())

                Text("Projected completion")
                    .font(WinnieTypography.bodyS())
                    .foregroundColor(WinnieColors.tertiaryText(for: colorScheme))
            }

            // Savings slider
            VStack(spacing: WinnieSpacing.m) {
                // Current savings display
                VStack(spacing: WinnieSpacing.xxs) {
                    Text("$\(NSDecimalNumber(decimal: adjustedSavingsPool).intValue)")
                        .font(WinnieTypography.financialM())
                        .foregroundColor(WinnieColors.primaryText(for: colorScheme))
                        .contentTransition(.numericText())

                    Text("per month toward goals")
                        .font(WinnieTypography.bodyS())
                        .foregroundColor(WinnieColors.tertiaryText(for: colorScheme))
                }

                // Slider
                VStack(spacing: WinnieSpacing.xs) {
                    Slider(
                        value: $savingsMultiplier,
                        in: 0.5...2.0,
                        step: 0.1
                    )
                    .tint(WinnieColors.accent)

                    HStack {
                        Text("Less")
                            .font(WinnieTypography.caption())
                            .foregroundColor(WinnieColors.tertiaryText(for: colorScheme))

                        Spacer()

                        Text("\(Int(savingsMultiplier * 100))%")
                            .font(WinnieTypography.bodyS())
                            .fontWeight(.semibold)
                            .foregroundColor(WinnieColors.accent)

                        Spacer()

                        Text("More")
                            .font(WinnieTypography.caption())
                            .foregroundColor(WinnieColors.tertiaryText(for: colorScheme))
                    }
                }
            }
            .padding(.horizontal, WinnieSpacing.screenMarginMobile)
            .padding(.vertical, WinnieSpacing.l)
            .background(WinnieColors.cardBackground(for: colorScheme))
            .clipShape(RoundedRectangle(cornerRadius: WinnieSpacing.cardCornerRadius))
            .padding(.horizontal, WinnieSpacing.screenMarginMobile)

            Spacer()

            // Continue button
            WinnieButton("Continue", style: .primary) {
                onContinue()
            }
            .padding(.horizontal, WinnieSpacing.screenMarginMobile)
            .padding(.bottom, WinnieSpacing.xl)
        }
        .background(WinnieColors.background(for: colorScheme).ignoresSafeArea())
    }
}

// MARK: - Previews

#Preview("Light Mode") {
    let state = OnboardingState()
    state.selectedGoalType = .house
    state.monthlyIncome = 7500
    state.monthlyNeeds = 3000
    state.monthlyWants = 1000
    state.nestEgg = 10000
    state.goalTargetAmount = 60000
    return OnboardingTuneUpView(onboardingState: state) {
        print("Continue tapped")
    }
}

#Preview("Dark Mode") {
    let state = OnboardingState()
    state.selectedGoalType = .house
    state.monthlyIncome = 7500
    state.monthlyNeeds = 3000
    state.monthlyWants = 1000
    state.nestEgg = 10000
    state.goalTargetAmount = 60000
    return OnboardingTuneUpView(onboardingState: state) {
        print("Continue tapped")
    }
    .preferredColorScheme(.dark)
}
