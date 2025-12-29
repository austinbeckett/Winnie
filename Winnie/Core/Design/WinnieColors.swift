import SwiftUI

/// Winnie Design System - Color Palette
/// Based on Winnie_Design_System.md
enum WinnieColors {

    // MARK: - Core Colors

    /// Light mode background, primary button backgrounds
    /// Hex: #F2EFE9
    static let parchment = Color(red: 242/255, green: 239/255, blue: 233/255)

    /// Accent color, highlights, warm CTAs, success states
    /// Hex: #F9B58B
    static let peachGlow = Color(red: 249/255, green: 181/255, blue: 139/255)

    /// Primary purple accent, interactive elements, progress indicators
    /// Hex: #A393BF
    static let amethystSmoke = Color(red: 163/255, green: 147/255, blue: 191/255)

    /// Dark mode background, headers, primary text in light mode
    /// Hex: #5B325D
    static let blackberryCream = Color(red: 91/255, green: 50/255, blue: 93/255)

    /// Pure black text, deep backgrounds, high contrast text
    /// Hex: #252627
    static let carbonBlack = Color(red: 37/255, green: 38/255, blue: 39/255)

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

// MARK: - Theme-Aware Colors

extension WinnieColors {

    /// Returns the appropriate background color for the current color scheme
    static func background(for colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? blackberryCream : parchment
    }

    /// Returns the appropriate primary text color for the current color scheme
    static func primaryText(for colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? parchment : carbonBlack
    }

    /// Returns the appropriate secondary text color for the current color scheme
    static func secondaryText(for colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? parchment.opacity(0.8) : blackberryCream
    }

    /// Returns the appropriate card background for the current color scheme
    static func cardBackground(for colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? carbonBlack : .white
    }

    /// Returns the appropriate primary button background for the current color scheme
    static func primaryButtonBackground(for colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? peachGlow : blackberryCream
    }

    /// Returns the appropriate primary button text for the current color scheme
    static func primaryButtonText(for colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? carbonBlack : parchment
    }
}
