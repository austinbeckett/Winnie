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
            // Placeholder - settings functionality coming later
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
