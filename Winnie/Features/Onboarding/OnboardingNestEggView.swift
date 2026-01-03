import SwiftUI

/// Current savings (Nest Egg) input screen for onboarding wizard.
///
/// Step 6 of the wizard: Asks user for their current liquid savings balance.
struct OnboardingNestEggView: View {

    @Bindable var onboardingState: OnboardingState
    let onContinue: () -> Void

    @Environment(\.colorScheme) private var colorScheme

    /// Local string for text field binding
    @State private var nestEggText: String = ""

    var body: some View {
        VStack(spacing: WinnieSpacing.xl) {
            Spacer()

            // Header
            VStack(spacing: WinnieSpacing.s) {
                Text("Your nest egg")
                    .font(WinnieTypography.headlineL())
                    .foregroundColor(WinnieColors.primaryText(for: colorScheme))

                Text("How much cash do you have saved up right now that you can put toward your goals?")
                    .font(WinnieTypography.bodyL())
                    .foregroundColor(WinnieColors.secondaryText(for: colorScheme))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, WinnieSpacing.m)
            }

            // Currency input
            VStack(spacing: WinnieSpacing.s) {
                WinnieCurrencyInput(
                    value: $onboardingState.nestEgg,
                    text: $nestEggText
                )
                .padding(.horizontal, WinnieSpacing.screenMarginMobile)

                // Helper text
                Text("Include savings and investment accounts you can access.")
                    .font(WinnieTypography.bodyS())
                    .foregroundColor(WinnieColors.tertiaryText(for: colorScheme))
            }

            Spacer()
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
            // Pre-fill if already set
            if onboardingState.nestEgg > 0 {
                nestEggText = "\(NSDecimalNumber(decimal: onboardingState.nestEgg).intValue)"
            }
        }
    }
}

// MARK: - Previews

#Preview("Light Mode") {
    OnboardingNestEggView(onboardingState: OnboardingState()) {
        print("Continue tapped")
    }
}

#Preview("Dark Mode") {
    OnboardingNestEggView(onboardingState: OnboardingState()) {
        print("Continue tapped")
    }
    .preferredColorScheme(.dark)
}

#Preview("With Value") {
    let state = OnboardingState()
    state.nestEgg = 15000
    return OnboardingNestEggView(onboardingState: state) {
        print("Continue tapped")
    }
}
