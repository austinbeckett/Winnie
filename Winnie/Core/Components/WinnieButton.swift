import SwiftUI

/// Button style variants for Winnie design system
enum WinnieButtonStyle {
    case primary    // Sweet Salmon fill + thick border, main actions
    case secondary  // Transparent + thick border, secondary actions
    case text       // No background or border, tertiary actions
}

/// A styled button component following Winnie design system.
/// Wispr Flow-inspired with thick borders and warm coral accent.
///
/// Usage:
/// ```swift
/// WinnieButton("Save Goal", style: .primary) {
///     await saveGoal()
/// }
///
/// WinnieButton("Cancel", style: .secondary) {
///     dismiss()
/// }
///
/// WinnieButton("Skip", style: .text) {
///     skipStep()
/// }
/// ```
struct WinnieButton: View {
    let title: String
    let style: WinnieButtonStyle
    let isLoading: Bool
    let isEnabled: Bool
    let action: () -> Void

    @Environment(\.colorScheme) private var colorScheme

    /// Border width for thick bordered buttons (per Wispr Flow aesthetic)
    private let borderWidth: CGFloat = 3

    init(
        _ title: String,
        style: WinnieButtonStyle = .primary,
        isLoading: Bool = false,
        isEnabled: Bool = true,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.style = style
        self.isLoading = isLoading
        self.isEnabled = isEnabled
        self.action = action
    }

    private var effectivelyEnabled: Bool {
        isEnabled && !isLoading
    }

    var body: some View {
        Button(action: action) {
            ZStack {
                // Title (hidden when loading)
                Text(title)
                    .font(WinnieTypography.bodyM())
                    .fontWeight(.semibold)
                    .opacity(isLoading ? 0 : 1)

                // Loading spinner
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: foregroundColor))
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: WinnieSpacing.buttonHeight)
            .foregroundColor(foregroundColor)
            .background(backgroundColor)
            .overlay(borderOverlay)
            .clipShape(RoundedRectangle(cornerRadius: WinnieSpacing.buttonCornerRadius))
        }
        .buttonStyle(WinnieButtonPressStyle())
        .disabled(!effectivelyEnabled)
        .opacity(effectivelyEnabled ? 1.0 : 0.5)
    }

    // MARK: - Style-Based Colors

    private var foregroundColor: Color {
        switch style {
        case .primary:
            // Carbon Black text on Sweet Salmon background
            return WinnieColors.primaryButtonText(for: colorScheme)
        case .secondary:
            // Match border color
            return WinnieColors.secondaryButtonText(for: colorScheme)
        case .text:
            // Sweet Salmon accent for text buttons
            return WinnieColors.sweetSalmon
        }
    }

    private var backgroundColor: Color {
        switch style {
        case .primary:
            return WinnieColors.primaryButtonBackground(for: colorScheme)
        case .secondary:
            return WinnieColors.secondaryButtonBackground(for: colorScheme)
        case .text:
            return .clear
        }
    }

    @ViewBuilder
    private var borderOverlay: some View {
        switch style {
        case .primary:
            // Primary buttons get thick border too (Wispr Flow style)
            RoundedRectangle(cornerRadius: WinnieSpacing.buttonCornerRadius)
                .stroke(WinnieColors.primaryButtonBorder(for: colorScheme), lineWidth: borderWidth)
        case .secondary:
            // Secondary buttons have thick border, no fill
            RoundedRectangle(cornerRadius: WinnieSpacing.buttonCornerRadius)
                .stroke(WinnieColors.secondaryButtonBorder(for: colorScheme), lineWidth: borderWidth)
        case .text:
            EmptyView()
        }
    }
}

// MARK: - Button Press Animation Style

/// Custom ButtonStyle that provides press animation.
/// Scales down slightly when pressed with a spring animation.
private struct WinnieButtonPressStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(
                .spring(response: 0.3, dampingFraction: 0.6),
                value: configuration.isPressed
            )
    }
}

// MARK: - Preview

#Preview("Button Styles - Light") {
    VStack(spacing: WinnieSpacing.m) {
        WinnieButton("Primary Button", style: .primary) {
            print("Primary tapped")
        }

        WinnieButton("Secondary Button", style: .secondary) {
            print("Secondary tapped")
        }

        WinnieButton("Text Button", style: .text) {
            print("Text tapped")
        }

        WinnieButton("Disabled Button", style: .primary) {
            print("Won't print")
        }
        .disabled(true)
    }
    .padding(WinnieSpacing.l)
    .background(WinnieColors.ivory)
}

#Preview("Button Styles - Dark") {
    VStack(spacing: WinnieSpacing.m) {
        WinnieButton("Primary Button", style: .primary) {}
        WinnieButton("Secondary Button", style: .secondary) {}
        WinnieButton("Text Button", style: .text) {}
    }
    .padding(WinnieSpacing.l)
    .background(WinnieColors.carbonBlack)
    .preferredColorScheme(.dark)
}
