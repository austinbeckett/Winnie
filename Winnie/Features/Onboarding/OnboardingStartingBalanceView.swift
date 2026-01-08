import SwiftUI

/// Current savings (Nest Egg) input screen for onboarding wizard.
///
/// Step 6 of the wizard: Asks user for their current liquid savings balance.
struct OnboardingStartingBalanceView: View {

    @Bindable var onboardingState: OnboardingState
    let onContinue: () -> Void

    @Environment(\.colorScheme) private var colorScheme

    /// Local string for text field binding
    @State private var startingBalanceText: String = ""

    /// Context-aware phrase based on selected goal type
    private var goalContextPhrase: String {
        guard let type = onboardingState.selectedGoalType else { return "this goal" }
        switch type {
        case .house: return "your home"
        case .car: return "your new car"
        case .vacation: return "your trip"
        case .retirement: return "retirement"
        case .emergencyFund: return "your emergency fund"
        case .babyFamily: return "your growing family"
        case .debt: return "paying down your debt"
        case .education: return "your education"
        case .hobby: return "your hobby"
        case .fitness: return "your fitness goals"
        case .gift: return "your gift"
        case .homeImprovement: return "your home improvement"
        case .investment: return "your investment"
        case .charity: return "your charitable giving"
        case .custom: return "this goal"
        }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: WinnieSpacing.xl) {
                Spacer(minLength: WinnieSpacing.xl)

                // Goal icon placeholder
                Image(systemName: onboardingState.selectedGoalType?.iconName ?? "sparkles")
                    .font(.system(size: 56))
                    .foregroundColor(WinnieColors.accent)

                // Header
                VStack(spacing: WinnieSpacing.s) {
                    Text("Your starting balance")
                        .font(WinnieTypography.headlineL())
                        .foregroundColor(WinnieColors.primaryText(for: colorScheme))

                    Text("How much do you already have saved for \(goalContextPhrase)?")
                        .font(WinnieTypography.bodyL())
                        .foregroundColor(WinnieColors.secondaryText(for: colorScheme))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, WinnieSpacing.m)
                }

                // Currency input
                VStack(spacing: WinnieSpacing.s) {
                    WinnieCurrencyInput(
                        value: $onboardingState.startingBalance,
                        text: $startingBalanceText
                    )
                    .padding(.horizontal, WinnieSpacing.screenMarginMobile)

                    // Helper text
                    Text("Include savings and investment accounts you can access.")
                        .font(WinnieTypography.bodyS())
                        .foregroundColor(WinnieColors.tertiaryText(for: colorScheme))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, WinnieSpacing.screenMarginMobile) // Fixed padding
                }

                Spacer(minLength: WinnieSpacing.xxxl)
            }
        }
        .scrollDismissesKeyboard(.interactively) // Enable keyboard dismissal
        .safeAreaInset(edge: .bottom) {
            // Continue button
            WinnieButton("Continue", style: .primary) {
                onContinue()
            }
            .padding(.horizontal, WinnieSpacing.screenMarginMobile)
            .padding(.vertical, WinnieSpacing.m)
            .background(WinnieColors.background(for: colorScheme))
        }
        .background(WinnieColors.background(for: colorScheme).ignoresSafeArea())
        .onAppear {
            // Pre-fill if already set
            if onboardingState.startingBalance > 0 {
                startingBalanceText = "\(NSDecimalNumber(decimal: onboardingState.startingBalance).intValue)"
            }
        }
    }
}

// MARK: - Previews

#Preview("Light Mode - House Goal") {
    let state = OnboardingState()
    state.selectedGoalType = .house
    return OnboardingStartingBalanceView(onboardingState: state) {
        print("Continue tapped")
    }
}

#Preview("Dark Mode - Car Goal") {
    let state = OnboardingState()
    state.selectedGoalType = .car
    return OnboardingStartingBalanceView(onboardingState: state) {
        print("Continue tapped")
    }
    .preferredColorScheme(.dark)
}

#Preview("With Value - Vacation Goal") {
    let state = OnboardingState()
    state.selectedGoalType = .vacation
    state.startingBalance = 15000
    return OnboardingStartingBalanceView(onboardingState: state) {
        print("Continue tapped")
    }
}
