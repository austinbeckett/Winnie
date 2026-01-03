import SwiftUI

/// Goal selection screen for onboarding.
///
/// Presents a grid of goal type options for the user to select their primary focus.
/// This personalizes the onboarding experience and determines which goal detail
/// questions to ask later.
struct OnboardingGoalPickerView: View {

    @Bindable var onboardingState: OnboardingState
    let onContinue: () -> Void

    @Environment(\.colorScheme) private var colorScheme

    /// Goal types shown during onboarding (subset of all types)
    private let onboardingGoalTypes: [GoalType] = [
        .house,
        .babyFamily,
        .retirement,
        .emergencyFund
    ]

    var body: some View {
        VStack(spacing: WinnieSpacing.xl) {
            Spacer()

            // Header
            VStack(spacing: WinnieSpacing.s) {
                Text("What's your focus?")
                    .font(WinnieTypography.headlineL())
                    .foregroundColor(WinnieColors.primaryText(for: colorScheme))

                Text("Let's pick your first goal. What is your top financial priority at this stage of your life?")
                    .font(WinnieTypography.bodyL())
                    .foregroundColor(WinnieColors.secondaryText(for: colorScheme))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, WinnieSpacing.m)
            }

            // Goal grid
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: WinnieSpacing.m) {
                ForEach(onboardingGoalTypes) { goalType in
                    goalOptionCard(for: goalType)
                }
            }
            .padding(.horizontal, WinnieSpacing.screenMarginMobile)

            Spacer()

            // Continue button
            WinnieButton("Continue", style: .primary) {
                onContinue()
            }
            .disabled(onboardingState.selectedGoalType == nil)
            .padding(.horizontal, WinnieSpacing.screenMarginMobile)
            .padding(.bottom, WinnieSpacing.xl)
        }
        .background(WinnieColors.background(for: colorScheme).ignoresSafeArea())
    }

    // MARK: - Goal Option Card

    @ViewBuilder
    private func goalOptionCard(for goalType: GoalType) -> some View {
        let isSelected = onboardingState.selectedGoalType == goalType

        Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                onboardingState.selectedGoalType = goalType
            }
        } label: {
            VStack(spacing: WinnieSpacing.s) {
                Image(systemName: goalType.iconName)
                    .font(.system(size: 32))
                    .foregroundColor(isSelected ? WinnieColors.contrastText : WinnieColors.accent)

                Text(goalType.displayName)
                    .font(WinnieTypography.bodyM())
                    .fontWeight(.medium)
                    .foregroundColor(isSelected
                                     ? WinnieColors.contrastText
                                     : WinnieColors.primaryText(for: colorScheme))
            }
            .frame(maxWidth: .infinity)
            .frame(height: 120)
            .background(isSelected
                        ? WinnieColors.accent
                        : WinnieColors.cardBackground(for: colorScheme))
            .clipShape(RoundedRectangle(cornerRadius: WinnieSpacing.cardCornerRadius))
            .overlay(
                RoundedRectangle(cornerRadius: WinnieSpacing.cardCornerRadius)
                    .stroke(isSelected ? WinnieColors.accent : WinnieColors.border(for: colorScheme),
                            lineWidth: isSelected ? 2 : 1)
            )
            .scaleEffect(isSelected ? 1.02 : 1.0)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Previews

#Preview("Light Mode") {
    OnboardingGoalPickerView(onboardingState: OnboardingState()) {
        print("Continue tapped")
    }
}

#Preview("Dark Mode") {
    OnboardingGoalPickerView(onboardingState: OnboardingState()) {
        print("Continue tapped")
    }
    .preferredColorScheme(.dark)
}

#Preview("With Selection") {
    let state = OnboardingState()
    state.selectedGoalType = .house
    return OnboardingGoalPickerView(onboardingState: state) {
        print("Continue tapped")
    }
}
