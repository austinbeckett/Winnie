//
//  GoalsStackCard.swift
//  Winnie
//
//  Created by Claude on 2026-01-09.
//

import SwiftUI

/// A vertical card containing stacked goal progress circles.
///
/// Displays all goals in a single ivory-bordered card with goals
/// stacked vertically for a compact dashboard layout.
///
/// Usage:
/// ```swift
/// GoalsStackCard(
///     goals: viewModel.goals,
///     onGoalTap: { goal in selectedGoal = goal }
/// )
/// ```
struct GoalsStackCard: View {
    let goals: [Goal]
    var onGoalTap: ((Goal) -> Void)?

    @Environment(\.colorScheme) private var colorScheme

    /// Fixed height matching: 3 cards × 120pt + 2 gaps × 16pt = 392pt
    private let fixedHeight: CGFloat = 392

    var body: some View {
        WinnieCard(style: .ivoryBordered) {
            ScrollView(.vertical) {
                VStack(spacing: WinnieSpacing.s) {
                    ForEach(goals) { goal in
                        GoalProgressCell(goal: goal) {
                            onGoalTap?(goal)
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
                .frame(maxWidth: .infinity)
            }
            .scrollClipDisabled()
            .contentMargins(0, for: .scrollContent)
            .scrollBounceBehavior(.basedOnSize)
        }
        .frame(height: fixedHeight)
    }
}

// MARK: - Previews

#Preview("Goals Stack Card - Scrollable (5 Goals)") {
    let goals = [
        Goal(
            id: "1",
            type: .emergencyFund,
            name: "Rainy Day Fund",
            targetAmount: 10000,
            currentAmount: 10000,
            colorHex: GoalPresetColor.teal.rawValue
        ),
        Goal(
            id: "2",
            type: .house,
            name: "Down Payment",
            targetAmount: 50000,
            currentAmount: 44000,
            colorHex: GoalPresetColor.gold.rawValue
        ),
        Goal(
            id: "3",
            type: .gift,
            name: "Wedding",
            targetAmount: 30000,
            currentAmount: 9000,
            colorHex: GoalPresetColor.coral.rawValue
        ),
        Goal(
            id: "4",
            type: .car,
            name: "New Car",
            targetAmount: 25000,
            currentAmount: 16750,
            colorHex: GoalPresetColor.slate.rawValue
        ),
        Goal(
            id: "5",
            type: .retirement,
            name: "Retirement",
            targetAmount: 100000,
            currentAmount: 10000,
            colorHex: GoalPresetColor.sage.rawValue
        )
    ]

    HStack(alignment: .top, spacing: WinnieSpacing.m) {
        // Placeholder for NextMilestoneCard
        RoundedRectangle(cornerRadius: 20)
            .fill(Color.gray.opacity(0.2))
            .frame(height: 120)
            .frame(maxWidth: .infinity)

        GoalsStackCard(
            goals: goals,
            onGoalTap: { goal in print("Tapped: \(goal.name)") }
        )
        .frame(maxWidth: .infinity)
    }
    .padding(WinnieSpacing.l)
    .background(WinnieColors.porcelain)
}

#Preview("Dark Mode") {
    let goals = [
        Goal(
            id: "1",
            type: .vacation,
            name: "Hawaii Trip",
            targetAmount: 5000,
            currentAmount: 3500,
            colorHex: GoalPresetColor.lavender.rawValue
        ),
        Goal(
            id: "2",
            type: .car,
            name: "New Car",
            targetAmount: 25000,
            currentAmount: 5000,
            colorHex: GoalPresetColor.slate.rawValue
        )
    ]

    HStack(alignment: .top, spacing: WinnieSpacing.m) {
        RoundedRectangle(cornerRadius: 20)
            .fill(Color.gray.opacity(0.2))
            .frame(height: 120)
            .frame(maxWidth: .infinity)

        GoalsStackCard(
            goals: goals,
            onGoalTap: nil
        )
        .frame(maxWidth: .infinity)
    }
    .padding(WinnieSpacing.l)
    .background(WinnieColors.onyx)
    .preferredColorScheme(.dark)
}
