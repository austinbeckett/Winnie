import SwiftUI

/// Partner invite screen for onboarding wizard.
///
/// Step 8 of the wizard: Encourages user to invite their partner.
/// This is included in the free tier.
struct OnboardingPartnerInviteView: View {

    let onInvite: () -> Void
    let onSkip: () -> Void

    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        VStack(spacing: WinnieSpacing.xl) {
            Spacer()

            // Illustration / Icon
            Image(systemName: "person.2.fill")
                .font(.system(size: 64))
                .foregroundColor(WinnieColors.accent)

            // Header
            VStack(spacing: WinnieSpacing.s) {
                Text("Better together")
                    .font(WinnieTypography.headlineL())
                    .foregroundColor(WinnieColors.primaryText(for: colorScheme))

                Text("Financial planning only works when you're in it together.")
                    .font(WinnieTypography.bodyL())
                    .foregroundColor(WinnieColors.secondaryText(for: colorScheme))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, WinnieSpacing.m)
            }

            // Features list
            VStack(alignment: .leading, spacing: WinnieSpacing.m) {
                featureRow(icon: "checkmark.circle.fill", text: "Shared goals and progress")
                featureRow(icon: "checkmark.circle.fill", text: "Same view, different devices")
                featureRow(icon: "checkmark.circle.fill", text: "Make decisions together")
            }
            .padding(.horizontal, WinnieSpacing.screenMarginMobile)
            .padding(.vertical, WinnieSpacing.l)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(WinnieColors.cardBackground(for: colorScheme))
            .clipShape(RoundedRectangle(cornerRadius: WinnieSpacing.cardCornerRadius))
            .padding(.horizontal, WinnieSpacing.screenMarginMobile)

            Spacer()

            // Buttons
            VStack(spacing: WinnieSpacing.m) {
                WinnieButton("Invite Partner", style: .primary) {
                    onInvite()
                }

                WinnieButton("I'll do this later", style: .text) {
                    onSkip()
                }
            }
            .padding(.horizontal, WinnieSpacing.screenMarginMobile)
            .padding(.bottom, WinnieSpacing.xl)
        }
        .background(WinnieColors.background(for: colorScheme).ignoresSafeArea())
    }

    // MARK: - Feature Row

    @ViewBuilder
    private func featureRow(icon: String, text: String) -> some View {
        HStack(spacing: WinnieSpacing.s) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(WinnieColors.success(for: colorScheme))

            Text(text)
                .font(WinnieTypography.bodyM())
                .foregroundColor(WinnieColors.primaryText(for: colorScheme))
        }
    }
}

// MARK: - Previews

#Preview("Light Mode") {
    OnboardingPartnerInviteView(
        onInvite: { print("Invite tapped") },
        onSkip: { print("Skip tapped") }
    )
}

#Preview("Dark Mode") {
    OnboardingPartnerInviteView(
        onInvite: { print("Invite tapped") },
        onSkip: { print("Skip tapped") }
    )
    .preferredColorScheme(.dark)
}
