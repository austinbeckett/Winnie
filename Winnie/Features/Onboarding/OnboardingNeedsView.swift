import SwiftUI

/// Fixed expenses (Needs) input screen for onboarding wizard.
///
/// Step 3 of the wizard: Asks user for their monthly fixed bills.
/// Shows a list of common expense categories with sliders.
struct OnboardingNeedsView: View {

    @Bindable var onboardingState: OnboardingState
    let onContinue: () -> Void

    @Environment(\.colorScheme) private var colorScheme

    /// Common fixed expense categories
    @State private var expenseCategories: [(name: String, icon: String, amount: Decimal)] = [
        ("Rent / Mortgage", "house.fill", 0),
        ("Utilities", "bolt.fill", 0),
        ("Loans / Debt", "creditcard.fill", 0),
        ("Insurance", "shield.fill", 0),
        ("Phone / Internet", "wifi", 0)
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: WinnieSpacing.xl) {
                // Header
                VStack(spacing: WinnieSpacing.s) {
                    Text("Your *NEEDS*")
                        .font(WinnieTypography.headlineL())
                        .foregroundColor(WinnieColors.primaryText(for: colorScheme))

                    Text("How much money goes to fixed bills or minimum debt payments each month?")
                        .font(WinnieTypography.bodyL())
                        .foregroundColor(WinnieColors.secondaryText(for: colorScheme))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, WinnieSpacing.m)
                }
                .padding(.top, WinnieSpacing.xl)

                // Total display
                totalDisplay

                // Expense category list
                VStack(spacing: WinnieSpacing.m) {
                    ForEach(0..<expenseCategories.count, id: \.self) { index in
                        expenseRow(at: index)
                    }
                }
                .padding(.horizontal, WinnieSpacing.screenMarginMobile)

                Spacer(minLength: WinnieSpacing.xxxl)
            }
        }
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
    }

    // MARK: - Total Display

    private var totalDisplay: some View {
        VStack(spacing: WinnieSpacing.xxs) {
            Text("Total Needs")
                .font(WinnieTypography.caption())
                .foregroundColor(WinnieColors.tertiaryText(for: colorScheme))
                .textCase(.uppercase)
                .tracking(0.5)

            Text("$\(NSDecimalNumber(decimal: onboardingState.monthlyNeeds).intValue)")
                .font(WinnieTypography.financialL())
                .foregroundColor(WinnieColors.primaryText(for: colorScheme))
                .contentTransition(.numericText())

            Text("/month")
                .font(WinnieTypography.bodyS())
                .foregroundColor(WinnieColors.tertiaryText(for: colorScheme))
        }
        .padding(.vertical, WinnieSpacing.m)
    }

    // MARK: - Expense Row

    @ViewBuilder
    private func expenseRow(at index: Int) -> some View {
        let category = expenseCategories[index]

        VStack(spacing: WinnieSpacing.s) {
            HStack {
                // Icon and name
                HStack(spacing: WinnieSpacing.s) {
                    Image(systemName: category.icon)
                        .font(.system(size: 18))
                        .foregroundColor(WinnieColors.accent)
                        .frame(width: 24)

                    Text(category.name)
                        .font(WinnieTypography.bodyM())
                        .foregroundColor(WinnieColors.primaryText(for: colorScheme))
                }

                Spacer()

                // Amount
                Text("$\(NSDecimalNumber(decimal: category.amount).intValue)")
                    .font(WinnieTypography.bodyM())
                    .fontWeight(.semibold)
                    .foregroundColor(WinnieColors.primaryText(for: colorScheme))
                    .contentTransition(.numericText())
            }

            // Slider
            Slider(
                value: Binding(
                    get: { Double(truncating: NSDecimalNumber(decimal: category.amount)) },
                    set: { newValue in
                        expenseCategories[index].amount = Decimal(Int(newValue))
                        updateTotal()
                    }
                ),
                in: 0...5000,
                step: 50
            )
            .tint(WinnieColors.accent)
        }
        .padding(WinnieSpacing.m)
        .background(WinnieColors.cardBackground(for: colorScheme))
        .clipShape(RoundedRectangle(cornerRadius: WinnieSpacing.inputCornerRadius))
    }

    // MARK: - Helpers

    private func updateTotal() {
        let total = expenseCategories.reduce(Decimal(0)) { $0 + $1.amount }
        onboardingState.monthlyNeeds = total
    }
}

// MARK: - Previews

#Preview("Light Mode") {
    OnboardingNeedsView(onboardingState: OnboardingState()) {
        print("Continue tapped")
    }
}

#Preview("Dark Mode") {
    OnboardingNeedsView(onboardingState: OnboardingState()) {
        print("Continue tapped")
    }
    .preferredColorScheme(.dark)
}
