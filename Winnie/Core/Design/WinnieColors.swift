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
/// Light Mode First Design System
/// Based on DesignSystem.md
enum WinnieColors {

    // MARK: - Core Colors

    /// Primary black color for text (light mode) and backgrounds (dark mode)
    /// Hex: #131718
    static let ink = Color(red: 19/255, green: 23/255, blue: 24/255)

    /// Elevated surface color for dark mode (cards, panels)
    /// Slightly lighter than ink for visual hierarchy
    /// Hex: #1E2224
    static let inkElevated = Color(red: 30/255, green: 34/255, blue: 36/255)

    /// Primary white color for backgrounds (light mode) and text (dark mode)
    /// Hex: #FFFCFF
    static let snow = Color(red: 255/255, green: 252/255, blue: 255/255)

    /// Elevated surface color for light mode (cards, panels)
    /// Slightly darker than snow for visual hierarchy
    /// Hex: #F7F4F7
    static let snowElevated = Color(red: 247/255, green: 244/255, blue: 247/255)

    /// Warm neutral background for light mode
    /// Hex: #F2EFE9
    static let parchment = Color(red: 242/255, green: 239/255, blue: 233/255)

    // MARK: - Accent Colors

    /// Primary accent - purple, interactive elements, progress indicators
    /// Hex: #A393BF
    static let amethystSmoke = Color(red: 163/255, green: 147/255, blue: 191/255)

    /// Secondary accent - deep plum, primary buttons in light mode
    /// Hex: #5B325D
    static let blackberryCream = Color(red: 91/255, green: 50/255, blue: 93/255)

    // MARK: - Legacy Colors

    /// Legacy: Deep black - kept for compatibility
    /// Hex: #252627
    static let carbonBlack = Color(red: 37/255, green: 38/255, blue: 39/255)

    /// Pure white for legacy compatibility
    static let white = Color.white
}

// MARK: - Goal Preset Colors

/// User-selectable colors for goals
/// These replace the automatic goal type colors with user choice
enum GoalPresetColor: String, CaseIterable, Identifiable, Sendable {
    case amethyst = "#A393BF"
    case blackberry = "#5B325D"
    case rose = "#D4A5A5"
    case sage = "#B5C4B1"
    case slate = "#8BA3B3"
    case sand = "#D4C4A8"
    case terracotta = "#C4907A"
    case storm = "#8B8B9B"

    var id: String { rawValue }

    /// The SwiftUI Color for this preset
    var color: Color {
        Color(hex: rawValue)
    }

    /// User-facing display name
    var displayName: String {
        switch self {
        case .amethyst: return "Amethyst"
        case .blackberry: return "Blackberry"
        case .rose: return "Rose"
        case .sage: return "Sage"
        case .slate: return "Slate"
        case .sand: return "Sand"
        case .terracotta: return "Terracotta"
        case .storm: return "Storm"
        }
    }

    /// The default color for new goals
    static let defaultColor: GoalPresetColor = .amethyst
}

// MARK: - Theme-Aware Colors (Light Mode Primary)

extension WinnieColors {

    // MARK: - Backgrounds

    /// Main app background
    /// Light: Snow (#FFFCFF) | Dark: Ink (#131718)
    static func background(for colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? ink : snow
    }

    /// Card and elevated surface background
    /// Light: Snow Elevated (#F7F4F7) | Dark: Ink Elevated (#1E2224)
    static func cardBackground(for colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? inkElevated : snowElevated
    }

    // MARK: - Text Colors

    /// Primary text (headlines, important text)
    /// Light: Ink (#131718) | Dark: Snow (#FFFCFF)
    static func primaryText(for colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? snow : ink
    }

    /// Secondary text (body text, descriptions)
    /// Light: Ink at 80% | Dark: Snow at 80%
    static func secondaryText(for colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? snow.opacity(0.8) : ink.opacity(0.8)
    }

    /// Tertiary text (helper text, captions)
    /// Light: Ink at 50% | Dark: Snow at 50%
    static func tertiaryText(for colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? snow.opacity(0.5) : ink.opacity(0.5)
    }

    // MARK: - Button Colors

    /// Primary button background
    /// Light: Blackberry Cream (#5B325D) | Dark: Amethyst Smoke (#A393BF)
    static func primaryButtonBackground(for colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? amethystSmoke : blackberryCream
    }

    /// Primary button text
    /// Light: Snow (#FFFCFF) | Dark: Ink (#131718)
    static func primaryButtonText(for colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? ink : snow
    }

    /// Secondary button background
    /// Light: Amethyst Smoke (#A393BF) | Dark: Blackberry Cream (#5B325D)
    static func secondaryButtonBackground(for colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? blackberryCream : amethystSmoke
    }

    /// Secondary button border (for outlined style)
    /// Light: Amethyst Smoke (#A393BF) | Dark: Blackberry Cream (#5B325D)
    static func secondaryButtonBorder(for colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? blackberryCream : amethystSmoke
    }

    // MARK: - UI Element Colors

    /// Border and divider color
    /// Light: Ink at 20% | Dark: Snow at 15%
    static func border(for colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? snow.opacity(0.15) : ink.opacity(0.2)
    }

    /// Input field border
    /// Light: Ink at 30% | Dark: Snow at 30%
    static func inputBorder(for colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? snow.opacity(0.3) : ink.opacity(0.3)
    }

    /// Slider/progress track background
    /// Light: Ink at 20% | Dark: Snow at 20%
    static func trackBackground(for colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? snow.opacity(0.2) : ink.opacity(0.2)
    }

    /// Progress bar background
    /// Light: Ink at 15% | Dark: Snow at 15%
    static func progressBackground(for colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? snow.opacity(0.15) : ink.opacity(0.15)
    }

    // MARK: - Accent Colors (same in both modes)

    /// Primary accent color (interactive elements, progress indicators)
    static var accent: Color { amethystSmoke }

    /// Secondary accent color (highlights, CTAs)
    static var secondaryAccent: Color { blackberryCream }

    // MARK: - Shadow Colors

    /// Card shadow color
    /// Light: Ink at 8% | Dark: transparent
    static func cardShadow(for colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? .clear : ink.opacity(0.08)
    }

    /// Button shadow color
    /// Light: Ink at 15% | Dark: Amethyst Smoke at 25%
    static func buttonShadow(for colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? amethystSmoke.opacity(0.25) : ink.opacity(0.15)
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
                return UIColor(snow)
            default:
                return UIColor(ink)
            }
        }
    }
}
