//
//  ScenarioGoalRow.swift
//  Winnie
//
//  Created by Claude Code on 2026-01-08.
//

import SwiftUI

/// A row displaying a goal within a scenario detail view.
///
/// Shows the goal's icon, name, allocation, progress, and tracking status.
/// Provides action buttons for adjusting target dates or allocations.
struct ScenarioGoalRow: View {
    let goal: Goal
    let allocation: Decimal
    let projection: GoalProjection?
    let trackingStatus: GoalTrackingStatus
    let onAdjustTarget: () -> Void
    let onEditAllocation: () -> Void
    var onGoalTap: (() -> Void)?

    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        WinnieCard(style: .ivoryBordered) {
            VStack(alignment: .leading, spacing: WinnieSpacing.m) {
                // Header: Icon + Name + Allocation
                goalHeader

                // Progress bar
                progressBar

                // Status section
                statusSection

                // Action buttons (conditional)
                actionButtons
            }
        }
    }

    // MARK: - Goal Header

    @ViewBuilder
    private var goalHeader: some View {
        if let onGoalTap {
            Button(action: {
                HapticFeedback.light()
                onGoalTap()
            }) {
                goalHeaderContent
            }
            .buttonStyle(InteractiveCardStyle())
            .accessibilityLabel("\(goal.name), \(goal.progressPercentageInt) percent complete")
            .accessibilityHint("Double tap to view goal details")
        } else {
            goalHeaderContent
        }
    }

    private var goalHeaderContent: some View {
        HStack(spacing: WinnieSpacing.m) {
            // Goal icon - uses user's custom icon if set, otherwise type default
            Image(systemName: goal.displayIcon)
                .font(.system(size: 24))
                .foregroundColor(goal.displayColor)
                .frame(width: 40, height: 40)
                .background(goal.displayColor.opacity(0.15))
                .clipShape(RoundedRectangle(cornerRadius: 10))

            // Goal info
            VStack(alignment: .leading, spacing: 2) {
                Text(goal.name)
                    .font(WinnieTypography.bodyM())
                    .fontWeight(.medium)
                    .contextPrimaryText()

                Text(Formatting.currency(goal.targetAmount) + " goal")
                    .font(WinnieTypography.caption())
                    .contextSecondaryText()
            }

            Spacer()

            // Monthly allocation
            VStack(alignment: .trailing, spacing: 2) {
                Text(Formatting.currency(allocation))
                    .font(WinnieTypography.financialM())
                    .contextPrimaryText()

                Text("/month")
                    .font(WinnieTypography.caption())
                    .contextSecondaryText()
            }

            // Chevron indicator when tappable
            if onGoalTap != nil {
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .contextTertiaryText()
            }
        }
    }

    // MARK: - Progress Bar

    private var progressBar: some View {
        VStack(alignment: .leading, spacing: WinnieSpacing.xs) {
            // Progress info
            HStack {
                Text(Formatting.currency(goal.currentAmount) + " saved")
                    .font(WinnieTypography.caption())
                    .contextSecondaryText()

                Spacer()

                Text(Formatting.percentage(Decimal(goal.progressPercentage), decimalPlaces: 0))
                    .font(WinnieTypography.caption())
                    .fontWeight(.medium)
                    .contextSecondaryText()
            }

            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background - adapts to card context
                    RoundedRectangle(cornerRadius: 4)
                        .fill(WinnieColors.progressBackground(for: colorScheme))

                    // Fill
                    RoundedRectangle(cornerRadius: 4)
                        .fill(goal.displayColor)
                        .frame(width: geometry.size.width * min(goal.progressPercentage, 1.0))
                }
            }
            .frame(height: 8)
        }
    }

    // MARK: - Status Section

    private var statusSection: some View {
        HStack(spacing: WinnieSpacing.s) {
            // Status badge
            HStack(spacing: WinnieSpacing.xxs) {
                Circle()
                    .fill(statusColor)
                    .frame(width: 8, height: 8)

                Text(trackingStatus.label)
                    .font(WinnieTypography.caption())
                    .fontWeight(.medium)
                    .foregroundColor(statusColor)
            }
            .padding(.horizontal, WinnieSpacing.s)
            .padding(.vertical, WinnieSpacing.xxs)
            .background(statusColor.opacity(0.15))
            .clipShape(Capsule())

            Spacer()

            // Projected date
            if let projectedDate = projection?.completionDate {
                Text(Formatting.monthYear(projectedDate))
                    .font(WinnieTypography.caption())
                    .contextSecondaryText()
            }
        }
    }

    private var statusColor: Color {
        switch trackingStatus {
        case .completed:
            return WinnieColors.amethystSmoke
        case .onTrack:
            return WinnieColors.success(for: colorScheme)
        case .behind:
            return WinnieColors.warning(for: colorScheme)
        case .noTargetDate, .notInPlan:
            return WinnieColors.tertiaryText(for: colorScheme)
        }
    }

    // MARK: - Action Buttons

    @ViewBuilder
    private var actionButtons: some View {
        switch trackingStatus {
        case .behind(let details, let requiredContribution):
            VStack(alignment: .leading, spacing: WinnieSpacing.s) {
                // Recommendation text
                if requiredContribution > details.currentContribution {
                    Text("Save \(Formatting.currency(requiredContribution))/month to hit your target")
                        .font(WinnieTypography.caption())
                        .contextSecondaryText()
                }

                // Action buttons
                HStack(spacing: WinnieSpacing.s) {
                    Button {
                        onAdjustTarget()
                    } label: {
                        Text("Adjust Target")
                            .font(WinnieTypography.bodyS())
                    }
                    .buttonStyle(.bordered)
                    .tint(WinnieColors.primaryText(for: colorScheme).opacity(0.7))

                    Button {
                        onEditAllocation()
                    } label: {
                        Text("Change Allocation")
                            .font(WinnieTypography.bodyS())
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(WinnieColors.sweetSalmon)
                }
            }

        case .onTrack, .completed:
            // Just an edit allocation button for convenience
            Button {
                onEditAllocation()
            } label: {
                Text("Edit Allocation")
                    .font(WinnieTypography.bodyS())
            }
            .buttonStyle(.bordered)
            .tint(WinnieColors.primaryText(for: colorScheme).opacity(0.7))

        case .noTargetDate, .notInPlan:
            EmptyView()
        }
    }
}

// MARK: - Previews

#Preview("On Track") {
    ScenarioGoalRow(
        goal: .sampleHouse,
        allocation: 1500,
        projection: nil,
        trackingStatus: .onTrack(GoalTrackingStatus.TrackingDetails(
            projectedDate: Date().addingTimeInterval(86400 * 365),
            targetDate: Date().addingTimeInterval(86400 * 365 * 1.5),
            monthsDifference: 6,
            currentContribution: 1500
        )),
        onAdjustTarget: {},
        onEditAllocation: {}
    )
    .padding()
}

#Preview("Behind") {
    ScenarioGoalRow(
        goal: .sampleHouse,
        allocation: 1000,
        projection: nil,
        trackingStatus: .behind(
            GoalTrackingStatus.TrackingDetails(
                projectedDate: Date().addingTimeInterval(86400 * 365 * 2),
                targetDate: Date().addingTimeInterval(86400 * 365),
                monthsDifference: -12,
                currentContribution: 1000
            ),
            requiredContribution: 2500
        ),
        onAdjustTarget: {},
        onEditAllocation: {}
    )
    .padding()
}
