import SwiftUI

/// Welcome screen that greets the user by name after they enter it.
///
/// This screen serves as a transition between name input and the value proposition,
/// creating a personalized moment. An animation can be added later.
struct OnboardingWelcomeView: View {

    let userName: String
    let onContinue: () -> Void

    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        VStack(spacing: WinnieSpacing.xl) {
            Spacer()

            // Welcome message
            Text("Welcome, \(userName).")
                .font(WinnieTypography.displayL())
                .foregroundColor(WinnieColors.primaryText(for: colorScheme))
                .multilineTextAlignment(.center)
                .padding(.horizontal, WinnieSpacing.screenMarginMobile)

            // TODO: Add animation here

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
    }
}

// MARK: - Previews

#Preview("Light Mode") {
    OnboardingWelcomeView(userName: "Austin") {
        print("Continue tapped")
    }
}

#Preview("Dark Mode") {
    OnboardingWelcomeView(userName: "Austin") {
        print("Continue tapped")
    }
    .preferredColorScheme(.dark)
}
