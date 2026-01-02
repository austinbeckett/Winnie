//
//  WinnieTabBarController.swift
//  Winnie
//
//  Created by Austin Beckett on 2026-01-02.
//

import SwiftUI
import UIKit

/// A UIKit-based tab bar controller wrapped for SwiftUI.
///
/// Uses UITabBarController to achieve native iOS tab bar appearance with:
/// - Proper fill/outline icon switching (outline when unselected, fill when selected)
/// - Custom tint color (amethyst smoke)
/// - Native liquid glass appearance
///
/// This is necessary because SwiftUI's TabView doesn't reliably support
/// different images for selected vs unselected states.
struct WinnieTabBarController: UIViewControllerRepresentable {
    @Bindable var appState: AppState
    var authService: AuthenticationService
    var currentUser: User

    func makeUIViewController(context: Context) -> UITabBarController {
        let tabBarController = UITabBarController()

        // Configure tab bar appearance
        tabBarController.tabBar.tintColor = UIColor(WinnieColors.amethystSmoke)

        // Create view controllers for each tab
        let dashboardVC = makeHostingController(
            rootView: DashboardView()
        )
        dashboardVC.tabBarItem = UITabBarItem(
            title: "Dashboard",
            image: UIImage(systemName: "rectangle.grid.2x2"),
            selectedImage: UIImage(systemName: "rectangle.grid.2x2.fill")
        )

        let goalsVC = makeHostingController(
            rootView: GoalsListView(
                coupleID: currentUser.coupleID ?? currentUser.id,
                currentUser: currentUser,
                partner: appState.partner
            )
        )
        goalsVC.tabBarItem = UITabBarItem(
            title: "Goals",
            image: UIImage(systemName: "flag"),
            selectedImage: UIImage(systemName: "flag.fill")
        )

        let scenariosVC = makeHostingController(
            rootView: ScenariosView()
        )
        scenariosVC.tabBarItem = UITabBarItem(
            title: "What If",
            image: UIImage(systemName: "lightbulb"),
            selectedImage: UIImage(systemName: "lightbulb.fill")
        )

        let meVC = makeHostingController(
            rootView: MeView(appState: appState)
                .environmentObject(authService)
        )
        meVC.tabBarItem = UITabBarItem(
            title: "Me",
            image: UIImage(systemName: "person"),
            selectedImage: UIImage(systemName: "person.fill")
        )

        tabBarController.viewControllers = [dashboardVC, goalsVC, scenariosVC, meVC]

        return tabBarController
    }

    func updateUIViewController(_ uiViewController: UITabBarController, context: Context) {
        // Update the Goals tab when user/partner data changes
        if let goalsVC = uiViewController.viewControllers?[1] as? UIHostingController<GoalsListView> {
            goalsVC.rootView = GoalsListView(
                coupleID: currentUser.coupleID ?? currentUser.id,
                currentUser: currentUser,
                partner: appState.partner
            )
        }
        // Note: MeView updates are handled via @Bindable appState
    }

    // MARK: - Helper

    private func makeHostingController<Content: View>(rootView: Content) -> UIHostingController<Content> {
        let hostingController = UIHostingController(rootView: rootView)
        return hostingController
    }
}

// MARK: - Preview

#Preview {
    let appState = AppState()
    appState.currentUser = .sample
    return WinnieTabBarController(
        appState: appState,
        authService: AuthenticationService(),
        currentUser: .sample
    )
}
