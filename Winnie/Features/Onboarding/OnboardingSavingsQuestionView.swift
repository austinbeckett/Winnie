import SwiftUI

/// Question screen asking if user knows their monthly savings amount.
///
/// Branches the onboarding flow:
/// - "Yes" → Skip to Savings Pool (direct input)
/// - "No" → Go through Needs → Wants → Savings Pool (calculated)
struct OnboardingSavingsQuestionView: View {

    let onKnowsSavings: () -> Void
    let onNeedHelp: () -> Void

    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        VStack(spacing: WinnieSpacing.xl) {
            Spacer()

            // Header
            VStack(spacing: WinnieSpacing.s) {
                Image(systemName: "questionmark.circle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(WinnieColors.accent)

                Text("Do you know how much you currently save each month?")
                    .font(WinnieTypography.headlineL())
                    .foregroundColor(WinnieColors.primaryText(for: colorScheme))
                    .multilineTextAlignment(.center)

                Text("This will help us determine how much money we can allocate to your goals.")
                    .font(WinnieTypography.bodyL())
                    .foregroundColor(WinnieColors.secondaryText(for: colorScheme))
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, WinnieSpacing.screenMarginMobile)

            Spacer()

            // Option buttons
            VStack(spacing: WinnieSpacing.m) {
                optionButton(
                    title: "Yes, I know how much I save",
                    subtitle: "I'll enter my monthly savings directly",
                    action: onKnowsSavings
                )

                optionButton(
                    title: "No, please help me figure it out",
                    subtitle: "I'll enter my expenses to calculate savings",
                    action: onNeedHelp
                )
            }
            .padding(.horizontal, WinnieSpacing.screenMarginMobile)
            .padding(.bottom, WinnieSpacing.xl)
        }
        .background(WinnieColors.background(for: colorScheme).ignoresSafeArea())
    }

    // MARK: - Option Button

    @ViewBuilder
    private func optionButton(title: String, subtitle: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: WinnieSpacing.xxs) {
                Text(title)
                    .font(WinnieTypography.bodyM().weight(.semibold))
                    .foregroundColor(WinnieColors.primaryText(for: colorScheme))

                Text(subtitle)
                    .font(WinnieTypography.bodyS())
                    .foregroundColor(WinnieColors.secondaryText(for: colorScheme))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(WinnieSpacing.m)
            .background(WinnieColors.cardBackground(for: colorScheme))
            .clipShape(RoundedRectangle(cornerRadius: WinnieSpacing.cardCornerRadius))
            .overlay(
                RoundedRectangle(cornerRadius: WinnieSpacing.cardCornerRadius)
                    .stroke(WinnieColors.tertiaryText(for: colorScheme).opacity(0.3), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Previews

#Preview("Light Mode") {
    OnboardingSavingsQuestionView(
        onKnowsSavings: { print("Knows savings") },
        onNeedHelp: { print("Needs help") }
    )
}

#Preview("Dark Mode") {
    OnboardingSavingsQuestionView(
        onKnowsSavings: { print("Knows savings") },
        onNeedHelp: { print("Needs help") }
    )
    .preferredColorScheme(.dark)
}
