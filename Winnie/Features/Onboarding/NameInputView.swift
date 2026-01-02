import SwiftUI

/// Onboarding screen that asks the user for their name.
///
/// This is shown to users who haven't set a display name yet.
/// The name is stored in Firestore and used throughout the app.
///
/// ## Usage
/// ```swift
/// NameInputView(appState: appState) {
///     // User completed name input
/// }
/// ```
struct NameInputView: View {
    @Bindable var appState: AppState
    let onComplete: () -> Void

    @State private var name = ""
    @State private var isSaving = false

    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        VStack(spacing: WinnieSpacing.xl) {
            Spacer()

            // Header
            VStack(spacing: WinnieSpacing.s) {
                Text("Welcome to Winnie")
                    .font(WinnieTypography.headlineL())
                    .foregroundColor(WinnieColors.primaryText(for: colorScheme))

                Text("What should we call you?")
                    .font(WinnieTypography.bodyL())
                    .foregroundColor(WinnieColors.secondaryText(for: colorScheme))
            }
            .multilineTextAlignment(.center)

            // Name input
            VStack(alignment: .leading, spacing: WinnieSpacing.xs) {
                Text("Your name")
                    .font(WinnieTypography.caption())
                    .foregroundColor(WinnieColors.secondaryText(for: colorScheme))
                    .textCase(.uppercase)
                    .tracking(0.5)

                TextField("Enter your name", text: $name)
                    .font(WinnieTypography.bodyL())
                    .padding(WinnieSpacing.m)
                    .background(WinnieColors.cardBackground(for: colorScheme))
                    .clipShape(RoundedRectangle(cornerRadius: WinnieSpacing.inputCornerRadius))
                    .overlay(
                        RoundedRectangle(cornerRadius: WinnieSpacing.inputCornerRadius)
                            .stroke(WinnieColors.tertiaryText(for: colorScheme).opacity(0.3), lineWidth: 1)
                    )
                    .textContentType(.givenName)
                    .autocorrectionDisabled()
            }
            .padding(.horizontal, WinnieSpacing.l)

            Spacer()

            // Continue button
            WinnieButton("Continue", style: .primary) {
                saveNameAndContinue()
            }
            .disabled(trimmedName.isEmpty || isSaving)
            .padding(.horizontal, WinnieSpacing.screenMarginMobile)
            .padding(.bottom, WinnieSpacing.l)
        }
        .background(WinnieColors.background(for: colorScheme).ignoresSafeArea(edges: .all))
    }

    // MARK: - Helpers

    private var trimmedName: String {
        name.trimmingCharacters(in: .whitespaces)
    }

    private func saveNameAndContinue() {
        guard !trimmedName.isEmpty else { return }

        isSaving = true

        Task {
            await appState.updateDisplayName(trimmedName)
            isSaving = false
            onComplete()
        }
    }
}

// MARK: - Previews

#Preview("Light Mode") {
    NameInputView(appState: AppState()) {
        print("Completed")
    }
}

#Preview("Dark Mode") {
    NameInputView(appState: AppState()) {
        print("Completed")
    }
    .preferredColorScheme(.dark)
}

#Preview("With Name Entered") {
    let view = NameInputView(appState: AppState()) {
        print("Completed")
    }
    return view
}
