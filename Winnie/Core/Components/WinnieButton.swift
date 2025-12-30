import SwiftUI

/// Button style variants for Winnie design system
enum WinnieButtonStyle {
    case primary    // Solid background, main actions
    case secondary  // Outlined border, secondary actions
    case text       // No background, tertiary actions
}

/// A styled button component following Winnie design system.
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
    let action: () -> Void

    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.isEnabled) private var isEnabled

    init(
        _ title: String,
        style: WinnieButtonStyle = .primary,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.style = style
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(WinnieTypography.bodyM())
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity)
                .frame(height: WinnieSpacing.buttonHeight)
                .foregroundColor(foregroundColor)
                .background(backgroundColor)
                .overlay(borderOverlay)
                .clipShape(RoundedRectangle(cornerRadius: WinnieSpacing.buttonCornerRadius))
        }
        .buttonStyle(WinnieButtonPressStyle())
        .opacity(isEnabled ? 1.0 : 0.5)
    }

    // MARK: - Style-Based Colors

    private var foregroundColor: Color {
        switch style {
        case .primary:
            return WinnieColors.primaryButtonText(for: colorScheme)
        case .secondary:
            return WinnieColors.secondaryButtonBorder(for: colorScheme)
        case .text:
            return WinnieColors.secondaryButtonBorder(for: colorScheme)
        }
    }

    private var backgroundColor: Color {
        switch style {
        case .primary:
            return WinnieColors.primaryButtonBackground(for: colorScheme)
        case .secondary:
            return .clear
        case .text:
            return .clear
        }
    }

    @ViewBuilder
    private var borderOverlay: some View {
        switch style {
        case .primary, .text:
            EmptyView()
        case .secondary:
            RoundedRectangle(cornerRadius: WinnieSpacing.buttonCornerRadius)
                .stroke(WinnieColors.secondaryButtonBorder(for: colorScheme), lineWidth: 2)
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

#Preview("Button Styles") {
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
    .background(WinnieColors.parchment)
}

#Preview("Dark Mode") {
    VStack(spacing: WinnieSpacing.m) {
        WinnieButton("Primary Button", style: .primary) {}
        WinnieButton("Secondary Button", style: .secondary) {}
        WinnieButton("Text Button", style: .text) {}
    }
    .padding(WinnieSpacing.l)
    .background(WinnieColors.blackberryCream)
    .preferredColorScheme(.dark)
}
