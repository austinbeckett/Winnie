import SwiftUI

/// Savings Pool reveal screen for onboarding wizard.
///
/// Step 5 of the wizard: Shows the calculated "Savings Pool" after
/// deducting needs and wants from income. Includes the pool illustration.
struct OnboardingSavingsPoolView: View {

    @Bindable var onboardingState: OnboardingState
    let onContinue: () -> Void

    @Environment(\.colorScheme) private var colorScheme
    @State private var hasAnimated = false

    var body: some View {
        VStack(spacing: WinnieSpacing.xl) {
            Spacer()

            // Header
            VStack(spacing: WinnieSpacing.s) {
                Text("Your Savings Pool")
                    .font(WinnieTypography.headlineL())
                    .foregroundColor(WinnieColors.primaryText(for: colorScheme))

                Text("This is what you have left each month to put toward your goals.")
                    .font(WinnieTypography.bodyL())
                    .foregroundColor(WinnieColors.secondaryText(for: colorScheme))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, WinnieSpacing.m)
            }

            // Illustration
            Image("SavingsPoolIllustration")
                .resizable()
                .scaledToFit()
                .frame(height: 180)
                .opacity(hasAnimated ? 1 : 0)
                .scaleEffect(hasAnimated ? 1 : 0.8)

            // Amount display
            VStack(spacing: WinnieSpacing.xs) {
                Text("$\(NSDecimalNumber(decimal: onboardingState.savingsPool).intValue)")
                    .font(WinnieTypography.financialXL())
                    .foregroundColor(WinnieColors.accent)
                    .contentTransition(.numericText())
                    .scaleEffect(hasAnimated ? 1 : 0.5)
                    .opacity(hasAnimated ? 1 : 0)

                Text("per month")
                    .font(WinnieTypography.bodyL())
                    .foregroundColor(WinnieColors.secondaryText(for: colorScheme))
            }

            // Breakdown
            breakdownView
                .padding(.horizontal, WinnieSpacing.screenMarginMobile)
                .opacity(hasAnimated ? 1 : 0)

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
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.2)) {
                hasAnimated = true
            }
        }
    }

    // MARK: - Breakdown View

    private var breakdownView: some View {
        VStack(spacing: WinnieSpacing.s) {
            breakdownRow(
                label: "Income",
                amount: onboardingState.monthlyIncome,
                color: WinnieColors.success(for: colorScheme)
            )

            breakdownRow(
                label: "Needs",
                amount: -onboardingState.monthlyNeeds,
                color: WinnieColors.tertiaryText(for: colorScheme)
            )

            breakdownRow(
                label: "Wants",
                amount: -onboardingState.monthlyWants,
                color: WinnieColors.tertiaryText(for: colorScheme)
            )

            Divider()

            breakdownRow(
                label: "Savings Pool",
                amount: onboardingState.savingsPool,
                color: WinnieColors.accent,
                isBold: true
            )
        }
        .padding(WinnieSpacing.m)
        .background(WinnieColors.cardBackground(for: colorScheme))
        .clipShape(RoundedRectangle(cornerRadius: WinnieSpacing.cardCornerRadius))
    }

    @ViewBuilder
    private func breakdownRow(
        label: String,
        amount: Decimal,
        color: Color,
        isBold: Bool = false
    ) -> some View {
        HStack {
            Text(label)
                .font(isBold ? WinnieTypography.bodyM().weight(.semibold) : WinnieTypography.bodyM())
                .foregroundColor(WinnieColors.primaryText(for: colorScheme))

            Spacer()

            Text(amount >= 0 ? "$\(NSDecimalNumber(decimal: amount).intValue)" : "-$\(NSDecimalNumber(decimal: abs(amount)).intValue)")
                .font(isBold ? WinnieTypography.bodyM().weight(.semibold) : WinnieTypography.bodyM())
                .foregroundColor(color)
        }
    }
}

// MARK: - Previews

#Preview("Light Mode") {
    let state = OnboardingState()
    state.monthlyIncome = 7500
    state.monthlyNeeds = 3000
    state.monthlyWants = 1000
    return OnboardingSavingsPoolView(onboardingState: state) {
        print("Continue tapped")
    }
}

#Preview("Dark Mode") {
    let state = OnboardingState()
    state.monthlyIncome = 7500
    state.monthlyNeeds = 3000
    state.monthlyWants = 1000
    return OnboardingSavingsPoolView(onboardingState: state) {
        print("Continue tapped")
    }
    .preferredColorScheme(.dark)
}
