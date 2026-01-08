//
//  GoalAllocationRow.swift
//  Winnie
//
//  Created by Claude Code on 2026-01-08.
//

import SwiftUI

/// A row displaying a goal with its allocation slider and projected timeline.
///
/// This component adapts its UI based on whether the goal has a target date:
/// - **With target date**: Shows "Required vs Your Allocation" comparison, status indicator, and "Match Required" button
/// - **Without target date**: Shows simpler UI with just projected completion date
///
/// Usage:
/// ```swift
/// GoalAllocationRow(
///     context: viewModel.allocationContext(for: goal),
///     allocationAmount: $allocation,
///     maxAllocation: 2000,
///     onSliderChanged: { isEditing in
///         if !isEditing { viewModel.recalculate() }
///     },
///     onMatchRequired: {
///         allocation = context.requiredContribution ?? allocation
///     }
/// )
/// ```
struct GoalAllocationRow: View {
    let context: GoalAllocationContext
    @Binding var allocationAmount: Decimal
    let maxAllocation: Decimal
    let onSliderChanged: (Bool) -> Void
    let onMatchRequired: (() -> Void)?

    @Environment(\.colorScheme) private var colorScheme

    init(
        context: GoalAllocationContext,
        allocationAmount: Binding<Decimal>,
        maxAllocation: Decimal,
        onSliderChanged: @escaping (Bool) -> Void,
        onMatchRequired: (() -> Void)? = nil
    ) {
        self.context = context
        self._allocationAmount = allocationAmount
        self.maxAllocation = maxAllocation
        self.onSliderChanged = onSliderChanged
        self.onMatchRequired = onMatchRequired
    }

    var body: some View {
        VStack(alignment: .leading, spacing: WinnieSpacing.s) {
            // Header with goal info
            headerSection

            if context.hasTargetDate {
                // Rich UI for goals with target dates
                targetDateContent
            } else {
                // Simple UI for goals without target dates
                noTargetDateContent
            }
        }
        .padding(WinnieSpacing.m)
        .background(backgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: WinnieSpacing.inputCornerRadius))
        .overlay(
            RoundedRectangle(cornerRadius: WinnieSpacing.inputCornerRadius)
                .stroke(borderColor, lineWidth: 1)
        )
    }

    // MARK: - Header Section

    private var headerSection: some View {
        HStack {
            // Goal icon
            Image(systemName: context.goal.displayIcon)
                .font(.system(size: WinnieSpacing.iconSizeM))
                .foregroundColor(context.goal.displayColor)
                .frame(width: WinnieSpacing.iconSizeL, height: WinnieSpacing.iconSizeL)

            // Goal name
            Text(context.goal.name)
                .font(WinnieTypography.bodyM())
                .fontWeight(.medium)
                .foregroundColor(WinnieColors.primaryText(for: colorScheme))

            Spacer()

            // Target date (if set)
            if let targetDate = context.targetDate {
                Text("Target: \(Formatting.monthYear(targetDate))")
                    .font(WinnieTypography.caption())
                    .foregroundColor(WinnieColors.tertiaryText(for: colorScheme))
            }
        }
    }

    // MARK: - Content for Goals WITH Target Date

    private var targetDateContent: some View {
        VStack(alignment: .leading, spacing: WinnieSpacing.s) {
            // Two-column comparison
            comparisonColumns

            // Slider with marker
            sliderSection

            // Status and action
            statusAndActionRow
        }
    }

    private var comparisonColumns: some View {
        HStack(spacing: WinnieSpacing.s) {
            // Required column
            VStack(alignment: .leading, spacing: WinnieSpacing.xxs) {
                Text("REQUIRED")
                    .font(WinnieTypography.caption())
                    .fontWeight(.medium)
                    .foregroundColor(WinnieColors.tertiaryText(for: colorScheme))

                if let required = context.requiredContribution {
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

                if let projectedDate = context.projectedDate {
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
            .background(allocationColumnBackground)
            .clipShape(RoundedRectangle(cornerRadius: WinnieSpacing.xs))
        }
    }

    private var sliderSection: some View {
        VStack(spacing: WinnieSpacing.xxs) {
            // Slider with optional marker
            ZStack(alignment: .leading) {
                WinnieSlider(
                    value: $allocationAmount,
                    in: 0...maxAllocation,
                    step: 50,
                    fillColor: context.goal.displayColor,
                    onEditingChanged: onSliderChanged
                )

                // Required amount marker (if within slider range)
                if let required = context.requiredContribution,
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
            let xPosition = (geometry.size.width - 24) * progress + 12 // Account for thumb size

            Rectangle()
                .fill(WinnieColors.tertiaryText(for: colorScheme))
                .frame(width: 2, height: 32)
                .offset(x: xPosition - 1, y: -4)
        }
        .frame(height: 24)
        .allowsHitTesting(false)
    }

    private var statusAndActionRow: some View {
        HStack {
            // Status indicator
            HStack(spacing: WinnieSpacing.xs) {
                Image(systemName: statusIcon)
                    .font(.system(size: 14))
                    .foregroundColor(statusColor)

                if let deltaText = context.monthsDeltaText {
                    Text(deltaText)
                        .font(WinnieTypography.bodyS())
                        .foregroundColor(statusColor)
                } else if allocationAmount == 0 {
                    Text("No allocation set")
                        .font(WinnieTypography.bodyS())
                        .foregroundColor(WinnieColors.tertiaryText(for: colorScheme))
                }
            }

            Spacer()

            // Match Required button (only if behind and there's a required amount)
            if context.needsMoreAllocation, let onMatch = onMatchRequired {
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

    private var statusIcon: String {
        if allocationAmount == 0 {
            return "minus.circle"
        } else if context.isOnTrack {
            return "checkmark.circle.fill"
        } else {
            return "exclamationmark.triangle.fill"
        }
    }

    private var statusColor: Color {
        if allocationAmount == 0 {
            return WinnieColors.tertiaryText(for: colorScheme)
        } else if context.isOnTrack {
            return WinnieColors.success(for: colorScheme)
        } else {
            return WinnieColors.warning(for: colorScheme)
        }
    }

    // MARK: - Content for Goals WITHOUT Target Date

    private var noTargetDateContent: some View {
        VStack(alignment: .leading, spacing: WinnieSpacing.s) {
            // Single row with allocation and projected date
            HStack {
                Text(formatCurrency(allocationAmount) + "/mo")
                    .font(WinnieTypography.bodyM())
                    .fontWeight(.semibold)
                    .foregroundColor(WinnieColors.primaryText(for: colorScheme))

                Spacer()

                if let projection = context.projection {
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
                fillColor: context.goal.displayColor,
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
            ? WinnieColors.carbonBlack.opacity(0.5)
            : WinnieColors.ivory.opacity(0.5)
    }

    private var borderColor: Color {
        WinnieColors.border(for: colorScheme)
    }

    private var requiredColumnBackground: Color {
        colorScheme == .dark
            ? WinnieColors.ivory.opacity(0.05)
            : WinnieColors.carbonBlack.opacity(0.03)
    }

    private var allocationColumnBackground: Color {
        if context.isOnTrack || allocationAmount == 0 {
            return colorScheme == .dark
                ? WinnieColors.ivory.opacity(0.05)
                : WinnieColors.carbonBlack.opacity(0.03)
        } else {
            // Behind - slight warning tint
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

// MARK: - Legacy Initializer (Backward Compatibility)

extension GoalAllocationRow {
    /// Legacy initializer for backward compatibility.
    /// Creates a context-less allocation row using the old interface.
    init(
        goal: Goal,
        allocationAmount: Binding<Decimal>,
        projection: GoalProjection?,
        maxAllocation: Decimal,
        onSliderChanged: @escaping (Bool) -> Void
    ) {
        // Create a minimal context from the old parameters
        let context = GoalAllocationContext(
            goal: goal,
            allocation: allocationAmount.wrappedValue,
            projection: projection,
            requiredContribution: nil,
            targetDate: goal.desiredDate,
            isOnTrack: true,
            monthsDelta: nil
        )
        self.init(
            context: context,
            allocationAmount: allocationAmount,
            maxAllocation: maxAllocation,
            onSliderChanged: onSliderChanged,
            onMatchRequired: nil
        )
    }
}

// MARK: - Previews

#Preview("With Target Date - On Track") {
    struct PreviewWrapper: View {
        @State private var amount: Decimal = 1850

        var body: some View {
            GoalAllocationRow(
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
                onSliderChanged: { _ in },
                onMatchRequired: { }
            )
            .padding(WinnieSpacing.l)
            .background(WinnieColors.porcelain)
        }
    }
    return PreviewWrapper()
}

#Preview("With Target Date - Behind") {
    struct PreviewWrapper: View {
        @State private var amount: Decimal = 1200

        var body: some View {
            GoalAllocationRow(
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
                onSliderChanged: { _ in },
                onMatchRequired: { amount = 1850 }
            )
            .padding(WinnieSpacing.l)
            .background(WinnieColors.porcelain)
        }
    }
    return PreviewWrapper()
}

#Preview("Without Target Date") {
    struct PreviewWrapper: View {
        @State private var amount: Decimal = 400

        var body: some View {
            GoalAllocationRow(
                context: GoalAllocationContext(
                    goal: Goal.sampleVacation,
                    allocation: 400,
                    projection: GoalProjection(
                        goalID: "3",
                        monthsToComplete: 8,
                        completionDate: Calendar.current.date(byAdding: .month, value: 8, to: Date()),
                        projectedFinalValue: 3000,
                        monthlyContribution: 400,
                        isReachable: true
                    ),
                    requiredContribution: nil,
                    targetDate: nil,
                    isOnTrack: true,
                    monthsDelta: nil
                ),
                allocationAmount: $amount,
                maxAllocation: 1500,
                onSliderChanged: { _ in },
                onMatchRequired: nil
            )
            .padding(WinnieSpacing.l)
            .background(WinnieColors.porcelain)
        }
    }
    return PreviewWrapper()
}

#Preview("Dark Mode - Behind") {
    struct PreviewWrapper: View {
        @State private var amount: Decimal = 1000

        var body: some View {
            GoalAllocationRow(
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
                onSliderChanged: { _ in },
                onMatchRequired: { amount = 1850 }
            )
            .padding(WinnieSpacing.l)
            .background(WinnieColors.onyx)
            .preferredColorScheme(.dark)
        }
    }
    return PreviewWrapper()
}
