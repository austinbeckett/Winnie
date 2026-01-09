//
//  DashboardPlaceholderCard.swift
//  Winnie
//
//  Created by Claude on 2026-01-09.
//

import SwiftUI

/// A placeholder card for the dashboard grid layout.
///
/// Used as temporary placeholders while deciding what content
/// to display in the 3-card stack on the left side of the dashboard.
///
/// Usage:
/// ```swift
/// DashboardPlaceholderCard(title: "Coming Soon")
/// ```
struct DashboardPlaceholderCard: View {
    let title: String

    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        WinnieCard(style: .ivoryBordered) {
            Text(title)
                .font(WinnieTypography.bodyS())
                .contextSecondaryText()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

// MARK: - Previews

#Preview("Placeholder Card") {
    VStack(spacing: WinnieSpacing.m) {
        DashboardPlaceholderCard(title: "Coming Soon")
            .frame(height: 100)

        DashboardPlaceholderCard(title: "Feature TBD")
            .frame(height: 100)
    }
    .padding(WinnieSpacing.l)
    .background(WinnieColors.porcelain)
}

#Preview("Dark Mode") {
    VStack(spacing: WinnieSpacing.m) {
        DashboardPlaceholderCard(title: "Coming Soon")
            .frame(height: 100)
    }
    .padding(WinnieSpacing.l)
    .background(WinnieColors.onyx)
    .preferredColorScheme(.dark)
}
