//
//  TabCoordinator.swift
//  Winnie
//
//  Created by Claude on 2026-01-08.
//

import SwiftUI

/// Coordinates tab navigation across the app.
///
/// This observable class allows any view to trigger tab switches,
/// enabling cross-tab navigation from places like the Dashboard.
///
/// Usage:
/// ```swift
/// // In MainTabView:
/// @State private var tabCoordinator = TabCoordinator()
/// // ... inject via .environment(tabCoordinator)
///
/// // In any child view:
/// @Environment(TabCoordinator.self) private var tabCoordinator
/// tabCoordinator.switchToGoals()
/// ```
@Observable
@MainActor
final class TabCoordinator {

    // MARK: - State

    /// The currently selected tab
    var selectedTab: WinnieTab = .dashboard

    // MARK: - Navigation Actions

    /// Switch to the Dashboard tab
    func switchToDashboard() {
        selectedTab = .dashboard
    }

    /// Switch to the Goals tab
    func switchToGoals() {
        selectedTab = .goals
    }

    /// Switch to the Planning tab
    func switchToPlanning() {
        selectedTab = .planning
    }

    /// Switch to the Me (profile) tab
    func switchToMe() {
        selectedTab = .me
    }
}
