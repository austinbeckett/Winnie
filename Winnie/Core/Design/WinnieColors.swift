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

    /// Primary text color (light mode) and background (dark mode)
    /// Hex: #1A1A1A
    static let carbonBlack = Color(hex: "1A1A1A")

    /// Primary background (light mode) and text (dark mode)
    /// Warm ivory with subtle yellow undertone
    /// Hex: #FFFFEB
    static let ivory = Color(hex: "FFFFEB")

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
    case storm = "#5A5A6B"      // Deep neutral gray

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
        case .storm: return "Storm"
        }
    }

    /// The default color for new goals
    static let defaultColor: GoalPresetColor = .coral
}

// MARK: - Theme-Aware Colors

extension WinnieColors {

    // MARK: - Backgrounds

    /// Main app background
    /// Light: Ivory (#FFFFEB) | Dark: Carbon Black (#1A1A1A)
    static func background(for colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? carbonBlack : ivory
    }

    /// Card background - Pine Teal in both modes for strong brand presence
    /// Both modes: Pine Teal (#034F46)
    static func cardBackground(for colorScheme: ColorScheme) -> Color {
        pineTeal
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

    /// Primary button background - Sweet Salmon in both modes
    /// Both modes: Sweet Salmon (#FFA099)
    static func primaryButtonBackground(for colorScheme: ColorScheme) -> Color {
        sweetSalmon
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

    /// Input field focus border - Sweet Salmon accent
    static func inputFocusBorder(for colorScheme: ColorScheme) -> Color {
        sweetSalmon
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
    static var accent: Color { sweetSalmon }

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
    /// Light: Carbon Black at 15% | Dark: Sweet Salmon at 25%
    static func buttonShadow(for colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? sweetSalmon.opacity(0.25) : carbonBlack.opacity(0.15)
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
    /// Both modes: Sweet Salmon
    static var primaryAccentUIColor: UIColor {
        UIColor(sweetSalmon)
    }

    /// Dynamic UIColor for backgrounds
    /// Light: Ivory | Dark: Carbon Black
    static var backgroundUIColor: UIColor {
        UIColor { traitCollection in
            switch traitCollection.userInterfaceStyle {
            case .dark:
                return UIColor(carbonBlack)
            default:
                return UIColor(ivory)
            }
        }
    }
}
