import SwiftUI

/// Winnie Design System - Typography
/// Wispr Flow-Inspired: Rhythm, Presence, Clarity
///
/// Fonts:
/// - Headlines: EB Garamond (serif) - elegant rhythm and warmth
/// - Body/UI: Figtree (sans-serif) - modern, clean, approachable
///
/// Custom fonts are loaded from Resources/Fonts/ and registered in Info.plist.
/// If fonts fail to load, system fonts are used as fallback.
enum WinnieTypography {

    // MARK: - Font Names (EB Garamond)

    private static let garamondRegular = "EBGaramond-Regular"
    private static let garamondMedium = "EBGaramond-Medium"
    private static let garamondSemiBold = "EBGaramond-SemiBold"

    // MARK: - Font Names (Figtree)

    private static let figtreeRegular = "Figtree-Regular"
    private static let figtreeMedium = "Figtree-Medium"
    private static let figtreeSemiBold = "Figtree-SemiBold"
    private static let figtreeBold = "Figtree-Bold"

    // MARK: - Display Styles (EB Garamond / Serif)

    /// 52pt - Welcome screens, major onboarding moments
    static func displayXL() -> Font {
        .custom(garamondRegular, size: 52)
    }

    /// 44pt - Subscription paywall, important screens
    static func displayL() -> Font {
        .custom(garamondRegular, size: 44)
    }

    /// 36pt - Screen titles, page headers
    static func displayM() -> Font {
        .custom(garamondMedium, size: 36)
    }

    /// 28pt - Section headers within screens
    static func headlineL() -> Font {
        .custom(garamondSemiBold, size: 28)
    }

    /// 22pt - Card titles, goal names, subsection headers
    static func headlineM() -> Font {
        .custom(garamondSemiBold, size: 22)
    }

    // MARK: - Body Styles (Figtree / Sans-serif)

    /// 18pt - Primary body text, longer descriptions
    static func bodyL() -> Font {
        .custom(figtreeRegular, size: 18)
    }

    /// 16pt - Button text, form labels, secondary descriptions
    static func bodyM() -> Font {
        .custom(figtreeRegular, size: 16)
    }

    /// 14pt - Helper text, timestamps, legal text
    static func bodyS() -> Font {
        .custom(figtreeRegular, size: 14)
    }

    /// 12pt - Very small helper text, footnotes
    static func caption() -> Font {
        .custom(figtreeRegular, size: 12)
    }

    // MARK: - Financial Styles (Figtree Bold with tabular figures)

    /// 40pt - Hero financial amounts (disposable income display)
    static func financialXL() -> Font {
        .custom(figtreeBold, size: 40)
    }

    /// 32pt - Large amounts, goal targets, timeline projections
    static func financialL() -> Font {
        .custom(figtreeBold, size: 32)
    }

    /// 24pt - Card amounts, allocation values
    static func financialM() -> Font {
        .custom(figtreeBold, size: 24)
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
