import SwiftUI

/// Value proposition screen for onboarding.
///
/// A 3-panel swipeable story that establishes Winnie's core value:
/// helping couples overcome decision paralysis when balancing multiple financial goals.
struct OnboardingValuePropView: View {

    let onContinue: () -> Void

    @Environment(\.colorScheme) private var colorScheme
    @State private var currentPage = 0

    private let panels: [(headline: String, subhead: String, icon: String)] = [
        (
            "You have goals. Plural.",
            "Whether it's your first home, a dream wedding, or a secure retirement, your financial goals represent the life you're building.",
            "sparkles"
        ),
        (
            "Saving for everything at once is hard.",
            "It feels impossible to know which choice is 'right' when everything feels important.",
            "questionmark.circle"
        ),
        (
            "We've got you.",
            "Winnie shows you exactly how every goal and decision fits into the bigger picture, giving you the confidence to save and plan for the future.",
            "sun.max.fill"
        )
    ]

    private let quotes: [String] = [
        "If we go all in saving for a house, when can we afford to travel?",
        "If we cut back on our wedding budget, how much longer can we extend our honeymoon?",
        "How much of my monthly savings should go to my credit card debt vs. investing for retirement?",
        "If we save $1,000 a month for a new car, how long does that delay us getting our first home?",
        "We'll have a newborn in 9 months—should we increase our emergency fund? How would that affect the timelines of our other goals?",
        "Are we saving enough for retirement if we do all of this?"
    ]

    var body: some View {
        VStack(spacing: 0) {
            // Page content
            TabView(selection: $currentPage) {
                panel1.tag(0)
                panel2.tag(1)
                panel3.tag(2)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))

            // Bottom section
            VStack(spacing: WinnieSpacing.l) {
                // Page indicator
                HStack(spacing: WinnieSpacing.xs) {
                    ForEach(0..<3, id: \.self) { index in
                        Circle()
                            .fill(index == currentPage
                                  ? WinnieColors.accent
                                  : WinnieColors.tertiaryText(for: colorScheme))
                            .frame(width: 8, height: 8)
                            .animation(.easeInOut(duration: 0.2), value: currentPage)
                    }
                }

                // Navigation button
                WinnieButton(currentPage < 2 ? "Next" : "Let's get started", style: .primary) {
                    if currentPage < 2 {
                        withAnimation {
                            currentPage += 1
                        }
                    } else {
                        onContinue()
                    }
                }
                .padding(.horizontal, WinnieSpacing.screenMarginMobile)
            }
            .padding(.bottom, WinnieSpacing.xl)
        }
        .background(WinnieColors.background(for: colorScheme).ignoresSafeArea())
    }

    // MARK: - Panel 1: The Dream

    private var panel1: some View {
        VStack(spacing: WinnieSpacing.l) {
            Spacer()

            // Icon placeholder for illustration
            Image(systemName: "sparkles")
                .font(.system(size: 56))
                .foregroundColor(WinnieColors.accent)

            // Headlines
            VStack(spacing: WinnieSpacing.m) {
                Text(panels[0].headline)
                    .font(WinnieTypography.headlineL())
                    .foregroundColor(WinnieColors.primaryText(for: colorScheme))
                    .multilineTextAlignment(.center)

                Text(panels[0].subhead)
                    .font(WinnieTypography.bodyL())
                    .foregroundColor(WinnieColors.secondaryText(for: colorScheme))
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, WinnieSpacing.screenMarginMobile)

            Spacer()
            Spacer()
        }
    }

    // MARK: - Panel 2: The Questions

    private var panel2: some View {
        VStack(spacing: WinnieSpacing.l) {
            Spacer()

            // Scrolling quotes
            ScrollView {
                VStack(spacing: WinnieSpacing.m) {
                    ForEach(quotes, id: \.self) { quote in
                        quoteCard(quote)
                    }
                }
                .padding(.horizontal, WinnieSpacing.screenMarginMobile)
            }
            .frame(maxHeight: 400)

            // Headlines
            VStack(spacing: WinnieSpacing.m) {
                Text(panels[1].headline)
                    .font(WinnieTypography.headlineL())
                    .foregroundColor(WinnieColors.primaryText(for: colorScheme))
                    .multilineTextAlignment(.center)

                Text(panels[1].subhead)
                    .font(WinnieTypography.bodyL())
                    .foregroundColor(WinnieColors.secondaryText(for: colorScheme))
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, WinnieSpacing.screenMarginMobile)
            .padding(.top, WinnieSpacing.s)

            Spacer()
        }
    }

    @ViewBuilder
    private func quoteCard(_ text: String) -> some View {
        Text("\"\(text)\"")
            .font(WinnieTypography.bodyM())
            .foregroundColor(WinnieColors.primaryText(for: colorScheme))
            .multilineTextAlignment(.leading)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(WinnieSpacing.m)
            .background(WinnieColors.cardBackground(for: colorScheme))
            .clipShape(RoundedRectangle(cornerRadius: WinnieSpacing.cardCornerRadius))
    }

    // MARK: - Panel 3: The Answer

    private var panel3: some View {
        VStack(spacing: WinnieSpacing.l) {
            Spacer()

            // Icon placeholder for illustration
            Image(systemName: "sun.max.fill")
                .font(.system(size: 56))
                .foregroundColor(WinnieColors.accent)

            // Headlines
            VStack(spacing: WinnieSpacing.m) {
                Text(panels[2].headline)
                    .font(WinnieTypography.headlineL())
                    .foregroundColor(WinnieColors.primaryText(for: colorScheme))
                    .multilineTextAlignment(.center)

                Text(panels[2].subhead)
                    .font(WinnieTypography.bodyL())
                    .foregroundColor(WinnieColors.secondaryText(for: colorScheme))
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, WinnieSpacing.screenMarginMobile)

            Spacer()
            Spacer()
        }
    }
}

// MARK: - Previews

#Preview("Light Mode") {
    OnboardingValuePropView {
        print("Continue tapped")
    }
}

#Preview("Dark Mode") {
    OnboardingValuePropView {
        print("Continue tapped")
    }
    .preferredColorScheme(.dark)
}

#Preview("Panel 2 - Questions") {
    OnboardingValuePropView {
        print("Continue tapped")
    }
}
