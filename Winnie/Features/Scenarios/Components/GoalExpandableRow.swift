//
//  GoalExpandableRow.swift
//  Winnie
//
//  Created by Claude Code on 2026-01-09.
//

import SwiftUI

/// A unified expandable row that combines goal selection and allocation controls.
///
/// When collapsed (unselected), shows a compact row with checkbox, icon, and goal info.
/// When expanded (selected), reveals allocation sliders and projection details.
///
/// Usage:
/// ```swift
/// GoalExpandableRow(
///     goal: goal,
///     isSelected: selectedGoalIDs.contains(goal.id),
///     context: isSelected ? viewModel.allocationContext(for: goal) : nil,
///     allocationAmount: $allocation,
///     maxAllocation: 2000,
///     onToggle: { viewModel.toggleGoalSelection(goal.id) },
///     onSliderChanged: { _ in },
///     onMatchRequired: { allocation = requiredAmount }
/// )
/// ```
struct GoalExpandableRow: View {
    let goal: Goal
    let isSelected: Bool
    let context: GoalAllocationContext?
    @Binding var allocationAmount: Decimal
    let maxAllocation: Decimal
    let onToggle: () -> Void
    let onSliderChanged: (Bool) -> Void
    let onMatchRequired: (() -> Void)?

    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        VStack(spacing: 0) {
            // Header row (always visible) - tappable to toggle selection
            Button(action: onToggle) {
                headerRow
            }
            .buttonStyle(.plain)

            // Expanded allocation content (visible when selected)
            if isSelected {
                Divider()
                    .padding(.horizontal, WinnieSpacing.m)

                allocationContent
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .background(backgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: WinnieSpacing.cardCornerRadius))
        .overlay(
            RoundedRectangle(cornerRadius: WinnieSpacing.cardCornerRadius)
                .stroke(borderColor, lineWidth: 1)
        )
        .animation(.spring(response: 0.35, dampingFraction: 0.85), value: isSelected)
    }

    // MARK: - Header Row (Collapsed State)

    private var headerRow: some View {
        HStack(spacing: WinnieSpacing.m) {
            // Checkbox
            Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                .font(.system(size: 22))
                .foregroundColor(isSelected ? goal.displayColor : WinnieColors.tertiaryText(for: colorScheme))

            // Goal icon
            Image(systemName: goal.displayIcon)
                .font(.system(size: 24))
                .foregroundColor(goal.displayColor)
                .frame(width: 32, height: 32)

            // Goal info
            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Text(goal.name)
                        .font(WinnieTypography.bodyM())
                        .foregroundColor(WinnieColors.primaryText(for: colorScheme))

                    Spacer()

                    // Show target date when expanded
                    if isSelected, let targetDate = goal.desiredDate {
                        Text("Target: \(Formatting.monthYear(targetDate))")
                            .font(WinnieTypography.caption())
                            .foregroundColor(WinnieColors.tertiaryText(for: colorScheme))
                    }
                }

                Text(Formatting.currency(goal.targetAmount) + " goal")
                    .font(WinnieTypography.caption())
                    .foregroundColor(WinnieColors.tertiaryText(for: colorScheme))
            }

            // Checkmark indicator when selected
            if isSelected {
                Image(systemName: "checkmark")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(goal.displayColor)
            }
        }
        .padding(.horizontal, WinnieSpacing.m)
        .padding(.vertical, WinnieSpacing.s)
        .contentShape(Rectangle())
    }

    // MARK: - Allocation Content (Expanded State)

    @ViewBuilder
    private var allocationContent: some View {
        // Check if goal is fully funded first
        if goal.isCompleted {
            fullyFundedContent
                .padding(WinnieSpacing.m)
        } else if let ctx = context {
            VStack(alignment: .leading, spacing: WinnieSpacing.s) {
                if ctx.hasTargetDate {
                    targetDateAllocationContent(ctx)
                } else {
                    noTargetDateAllocationContent(ctx)
                }
            }
            .padding(WinnieSpacing.m)
        }
    }

    // MARK: - Fully Funded Content

    private var fullyFundedContent: some View {
        VStack(spacing: WinnieSpacing.m) {
            // Success icon
            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 40))
                .foregroundColor(WinnieColors.success(for: colorScheme))

            // Message
            VStack(spacing: WinnieSpacing.xs) {
                Text("Goal Fully Funded!")
                    .font(WinnieTypography.headlineS())
                    .foregroundColor(WinnieColors.primaryText(for: colorScheme))

                Text("You've reached \(Formatting.currency(goal.targetAmount)). No additional allocation needed.")
                    .font(WinnieTypography.bodyS())
                    .foregroundColor(WinnieColors.secondaryText(for: colorScheme))
                    .multilineTextAlignment(.center)
            }

            // Progress indicator
            HStack(spacing: WinnieSpacing.xs) {
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .font(.system(size: 12))
                Text("\(Formatting.currency(goal.currentAmount)) of \(Formatting.currency(goal.targetAmount))")
                    .font(WinnieTypography.caption())
            }
            .foregroundColor(WinnieColors.tertiaryText(for: colorScheme))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, WinnieSpacing.s)
    }

    // MARK: - Content for Goals WITH Target Date

    private func targetDateAllocationContent(_ ctx: GoalAllocationContext) -> some View {
        VStack(alignment: .leading, spacing: WinnieSpacing.s) {
            // Two-column comparison
            comparisonColumns(ctx)

            // Slider with marker
            sliderSection(ctx)

            // Status and action
            statusAndActionRow(ctx)
        }
    }

    private func comparisonColumns(_ ctx: GoalAllocationContext) -> some View {
        HStack(spacing: WinnieSpacing.s) {
            // Required column
            VStack(alignment: .leading, spacing: WinnieSpacing.xxs) {
                Text("REQUIRED")
                    .font(WinnieTypography.caption())
                    .fontWeight(.medium)
                    .foregroundColor(WinnieColors.tertiaryText(for: colorScheme))

                if let required = ctx.requiredContribution {
                    Text(formatCurrency(required) + "/mo")
                        .font(WinnieTypography.bodyM())
                        .fontWeight(.semibold)
                        .foregroundColor(WinnieColors.primaryText(for: colorScheme))

                    Text("to hit target")
                        .font(WinnieTypography.caption())
                        .foregroundColor(WinnieColors.tertiaryText(for: colorScheme))
                } else {
                    Text("--")
                        .font(WinnieTypography.bodyM())
                        .foregroundColor(WinnieColors.tertiaryText(for: colorScheme))
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(WinnieSpacing.s)
            .background(requiredColumnBackground)
            .clipShape(RoundedRectangle(cornerRadius: WinnieSpacing.xs))

            // Your allocation column
            VStack(alignment: .leading, spacing: WinnieSpacing.xxs) {
                Text("YOUR ALLOCATION")
                    .font(WinnieTypography.caption())
                    .fontWeight(.medium)
                    .foregroundColor(WinnieColors.tertiaryText(for: colorScheme))

                Text(formatCurrency(allocationAmount) + "/mo")
                    .font(WinnieTypography.bodyM())
                    .fontWeight(.semibold)
                    .foregroundColor(WinnieColors.primaryText(for: colorScheme))

                if let projectedDate = ctx.projectedDate {
                    Text("projects \(Formatting.monthYear(projectedDate))")
                        .font(WinnieTypography.caption())
                        .foregroundColor(WinnieColors.tertiaryText(for: colorScheme))
                } else if allocationAmount > 0 {
                    Text("calculating...")
                        .font(WinnieTypography.caption())
                        .foregroundColor(WinnieColors.tertiaryText(for: colorScheme))
                } else {
                    Text("no allocation")
                        .font(WinnieTypography.caption())
                        .foregroundColor(WinnieColors.tertiaryText(for: colorScheme))
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(WinnieSpacing.s)
            .background(allocationColumnBackground(ctx))
            .clipShape(RoundedRectangle(cornerRadius: WinnieSpacing.xs))
        }
    }

    private func sliderSection(_ ctx: GoalAllocationContext) -> some View {
        VStack(spacing: WinnieSpacing.xxs) {
            // Slider with optional marker
            ZStack(alignment: .leading) {
                WinnieSlider(
                    value: $allocationAmount,
                    in: 0...maxAllocation,
                    step: 50,
                    fillColor: goal.displayColor,
                    onEditingChanged: onSliderChanged
                )

                // Required amount marker (if within slider range)
                if let required = ctx.requiredContribution,
                   required > 0,
                   required <= maxAllocation {
                    requiredMarker(for: required)
                }
            }

            // Min/Max labels
            HStack {
                Text("$0")
                    .font(WinnieTypography.caption())
                    .foregroundColor(WinnieColors.tertiaryText(for: colorScheme))
                Spacer()
                Text(formatCurrency(maxAllocation))
                    .font(WinnieTypography.caption())
                    .foregroundColor(WinnieColors.tertiaryText(for: colorScheme))
            }
        }
    }

    private func requiredMarker(for required: Decimal) -> some View {
        GeometryReader { geometry in
            let progress = Double(truncating: (required / maxAllocation) as NSNumber)
            let xPosition = (geometry.size.width - 24) * progress + 12

            Rectangle()
                .fill(WinnieColors.tertiaryText(for: colorScheme))
                .frame(width: 2, height: 32)
                .offset(x: xPosition - 1, y: -4)
        }
        .frame(height: 24)
        .allowsHitTesting(false)
    }

    private func statusAndActionRow(_ ctx: GoalAllocationContext) -> some View {
        HStack {
            // Status indicator
            HStack(spacing: WinnieSpacing.xs) {
                Image(systemName: statusIcon(ctx))
                    .font(.system(size: 14))
                    .foregroundColor(statusColor(ctx))

                if let deltaText = ctx.monthsDeltaText {
                    Text(deltaText)
                        .font(WinnieTypography.bodyS())
                        .foregroundColor(statusColor(ctx))
                } else if allocationAmount == 0 {
                    Text("No allocation set")
                        .font(WinnieTypography.bodyS())
                        .foregroundColor(WinnieColors.tertiaryText(for: colorScheme))
                }
            }

            Spacer()

            // Match Required button
            if ctx.needsMoreAllocation, let onMatch = onMatchRequired {
                Button {
                    onMatch()
                } label: {
                    Text("Match Required")
                        .font(WinnieTypography.bodyS())
                        .fontWeight(.medium)
                        .foregroundColor(WinnieColors.lavenderVeil)
                }
                .buttonStyle(.plain)
            }
        }
    }

    private func statusIcon(_ ctx: GoalAllocationContext) -> String {
        if allocationAmount == 0 {
            return "minus.circle"
        } else if ctx.isOnTrack {
            return "checkmark.circle.fill"
        } else {
            return "exclamationmark.triangle.fill"
        }
    }

    private func statusColor(_ ctx: GoalAllocationContext) -> Color {
        if allocationAmount == 0 {
            return WinnieColors.tertiaryText(for: colorScheme)
        } else if ctx.isOnTrack {
            return WinnieColors.success(for: colorScheme)
        } else {
            return WinnieColors.warning(for: colorScheme)
        }
    }

    // MARK: - Content for Goals WITHOUT Target Date

    private func noTargetDateAllocationContent(_ ctx: GoalAllocationContext) -> some View {
        VStack(alignment: .leading, spacing: WinnieSpacing.s) {
            // Single row with allocation and projected date
            HStack {
                Text(formatCurrency(allocationAmount) + "/mo")
                    .font(WinnieTypography.bodyM())
                    .fontWeight(.semibold)
                    .foregroundColor(WinnieColors.primaryText(for: colorScheme))

                Spacer()

                if let projection = ctx.projection {
                    if projection.isReachable {
                        Text("projects \(Formatting.monthYear(projection.completionDate!))")
                            .font(WinnieTypography.bodyS())
                            .foregroundColor(WinnieColors.secondaryText(for: colorScheme))
                    } else {
                        Text("50+ years")
                            .font(WinnieTypography.bodyS())
                            .foregroundColor(WinnieColors.tertiaryText(for: colorScheme))
                    }
                } else if allocationAmount > 0 {
                    Text("Calculating...")
                        .font(WinnieTypography.bodyS())
                        .foregroundColor(WinnieColors.tertiaryText(for: colorScheme))
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

            // Footer
            HStack {
                Image(systemName: "calendar.badge.clock")
                    .font(.system(size: 12))
                Text("No target date set")
                    .font(WinnieTypography.caption())
            }
            .foregroundColor(WinnieColors.tertiaryText(for: colorScheme))
        }
    }

    // MARK: - Colors

    private var backgroundColor: Color {
        colorScheme == .dark
            ? WinnieColors.carbonBlack
            : WinnieColors.ivory
    }

    private var borderColor: Color {
        WinnieColors.border(for: colorScheme)
    }

    private var requiredColumnBackground: Color {
        colorScheme == .dark
            ? WinnieColors.ivory.opacity(0.05)
            : WinnieColors.carbonBlack.opacity(0.03)
    }

    private func allocationColumnBackground(_ ctx: GoalAllocationContext) -> Color {
        if ctx.isOnTrack || allocationAmount == 0 {
            return colorScheme == .dark
                ? WinnieColors.ivory.opacity(0.05)
                : WinnieColors.carbonBlack.opacity(0.03)
        } else {
            return WinnieColors.warning(for: colorScheme).opacity(0.08)
        }
    }

    // MARK: - Formatting

    private func formatCurrency(_ amount: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSDecimalNumber(decimal: amount)) ?? "$0"
    }
}

// MARK: - Previews

#Preview("Collapsed (Unselected)") {
    GoalExpandableRow(
        goal: Goal.sampleHouse,
        isSelected: false,
        context: nil,
        allocationAmount: .constant(0),
        maxAllocation: 3000,
        onToggle: {},
        onSliderChanged: { _ in },
        onMatchRequired: nil
    )
    .padding()
    .background(WinnieColors.porcelain)
}

#Preview("Expanded (Selected) - On Track") {
    struct PreviewWrapper: View {
        @State private var amount: Decimal = 1850

        var body: some View {
            GoalExpandableRow(
                goal: Goal.sampleHouse,
                isSelected: true,
                context: GoalAllocationContext(
                    goal: Goal.sampleHouse,
                    allocation: 1850,
                    projection: GoalProjection(
                        goalID: "1",
                        monthsToComplete: 24,
                        completionDate: Calendar.current.date(byAdding: .month, value: 24, to: Date()),
                        projectedFinalValue: 50000,
                        monthlyContribution: 1850,
                        isReachable: true
                    ),
                    requiredContribution: 1850,
                    targetDate: Calendar.current.date(byAdding: .month, value: 26, to: Date()),
                    isOnTrack: true,
                    monthsDelta: 2
                ),
                allocationAmount: $amount,
                maxAllocation: 3000,
                onToggle: {},
                onSliderChanged: { _ in },
                onMatchRequired: {}
            )
            .padding()
            .background(WinnieColors.porcelain)
        }
    }
    return PreviewWrapper()
}

#Preview("Expanded (Selected) - Behind") {
    struct PreviewWrapper: View {
        @State private var amount: Decimal = 1200

        var body: some View {
            GoalExpandableRow(
                goal: Goal.sampleHouse,
                isSelected: true,
                context: GoalAllocationContext(
                    goal: Goal.sampleHouse,
                    allocation: 1200,
                    projection: GoalProjection(
                        goalID: "1",
                        monthsToComplete: 32,
                        completionDate: Calendar.current.date(byAdding: .month, value: 32, to: Date()),
                        projectedFinalValue: 50000,
                        monthlyContribution: 1200,
                        isReachable: true
                    ),
                    requiredContribution: 1850,
                    targetDate: Calendar.current.date(byAdding: .month, value: 24, to: Date()),
                    isOnTrack: false,
                    monthsDelta: -8
                ),
                allocationAmount: $amount,
                maxAllocation: 3000,
                onToggle: {},
                onSliderChanged: { _ in },
                onMatchRequired: { amount = 1850 }
            )
            .padding()
            .background(WinnieColors.porcelain)
        }
    }
    return PreviewWrapper()
}

#Preview("Dark Mode - Expanded") {
    struct PreviewWrapper: View {
        @State private var amount: Decimal = 1000

        var body: some View {
            GoalExpandableRow(
                goal: Goal.sampleHouse,
                isSelected: true,
                context: GoalAllocationContext(
                    goal: Goal.sampleHouse,
                    allocation: 1000,
                    projection: GoalProjection(
                        goalID: "1",
                        monthsToComplete: 40,
                        completionDate: Calendar.current.date(byAdding: .month, value: 40, to: Date()),
                        projectedFinalValue: 50000,
                        monthlyContribution: 1000,
                        isReachable: true
                    ),
                    requiredContribution: 1850,
                    targetDate: Calendar.current.date(byAdding: .month, value: 24, to: Date()),
                    isOnTrack: false,
                    monthsDelta: -16
                ),
                allocationAmount: $amount,
                maxAllocation: 3000,
                onToggle: {},
                onSliderChanged: { _ in },
                onMatchRequired: { amount = 1850 }
            )
            .padding()
            .background(WinnieColors.onyx)
            .preferredColorScheme(.dark)
        }
    }
    return PreviewWrapper()
}

#Preview("Fully Funded Goal") {
    // Create a fully funded goal (currentAmount >= targetAmount)
    let fundedGoal = Goal(
        type: .emergencyFund,
        name: "Rainy Day Fund",
        targetAmount: Decimal(20000),
        currentAmount: Decimal(20000),  // Fully funded!
        desiredDate: nil,
        priority: 2,
        colorHex: GoalPresetColor.teal.rawValue,
        iconName: "cloud.rain.fill"
    )

    GoalExpandableRow(
        goal: fundedGoal,
        isSelected: true,
        context: nil,  // No context needed for fully funded
        allocationAmount: .constant(0),
        maxAllocation: 3000,
        onToggle: {},
        onSliderChanged: { _ in },
        onMatchRequired: nil
    )
    .padding()
    .background(WinnieColors.porcelain)
}
