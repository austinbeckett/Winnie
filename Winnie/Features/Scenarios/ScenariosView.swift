//
//  ScenariosView.swift
//  Winnie
//
//  Created by Austin Beckett on 2026-01-02.
//

import SwiftUI

/// Placeholder view for the Scenarios tab.
///
/// This will eventually show "what-if" financial scenarios:
/// - Scenario builder
/// - Projections and charts
/// - Compare different financial paths
struct ScenariosView: View {
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        NavigationStack {
            VStack(spacing: WinnieSpacing.l) {
                Spacer()

                Image(systemName: "lightbulb")
                    .font(.system(size: 64))
                    .foregroundColor(WinnieColors.amethystSmoke)

                VStack(spacing: WinnieSpacing.s) {
                    Text("What If")
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
            .navigationTitle("What If")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

// MARK: - Previews

#Preview("Light Mode") {
    ScenariosView()
}

#Preview("Dark Mode") {
    ScenariosView()
        .preferredColorScheme(.dark)
}
