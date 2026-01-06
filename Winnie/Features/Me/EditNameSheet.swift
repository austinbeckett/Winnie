//
//  EditNameSheet.swift
//  Winnie
//
//  Created by Austin Beckett on 2026-01-02.
//

import SwiftUI

/// Bottom sheet for editing the user's display name.
///
/// Presented as a half-sheet when the user taps their name in the Me tab.
/// Pre-fills with the current display name and saves via AppState.
///
/// ## Usage
/// ```swift
/// .sheet(isPresented: $showEditNameSheet) {
///     EditNameSheet(appState: appState)
/// }
/// ```
struct EditNameSheet: View {
    @Bindable var appState: AppState

    @State private var name: String = ""
    @State private var isSaving = false

    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: WinnieSpacing.xl) {
                // Header
                VStack(spacing: WinnieSpacing.s) {
                    Text("What should we call you?")
                        .font(WinnieTypography.headlineM())
                        .foregroundColor(WinnieColors.primaryText(for: colorScheme))
                }
                .multilineTextAlignment(.center)
                .padding(.top, WinnieSpacing.l)

                // Name input (following NameInputView pattern)
                VStack(alignment: .leading, spacing: WinnieSpacing.xs) {
                    Text("Your name")
                        .font(WinnieTypography.caption())
                        .foregroundColor(WinnieColors.secondaryText(for: colorScheme))
                        .textCase(.uppercase)
                        .tracking(0.5)

                    TextField("Enter your name", text: $name)
                        .font(WinnieTypography.bodyL())
                        .foregroundColor(WinnieColors.cardText)
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

                // Save button
                WinnieButton("Save", style: .primary) {
                    saveNameAndDismiss()
                }
                .disabled(trimmedName.isEmpty || isSaving)
                .padding(.horizontal, WinnieSpacing.screenMarginMobile)
                .padding(.bottom, WinnieSpacing.l)
            }
            .background(WinnieColors.background(for: colorScheme).ignoresSafeArea())
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(WinnieColors.amethystSmoke)
                }
            }
            .onAppear {
                // Pre-fill with current name
                name = appState.currentUser?.displayName ?? ""
            }
        }
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
    }

    // MARK: - Helpers

    private var trimmedName: String {
        name.trimmingCharacters(in: .whitespaces)
    }

    private func saveNameAndDismiss() {
        guard !trimmedName.isEmpty else { return }

        isSaving = true

        Task {
            await appState.updateDisplayName(trimmedName)
            isSaving = false
            dismiss()
        }
    }
}

// MARK: - Previews

#Preview("Light Mode") {
    let appState = AppState()
    appState.currentUser = .sample
    return EditNameSheet(appState: appState)
}

#Preview("Dark Mode") {
    let appState = AppState()
    appState.currentUser = .sample
    return EditNameSheet(appState: appState)
        .preferredColorScheme(.dark)
}
