import SwiftUI

/// Savings Pool reveal screen for onboarding wizard.
///
/// Shows either:
/// - An editable input (when user knows their savings amount)
/// - A calculated display with breakdown (when calculated from expenses)
struct OnboardingSavingsPoolView: View {

    @Bindable var onboardingState: OnboardingState
    let onContinue: () -> Void

    @Environment(\.colorScheme) private var colorScheme
    @State private var hasAnimated = false

    /// Local string for text field binding (only used in editable mode)
    @State private var savingsText: String = ""

    var body: some View {
        ScrollView {
            VStack(spacing: WinnieSpacing.xl) {
                Spacer(minLength: WinnieSpacing.xl)

                // Header
                VStack(spacing: WinnieSpacing.s) {
                    Text("Your Savings Pool")
                        .font(WinnieTypography.headlineL())
                        .foregroundColor(WinnieColors.primaryText(for: colorScheme))

                    Text(onboardingState.knowsSavingsAmount
                         ? "Enter how much you save each month."
                         : "This is what you have left each month to put toward your goals.")
                        .font(WinnieTypography.bodyL())
                        .foregroundColor(WinnieColors.secondaryText(for: colorScheme))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, WinnieSpacing.m)
                        .fixedSize(horizontal: false, vertical: true)
                }

                // Illustration
                Image("SavingsPoolIllustration")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 180)
                    .opacity(hasAnimated ? 1 : 0)
                    .scaleEffect(hasAnimated ? 1 : 0.8)

                // Amount display (editable or calculated)
                if onboardingState.knowsSavingsAmount {
                    editableAmountView
                } else {
                    calculatedAmountView
                }

                Spacer(minLength: WinnieSpacing.xxxl)
            }
        }
        .scrollDismissesKeyboard(.interactively)
        .safeAreaInset(edge: .bottom) {
            WinnieButton("Continue", style: .primary) {
                onContinue()
            }
            .disabled(onboardingState.knowsSavingsAmount && onboardingState.directSavingsPool <= 0)
            .padding(.horizontal, WinnieSpacing.screenMarginMobile)
            .padding(.vertical, WinnieSpacing.m)
            .background(WinnieColors.background(for: colorScheme))
        }
        .background(WinnieColors.background(for: colorScheme).ignoresSafeArea())
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.2)) {
                hasAnimated = true
            }
            // Pre-fill if already set
            if onboardingState.directSavingsPool > 0 {
                savingsText = "\(NSDecimalNumber(decimal: onboardingState.directSavingsPool).intValue)"
            }
        }
    }

    // MARK: - Editable Amount View

    private var editableAmountView: some View {
        VStack(spacing: WinnieSpacing.s) {
            WinnieCurrencyInput(
                value: $onboardingState.directSavingsPool,
                text: $savingsText,
                suffix: "/mo",
                accentValue: true
            )
            .padding(.horizontal, WinnieSpacing.screenMarginMobile)

            // Helper text
            Text("This is the amount you can put toward your goals each month.")
                .font(WinnieTypography.bodyS())
                .foregroundColor(WinnieColors.tertiaryText(for: colorScheme))
                .multilineTextAlignment(.center)
                .padding(.horizontal, WinnieSpacing.m)
        }
    }

    // MARK: - Calculated Amount View

    private var calculatedAmountView: some View {
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

            // Breakdown card
            breakdownView
                .padding(.horizontal, WinnieSpacing.screenMarginMobile)
                .padding(.top, WinnieSpacing.m)
                .opacity(hasAnimated ? 1 : 0)
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

#Preview("Editable Mode") {
    let state = OnboardingState()
    state.monthlyIncome = 7500
    state.knowsSavingsAmount = true
    return OnboardingSavingsPoolView(onboardingState: state) {
        print("Continue tapped")
    }
}

#Preview("Calculated Mode") {
    let state = OnboardingState()
    state.monthlyIncome = 7500
    state.monthlyNeeds = 3000
    state.monthlyWants = 1000
    state.knowsSavingsAmount = false
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
