import SwiftUI

/// A styled card container following Winnie design system.
/// Supports multiple background styles with automatic text color adaptation.
///
/// WinnieCard automatically sets `cardContext` in the environment, so child views
/// can use context-aware modifiers like `.contextPrimaryText()` to automatically
/// get the correct text color.
///
/// Usage:
/// ```swift
/// // Simple usage - text auto-adapts via context modifiers
/// WinnieCard {
///     Text("Card content")
///         .contextPrimaryText()  // Automatically uses ivory on pine teal
/// }
///
/// // Or use WinnieColors.cardText directly
/// WinnieCard {
///     Text("Card content")
///         .foregroundColor(WinnieColors.cardText)
/// }
///
/// // Different card styles
/// WinnieCard(style: .carbon) {
///     Text("Dark card")
///         .contextPrimaryText()
/// }
///
/// // Card with accent border (for goals)
/// WinnieCard(accentColor: goal.displayColor) {
///     GoalContent()
/// }
/// ```
struct WinnieCard<Content: View>: View {
    let style: WinnieCardStyle
    let accentColor: Color?
    let content: Content

    @Environment(\.colorScheme) private var colorScheme

    /// Creates a card with optional style and accent border.
    /// - Parameters:
    ///   - style: The card background style. Defaults to `.pineTeal`.
    ///   - accentColor: Optional left border color (4pt wide). Use for goal type identification.
    ///   - content: The card's content.
    init(
        style: WinnieCardStyle = .pineTeal,
        accentColor: Color? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.style = style
        self.accentColor = accentColor
        self.content = content()
    }

    var body: some View {
        content
            .cardContext(style)  // Propagate card context to all children
            .padding(WinnieSpacing.l)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(WinnieColors.cardBackground(for: style, colorScheme: colorScheme))
            .clipShape(RoundedRectangle(cornerRadius: WinnieSpacing.cardCornerRadius))
            .overlay(accentBorderOverlay)
            .shadow(
                color: WinnieColors.cardShadow(for: colorScheme),
                radius: 6,
                x: 0,
                y: 2
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

// MARK: - Card Text Modifiers

extension View {
    /// Applies primary text styling for card content based on the card style.
    /// - Parameter style: The card style to match text color to
    /// - Returns: View with appropriate foreground color
    func cardPrimaryText(for style: WinnieCardStyle) -> some View {
        modifier(CardTextModifier(style: style, isSecondary: false))
    }

    /// Applies secondary text styling for card content based on the card style.
    /// - Parameter style: The card style to match text color to
    /// - Returns: View with appropriate foreground color at 80% opacity
    func cardSecondaryText(for style: WinnieCardStyle) -> some View {
        modifier(CardTextModifier(style: style, isSecondary: true))
    }
}

/// View modifier that applies the correct text color for a card style.
private struct CardTextModifier: ViewModifier {
    let style: WinnieCardStyle
    let isSecondary: Bool

    @Environment(\.colorScheme) private var colorScheme

    func body(content: Content) -> some View {
        content.foregroundStyle(textColor)
    }

    private var textColor: Color {
        if isSecondary {
            return WinnieColors.cardSecondaryTextColor(for: style, colorScheme: colorScheme)
        } else {
            return WinnieColors.cardTextColor(for: style, colorScheme: colorScheme)
        }
    }
}

// MARK: - Preview

#Preview("Card Styles") {
    CardStylePreview()
}

#Preview("Card Styles - Dark Mode") {
    CardStylePreview()
        .preferredColorScheme(.dark)
}

#Preview("Cards with Accent Borders") {
    VStack(spacing: WinnieSpacing.m) {
        WinnieCard(accentColor: GoalPresetColor.coral.color) {
            Text("Coral Goal")
                .font(WinnieTypography.headlineM())
                .foregroundColor(WinnieColors.cardText)
        }

        WinnieCard(accentColor: GoalPresetColor.gold.color) {
            Text("Gold Goal")
                .font(WinnieTypography.headlineM())
                .foregroundColor(WinnieColors.cardText)
        }

        WinnieCard(accentColor: GoalPresetColor.sage.color) {
            Text("Sage Goal")
                .font(WinnieTypography.headlineM())
                .foregroundColor(WinnieColors.cardText)
        }
    }
    .padding(WinnieSpacing.l)
    .background(WinnieColors.ivory)
}

/// Preview helper that shows all three card styles
private struct CardStylePreview: View {
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        ScrollView {
            VStack(spacing: WinnieSpacing.m) {
                // Pine Teal (default)
                WinnieCard(style: .pineTeal) {
                    VStack(alignment: .leading, spacing: WinnieSpacing.xs) {
                        Text("Pine Teal Card")
                            .font(WinnieTypography.headlineM())
                            .cardPrimaryText(for: .pineTeal)
                        Text("Default style with Pine Teal background and Ivory text.")
                            .font(WinnieTypography.bodyM())
                            .cardSecondaryText(for: .pineTeal)
                    }
                }

                // Carbon Black
                WinnieCard(style: .carbon) {
                    VStack(alignment: .leading, spacing: WinnieSpacing.xs) {
                        Text("Carbon Black Card")
                            .font(WinnieTypography.headlineM())
                            .cardPrimaryText(for: .carbon)
                        Text("Dark style with Carbon Black background and Ivory text.")
                            .font(WinnieTypography.bodyM())
                            .cardSecondaryText(for: .carbon)
                    }
                }

                // Ivory (adaptive)
                WinnieCard(style: .ivory) {
                    VStack(alignment: .leading, spacing: WinnieSpacing.xs) {
                        Text("Ivory Card")
                            .font(WinnieTypography.headlineM())
                            .cardPrimaryText(for: .ivory)
                        Text("Light style that inverts in dark mode for theme consistency.")
                            .font(WinnieTypography.bodyM())
                            .cardSecondaryText(for: .ivory)
                    }
                }
            }
            .padding(WinnieSpacing.l)
        }
        .background(WinnieColors.background(for: colorScheme))
    }
}
