import SwiftUI

/// Value proposition carousel shown during onboarding.
///
/// Displays 3 slides highlighting key features:
/// - "Your future, built together" - Goal alignment
/// - "Play with Scenarios" - What-if planning
/// - "Stay on Track" - Monthly check-ins
struct OnboardingCarouselView: View {

    let onContinue: () -> Void

    @Environment(\.colorScheme) private var colorScheme
    @State private var currentPage = 0

    private let slides: [(title: String, subtitle: String, icon: String)] = [
        (
            "Your future, built together",
            "Align your goals without the arguments.",
            "heart.fill"
        ),
        (
            "Play with Scenarios",
            "See how the cost of your wedding impacts your timeline to buy a house.",
            "slider.horizontal.3"
        ),
        (
            "Stay on Track",
            "Simple monthly check-ins keep you both moving forward.",
            "checkmark.circle.fill"
        )
    ]

    var body: some View {
        VStack(spacing: WinnieSpacing.xl) {
            Spacer()

            // Page content
            TabView(selection: $currentPage) {
                ForEach(0..<slides.count, id: \.self) { index in
                    slideView(for: slides[index])
                        .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .frame(height: 300)

            // Page indicator
            HStack(spacing: WinnieSpacing.xs) {
                ForEach(0..<slides.count, id: \.self) { index in
                    Circle()
                        .fill(index == currentPage
                              ? WinnieColors.accent
                              : WinnieColors.tertiaryText(for: colorScheme))
                        .frame(width: 8, height: 8)
                        .animation(.easeInOut(duration: 0.2), value: currentPage)
                }
            }

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

    // MARK: - Slide View

    @ViewBuilder
    private func slideView(for slide: (title: String, subtitle: String, icon: String)) -> some View {
        VStack(spacing: WinnieSpacing.l) {
            // Icon
            Image(systemName: slide.icon)
                .font(.system(size: 60))
                .foregroundColor(WinnieColors.accent)

            // Title
            Text(slide.title)
                .font(WinnieTypography.headlineL())
                .foregroundColor(WinnieColors.primaryText(for: colorScheme))
                .multilineTextAlignment(.center)

            // Subtitle
            Text(slide.subtitle)
                .font(WinnieTypography.bodyL())
                .foregroundColor(WinnieColors.secondaryText(for: colorScheme))
                .multilineTextAlignment(.center)
                .padding(.horizontal, WinnieSpacing.l)
        }
        .padding(.horizontal, WinnieSpacing.screenMarginMobile)
    }
}

// MARK: - Previews

#Preview("Light Mode") {
    OnboardingCarouselView {
        print("Continue tapped")
    }
}

#Preview("Dark Mode") {
    OnboardingCarouselView {
        print("Continue tapped")
    }
    .preferredColorScheme(.dark)
}
