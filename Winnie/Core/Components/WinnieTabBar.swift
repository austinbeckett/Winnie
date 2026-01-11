//
//  WinnieTabBar.swift
//  Winnie
//
//  Created by Austin Beckett on 2026-01-07.
//

import SwiftUI

/// The tabs available in the main app navigation.
enum WinnieTab: Int, CaseIterable {
    case dashboard
    case goals
    case planning
    case me

    var title: String {
        switch self {
        case .dashboard: return "Dashboard"
        case .goals: return "Goals"
        case .planning: return "Planning"
        case .me: return "Me"
        }
    }

    var icon: String {
        switch self {
        case .dashboard: return "rectangle.grid.2x2"
        case .goals: return "flag"
        case .planning: return "chart.pie"
        case .me: return "person"
        }
    }

    var selectedIcon: String {
        switch self {
        case .dashboard: return "rectangle.grid.2x2.fill"
        case .goals: return "flag.fill"
        case .planning: return "chart.pie.fill"
        case .me: return "person.fill"
        }
    }
}

/// Custom tab bar with solid Pine Teal background.
///
/// Features:
/// - Solid Pine Teal background spanning full width
/// - Center action button for quick contribution (larger, Lavender Veil)
/// - Lavender Veil filled icons when selected
/// - Ivory outlined icons when unselected
/// - Respects safe area for home indicator
struct WinnieTabBar: View {
    @Binding var selectedTab: WinnieTab

    /// Action triggered when the center "+" button is pressed
    var onAddPressed: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                // Left tabs: Dashboard, Goals
                tabButton(for: .dashboard)
                tabButton(for: .goals)

                // Center action button
                centerActionButton

                // Right tabs: Planning, Me
                tabButton(for: .planning)
                tabButton(for: .me)
            }
            .padding(.top, WinnieSpacing.s)

        }
        .background(WinnieColors.pineTeal)
        .background(
            // Extend background into safe area
            WinnieColors.pineTeal
                .ignoresSafeArea(edges: .bottom)
        )
    }

    // MARK: - Center Action Button

    private var centerActionButton: some View {
        Button {
            HapticFeedback.medium()
            onAddPressed()
        } label: {
            Image(systemName: "plus.circle.fill")
                .font(.system(size: 32, weight: .medium))
                .foregroundColor(WinnieColors.lavenderVeil)
                .frame(height: 24) // Match other icons' frame height for alignment
        }
        .frame(maxWidth: .infinity)
        .buttonStyle(.plain)
        .accessibilityLabel("Log contribution")
        .accessibilityHint("Double tap to log a contribution to your goals")
    }

    @ViewBuilder
    private func tabButton(for tab: WinnieTab) -> some View {
        let isSelected = selectedTab == tab

        Button {
            // Only trigger haptic when switching to a different tab
            if selectedTab != tab {
                HapticFeedback.light()
            }
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                selectedTab = tab
            }
        } label: {
            VStack(spacing: 4) {
                Image(systemName: isSelected ? tab.selectedIcon : tab.icon)
                    .font(.system(size: 22))
                    .frame(height: 24)

                Text(tab.title)
                    .font(WinnieTypography.caption())
            }
            .foregroundColor(isSelected ? WinnieColors.lavenderVeil : WinnieColors.ivory)
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    struct PreviewWrapper: View {
        @State private var selectedTab: WinnieTab = .dashboard

        var body: some View {
            VStack {
                Spacer()
                WinnieTabBar(
                    selectedTab: $selectedTab,
                    onAddPressed: { print("Add pressed") }
                )
            }
            .background(WinnieColors.ivory)
        }
    }
    return PreviewWrapper()
}
