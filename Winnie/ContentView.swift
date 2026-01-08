//
//  ContentView.swift
//  Winnie
//
//  Created by Austin Beckett on 2025-12-29.
//

import SwiftUI

/// Main content view shown after authentication.
///
/// Displays a tab bar with four sections:
/// - Dashboard: Financial overview (coming soon)
/// - Goals: Track savings goals
/// - Scenarios: What-if projections (coming soon)
/// - Me: Profile and settings
///
/// Uses custom SwiftUI tab bar for full design control.
struct ContentView: View {
    @Bindable var appState: AppState
    @EnvironmentObject var authService: AuthenticationService

    var body: some View {
        Group {
            if let currentUser = appState.currentUser {
                MainTabView(
                    appState: appState,
                    currentUser: currentUser
                )
                .environmentObject(authService)
            } else {
                // Fallback if somehow signed in without user data
                VStack {
                    Text("Loading...")
                    ProgressView()
                }
            }
        }
    }
}

#Preview {
    let appState = AppState()
    appState.currentUser = .sample
    return ContentView(appState: appState)
        .environmentObject(AuthenticationService())
}
