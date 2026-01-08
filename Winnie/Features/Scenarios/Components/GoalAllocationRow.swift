//
//  GoalAllocationRow.swift
//  Winnie
//
//  Created by Claude Code on 2026-01-08.
//

import SwiftUI

/// A row displaying a goal with its allocation slider and projected timeline.
///
/// Shows:
/// - Goal icon and name
/// - Monthly allocation amount
/// - Allocation slider
/// - Projected completion timeline
///
/// Usage:
/// ```swift
/// GoalAllocationRow(
///     goal: houseGoal,
///     allocationAmount: $allocation,
///     projection: engineOutput.projection(for: goal.id),
///     maxAllocation: 2000,
///     onSliderChanged: { isEditing in
///         if !isEditing { viewModel.recalculate() }
///     }
/// )
/// ```
struct GoalAllocationRow: View {
    let goal: Goal
    @Binding var allocationAmount: Decimal
    let projection: GoalProjection?
    let maxAllocation: Decimal
    let onSliderChanged: (Bool) -> Void

    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        VStack(alignment: .leading, spacing: WinnieSpacing.s) {
            // Header: Icon, name, and amount
            HStack {
                // Goal icon
                Image(systemName: goal.type.iconName)
                    .font(.system(size: WinnieSpacing.iconSizeM))
                    .foregroundColor(goal.displayColor)
                    .frame(width: WinnieSpacing.iconSizeL, height: WinnieSpacing.iconSizeL)

                // Goal name
                Text(goal.name)
                    .font(WinnieTypography.bodyM())
                    .fontWeight(.medium)
                    .foregroundColor(WinnieColors.primaryText(for: colorScheme))

                Spacer()

                // Monthly amount
                Text(formatCurrency(allocationAmount) + "/mo")
                    .font(WinnieTypography.bodyS())
                    .fontWeight(.semibold)
                    .foregroundColor(WinnieColors.secondaryText(for: colorScheme))
            }

            // Slider
            WinnieSlider(
                value: $allocationAmount,
                in: 0...maxAllocation,
                step: 50,
                fillColor: goal.displayColor,
                onEditingChanged: onSliderChanged
            )

            // Timeline projection
            HStack {
                Image(systemName: "clock")
                    .font(.system(size: 12))

                if let proj = projection {
                    if proj.isReachable {
                        Text(proj.timeToCompletionText)
                            .font(WinnieTypography.caption())
                    } else {
                        Text("50+ years")
                            .font(WinnieTypography.caption())
                    }
                } else if allocationAmount == 0 {
                    Text("No allocation set")
                        .font(WinnieTypography.caption())
                } else {
                    Text("Calculating...")
                        .font(WinnieTypography.caption())
                }
            }
            .foregroundColor(WinnieColors.tertiaryText(for: colorScheme))
        }
        .padding(WinnieSpacing.m)
        .background(backgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: WinnieSpacing.inputCornerRadius))
        .overlay(
            RoundedRectangle(cornerRadius: WinnieSpacing.inputCornerRadius)
                .stroke(borderColor, lineWidth: 1)
        )
    }

    // MARK: - Colors

    private var backgroundColor: Color {
        colorScheme == .dark
            ? WinnieColors.carbonBlack.opacity(0.5)
            : WinnieColors.ivory.opacity(0.5)
    }

    private var borderColor: Color {
        WinnieColors.border(for: colorScheme)
    }

    // MARK: - Formatting

    private func formatCurrency(_ amount: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSDecimalNumber(decimal: amount)) ?? "$0"
    }
}

// MARK: - Compact Variant

/// A more compact version of GoalAllocationRow for tighter layouts.
struct GoalAllocationRowCompact: View {
    let goal: Goal
    @Binding var allocationAmount: Decimal
    let projection: GoalProjection?
    let maxAllocation: Decimal
    let onSliderChanged: (Bool) -> Void

    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        VStack(alignment: .leading, spacing: WinnieSpacing.xs) {
            // Header row
            HStack {
                // Goal icon
                Image(systemName: goal.type.iconName)
                    .font(.system(size: WinnieSpacing.iconSizeS))
                    .foregroundColor(goal.displayColor)

                // Goal name
                Text(goal.name)
                    .font(WinnieTypography.bodyS())
                    .foregroundColor(WinnieColors.primaryText(for: colorScheme))
                    .lineLimit(1)

                Spacer()

                // Amount and timeline
                VStack(alignment: .trailing, spacing: 2) {
                    Text(formatCurrency(allocationAmount))
                        .font(WinnieTypography.bodyS())
                        .fontWeight(.semibold)
                        .foregroundColor(WinnieColors.primaryText(for: colorScheme))

                    if let proj = projection, proj.isReachable {
                        Text(proj.timeToCompletionText)
                            .font(WinnieTypography.caption())
                            .foregroundColor(WinnieColors.tertiaryText(for: colorScheme))
                    }
                }
            }

            // Slider
            WinnieSlider(
                value: $allocationAmount,
                in: 0...maxAllocation,
                step: 50,
                fillColor: goal.displayColor,
                onEditingChanged: onSliderChanged
            )
        }
    }

    private func formatCurrency(_ amount: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSDecimalNumber(decimal: amount)) ?? "$0"
    }
}

// MARK: - Previews

#Preview("Goal Allocation Row") {
    struct PreviewWrapper: View {
        @State private var amount: Decimal = 800

        var body: some View {
            GoalAllocationRow(
                goal: Goal.sampleHouse,
                allocationAmount: $amount,
                projection: GoalProjection(
                    goalID: Goal.sampleHouse.id,
                    monthsToComplete: 28,
                    completionDate: Calendar.current.date(byAdding: .month, value: 28, to: Date()),
                    projectedFinalValue: 50000,
                    monthlyContribution: 800,
                    isReachable: true
                ),
                maxAllocation: 2000,
                onSliderChanged: { _ in }
            )
            .padding(WinnieSpacing.l)
            .background(WinnieColors.porcelain)
        }
    }

    return PreviewWrapper()
}

#Preview("Multiple Rows") {
    struct PreviewWrapper: View {
        @State private var house: Decimal = 1200
        @State private var retirement: Decimal = 500
        @State private var vacation: Decimal = 300

        var body: some View {
            ScrollView {
                VStack(spacing: WinnieSpacing.m) {
                    GoalAllocationRow(
                        goal: Goal.sampleHouse,
                        allocationAmount: $house,
                        projection: GoalProjection(
                            goalID: "1", monthsToComplete: 24,
                            completionDate: Date(), projectedFinalValue: 50000,
                            monthlyContribution: 1200, isReachable: true
                        ),
                        maxAllocation: 2000,
                        onSliderChanged: { _ in }
                    )

                    GoalAllocationRow(
                        goal: Goal.sampleRetirement,
                        allocationAmount: $retirement,
                        projection: GoalProjection(
                            goalID: "2", monthsToComplete: 336,
                            completionDate: Date(), projectedFinalValue: 1000000,
                            monthlyContribution: 500, isReachable: true
                        ),
                        maxAllocation: 2000,
                        onSliderChanged: { _ in }
                    )

                    GoalAllocationRow(
                        goal: Goal.sampleVacation,
                        allocationAmount: $vacation,
                        projection: GoalProjection(
                            goalID: "3", monthsToComplete: 8,
                            completionDate: Date(), projectedFinalValue: 3000,
                            monthlyContribution: 300, isReachable: true
                        ),
                        maxAllocation: 2000,
                        onSliderChanged: { _ in }
                    )
                }
                .padding(WinnieSpacing.l)
            }
            .background(WinnieColors.porcelain)
        }
    }

    return PreviewWrapper()
}

#Preview("Compact Variant") {
    struct PreviewWrapper: View {
        @State private var amount: Decimal = 600

        var body: some View {
            GoalAllocationRowCompact(
                goal: Goal.sampleHouse,
                allocationAmount: $amount,
                projection: GoalProjection(
                    goalID: "1", monthsToComplete: 32,
                    completionDate: Date(), projectedFinalValue: 50000,
                    monthlyContribution: 600, isReachable: true
                ),
                maxAllocation: 1500,
                onSliderChanged: { _ in }
            )
            .padding(WinnieSpacing.l)
            .background(WinnieColors.porcelain)
        }
    }

    return PreviewWrapper()
}

#Preview("Dark Mode") {
    struct PreviewWrapper: View {
        @State private var amount: Decimal = 1000

        var body: some View {
            GoalAllocationRow(
                goal: Goal.sampleHouse,
                allocationAmount: $amount,
                projection: GoalProjection(
                    goalID: "1", monthsToComplete: 20,
                    completionDate: Date(), projectedFinalValue: 50000,
                    monthlyContribution: 1000, isReachable: true
                ),
                maxAllocation: 2000,
                onSliderChanged: { _ in }
            )
            .padding(WinnieSpacing.l)
            .background(WinnieColors.onyx)
            .preferredColorScheme(.dark)
        }
    }

    return PreviewWrapper()
}
