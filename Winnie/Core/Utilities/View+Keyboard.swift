import SwiftUI
import UIKit

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

    /// Adds a global keyboard toolbar with a trailing "Done" button that dismisses the keyboard.
    ///
    /// Apply this high in the view hierarchy (e.g. `MainTabView`) to make it available everywhere.
    func winnieKeyboardDoneToolbar(title: String = "Done") -> some View {
        toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button(title) {
                    dismissKeyboard()
                }
            }
        }
    }
}


