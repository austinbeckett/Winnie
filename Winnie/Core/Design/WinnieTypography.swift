import SwiftUI

/// Winnie Design System - Typography
/// Based on Winnie_Design_System.md
///
/// Fonts:
/// - Headlines: Playfair Display (serif) - warmth and sophistication
/// - Body/UI: Lato (sans-serif) - clean and friendly
///
/// Note: Using system fonts as fallback until custom fonts are added.
/// To add custom fonts:
/// 1. Download Playfair Display and Lato from Google Fonts
/// 2. Add .ttf files to Resources/Fonts/
/// 3. Add font filenames to Info.plist under "Fonts provided by application"
/// 4. Update the font names below
enum WinnieTypography {

    // MARK: - Font Names

    /// Serif font for headlines (Playfair Display)
    /// Using system serif as fallback
    static let serifFontName: String? = nil  // Set to "PlayfairDisplay-Regular" after adding fonts

    /// Sans-serif font for body text (Lato)
    /// Using system sans-serif as fallback
    static let sansFontName: String? = nil  // Set to "Lato-Regular" after adding fonts

    // MARK: - Display Styles (Playfair Display / Serif)

    /// 52pt - Welcome screens, major onboarding moments
    static func displayXL() -> Font {
        if let fontName = serifFontName {
            return .custom(fontName, size: 52)
        }
        return .system(size: 52, weight: .regular, design: .serif)
    }

    /// 44pt - Subscription paywall, important screens
    static func displayL() -> Font {
        if let fontName = serifFontName {
            return .custom(fontName, size: 44)
        }
        return .system(size: 44, weight: .regular, design: .serif)
    }

    /// 36pt - Screen titles, page headers
    static func displayM() -> Font {
        if let fontName = serifFontName {
            return .custom(fontName, size: 36)
        }
        return .system(size: 36, weight: .medium, design: .serif)
    }

    /// 28pt - Section headers within screens
    static func headlineL() -> Font {
        if let fontName = serifFontName {
            return .custom(fontName, size: 28)
        }
        return .system(size: 28, weight: .semibold, design: .serif)
    }

    /// 22pt - Card titles, goal names, subsection headers
    static func headlineM() -> Font {
        if let fontName = serifFontName {
            return .custom(fontName, size: 22)
        }
        return .system(size: 22, weight: .semibold, design: .serif)
    }

    // MARK: - Body Styles (Lato / Sans-serif)

    /// 18pt - Primary body text, longer descriptions
    static func bodyL() -> Font {
        if let fontName = sansFontName {
            return .custom(fontName, size: 18)
        }
        return .system(size: 18, weight: .regular, design: .default)
    }

    /// 16pt - Button text, form labels, secondary descriptions
    static func bodyM() -> Font {
        if let fontName = sansFontName {
            return .custom(fontName, size: 16)
        }
        return .system(size: 16, weight: .regular, design: .default)
    }

    /// 14pt - Helper text, timestamps, legal text
    static func bodyS() -> Font {
        if let fontName = sansFontName {
            return .custom(fontName, size: 14)
        }
        return .system(size: 14, weight: .regular, design: .default)
    }

    /// 12pt - Very small helper text, footnotes
    static func caption() -> Font {
        if let fontName = sansFontName {
            return .custom(fontName, size: 12)
        }
        return .system(size: 12, weight: .regular, design: .default)
    }

    // MARK: - Financial Styles (Lato Bold with tabular figures)

    /// 40pt - Hero financial amounts (disposable income display)
    static func financialXL() -> Font {
        if let fontName = sansFontName {
            return .custom(fontName, size: 40).weight(.bold)
        }
        return .system(size: 40, weight: .bold, design: .default).monospacedDigit()
    }

    /// 32pt - Large amounts, goal targets, timeline projections
    static func financialL() -> Font {
        if let fontName = sansFontName {
            return .custom(fontName, size: 32).weight(.bold)
        }
        return .system(size: 32, weight: .bold, design: .default).monospacedDigit()
    }

    /// 24pt - Card amounts, allocation values
    static func financialM() -> Font {
        if let fontName = sansFontName {
            return .custom(fontName, size: 24).weight(.bold)
        }
        return .system(size: 24, weight: .bold, design: .default).monospacedDigit()
    }
}

// MARK: - View Modifiers for Typography

extension View {
    func winnieDisplayXL() -> some View {
        self.font(WinnieTypography.displayXL())
    }

    func winnieDisplayL() -> some View {
        self.font(WinnieTypography.displayL())
    }

    func winnieDisplayM() -> some View {
        self.font(WinnieTypography.displayM())
    }

    func winnieHeadlineL() -> some View {
        self.font(WinnieTypography.headlineL())
    }

    func winnieHeadlineM() -> some View {
        self.font(WinnieTypography.headlineM())
    }

    func winnieBodyL() -> some View {
        self.font(WinnieTypography.bodyL())
    }

    func winnieBodyM() -> some View {
        self.font(WinnieTypography.bodyM())
    }

    func winnieBodyS() -> some View {
        self.font(WinnieTypography.bodyS())
    }

    func winnieCaption() -> some View {
        self.font(WinnieTypography.caption())
    }

    func winnieFinancialXL() -> some View {
        self.font(WinnieTypography.financialXL())
    }

    func winnieFinancialL() -> some View {
        self.font(WinnieTypography.financialL())
    }

    func winnieFinancialM() -> some View {
        self.font(WinnieTypography.financialM())
    }
}
