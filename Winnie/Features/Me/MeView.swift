//
//  MeView.swift
//  Winnie
//
//  Created by Austin Beckett on 2026-01-02.
//

import SwiftUI

/// User profile and settings view.
///
/// Shows the user's name in the top left (tappable to edit) and a settings
/// cogwheel in the top right. Contains the sign-out button and placeholder
/// for future settings.
struct MeView: View {
    @Bindable var appState: AppState
    @EnvironmentObject var authService: AuthenticationService

    @State private var showEditNameSheet = false
    @State private var showSettingsSheet = false

    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Content area
                VStack(spacing: WinnieSpacing.xl) {
                    Spacer()

                    // Placeholder content
                    Image(systemName: "gearshape")
                        .font(.system(size: 48))
                        .foregroundColor(WinnieColors.tertiaryText(for: colorScheme))

                    Text("More settings coming soon")
                        .font(WinnieTypography.bodyM())
                        .foregroundColor(WinnieColors.secondaryText(for: colorScheme))

                    Spacer()

                    // Sign out button at bottom
                    signOutButton
                        .padding(.horizontal, WinnieSpacing.screenMarginMobile)
                        .padding(.bottom, WinnieSpacing.l)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(WinnieColors.background(for: colorScheme).ignoresSafeArea())
            .toolbar {
                // Left: User's first name (tappable)
                ToolbarItem(placement: .topBarLeading) {
                    nameButton
                }

                // Right: Settings cogwheel
                ToolbarItem(placement: .topBarTrailing) {
                    settingsButton
                }
            }
            .sheet(isPresented: $showEditNameSheet) {
                EditNameSheet(appState: appState)
            }
            .sheet(isPresented: $showSettingsSheet) {
                SettingsSheet(appState: appState)
            }
        }
    }

    // MARK: - Toolbar Buttons

    private var nameButton: some View {
        Button {
            showEditNameSheet = true
        } label: {
            Text(appState.currentUser?.firstName ?? "Me")
                .font(WinnieTypography.headlineM())
                .foregroundColor(WinnieColors.primaryText(for: colorScheme))
        }
    }

    private var settingsButton: some View {
        Button {
            showSettingsSheet = true
        } label: {
            Image(systemName: "gearshape")
                .font(.system(size: 18))
                .foregroundColor(WinnieColors.primaryText(for: colorScheme))
        }
    }

    // MARK: - Sign Out Button (moved from ContentView)

    private var signOutButton: some View {
        WinnieButton("Sign Out", style: .secondary) {
            try? authService.signOut()
        }
    }
}

/// Settings sheet with developer options.
struct SettingsSheet: View {
    @Bindable var appState: AppState
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme

    @State private var showResetConfirmation = false
    @State private var showOnboardingGallery = false

    var body: some View {
        NavigationStack {
            List {
                // Developer Tools Section
                Section {
                    // Onboarding Gallery
                    Button {
                        showOnboardingGallery = true
                    } label: {
                        HStack {
                            Image(systemName: "rectangle.grid.2x2")
                            Text("Onboarding Gallery")
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(WinnieColors.tertiaryText(for: colorScheme))
                        }
                        .foregroundColor(WinnieColors.primaryText(for: colorScheme))
                    }

                    // Reset Onboarding
                    Button(role: .destructive) {
                        showResetConfirmation = true
                    } label: {
                        HStack {
                            Image(systemName: "arrow.counterclockwise")
                            Text("Reset Onboarding")
                        }
                    }
                } header: {
                    Text("Developer Tools")
                } footer: {
                    Text("Use the gallery to preview onboarding screens. Reset to test the full flow.")
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .confirmationDialog(
                "Reset Onboarding?",
                isPresented: $showResetConfirmation,
                titleVisibility: .visible
            ) {
                Button("Reset", role: .destructive) {
                    Task {
                        await appState.resetOnboarding()
                    }
                    dismiss()
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("This will take you back to the onboarding flow. Your data will not be deleted.")
            }
            .fullScreenCover(isPresented: $showOnboardingGallery) {
                OnboardingGalleryView()
            }
        }
    }
}

// MARK: - Previews

#Preview("Light Mode") {
    let appState = AppState()
    appState.currentUser = .sample
    return MeView(appState: appState)
        .environmentObject(AuthenticationService())
}

#Preview("Dark Mode") {
    let appState = AppState()
    appState.currentUser = .sample
    return MeView(appState: appState)
        .environmentObject(AuthenticationService())
        .preferredColorScheme(.dark)
}

#Preview("Settings Sheet") {
    let appState = AppState()
    appState.currentUser = .sample
    return SettingsSheet(appState: appState)
}
