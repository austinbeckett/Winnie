import SwiftUI

/// A styled card container following Winnie design system.
///
/// Usage:
/// ```swift
/// // Basic card
/// WinnieCard {
///     Text("Card content here")
/// }
///
/// // Card with accent border (for goals)
/// WinnieCard(accentColor: goal.displayColor) {
///     GoalContent()
/// }
/// ```
struct WinnieCard<Content: View>: View {
    let accentColor: Color?
    let content: Content

    @Environment(\.colorScheme) private var colorScheme

    /// Creates a card with optional accent border.
    /// - Parameters:
    ///   - accentColor: Optional left border color (4pt wide). Use for goal type identification.
    ///   - content: The card's content.
    init(
        accentColor: Color? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.accentColor = accentColor
        self.content = content()
    }

    var body: some View {
        content
            .padding(WinnieSpacing.l)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(WinnieColors.cardBackground(for: colorScheme))
            .clipShape(RoundedRectangle(cornerRadius: WinnieSpacing.cardCornerRadius))
            .overlay(accentBorderOverlay)
            .shadow(
                color: WinnieColors.cardShadow(for: colorScheme),
                radius: 8,
                x: 0,
                y: 3
            )
    }

    // MARK: - Accent Border

    @ViewBuilder
    private var accentBorderOverlay: some View {
        if let accentColor {
            // Left accent border using a shape overlay
            HStack(spacing: 0) {
                RoundedRectangle(cornerRadius: 2)
                    .fill(accentColor)
                    .frame(width: 4)
                Spacer()
            }
            .clipShape(RoundedRectangle(cornerRadius: WinnieSpacing.cardCornerRadius))
        }
    }
}

// MARK: - Preview

#Preview("Basic Card") {
    VStack(spacing: WinnieSpacing.m) {
        WinnieCard {
            VStack(alignment: .leading, spacing: WinnieSpacing.xs) {
                Text("Card Title")
                    .font(WinnieTypography.headlineM())
                Text("This is some card content that explains something important.")
                    .font(WinnieTypography.bodyM())
            }
        }

        WinnieCard {
            Text("Simple card with just text")
                .font(WinnieTypography.bodyM())
        }
    }
    .padding(WinnieSpacing.l)
    .background(WinnieColors.parchment)
}

#Preview("Cards with Accent Borders") {
    VStack(spacing: WinnieSpacing.m) {
        WinnieCard(accentColor: GoalPresetColor.amethyst.color) {
            Text("Amethyst Goal")
                .font(WinnieTypography.headlineM())
        }

        WinnieCard(accentColor: GoalPresetColor.blackberry.color) {
            Text("Blackberry Goal")
                .font(WinnieTypography.headlineM())
        }

        WinnieCard(accentColor: GoalPresetColor.sage.color) {
            Text("Sage Goal")
                .font(WinnieTypography.headlineM())
        }

        WinnieCard(accentColor: GoalPresetColor.terracotta.color) {
            Text("Terracotta Goal")
                .font(WinnieTypography.headlineM())
        }
    }
    .padding(WinnieSpacing.l)
    .background(WinnieColors.parchment)
}

#Preview("Dark Mode") {
    VStack(spacing: WinnieSpacing.m) {
        WinnieCard {
            Text("Card in Dark Mode")
                .font(WinnieTypography.headlineM())
        }

        WinnieCard(accentColor: GoalPresetColor.amethyst.color) {
            Text("With Accent Border")
                .font(WinnieTypography.headlineM())
        }
    }
    .padding(WinnieSpacing.l)
    .background(WinnieColors.blackberryCream)
    .preferredColorScheme(.dark)
}
