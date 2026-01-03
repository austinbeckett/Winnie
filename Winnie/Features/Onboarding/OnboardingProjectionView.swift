import SwiftUI

/// Projection reveal screen for onboarding wizard (The Magic Moment).
///
/// Step 6 of the wizard: Shows the calculated "Winnie Projection" date
/// based on the user's savings rate and goal.
struct OnboardingProjectionView: View {

    @Bindable var onboardingState: OnboardingState
    let onContinue: () -> Void

    @Environment(\.colorScheme) private var colorScheme
    @State private var hasAnimated = false

    private var goalType: GoalType {
        onboardingState.selectedGoalType ?? .house
    }

    var body: some View {
        VStack(spacing: WinnieSpacing.xl) {
            Spacer()

            // Celebration header
            VStack(spacing: WinnieSpacing.m) {
                Image(systemName: "sparkles")
                    .font(.system(size: 48))
                    .foregroundColor(WinnieColors.accent)
                    .scaleEffect(hasAnimated ? 1 : 0)
                    .opacity(hasAnimated ? 1 : 0)

                Text("Your Winnie Projection")
                    .font(WinnieTypography.headlineL())
                    .foregroundColor(WinnieColors.primaryText(for: colorScheme))
            }

            // The magic date
            VStack(spacing: WinnieSpacing.s) {
                Text("Based on your current habits,")
                    .font(WinnieTypography.bodyL())
                    .foregroundColor(WinnieColors.secondaryText(for: colorScheme))

                Text("you'll hit your \(goalType.displayName.lowercased()) goal in")
                    .font(WinnieTypography.bodyL())
                    .foregroundColor(WinnieColors.secondaryText(for: colorScheme))

                Text(onboardingState.projectedDateFormatted ?? "—")
                    .font(WinnieTypography.displayM())
                    .foregroundColor(WinnieColors.accent)
                    .scaleEffect(hasAnimated ? 1 : 0.5)
                    .opacity(hasAnimated ? 1 : 0)
            }

            // Stats card
            statsCard
                .padding(.horizontal, WinnieSpacing.screenMarginMobile)
                .opacity(hasAnimated ? 1 : 0)
                .offset(y: hasAnimated ? 0 : 20)

            Spacer()

            // Continue button
            WinnieButton("Continue", style: .primary) {
                onContinue()
            }
            .padding(.horizontal, WinnieSpacing.screenMarginMobile)
            .padding(.bottom, WinnieSpacing.xl)
        }
        .background(WinnieColors.background(for: colorScheme).ignoresSafeArea())
        .onAppear {
            withAnimation(.spring(response: 0.7, dampingFraction: 0.6).delay(0.3)) {
                hasAnimated = true
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
                    value: "\(onboardingState.projectedMonthsToGoal ?? 0)"
                )
            }
        }
        .padding(WinnieSpacing.l)
        .background(WinnieColors.cardBackground(for: colorScheme))
        .clipShape(RoundedRectangle(cornerRadius: WinnieSpacing.cardCornerRadius))
    }

    @ViewBuilder
    private func statItem(label: String, value: String) -> some View {
        VStack(spacing: WinnieSpacing.xxs) {
            Text(value)
                .font(WinnieTypography.financialM())
                .foregroundColor(WinnieColors.primaryText(for: colorScheme))

            Text(label)
                .font(WinnieTypography.caption())
                .foregroundColor(WinnieColors.tertiaryText(for: colorScheme))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
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
    return OnboardingProjectionView(onboardingState: state) {
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
    return OnboardingProjectionView(onboardingState: state) {
        print("Continue tapped")
    }
    .preferredColorScheme(.dark)
}
