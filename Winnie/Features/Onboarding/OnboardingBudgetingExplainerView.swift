import SwiftUI

/// Educational screen explaining the Needs/Wants/Savings budgeting style.
///
/// Shown after user selects "No, help me figure it out" on the savings question,
/// before collecting expense data.
struct OnboardingBudgetingExplainerView: View {

    let onContinue: () -> Void

    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        ScrollView {
            VStack(spacing: WinnieSpacing.xl) {
                Spacer(minLength: WinnieSpacing.xl)

                // Header
                VStack(spacing: WinnieSpacing.s) {
                    Image(systemName: "chart.pie.fill")
                        .font(.system(size: 60))
                        .foregroundColor(WinnieColors.accent)

                    Text("How we think about budgeting")
                        .font(WinnieTypography.headlineL())
                        .foregroundColor(WinnieColors.primaryText(for: colorScheme))
                        .multilineTextAlignment(.center)
                }

                // Main explanation
                VStack(alignment: .leading, spacing: WinnieSpacing.m) {
                    Text("We use a simple **Needs / Wants / Savings** approach instead of strict category-by-category budgets.")
                        .font(WinnieTypography.bodyL())
                        .foregroundColor(WinnieColors.primaryText(for: colorScheme))

                    Text("Why? Because expenses fluctuate month to month. This gives you a quick, high-level view of where your money goes without getting bogged down in the details.")
                        .font(WinnieTypography.bodyM())
                        .foregroundColor(WinnieColors.secondaryText(for: colorScheme))
                }
                .padding(.horizontal, WinnieSpacing.screenMarginMobile)

                // Category breakdown
                VStack(spacing: WinnieSpacing.s) {
                    categoryRow(
                        icon: "house.fill",
                        title: "Needs",
                        description: "Fixed bills and essentials",
                        color: WinnieColors.accent
                    )

                    categoryRow(
                        icon: "cart.fill",
                        title: "Wants",
                        description: "Discretionary spending",
                        color: WinnieColors.accent
                    )

                    categoryRow(
                        icon: "dollarsign.circle.fill",
                        title: "Savings",
                        description: "What's left for your goals",
                        color: WinnieColors.accent
                    )
                }
                .padding(WinnieSpacing.m)
                .background(WinnieColors.cardBackground(for: colorScheme))
                .clipShape(RoundedRectangle(cornerRadius: WinnieSpacing.cardCornerRadius))
                .padding(.horizontal, WinnieSpacing.screenMarginMobile)

                // Note about future budgeting
                Text("Don't worry about being exact. We'll help you build a more detailed, \"pay yourself first\" budget later. For now, let's just get a quick sense of your current needs and wants.")
                    .font(WinnieTypography.bodyS())
                    .foregroundColor(WinnieColors.tertiaryText(for: colorScheme))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, WinnieSpacing.m)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.top, WinnieSpacing.s)

                Spacer(minLength: WinnieSpacing.xxxl)
            }
        }
        .safeAreaInset(edge: .bottom) {
            WinnieButton("Got it", style: .primary) {
                onContinue()
            }
            .padding(.horizontal, WinnieSpacing.screenMarginMobile)
            .padding(.vertical, WinnieSpacing.m)
            .background(WinnieColors.background(for: colorScheme))
        }
        .background(WinnieColors.background(for: colorScheme).ignoresSafeArea())
    }

    // MARK: - Category Row

    @ViewBuilder
    private func categoryRow(icon: String, title: String, description: String, color: Color) -> some View {
        HStack(spacing: WinnieSpacing.m) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(color)
                .frame(width: 32)

            VStack(alignment: .leading, spacing: WinnieSpacing.xxs) {
                Text(title)
                    .font(WinnieTypography.bodyM().weight(.semibold))
                    .foregroundColor(WinnieColors.cardText)

                Text(description)
                    .font(WinnieTypography.bodyS())
                    .foregroundColor(WinnieColors.cardText.opacity(0.8))
            }

            Spacer()
        }
    }
}

// MARK: - Previews

#Preview("Light Mode") {
    OnboardingBudgetingExplainerView {
        print("Continue tapped")
    }
}

#Preview("Dark Mode") {
    OnboardingBudgetingExplainerView {
        print("Continue tapped")
    }
    .preferredColorScheme(.dark)
}
