import SwiftUI

/// Winnie Design System - Color Palette
/// Light Mode First Design System
/// Based on DesignSystem.md
enum WinnieColors {

    // MARK: - Core Colors

    /// Primary background color (light mode)
    /// Hex: #F2EFE9
    static let parchment = Color(red: 242/255, green: 239/255, blue: 233/255)

    /// Warm accent color, secondary buttons, highlights
    /// Hex: #F9B58B
    static let peachGlow = Color(red: 249/255, green: 181/255, blue: 139/255)

    /// Purple accent, interactive elements, progress indicators, sliders
    /// Hex: #A393BF
    static let amethystSmoke = Color(red: 163/255, green: 147/255, blue: 191/255)

    /// Primary button background (light mode), dark mode background
    /// Hex: #5B325D
    static let blackberryCream = Color(red: 91/255, green: 50/255, blue: 93/255)

    /// Primary text color (light mode), deep backgrounds
    /// Hex: #252627
    static let carbonBlack = Color(red: 37/255, green: 38/255, blue: 39/255)

    /// Pure white for cards in light mode
    static let white = Color.white

    // MARK: - Financial Data Colors

    /// Progress bars, on-track indicators, positive states
    /// Hex: #98D8AA
    static let successMint = Color(red: 152/255, green: 216/255, blue: 170/255)

    /// Alerts, allocation warnings, attention needed
    /// Hex: #F5C894
    static let warningPeach = Color(red: 245/255, green: 200/255, blue: 148/255)

    // MARK: - Goal Type Colors

    /// House/home purchase goal identification
    /// Hex: #A8D8EA
    static let goalHouse = Color(red: 168/255, green: 216/255, blue: 234/255)

    /// Retirement goal identification
    /// Hex: #C9AED4
    static let goalRetirement = Color(red: 201/255, green: 174/255, blue: 212/255)

    /// Vacation/travel goal identification
    /// Hex: #FFD4A3
    static let goalVacation = Color(red: 255/255, green: 212/255, blue: 163/255)

    /// Emergency fund goal identification
    /// Hex: #F4A5A5
    static let goalEmergency = Color(red: 244/255, green: 165/255, blue: 165/255)
}

// MARK: - Theme-Aware Colors (Light Mode Primary)

extension WinnieColors {

    // MARK: - Backgrounds

    /// Main app background
    /// Light: Parchment (#F2EFE9) | Dark: Blackberry Cream (#5B325D)
    static func background(for colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? blackberryCream : parchment
    }

    /// Card and elevated surface background
    /// Light: White | Dark: Carbon Black (#252627)
    static func cardBackground(for colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? carbonBlack : white
    }

    // MARK: - Text Colors

    /// Primary text (headlines, important text)
    /// Light: Carbon Black (#252627) | Dark: Parchment (#F2EFE9)
    static func primaryText(for colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? parchment : carbonBlack
    }

    /// Secondary text (body text, descriptions)
    /// Light: Blackberry Cream (#5B325D) | Dark: Parchment at 80%
    static func secondaryText(for colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? parchment.opacity(0.8) : blackberryCream
    }

    /// Tertiary text (helper text, captions)
    /// Light: Blackberry Cream at 60% | Dark: Parchment at 50%
    static func tertiaryText(for colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? parchment.opacity(0.5) : blackberryCream.opacity(0.6)
    }

    // MARK: - Button Colors

    /// Primary button background
    /// Light: Blackberry Cream (#5B325D) | Dark: Peach Glow (#F9B58B)
    static func primaryButtonBackground(for colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? peachGlow : blackberryCream
    }

    /// Primary button text
    /// Light: Parchment (#F2EFE9) | Dark: Carbon Black (#252627)
    static func primaryButtonText(for colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? carbonBlack : parchment
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
    /// Light: Blackberry Cream at 20% | Dark: Parchment at 15%
    static func border(for colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? parchment.opacity(0.15) : blackberryCream.opacity(0.2)
    }

    /// Input field border
    /// Light: Blackberry Cream at 30% | Dark: Parchment at 30%
    static func inputBorder(for colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? parchment.opacity(0.3) : blackberryCream.opacity(0.3)
    }

    /// Slider/progress track background
    /// Light: Blackberry Cream at 20% | Dark: Parchment at 20%
    static func trackBackground(for colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? parchment.opacity(0.2) : blackberryCream.opacity(0.2)
    }

    /// Progress bar background
    /// Light: Blackberry Cream at 15% | Dark: Parchment at 15%
    static func progressBackground(for colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? parchment.opacity(0.15) : blackberryCream.opacity(0.15)
    }

    // MARK: - Accent Colors (same in both modes)

    /// Primary accent color (interactive elements, progress indicators)
    static var accent: Color { amethystSmoke }

    /// Warm accent color (highlights, CTAs)
    static var warmAccent: Color { peachGlow }

    // MARK: - Shadow Colors

    /// Card shadow color
    /// Light: Blackberry Cream at 8% | Dark: transparent
    static func cardShadow(for colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? .clear : blackberryCream.opacity(0.08)
    }

    /// Button shadow color
    /// Light: Blackberry Cream at 15% | Dark: Peach Glow at 25%
    static func buttonShadow(for colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? peachGlow.opacity(0.25) : blackberryCream.opacity(0.15)
    }
}
