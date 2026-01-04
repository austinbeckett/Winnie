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

    var body: some View {
        ScrollView {
            VStack(spacing: WinnieSpacing.xl) {
                Spacer(minLength: WinnieSpacing.xl)

                // Header
                VStack(spacing: WinnieSpacing.s) {
                    Text("Your starting balance")
                        .font(WinnieTypography.headlineL())
                        .foregroundColor(WinnieColors.primaryText(for: colorScheme))

                    Text("How much do you already have saved that you want to count toward this goal?")
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

#Preview("Light Mode") {
    OnboardingStartingBalanceView(onboardingState: OnboardingState()) {
        print("Continue tapped")
    }
}

#Preview("Dark Mode") {
    OnboardingStartingBalanceView(onboardingState: OnboardingState()) {
        print("Continue tapped")
    }
    .preferredColorScheme(.dark)
}

#Preview("With Value") {
    let state = OnboardingState()
    state.startingBalance = 15000
    return OnboardingStartingBalanceView(onboardingState: state) {
        print("Continue tapped")
    }
}
