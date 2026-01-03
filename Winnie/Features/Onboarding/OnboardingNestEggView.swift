import SwiftUI

/// Current savings (Nest Egg) input screen for onboarding wizard.
///
/// Step 6 of the wizard: Asks user for their current liquid savings balance.
struct OnboardingNestEggView: View {

    @Bindable var onboardingState: OnboardingState
    let onContinue: () -> Void

    @Environment(\.colorScheme) private var colorScheme
    @FocusState private var isInputFocused: Bool

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
            VStack(spacing: WinnieSpacing.xs) {
                HStack(alignment: .center, spacing: WinnieSpacing.xxs) {
                    Text("$")
                        .font(WinnieTypography.financialL())
                        .foregroundColor(WinnieColors.tertiaryText(for: colorScheme))

                    TextField("0", text: $nestEggText)
                        .font(WinnieTypography.financialL())
                        .foregroundColor(WinnieColors.primaryText(for: colorScheme))
                        .keyboardType(.numberPad)
                        .multilineTextAlignment(.leading)
                        .focused($isInputFocused)
                        .onChange(of: nestEggText) { _, newValue in
                            // Filter to digits only
                            let filtered = newValue.filter { $0.isNumber }
                            if filtered != newValue {
                                nestEggText = filtered
                            }
                            // Update state
                            if let value = Decimal(string: filtered) {
                                onboardingState.nestEgg = value
                            } else {
                                onboardingState.nestEgg = 0
                            }
                        }
                }
                .padding(.horizontal, WinnieSpacing.l)

                // Underline
                Rectangle()
                    .fill(isInputFocused ? WinnieColors.accent : WinnieColors.tertiaryText(for: colorScheme))
                    .frame(height: 2)
                    .padding(.horizontal, WinnieSpacing.xxxl)

                // Helper text
                Text("Include savings and investment accounts you can access.")
                    .font(WinnieTypography.bodyS())
                    .foregroundColor(WinnieColors.tertiaryText(for: colorScheme))
                    .padding(.top, WinnieSpacing.s)
            }

            Spacer()
            Spacer()

            // Continue button
            WinnieButton("Continue", style: .primary) {
                isInputFocused = false
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
            isInputFocused = true
        }
        .onTapGesture {
            isInputFocused = false
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
