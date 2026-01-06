import SwiftUI

/// Fixed expenses (Needs) input screen for onboarding wizard.
///
/// Asks user for their monthly fixed bills with a single input,
/// with an optional breakdown by category for more precision.
struct OnboardingNeedsView: View {

    @Bindable var onboardingState: OnboardingState
    let onContinue: () -> Void

    @Environment(\.colorScheme) private var colorScheme

    /// Local string for text field binding
    @State private var needsText: String = ""

    /// Whether to show the category breakdown
    @State private var showBreakdown = false

    /// Category breakdown amounts (only used when expanded)
    @State private var categoryAmounts: [String: Decimal] = [
        "Rent / Mortgage": 0,
        "Utilities": 0,
        "Loans / Debt": 0,
        "Insurance": 0,
        "Phone / Internet": 0
    ]

    private let categories: [(name: String, icon: String)] = [
        ("Rent / Mortgage", "house.fill"),
        ("Utilities", "bolt.fill"),
        ("Loans / Debt", "creditcard.fill"),
        ("Insurance", "shield.fill"),
        ("Phone / Internet", "wifi")
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: WinnieSpacing.xl) {
                // Header
                VStack(spacing: WinnieSpacing.s) {
                    Text("Your fixed expenses")
                        .font(WinnieTypography.headlineL())
                        .foregroundColor(WinnieColors.primaryText(for: colorScheme))

                    Text("About how much goes to bills and essentials each month?")
                        .font(WinnieTypography.bodyL())
                        .foregroundColor(WinnieColors.secondaryText(for: colorScheme))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, WinnieSpacing.m)
                }
                .padding(.top, WinnieSpacing.xl)

                // Main currency input
                VStack(spacing: WinnieSpacing.s) {
                    WinnieCurrencyInput(
                        value: $onboardingState.monthlyNeeds,
                        text: $needsText,
                        suffix: "/mo"
                    )
                    .padding(.horizontal, WinnieSpacing.screenMarginMobile)
                    .disabled(showBreakdown)
                    .opacity(showBreakdown ? 0.5 : 1)

                    // Helper text
                    Text("Rent, utilities, insurance, loans, subscriptions—the essentials.")
                        .font(WinnieTypography.bodyS())
                        .foregroundColor(WinnieColors.tertiaryText(for: colorScheme))
                        .multilineTextAlignment(.center)
                }

                // Optional breakdown toggle
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        showBreakdown.toggle()
                        if !showBreakdown {
                            // When collapsing, sync total from categories
                            syncTotalFromCategories()
                        }
                    }
                } label: {
                    HStack(spacing: WinnieSpacing.xs) {
                        Image(systemName: showBreakdown ? "chevron.up" : "chevron.down")
                            .font(.system(size: 12, weight: .semibold))
                        Text(showBreakdown ? "Hide breakdown" : "Break it down by category")
                            .font(WinnieTypography.bodyS().weight(.medium))
                    }
                    .foregroundColor(WinnieColors.accent)
                }
                .padding(.top, WinnieSpacing.xs)

                // Expandable category breakdown
                if showBreakdown {
                    categoryBreakdown
                        .transition(.opacity.combined(with: .move(edge: .top)))
                }

                Spacer(minLength: WinnieSpacing.xxxl)
            }
        }
        .scrollDismissesKeyboard(.interactively)
        .safeAreaInset(edge: .bottom) {
            WinnieButton("Continue", style: .primary) {
                onContinue()
            }
            .padding(.horizontal, WinnieSpacing.screenMarginMobile)
            .padding(.vertical, WinnieSpacing.m)
            .background(WinnieColors.background(for: colorScheme))
        }
        .background(WinnieColors.background(for: colorScheme).ignoresSafeArea())
        .onAppear {
            if onboardingState.monthlyNeeds > 0 {
                needsText = "\(NSDecimalNumber(decimal: onboardingState.monthlyNeeds).intValue)"
            }
        }
    }

    // MARK: - Category Breakdown

    private var categoryBreakdown: some View {
        VStack(spacing: WinnieSpacing.s) {
            ForEach(categories, id: \.name) { category in
                categoryRow(name: category.name, icon: category.icon)
            }

            // Total from breakdown
            HStack {
                Text("Total")
                    .font(WinnieTypography.bodyM().weight(.semibold))
                    .foregroundColor(WinnieColors.cardText)
                Spacer()
                Text("$\(breakdownTotal)")
                    .font(WinnieTypography.bodyM().weight(.semibold))
                    .foregroundColor(WinnieColors.accent)
            }
            .padding(.top, WinnieSpacing.xs)
        }
        .padding(WinnieSpacing.m)
        .background(WinnieColors.cardBackground(for: colorScheme))
        .clipShape(RoundedRectangle(cornerRadius: WinnieSpacing.cardCornerRadius))
        .padding(.horizontal, WinnieSpacing.screenMarginMobile)
    }

    @ViewBuilder
    private func categoryRow(name: String, icon: String) -> some View {
        HStack(spacing: WinnieSpacing.s) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(WinnieColors.accent)
                .frame(width: 24)

            Text(name)
                .font(WinnieTypography.bodyS())
                .foregroundColor(WinnieColors.cardText)

            Spacer()

            // Small text field for amount
            TextField("$0", value: Binding(
                get: { categoryAmounts[name] ?? 0 },
                set: { newValue in
                    categoryAmounts[name] = newValue
                    syncTotalFromCategories()
                }
            ), format: .currency(code: "USD").precision(.fractionLength(0)))
            .font(WinnieTypography.bodyS())
            .foregroundColor(WinnieColors.cardText)
            .keyboardType(.numberPad)
            .multilineTextAlignment(.trailing)
            .frame(width: 80)
        }
    }

    // MARK: - Helpers

    private var breakdownTotal: Int {
        let total = categoryAmounts.values.reduce(Decimal(0), +)
        return NSDecimalNumber(decimal: total).intValue
    }

    private func syncTotalFromCategories() {
        let total = categoryAmounts.values.reduce(Decimal(0), +)
        onboardingState.monthlyNeeds = total
        needsText = "\(NSDecimalNumber(decimal: total).intValue)"
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

#Preview("With Breakdown") {
    OnboardingNeedsView(onboardingState: OnboardingState()) {
        print("Continue tapped")
    }
}
