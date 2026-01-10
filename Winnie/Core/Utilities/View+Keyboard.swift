import SwiftUI
import UIKit

// MARK: - Keyboard Toolbar

extension View {
    /// Dismisses the currently focused keyboard (if any).
    func dismissKeyboard() {
        UIApplication.shared.sendAction(
            #selector(UIResponder.resignFirstResponder),
            to: nil,
            from: nil,
            for: nil
        )
    }

    /// Adds a keyboard toolbar with a minimal "Done" text button on the right.
    ///
    /// The toolbar displays as a simple bar above the keyboard with plain text styling,
    /// using Lavender Veil color to match the app's design system.
    ///
    /// - Parameter title: The button text (default: "Done")
    func winnieKeyboardDoneToolbar(title: String = "Done") -> some View {
        modifier(KeyboardToolbarModifier(title: title))
    }
}

// MARK: - Keyboard Toolbar Modifier

/// View modifier that adds a styled keyboard toolbar with minimal "Done" text.
private struct KeyboardToolbarModifier: ViewModifier {
    let title: String

    func body(content: Content) -> some View {
        content
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button {
                        dismissKeyboard()
                    } label: {
                        Text(title)
                            .font(WinnieTypography.bodyM())
                            .fontWeight(.medium)
                            .foregroundStyle(WinnieColors.lavenderVeil)
                    }
                    .buttonStyle(PlainTextButtonStyle())
                }
            }
    }

    private func dismissKeyboard() {
        UIApplication.shared.sendAction(
            #selector(UIResponder.resignFirstResponder),
            to: nil,
            from: nil,
            for: nil
        )
    }
}

// MARK: - Plain Text Button Style

/// Button style that removes default button chrome (background, border).
/// Shows a subtle opacity change on press for feedback.
private struct PlainTextButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .opacity(configuration.isPressed ? 0.6 : 1.0)
    }
}
