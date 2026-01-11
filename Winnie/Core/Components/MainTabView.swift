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
/// - Center "+" action button for quick contribution logging
/// - Proper safe area handling
/// - Smooth tab switching animations
struct MainTabView: View {
    @Bindable var appState: AppState
    @EnvironmentObject var authService: AuthenticationService
    var currentUser: User

    @State private var tabCoordinator = TabCoordinator()
    @State private var showContributeSheet = false

    var body: some View {
        VStack(spacing: 0) {
            // Content area
            tabContent
                .frame(maxWidth: .infinity, maxHeight: .infinity)

            // Custom tab bar (handles its own safe area)
            WinnieTabBar(
                selectedTab: $tabCoordinator.selectedTab,
                onAddPressed: { showContributeSheet = true }
            )
        }
        // Prevent SwiftUI's keyboard avoidance from shrinking the root container.
        // This keeps the tab bar from being pushed upward when the keyboard appears.
        // (Keyboard will cover the tab bar, matching the desired behavior.)
        .ignoresSafeArea(.keyboard)
        .winnieKeyboardDoneToolbar()
        .environment(tabCoordinator)
        .sheet(isPresented: $showContributeSheet) {
            ContributeSheet(
                coupleID: currentUser.coupleID ?? currentUser.id,
                currentUserID: currentUser.id
            )
        }
    }

    @ViewBuilder
    private var tabContent: some View {
        switch tabCoordinator.selectedTab {
        case .dashboard:
            NavigationStack {
                DashboardView(
                    coupleID: currentUser.coupleID ?? currentUser.id,
                    currentUser: currentUser,
                    partner: appState.partner
                )
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
                ScenariosView(
                    coupleID: currentUser.coupleID ?? currentUser.id,
                    userID: currentUser.id
                )
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
