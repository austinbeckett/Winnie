//
//  StreakDisplay.swift
//  Winnie
//
//  Created by Claude on 2026-01-09.
//

import SwiftUI

/// Displays a contribution streak with calendar icons for years and dots for months.
///
/// The streak represents consecutive months where the couple contributed their full
/// planned allocation to their goals.
///
/// Visual representation:
/// - **0 months**: "Start your streak this month!" encouraging text
/// - **1-11 months**: 1-11 lavender dots (●)
/// - **12+ months**: Calendar icons for complete years + dots for remaining months
///   - Example: 27 months = 📅📅 ●●● (2 years, 3 months)
///
/// Usage:
/// ```swift
/// StreakDisplay(months: 27)
/// StreakDisplay(months: 0)  // Shows encouraging zero state
/// ```
struct StreakDisplay: View {
    /// Total streak in months
    let months: Int

    /// Color for the dots and icons (defaults to lavender)
    var color: Color = WinnieColors.lavenderVeil

    @Environment(\.colorScheme) private var colorScheme

    // MARK: - Computed Properties

    private var years: Int {
        months / 12
    }

    private var remainingMonths: Int {
        months % 12
    }

    private var streakText: String {
        if months == 0 {
            return ""
        } else if years == 0 {
            return months == 1 ? "1 month" : "\(months) months"
        } else if remainingMonths == 0 {
            return years == 1 ? "1 year" : "\(years) years"
        } else {
            let yearText = years == 1 ? "1yr" : "\(years)yr"
            let monthText = remainingMonths == 1 ? "1mo" : "\(remainingMonths)mo"
            return "\(yearText) \(monthText)"
        }
    }

    var body: some View {
        if months == 0 {
            zeroState
        } else {
            activeStreak
        }
    }

    // MARK: - Zero State

    private var zeroState: some View {
        VStack(spacing: WinnieSpacing.xxs) {
            Text("Start your streak")
                .font(WinnieTypography.labelS())
                .contextSecondaryText()

            Text("this month!")
                .font(WinnieTypography.caption())
                .contextTertiaryText()
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Active Streak

    private var activeStreak: some View {
        VStack(spacing: WinnieSpacing.xs) {
            // Icons and dots row
            HStack(spacing: WinnieSpacing.xxs) {
                // Year icons (calendar symbols)
                ForEach(0..<years, id: \.self) { _ in
                    Image(systemName: "calendar")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(color)
                }

                // Month dots
                ForEach(0..<remainingMonths, id: \.self) { _ in
                    Circle()
                        .fill(color)
                        .frame(width: 6, height: 6)
                }
            }

            // Text label
            Text(streakText)
                .font(WinnieTypography.caption())
                .contextSecondaryText()
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Previews

#Preview("Zero State") {
    VStack(spacing: WinnieSpacing.l) {
        WinnieCard(style: .ivoryBordered) {
            StreakDisplay(months: 0)
                .padding()
        }
    }
    .padding()
    .background(WinnieColors.porcelain)
}

#Preview("Under 12 Months") {
    VStack(spacing: WinnieSpacing.m) {
        ForEach([1, 3, 6, 11], id: \.self) { months in
            WinnieCard(style: .ivoryBordered) {
                StreakDisplay(months: months)
                    .padding()
            }
        }
    }
    .padding()
    .background(WinnieColors.porcelain)
}

#Preview("Over 12 Months") {
    VStack(spacing: WinnieSpacing.m) {
        ForEach([12, 15, 24, 27, 36, 60], id: \.self) { months in
            WinnieCard(style: .ivoryBordered) {
                StreakDisplay(months: months)
                    .padding()
            }
        }
    }
    .padding()
    .background(WinnieColors.porcelain)
}

#Preview("Dark Mode") {
    VStack(spacing: WinnieSpacing.m) {
        WinnieCard(style: .ivoryBordered) {
            StreakDisplay(months: 0)
                .padding()
        }
        WinnieCard(style: .ivoryBordered) {
            StreakDisplay(months: 6)
                .padding()
        }
        WinnieCard(style: .ivoryBordered) {
            StreakDisplay(months: 27)
                .padding()
        }
    }
    .padding()
    .background(WinnieColors.onyx)
    .preferredColorScheme(.dark)
}
