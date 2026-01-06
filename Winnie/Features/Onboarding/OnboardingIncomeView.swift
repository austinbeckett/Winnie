import SwiftUI

/// Income input screen for onboarding wizard.
///
/// Step 2 of the wizard: Asks user for their monthly take-home pay.
/// Uses a large currency input with helper text.
struct OnboardingIncomeView: View {

    @Bindable var onboardingState: OnboardingState
    let onContinue: () -> Void

    @Environment(\.colorScheme) private var colorScheme

    /// Local string for text field binding
    @State private var incomeText: String = ""

    var body: some View {
        VStack(spacing: WinnieSpacing.xl) {
            Spacer()

            // Header
            VStack(spacing: WinnieSpacing.s) {
                Text("What is your monthly income?")
                    .font(WinnieTypography.headlineL())
                    .foregroundColor(WinnieColors.primaryText(for: colorScheme))
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)

                Text("Only enter yours, we will add your partner's later.")
                    .font(WinnieTypography.bodyL())
                    .foregroundColor(WinnieColors.secondaryText(for: colorScheme))
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.horizontal, WinnieSpacing.screenMarginMobile)

            // Currency input
            VStack(spacing: WinnieSpacing.s) {
                WinnieCurrencyInput(
                    value: $onboardingState.monthlyIncome,
                    text: $incomeText,
                    suffix: "/mo"
                )
                .padding(.horizontal, WinnieSpacing.screenMarginMobile)

                // Helper text
                Text("Please be as accurate as possible.")
                    .font(WinnieTypography.bodyS())
                    .foregroundColor(WinnieColors.tertiaryText(for: colorScheme))
            }

            Spacer()
            Spacer()

            // Continue button
            WinnieButton("Continue", style: .primary) {
                onContinue()
            }
            .disabled(!onboardingState.isIncomeValid)
            .padding(.horizontal, WinnieSpacing.screenMarginMobile)
            .padding(.bottom, WinnieSpacing.xl)
        }
        .background(WinnieColors.background(for: colorScheme).ignoresSafeArea())
        .onAppear {
            // Pre-fill if already set
            if onboardingState.monthlyIncome > 0 {
                incomeText = "\(NSDecimalNumber(decimal: onboardingState.monthlyIncome).intValue)"
            }
        }
    }
}

// MARK: - Previews

#Preview("Light Mode") {
    OnboardingIncomeView(onboardingState: OnboardingState()) {
        print("Continue tapped")
    }
}

#Preview("Dark Mode") {
    OnboardingIncomeView(onboardingState: OnboardingState()) {
        print("Continue tapped")
    }
    .preferredColorScheme(.dark)
}

#Preview("With Value") {
    let state = OnboardingState()
    state.monthlyIncome = 7500
    return OnboardingIncomeView(onboardingState: state) {
        print("Continue tapped")
    }
}
