import SwiftUI

// MARK: - Color Extension for Hex Support

extension Color {
    /// Initialize a Color from a hex string (e.g., "#A393BF" or "A393BF")
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r, g, b: UInt64
        switch hex.count {
        case 6: // RGB (24-bit)
            (r, g, b) = ((int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF)
        default:
            (r, g, b) = (0, 0, 0)
        }
        self.init(
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255
        )
    }
}

/// Winnie Design System - Color Palette
/// Wispr Flow-Inspired Design: Rhythm, Presence, Clarity
/// Based on DesignOverhaul.md - January 2026
enum WinnieColors {

    // MARK: - Core Colors

    /// Primary text color (light mode) and elevated surfaces (dark mode cards)
    /// Hex: #1A1A1A
    static let carbonBlack = Color(hex: "1A1A1A")

    /// Main app background in dark mode
    /// Darker than Carbon Black for proper elevation hierarchy
    /// Hex: #121212
    static let onyx = Color(hex: "121212")

    /// Primary text (dark mode) and card text
    /// Warm ivory with subtle yellow undertone
    /// Hex: #FFFFEB
    static let ivory = Color(hex: "FFFFEB")

    /// Primary background (light mode)
    /// Clean white - purer than Ivory
    /// Hex: #FFFFFB
    static let porcelain = Color(hex: "FFFFFB")

    // MARK: - Accent Colors

    /// Primary accent - warm coral for buttons and interactive elements
    /// Hex: #FFA099
    static let sweetSalmon = Color(hex: "FFA099")

    /// Secondary accent - deep teal for cards and large areas
    /// Hex: #034F46
    static let pineTeal = Color(hex: "034F46")

    /// Tertiary accent - golden orange for highlights and icons
    /// Hex: #F0A202
    static let goldenOrange = Color(hex: "F0A202")

    /// Primary accent - soft lavender for buttons and interactive elements
    /// Hex: #F0D7FF
    static let lavenderVeil = Color(hex: "F0D7FF")

    // MARK: - Legacy Aliases (for migration compatibility)

    /// Legacy alias for carbonBlack - use carbonBlack directly in new code
    static var ink: Color { carbonBlack }

    /// Legacy alias for ivory - use ivory directly in new code
    static var snow: Color { ivory }

    /// Legacy alias for sweetSalmon - use sweetSalmon directly in new code
    static var amethystSmoke: Color { sweetSalmon }

    /// Legacy alias for pineTeal - use pineTeal directly in new code
    static var blackberryCream: Color { pineTeal }

    /// Pure white for specific use cases
    static let white = Color.white
}

// MARK: - Goal Preset Colors

/// User-selectable colors for goals
/// Warm palette that harmonizes with Sweet Salmon/Pine Teal/Golden Orange
enum GoalPresetColor: String, CaseIterable, Identifiable, Sendable {
    case coral = "#FFA099"      // Sweet Salmon - default
    case teal = "#034F46"       // Pine Teal
    case gold = "#F0A202"       // Golden Orange
    case sage = "#7A9E7E"       // Warm muted green
    case clay = "#C4907A"       // Terracotta/earthy warm
    case sand = "#D4C4A8"       // Warm beige
    case slate = "#6B8B9B"      // Cool blue-gray
    case lavender = "#F0D7FF"   // Lavender Veil

    var id: String { rawValue }

    /// The SwiftUI Color for this preset
    var color: Color {
        Color(hex: rawValue)
    }

    /// User-facing display name
    var displayName: String {
        switch self {
        case .coral: return "Coral"
        case .teal: return "Teal"
        case .gold: return "Gold"
        case .sage: return "Sage"
        case .clay: return "Clay"
        case .sand: return "Sand"
        case .slate: return "Slate"
        case .lavender: return "Lavender"
        }
    }

    /// The default color for new goals
    static let defaultColor: GoalPresetColor = .lavender
}

// MARK: - Card Styles

/// Card background style variants for mixed card aesthetics.
/// Each style provides consistent background and text colors.
enum WinnieCardStyle {
    /// Pine Teal background with Ivory text (same in both light/dark modes)
    case pineTeal
    /// Carbon Black background with Ivory text (same in both light/dark modes)
    case carbon
    /// Ivory background in light mode, Carbon Black in dark mode (text adapts)
    case ivory
    /// Ivory background with border in light mode, inverts to Carbon Black with Ivory border in dark mode
    case ivoryBordered
}

// MARK: - Card Context Environment

/// Environment key to propagate card background context down the view hierarchy.
/// This allows child views to automatically adapt their text colors based on their container.
private struct CardContextKey: EnvironmentKey {
    static let defaultValue: WinnieCardStyle? = nil  // nil = not inside a card
}

extension EnvironmentValues {
    /// The current card style context (nil if not inside a card).
    /// Child views can read this to automatically use correct text colors.
    var cardContext: WinnieCardStyle? {
        get { self[CardContextKey.self] }
        set { self[CardContextKey.self] = newValue }
    }
}

extension View {
    /// Sets the card context for all child views.
    /// Children can then use context-aware modifiers like `.contextPrimaryText()`.
    func cardContext(_ style: WinnieCardStyle) -> some View {
        environment(\.cardContext, style)
    }
}

// MARK: - Opacity Levels

extension WinnieColors {
    /// Standard opacity levels for text hierarchy.
    /// Use these instead of magic numbers for consistency.
    enum Opacity {
        /// Full opacity for primary text (1.0)
        static let primary: Double = 1.0
        /// Secondary text opacity (0.8)
        static let secondary: Double = 0.8
        /// Tertiary/placeholder text opacity (0.5)
        static let tertiary: Double = 0.5
        /// Small label text opacity (0.6)
        static let label: Double = 0.6
    }
}

// MARK: - Theme-Aware Colors

extension WinnieColors {

    // MARK: - Backgrounds

    /// Main app background
    /// Light: Porcelain (#FFFFFB) | Dark: Onyx (#121212)
    static func background(for colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? onyx : porcelain
    }

    /// Card background - Pine Teal in both modes for strong brand presence
    /// Both modes: Pine Teal (#034F46)
    static func cardBackground(for colorScheme: ColorScheme) -> Color {
        pineTeal
    }

    // MARK: - Card Style Colors

    /// Card background color based on style.
    /// - Parameters:
    ///   - style: The card style (pineTeal, carbon, or ivory)
    ///   - colorScheme: Current color scheme for adaptive styles
    /// - Returns: Background color for the card
    static func cardBackground(for style: WinnieCardStyle, colorScheme: ColorScheme) -> Color {
        switch style {
        case .pineTeal:
            return pineTeal
        case .carbon:
            return carbonBlack
        case .ivory:
            // Ivory inverts in dark mode to maintain theme consistency
            return colorScheme == .dark ? carbonBlack : ivory
        case .ivoryBordered:
            // Carbon Black in dark mode - elevated above Onyx app background
            return colorScheme == .dark ? carbonBlack : ivory
        }
    }

    /// Primary text color for card content based on style.
    /// - Parameters:
    ///   - style: The card style (pineTeal, carbon, or ivory)
    ///   - colorScheme: Current color scheme for adaptive styles
    /// - Returns: Primary text color for the card
    static func cardTextColor(for style: WinnieCardStyle, colorScheme: ColorScheme) -> Color {
        switch style {
        case .pineTeal, .carbon:
            // Dark backgrounds always use Ivory text
            return ivory
        case .ivory:
            // Light background uses dark text; dark mode uses light text
            return colorScheme == .dark ? ivory : carbonBlack
        case .ivoryBordered:
            // Text inverts with background for legibility
            return colorScheme == .dark ? ivory : carbonBlack
        }
    }

    /// Secondary text color for card content based on style (80% opacity).
    /// - Parameters:
    ///   - style: The card style (pineTeal, carbon, or ivory)
    ///   - colorScheme: Current color scheme for adaptive styles
    /// - Returns: Secondary text color for the card
    static func cardSecondaryTextColor(for style: WinnieCardStyle, colorScheme: ColorScheme) -> Color {
        cardTextColor(for: style, colorScheme: colorScheme).opacity(0.8)
    }

    // MARK: - Text Colors

    /// Primary text (headlines, important text)
    /// Light: Carbon Black (#1A1A1A) | Dark: Ivory (#FFFFEB)
    static func primaryText(for colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? ivory : carbonBlack
    }

    /// Secondary text (body text, descriptions)
    /// Light: Carbon Black at 80% | Dark: Ivory at 80%
    static func secondaryText(for colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? ivory.opacity(0.8) : carbonBlack.opacity(0.8)
    }

    /// Tertiary text (helper text, captions)
    /// Light: Carbon Black at 50% | Dark: Ivory at 50%
    static func tertiaryText(for colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? ivory.opacity(0.5) : carbonBlack.opacity(0.5)
    }

    /// Text color for use on Pine Teal card backgrounds
    /// Always Ivory for contrast on dark teal
    static var cardText: Color { ivory }

    // MARK: - Button Colors

    /// Primary button background - Lavender Veil in both modes
    /// Both modes: Lavender Veil (#F0D7FF)
    static func primaryButtonBackground(for colorScheme: ColorScheme) -> Color {
        lavenderVeil
    }

    /// Primary button text - Carbon Black for contrast on salmon
    /// Both modes: Carbon Black (#1A1A1A)
    static func primaryButtonText(for colorScheme: ColorScheme) -> Color {
        carbonBlack
    }

    /// Primary button border - thick 3px border per Wispr Flow aesthetic
    /// Light: Carbon Black | Dark: Ivory
    static func primaryButtonBorder(for colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? ivory : carbonBlack
    }

    /// Secondary button background - transparent with border
    static func secondaryButtonBackground(for colorScheme: ColorScheme) -> Color {
        Color.clear
    }

    /// Secondary button border
    /// Light: Carbon Black | Dark: Ivory
    static func secondaryButtonBorder(for colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? ivory : carbonBlack
    }

    /// Secondary button text
    /// Light: Carbon Black | Dark: Ivory
    static func secondaryButtonText(for colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? ivory : carbonBlack
    }

    // MARK: - UI Element Colors

    /// Border and divider color
    /// Light: Carbon Black at 20% | Dark: Ivory at 15%
    static func border(for colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? ivory.opacity(0.15) : carbonBlack.opacity(0.2)
    }

    /// Input field border
    /// Light: Carbon Black at 30% | Dark: Ivory at 30%
    static func inputBorder(for colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? ivory.opacity(0.3) : carbonBlack.opacity(0.3)
    }

    /// Input field focus border - Lavender Veil accent
    static func inputFocusBorder(for colorScheme: ColorScheme) -> Color {
        lavenderVeil
    }

    /// Slider/progress track background
    /// Light: Carbon Black at 20% | Dark: Ivory at 20%
    static func trackBackground(for colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? ivory.opacity(0.2) : carbonBlack.opacity(0.2)
    }

    /// Progress bar background
    /// Light: Carbon Black at 15% | Dark: Ivory at 15%
    static func progressBackground(for colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? ivory.opacity(0.15) : carbonBlack.opacity(0.15)
    }

    // MARK: - Semantic Colors

    /// Error color for validation states
    /// Uses a consistent red that works in both light and dark modes
    static func error(for colorScheme: ColorScheme) -> Color {
        Color(hex: "DC3545")
    }

    /// Success/on-track status color
    /// Uses a consistent green that works in both light and dark modes
    static func success(for colorScheme: ColorScheme) -> Color {
        Color(hex: "28A745")
    }

    /// Warning/behind status color
    /// Uses a consistent orange that works in both light and dark modes
    static func warning(for colorScheme: ColorScheme) -> Color {
        Color(hex: "F5A623")
    }

    /// Shadow color for elevated surfaces
    /// Light: subtle black shadow | Dark: darker shadow
    static func shadow(for colorScheme: ColorScheme) -> Color {
        colorScheme == .dark
            ? Color.black.opacity(0.3)
            : Color.black.opacity(0.08)
    }

    /// Contrast text for colored backgrounds (icons, initials on accent backgrounds)
    /// Always ivory - used on colored backgrounds where we need maximum contrast
    static var contrastText: Color { ivory }

    // MARK: - Accent Colors (same in both modes)

    /// Primary accent color (interactive elements, progress indicators)
    static var accent: Color { lavenderVeil }

    /// Secondary accent color (highlights, CTAs)
    static var secondaryAccent: Color { pineTeal }

    /// Tertiary accent color (icons, small highlights)
    static var tertiaryAccent: Color { goldenOrange }

    // MARK: - Shadow Colors

    /// Card shadow color
    /// Light: Carbon Black at 8% | Dark: transparent
    static func cardShadow(for colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? .clear : carbonBlack.opacity(0.08)
    }

    /// Button shadow color
    /// Light: Carbon Black at 15% | Dark: Lavender Veil at 25%
    static func buttonShadow(for colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? lavenderVeil.opacity(0.25) : carbonBlack.opacity(0.15)
    }
}

// MARK: - Context-Aware Text Modifiers

extension View {
    /// Applies primary text color based on card context.
    /// - On card: uses card text color (ivory for dark backgrounds)
    /// - On background: uses primaryText for current colorScheme
    func contextPrimaryText() -> some View {
        modifier(ContextTextModifier(opacity: WinnieColors.Opacity.primary))
    }

    /// Applies secondary text color based on card context (80% opacity).
    func contextSecondaryText() -> some View {
        modifier(ContextTextModifier(opacity: WinnieColors.Opacity.secondary))
    }

    /// Applies tertiary/placeholder text color based on card context (50% opacity).
    func contextTertiaryText() -> some View {
        modifier(ContextTextModifier(opacity: WinnieColors.Opacity.tertiary))
    }

    /// Applies label text color based on card context (60% opacity).
    func contextLabelText() -> some View {
        modifier(ContextTextModifier(opacity: WinnieColors.Opacity.label))
    }
}

/// View modifier that reads card context from environment and applies appropriate text color.
private struct ContextTextModifier: ViewModifier {
    @Environment(\.cardContext) private var cardContext
    @Environment(\.colorScheme) private var colorScheme

    let opacity: Double

    func body(content: Content) -> some View {
        content.foregroundColor(textColor)
    }

    private var textColor: Color {
        if let style = cardContext {
            // We're inside a card - use card text color
            return WinnieColors.cardTextColor(for: style, colorScheme: colorScheme)
                .opacity(opacity)
        } else {
            // We're on the background - use primary text
            return WinnieColors.primaryText(for: colorScheme)
                .opacity(opacity)
        }
    }
}

// MARK: - UIKit Compatibility

// Usage Guide:
//
// SwiftUI Views (Text, Button, VStack, etc.):
//   Use: WinnieColors.primaryText(for: colorScheme)
//   With: @Environment(\.colorScheme) private var colorScheme
//   Why:  SwiftUI automatically re-renders when colorScheme changes
//
// UIKit Components (UINavigationBar, UITabBar, etc.):
//   Use: WinnieColors.primaryTextUIColor
//   Why:  UIKit needs trait-collection-based dynamic colors
//   Note: Configured globally in WinnieApp.configureGlobalAppearance()

extension WinnieColors {

    /// Dynamic UIColor for primary text - automatically updates with dark/light mode.
    /// Use this for UIKit components (UINavigationBar, UITabBar, etc.).
    /// For SwiftUI views, use `primaryText(for: colorScheme)` instead.
    static var primaryTextUIColor: UIColor {
        UIColor { traitCollection in
            switch traitCollection.userInterfaceStyle {
            case .dark:
                return UIColor(ivory)
            default:
                return UIColor(carbonBlack)
            }
        }
    }

    /// Dynamic UIColor for primary accent - automatically updates with dark/light mode.
    /// Use this for UIKit components (UITabBar tint, etc.).
    /// Both modes: Lavender Veil
    static var primaryAccentUIColor: UIColor {
        UIColor(lavenderVeil)
    }

    /// Dynamic UIColor for backgrounds
    /// Light: Porcelain | Dark: Onyx
    static var backgroundUIColor: UIColor {
        UIColor { traitCollection in
            switch traitCollection.userInterfaceStyle {
            case .dark:
                return UIColor(onyx)
            default:
                return UIColor(porcelain)
            }
        }
    }

    /// UIColor for Pine Teal - for UIKit components (UITabBar background, etc.)
    static var pineTealUIColor: UIColor {
        UIColor(pineTeal)
    }

    /// UIColor for Ivory - for UIKit components (unselected tab icons, etc.)
    static var ivoryUIColor: UIColor {
        UIColor(ivory)
    }
}
