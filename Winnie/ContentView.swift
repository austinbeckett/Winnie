//
//  ContentView.swift
//  Winnie
//
//  Created by Austin Beckett on 2025-12-29.
//

import SwiftUI

/// Main content view shown after authentication.
///
/// Currently shows the Goals list. Will eventually be expanded to include
/// a tab bar with Dashboard, Goals, Scenarios, and Settings.
struct ContentView: View {
    @Bindable var appState: AppState
    @EnvironmentObject var authService: AuthenticationService

    var body: some View {
        Group {
            if let currentUser = appState.currentUser {
                // Use user's UID as coupleID until partner system is built
                // This allows each user to have their own goals during development
                GoalsListView(
                    coupleID: currentUser.coupleID ?? currentUser.id,
                    currentUser: currentUser,
                    partner: appState.partner
                )
                .overlay(alignment: .bottom) {
                    // Temporary sign out button for testing
                    signOutButton
                }
            } else {
                // Fallback if somehow signed in without user data
                VStack {
                    Text("Loading...")
                    ProgressView()
                }
            }
        }
    }

    // MARK: - Temporary Sign Out Button

    private var signOutButton: some View {
        Button {
            try? authService.signOut()
        } label: {
            Text("Sign Out")
                .font(WinnieTypography.bodyS())
                .foregroundColor(.white)
                .padding(.horizontal, WinnieSpacing.m)
                .padding(.vertical, WinnieSpacing.xs)
                .background(Color.red.opacity(0.8))
                .clipShape(Capsule())
        }
        .padding(.bottom, WinnieSpacing.l)
    }
}

#Preview {
    let appState = AppState()
    appState.currentUser = .sample
    return ContentView(appState: appState)
        .environmentObject(AuthenticationService())
}
