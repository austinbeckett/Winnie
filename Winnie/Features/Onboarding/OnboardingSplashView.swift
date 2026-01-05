import SwiftUI

/// Onboarding splash screen with motion graphic and tagline.
///
/// This is the first screen users see when launching the app for the first time.
/// Displays the Winnie brand, tagline, and a "Get Started" button.
struct OnboardingSplashView: View {

    let onGetStarted: () -> Void

    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        VStack(spacing: WinnieSpacing.xl) {
            Spacer()

            // Logo / Brand
            VStack(spacing: WinnieSpacing.m) {
                Text("Winnie")
                    .font(WinnieTypography.displayL())
                    .foregroundColor(WinnieColors.primaryText(for: colorScheme))

                // Tagline
                Text("Save smarter, together.")
                    .font(WinnieTypography.bodyL())
                    .foregroundColor(WinnieColors.primaryText(for: colorScheme))
            }
            .multilineTextAlignment(.center)

            Spacer()
            Spacer()

            // Get Started button
            WinnieButton("Get Started", style: .primary) {
                onGetStarted()
            }
            .padding(.horizontal, WinnieSpacing.screenMarginMobile)
            .padding(.bottom, WinnieSpacing.xl)
        }
        .background(WinnieColors.background(for: colorScheme).ignoresSafeArea())
    }
}

// MARK: - Previews

#Preview("Light Mode") {
    OnboardingSplashView {
        print("Get Started tapped")
    }
}

#Preview("Dark Mode") {
    OnboardingSplashView {
        print("Get Started tapped")
    }
    .preferredColorScheme(.dark)
}
