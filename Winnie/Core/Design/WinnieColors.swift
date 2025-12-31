import SwiftUI

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

    /// Legacy: Primary background color (light mode) - kept for accent uses
    /// Hex: #F2EFE9
    static let parchment = Color(red: 242/255, green: 239/255, blue: 233/255)

    /// Warm accent color, secondary buttons, highlights
    /// Hex: #F9B58B
    static let peachGlow = Color(red: 249/255, green: 181/255, blue: 139/255)

    /// Purple accent, interactive elements, progress indicators, sliders
    /// Hex: #A393BF
    static let amethystSmoke = Color(red: 163/255, green: 147/255, blue: 191/255)

    /// Primary button background (light mode)
    /// Hex: #5B325D
    static let blackberryCream = Color(red: 91/255, green: 50/255, blue: 93/255)

    /// Legacy: Deep black - kept for compatibility
    /// Hex: #252627
    static let carbonBlack = Color(red: 37/255, green: 38/255, blue: 39/255)

    /// Pure white for legacy compatibility
    static let white = Color.white

    // MARK: - Financial Data Colors

    /// Progress bars, on-track indicators, positive states
    /// Hex: #98D8AA
    static let successMint = Color(red: 152/255, green: 216/255, blue: 170/255)

    /// Alerts, allocation warnings, attention needed
    /// Hex: #F5C894
    static let warningPeach = Color(red: 245/255, green: 200/255, blue: 148/255)

    /// Soft sage green - stability and growth
    /// Hex: #A8C5B5
    static let softSage = Color(red: 168/255, green: 197/255, blue: 181/255)

    /// Warm coral - safety and protection
    /// Hex: #E8A898
    static let warmCoral = Color(red: 232/255, green: 168/255, blue: 152/255)

    /// Warm slate - neutral blue-gray for custom goals
    /// Hex: #7492A6
    static let warmSlate = Color(red: 116/255, green: 146/255, blue: 166/255)

    /// Sandy dune - warm sand for vacation/travel
    /// Hex: #D4C4A8
    static let sandyDune = Color(red: 212/255, green: 196/255, blue: 168/255)

    // MARK: - Goal Type Colors

    /// House/home purchase goal identification
    /// Hex: #A8C5B5 (Soft Sage)
    static let goalHouse = softSage

    /// Retirement goal identification
    /// Hex: #F9B58B (Peach Glow - warm orange)
    static let goalRetirement = peachGlow

    /// Vacation/travel goal identification
    /// Hex: #D4C4A8 (Sandy Dune)
    static let goalVacation = sandyDune

    /// Emergency fund goal identification
    /// Hex: #E8A898 (Warm Coral)
    static let goalEmergency = warmCoral
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
    /// Light: Snow (#FFFCFF) | Dark: Ink Elevated (#1E2224)
    static func cardBackground(for colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? inkElevated : snow
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
    /// Light: Blackberry Cream (#5B325D) | Dark: Peach Glow (#F9B58B)
    static func primaryButtonBackground(for colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? peachGlow : blackberryCream
    }

    /// Primary button text
    /// Light: Snow (#FFFCFF) | Dark: Ink (#131718)
    static func primaryButtonText(for colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? ink : snow
    }

    /// Secondary button background
    /// Light: Peach Glow (#F9B58B) | Dark: Amethyst Smoke (#A393BF)
    static func secondaryButtonBackground(for colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? amethystSmoke : peachGlow
    }

    /// Secondary button border (for outlined style)
    /// Light: Amethyst Smoke (#A393BF) | Dark: Peach Glow (#F9B58B)
    static func secondaryButtonBorder(for colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? peachGlow : amethystSmoke
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

    /// Warm accent color (highlights, CTAs)
    static var warmAccent: Color { peachGlow }

    // MARK: - Shadow Colors

    /// Card shadow color
    /// Light: Ink at 8% | Dark: transparent
    static func cardShadow(for colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? .clear : ink.opacity(0.08)
    }

    /// Button shadow color
    /// Light: Ink at 15% | Dark: Peach Glow at 25%
    static func buttonShadow(for colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? peachGlow.opacity(0.25) : ink.opacity(0.15)
    }
}
