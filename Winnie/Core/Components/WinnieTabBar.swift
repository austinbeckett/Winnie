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
/// - Sweet Salmon filled icons when selected
/// - Ivory outlined icons when unselected
/// - Respects safe area for home indicator
struct WinnieTabBar: View {
    @Binding var selectedTab: WinnieTab

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                ForEach(WinnieTab.allCases, id: \.rawValue) { tab in
                    tabButton(for: tab)
                }
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
                WinnieTabBar(selectedTab: $selectedTab)
            }
            .background(WinnieColors.ivory)
        }
    }
    return PreviewWrapper()
}
