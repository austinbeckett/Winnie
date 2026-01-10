import Combine
import SwiftUI
import UIKit

/// Tracks the keyboard height so views can adjust their layout when the keyboard appears.
@MainActor
final class KeyboardObserver: ObservableObject {
    @Published var height: CGFloat = 0

    private var cancellables: Set<AnyCancellable> = []

    init() {
        let willChange = NotificationCenter.default.publisher(for: UIResponder.keyboardWillChangeFrameNotification)
        let willHide = NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)

        willChange
            .merge(with: willHide)
            .sink { [weak self] notification in
                guard let self else { return }

                if notification.name == UIResponder.keyboardWillHideNotification {
                    withAnimation(.easeOut(duration: 0.25)) {
                        self.height = 0
                    }
                    return
                }

                guard
                    let userInfo = notification.userInfo,
                    let endFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect
                else {
                    return
                }

                // Get screen height from the active window scene to avoid deprecated UIScreen.main
                let screenHeight: CGFloat
                if let windowScene = UIApplication.shared.connectedScenes
                    .compactMap({ $0 as? UIWindowScene })
                    .first(where: { $0.activationState == .foregroundActive }) {
                    screenHeight = windowScene.screen.bounds.height
                } else {
                    // Fallback: use the keyboard frame's screen coordinate space
                    screenHeight = endFrame.maxY
                }
                let keyboardHeight = max(0, screenHeight - endFrame.minY)

                withAnimation(.easeOut(duration: 0.25)) {
                    self.height = keyboardHeight
                }
            }
            .store(in: &cancellables)
    }
}


