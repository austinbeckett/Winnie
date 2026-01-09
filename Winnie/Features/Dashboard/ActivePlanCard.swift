//
//  ActivePlanCard.swift
//  Winnie
//
//  Created by Claude on 2026-01-08.
//

import SwiftUI

/// A card showing the active plan with budget health and next milestone.
///
/// Displays:
/// - Plan name with "Active Plan" badge
/// - Monthly savings pool allocation progress
/// - Next milestone (closest goal to completion)
///
/// Usage:
/// ```swift
/// ActivePlanCard(
///     scenario: viewModel.activeScenario,
///     savingsPool: viewModel.savingsPool,
///     allocatedGoals: viewModel.allocatedGoals,
///     projections: viewModel.projections
/// )
/// ```
struct ActivePlanCard: View {
    let scenario: Scenario
    let savingsPool: Decimal
    let allocatedGoals: [Goal]
    let projections: [String: GoalProjection]

    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        WinnieCard(style: .ivoryBordered) {
            VStack(alignment: .leading, spacing: WinnieSpacing.m) {
                // Header: Badge + Plan name
                headerSection

                // Budget health: Progress bar + amounts
                budgetHealthSection

                // Next milestone (if exists)
                if let milestone = nextMilestone {
                    Divider()
                        .background(WinnieColors.border(for: colorScheme))

                    nextMilestoneSection(goal: milestone.goal, projection: milestone.projection)
                }
            }
        }
    }

    // MARK: - Header Section

    private var headerSection: some View {
        HStack {
            // Active plan badge + name
            VStack(alignment: .leading, spacing: WinnieSpacing.xxs) {
                HStack(spacing: WinnieSpacing.xs) {
                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 14))
                        .foregroundColor(WinnieColors.success(for: colorScheme))

                    Text("Active Plan")
                        .font(WinnieTypography.caption())
                        .contextSecondaryText()
                }

                Text(scenario.name)
                    .font(WinnieTypography.headlineS())
                    .contextPrimaryText()
                    .lineLimit(1)
            }

            Spacer()

            // Goal count badge
            if allocatedGoals.count > 0 {
                Text("\(allocatedGoals.count) goals")
                    .font(WinnieTypography.caption())
                    .contextTertiaryText()
            }
        }
    }

    // MARK: - Budget Health Section

    private var budgetHealthSection: some View {
        VStack(alignment: .leading, spacing: WinnieSpacing.s) {
            // Label
            Text("Monthly Savings Pool")
                .font(WinnieTypography.caption())
                .contextSecondaryText()

            // Progress bar
            WinnieProgressBar(
                progress: allocationProgress,
                color: WinnieColors.lavenderVeil,
                showLabel: false,
                onCard: true
            )

            // Amounts row
            HStack {
                // Allocated amount
                HStack(spacing: WinnieSpacing.xs) {
                    Text(formatCurrency(totalAllocated))
                        .font(WinnieTypography.financialM())
                        .contextPrimaryText()

                    Text("of \(formatCurrency(savingsPool))")
                        .font(WinnieTypography.bodyS())
                        .contextTertiaryText()
                }

                Spacer()

                // Unallocated indicator (if any)
                if unallocatedAmount > 0 {
                    Text("\(formatCurrency(unallocatedAmount)) unallocated")
                        .font(WinnieTypography.bodyS())
                        .foregroundColor(WinnieColors.goldenOrange)
                }
            }
        }
    }

    // MARK: - Next Milestone Section

    private func nextMilestoneSection(goal: Goal, projection: GoalProjection) -> some View {
        VStack(alignment: .leading, spacing: WinnieSpacing.s) {
            // Section label
            Text("NEXT MILESTONE")
                .font(WinnieTypography.labelS())
                .contextTertiaryText()
                .tracking(0.5)

            // Goal row
            HStack {
                // Goal icon
                Image(systemName: goal.displayIcon)
                    .font(.system(size: WinnieSpacing.iconSizeM))
                    .foregroundColor(goal.displayColor)

                // Goal name
                Text(goal.name)
                    .font(WinnieTypography.bodyM())
                    .contextPrimaryText()
                    .lineLimit(1)

                Spacer()

                // Timeline
                Text(projection.timeToCompletionText)
                    .font(WinnieTypography.bodyM())
                    .fontWeight(.semibold)
                    .contextSecondaryText()
            }

            // Progress text
            Text("\(goal.progressPercentageInt)% complete")
                .font(WinnieTypography.caption())
                .contextTertiaryText()
        }
    }

    // MARK: - Computed Properties

    private var totalAllocated: Decimal {
        scenario.allocations.totalAllocated
    }

    private var unallocatedAmount: Decimal {
        max(savingsPool - totalAllocated, 0)
    }

    private var allocationProgress: Double {
        guard savingsPool > 0 else { return 0 }
        let progress = totalAllocated / savingsPool
        return Double(truncating: progress as NSNumber)
    }

    /// Find the next milestone - the allocated goal closest to completion that isn't 100% done
    private var nextMilestone: (goal: Goal, projection: GoalProjection)? {
        // Filter to goals with projections that are reachable and not complete
        let goalsWithProjections = allocatedGoals.compactMap { goal -> (goal: Goal, projection: GoalProjection, months: Int)? in
            guard let projection = projections[goal.id],
                  projection.isReachable,
                  let months = projection.monthsToComplete,
                  goal.progressPercentage < 1.0 else {
                return nil
            }
            return (goal, projection, months)
        }

        // Sort by months to completion and take the closest
        guard let closest = goalsWithProjections.min(by: { $0.months < $1.months }) else {
            return nil
        }

        return (closest.goal, closest.projection)
    }

    // MARK: - Helpers

    private func formatCurrency(_ amount: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSDecimalNumber(decimal: amount)) ?? "$0"
    }
}

// MARK: - Empty Plan Card

/// Shown when there's no active plan
struct EmptyPlanCard: View {
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        WinnieCard(style: .ivoryBordered) {
            VStack(spacing: WinnieSpacing.m) {
                Text("No active plan yet")
                    .font(WinnieTypography.headlineS())
                    .contextPrimaryText()

                Text("Create a plan in the Planning tab to see your budget health and goal timelines here.")
                    .font(WinnieTypography.bodyS())
                    .contextSecondaryText()
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, WinnieSpacing.s)
        }
    }
}

// MARK: - Previews

#Preview("Active Plan Card") {
    let scenario = Scenario.sample
    let goals = [
        Goal(
            id: "1",
            type: .house,
            name: "Down Payment",
            targetAmount: 50000,
            currentAmount: 37500,
            colorHex: GoalPresetColor.coral.rawValue
        ),
        Goal(
            id: "2",
            type: .emergencyFund,
            name: "Emergency Fund",
            targetAmount: 10000,
            currentAmount: 6000,
            colorHex: GoalPresetColor.slate.rawValue
        ),
        Goal(
            id: "3",
            type: .vacation,
            name: "Hawaii Trip",
            targetAmount: 5000,
            currentAmount: 1550,
            colorHex: GoalPresetColor.gold.rawValue
        )
    ]

    let projections: [String: GoalProjection] = [
        "1": GoalProjection(
            goalID: "1",
            monthsToComplete: 27,
            completionDate: Calendar.current.date(byAdding: .month, value: 27, to: Date()),
            projectedFinalValue: 50000,
            monthlyContribution: 800,
            isReachable: true
        ),
        "2": GoalProjection(
            goalID: "2",
            monthsToComplete: 18,
            completionDate: Calendar.current.date(byAdding: .month, value: 18, to: Date()),
            projectedFinalValue: 10000,
            monthlyContribution: 300,
            isReachable: true
        ),
        "3": GoalProjection(
            goalID: "3",
            monthsToComplete: 8,
            completionDate: Calendar.current.date(byAdding: .month, value: 8, to: Date()),
            projectedFinalValue: 5000,
            monthlyContribution: 200,
            isReachable: true
        )
    ]

    VStack {
        ActivePlanCard(
            scenario: scenario,
            savingsPool: 2500,
            allocatedGoals: goals,
            projections: projections
        )
    }
    .padding(WinnieSpacing.l)
    .background(WinnieColors.porcelain)
}

#Preview("Fully Allocated") {
    ActivePlanCardPreviewFullyAllocated()
}

/// Helper view for preview to avoid type inference issues
private struct ActivePlanCardPreviewFullyAllocated: View {
    var body: some View {
        let goals = [Goal.sampleHouse]
        let projections: [String: GoalProjection] = [
            Goal.sampleHouse.id: GoalProjection(
                goalID: Goal.sampleHouse.id,
                monthsToComplete: 24,
                completionDate: Calendar.current.date(byAdding: .month, value: 24, to: Date()),
                projectedFinalValue: 50000,
                monthlyContribution: 2500,
                isReachable: true
            )
        ]

        var scenario = Scenario.sample
        scenario.allocations.setAmount(2500, for: Goal.sampleHouse.id)

        return VStack {
            ActivePlanCard(
                scenario: scenario,
                savingsPool: 2500,
                allocatedGoals: goals,
                projections: projections
            )
        }
        .padding(WinnieSpacing.l)
        .background(WinnieColors.porcelain)
    }
}

#Preview("Empty Plan Card") {
    VStack {
        EmptyPlanCard()
    }
    .padding(WinnieSpacing.l)
    .background(WinnieColors.porcelain)
}

#Preview("Dark Mode") {
    let scenario = Scenario.sample
    let goals = [Goal.sampleHouse]
    let projections: [String: GoalProjection] = [
        Goal.sampleHouse.id: GoalProjection(
            goalID: Goal.sampleHouse.id,
            monthsToComplete: 27,
            completionDate: Calendar.current.date(byAdding: .month, value: 27, to: Date()),
            projectedFinalValue: 50000,
            monthlyContribution: 1000,
            isReachable: true
        )
    ]

    VStack {
        ActivePlanCard(
            scenario: scenario,
            savingsPool: 2500,
            allocatedGoals: goals,
            projections: projections
        )
    }
    .padding(WinnieSpacing.l)
    .background(WinnieColors.onyx)
    .preferredColorScheme(.dark)
}
