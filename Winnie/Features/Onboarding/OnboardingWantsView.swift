import SwiftUI

/// Discretionary spending (Wants) input screen for onboarding wizard.
///
/// Step 4 of the wizard: Asks user for their monthly wants/discretionary spending.
/// Shows a list of common discretionary categories with sliders.
struct OnboardingWantsView: View {

    @Bindable var onboardingState: OnboardingState
    let onContinue: () -> Void

    @Environment(\.colorScheme) private var colorScheme

    /// Common discretionary expense categories
    @State private var wantCategories: [(name: String, icon: String, amount: Decimal)] = [
        ("Dining Out", "fork.knife", 0),
        ("Entertainment", "tv.fill", 0),
        ("Subscriptions", "play.rectangle.fill", 0),
        ("Shopping", "bag.fill", 0),
        ("Hobbies", "gamecontroller.fill", 0)
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: WinnieSpacing.xl) {
                // Header
                VStack(spacing: WinnieSpacing.s) {
                    Text("Your wants")
                        .font(WinnieTypography.headlineL())
                        .foregroundColor(WinnieColors.primaryText(for: colorScheme))

                    Text("How much goes to wants like entertainment, subscriptions, and going out to eat?")
                        .font(WinnieTypography.bodyL())
                        .foregroundColor(WinnieColors.secondaryText(for: colorScheme))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, WinnieSpacing.m)
                }
                .padding(.top, WinnieSpacing.xl)

                // Total display
                totalDisplay

                // Want category list
                VStack(spacing: WinnieSpacing.m) {
                    ForEach(0..<wantCategories.count, id: \.self) { index in
                        wantRow(at: index)
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
            Text("Total Wants")
                .font(WinnieTypography.caption())
                .foregroundColor(WinnieColors.tertiaryText(for: colorScheme))
                .textCase(.uppercase)
                .tracking(0.5)

            Text("$\(NSDecimalNumber(decimal: onboardingState.monthlyWants).intValue)")
                .font(WinnieTypography.financialL())
                .foregroundColor(WinnieColors.primaryText(for: colorScheme))
                .contentTransition(.numericText())

            Text("/month")
                .font(WinnieTypography.bodyS())
                .foregroundColor(WinnieColors.tertiaryText(for: colorScheme))
        }
        .padding(.vertical, WinnieSpacing.m)
    }

    // MARK: - Want Row

    @ViewBuilder
    private func wantRow(at index: Int) -> some View {
        let category = wantCategories[index]

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
                        wantCategories[index].amount = Decimal(Int(newValue))
                        updateTotal()
                    }
                ),
                in: 0...2000,
                step: 25
            )
            .tint(WinnieColors.accent)
        }
        .padding(WinnieSpacing.m)
        .background(WinnieColors.cardBackground(for: colorScheme))
        .clipShape(RoundedRectangle(cornerRadius: WinnieSpacing.inputCornerRadius))
    }

    // MARK: - Helpers

    private func updateTotal() {
        let total = wantCategories.reduce(Decimal(0)) { $0 + $1.amount }
        onboardingState.monthlyWants = total
    }
}

// MARK: - Previews

#Preview("Light Mode") {
    OnboardingWantsView(onboardingState: OnboardingState()) {
        print("Continue tapped")
    }
}

#Preview("Dark Mode") {
    OnboardingWantsView(onboardingState: OnboardingState()) {
        print("Continue tapped")
    }
    .preferredColorScheme(.dark)
}
