import SwiftUI

/// Winnie Design System - Spacing Scale
/// Based on 8pt grid system from Winnie_Design_System.md
enum WinnieSpacing {

    // MARK: - Spacing Scale

    /// 4pt - Icon padding, minimal internal component spacing
    static let xxs: CGFloat = 4

    /// 8pt - Tight spacing between related elements (label to input)
    static let xs: CGFloat = 8

    /// 12pt - Text line spacing, small component gaps
    static let s: CGFloat = 12

    /// 16pt - Standard spacing between list items, card content internal spacing
    static let m: CGFloat = 16

    /// 24pt - Card padding, spacing between sections within a screen
    static let l: CGFloat = 24

    /// 32pt - Between major content sections, large component spacing
    static let xl: CGFloat = 32

    /// 48pt - Screen top padding, bottom safe area padding, major sections
    static let xxl: CGFloat = 48

    /// 64pt - Onboarding screen spacing, large hero sections
    static let xxxl: CGFloat = 64

    // MARK: - Layout Constants

    /// Horizontal screen margins on mobile
    static let screenMarginMobile: CGFloat = 24

    /// Horizontal screen margins on tablet
    static let screenMarginTablet: CGFloat = 32

    /// Maximum content width for readability on larger screens
    static let contentMaxWidth: CGFloat = 680

    /// Standard card corner radius
    static let cardCornerRadius: CGFloat = 20

    /// Button corner radius (pill-shaped)
    static let buttonCornerRadius: CGFloat = 28

    /// Input field corner radius
    static let inputCornerRadius: CGFloat = 16

    /// Minimum touch target size (iOS guideline)
    static let minTouchTarget: CGFloat = 44

    /// Standard button height
    static let buttonHeight: CGFloat = 56

    /// Standard input height
    static let inputHeight: CGFloat = 56

    /// Standard card minimum height
    static let cardMinHeight: CGFloat = 140
}
