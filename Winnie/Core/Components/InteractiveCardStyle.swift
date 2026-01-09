//
//  InteractiveCardStyle.swift
//  Winnie
//
//  Created by Claude on 2026-01-08.
//

import SwiftUI
import UIKit

/// A button style for interactive cards that provides subtle press feedback.
///
/// Applies a gentle scale animation when pressed, making cards feel responsive
/// without being distracting.
///
/// Usage:
/// ```swift
/// Button(action: { ... }) {
///     MyCardContent()
/// }
/// .buttonStyle(InteractiveCardStyle())
/// ```
struct InteractiveCardStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(
                .spring(response: 0.3, dampingFraction: 0.7),
                value: configuration.isPressed
            )
    }
}

// MARK: - Haptic Feedback Helpers

/// Provides consistent haptic feedback across the app.
enum HapticFeedback {
    /// Light tap feedback for navigation and selection
    static func light() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }

    /// Medium tap feedback for confirmations
    static func medium() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }

    /// Success feedback for completed actions
    static func success() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }

    /// Selection feedback for picking items
    static func selection() {
        let generator = UISelectionFeedbackGenerator()
        generator.selectionChanged()
    }
}
