//
//  MainTabView.swift
//  Winnie
//
//  Created by Austin Beckett on 2026-01-07.
//

import SwiftUI

/// Main navigation container with custom tab bar.
///
/// Replaces UITabBarController to provide full control over tab bar styling.
/// Features:
/// - Custom Pine Teal tab bar at bottom
/// - Proper safe area handling
/// - Smooth tab switching animations
struct MainTabView: View {
    @Bindable var appState: AppState
    @EnvironmentObject var authService: AuthenticationService
    var currentUser: User

    @State private var selectedTab: WinnieTab = .dashboard

    var body: some View {
        VStack(spacing: 0) {
            // Content area
            tabContent
                .frame(maxWidth: .infinity, maxHeight: .infinity)

            // Custom tab bar (handles its own safe area)
            WinnieTabBar(selectedTab: $selectedTab)
        }
    }

    @ViewBuilder
    private var tabContent: some View {
        switch selectedTab {
        case .dashboard:
            NavigationStack {
                DashboardView()
            }
        case .goals:
            NavigationStack {
                GoalsListView(
                    coupleID: currentUser.coupleID ?? currentUser.id,
                    currentUser: currentUser,
                    partner: appState.partner
                )
            }
        case .planning:
            NavigationStack {
                ScenariosView()
            }
        case .me:
            NavigationStack {
                MeView(appState: appState)
                    .environmentObject(authService)
            }
        }
    }
}

#Preview {
    let appState = AppState()
    appState.currentUser = .sample
    return MainTabView(
        appState: appState,
        currentUser: .sample
    )
    .environmentObject(AuthenticationService())
}
