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

    /// Adds a keyboard toolbar with a standard iOS "Done" button on the right.
    ///
    /// - Parameter title: The button text (default: "Done")
    func winnieKeyboardDoneToolbar(title: String = "Done") -> some View {
        modifier(KeyboardToolbarModifier(title: title))
    }
}

// MARK: - Keyboard Toolbar Modifier

/// View modifier that adds a standard iOS keyboard toolbar with a "Done" button.
private struct KeyboardToolbarModifier: ViewModifier {
    let title: String

    func body(content: Content) -> some View {
        content
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button(title) {
                        dismissKeyboard()
                    }
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
