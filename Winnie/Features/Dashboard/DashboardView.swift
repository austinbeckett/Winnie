//
//  DashboardView.swift
//  Winnie
//
//  Created by Austin Beckett on 2026-01-02.
//

import SwiftUI

/// Placeholder view for the Dashboard tab.
///
/// This will eventually show a financial overview with:
/// - Net worth summary
/// - Goal progress overview
/// - Recent activity
struct DashboardView: View {
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        NavigationStack {
            VStack(spacing: WinnieSpacing.l) {
                Spacer()

                Image(systemName: "rectangle.grid.2x2")
                    .font(.system(size: 64))
                    .foregroundColor(WinnieColors.amethystSmoke)

                VStack(spacing: WinnieSpacing.s) {
                    Text("Dashboard")
                        .font(WinnieTypography.headlineL())
                        .foregroundColor(WinnieColors.primaryText(for: colorScheme))

                    Text("Coming Soon")
                        .font(WinnieTypography.bodyM())
                        .foregroundColor(WinnieColors.secondaryText(for: colorScheme))
                }

                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(WinnieColors.background(for: colorScheme).ignoresSafeArea())
            .navigationTitle("Dashboard")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

// MARK: - Previews

#Preview("Light Mode") {
    DashboardView()
}

#Preview("Dark Mode") {
    DashboardView()
        .preferredColorScheme(.dark)
}
