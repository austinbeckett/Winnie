//
//  ScenarioCard.swift
//  Winnie
//
//  Created by Claude Code on 2026-01-08.
//

import SwiftUI

/// A card displaying a scenario summary in the list view.
///
/// Shows:
/// - Scenario name and status badge
/// - Total allocation and goal count
/// - Quick timeline summary for top goals
/// - Last modified date
///
/// Usage:
/// ```swift
/// ScenarioCard(scenario: myScenario, goals: allGoals) {
///     // Handle tap to edit
/// }
/// ```
struct ScenarioCard: View {
    let scenario: Scenario
    let goals: [Goal]
    let projections: [String: GoalProjection]?
    let onTap: () -> Void

    @Environment(\.colorScheme) private var colorScheme

    private var totalAllocation: Decimal {
        scenario.allocations.totalAllocated
    }

    private var goalsInPlan: [Goal] {
        goals.filter { scenario.allocations.goalIDs.contains($0.id) }
    }

    var body: some View {
        Button(action: onTap) {
            WinnieCard(style: .ivoryBordered) {
                VStack(alignment: .leading, spacing: WinnieSpacing.m) {
                    // Header: Status badge + Name
                    headerSection

                    Divider()
                        .background(WinnieColors.border(for: colorScheme))

                    // Allocation summary
                    allocationSummarySection

                    // Goal list with icons (replaces colored dots)
                    if !goalsInPlan.isEmpty {
                        goalListSection
                    }

                    // Footer: Last modified
                    Text("Updated \(scenario.lastModified.formatted(date: .abbreviated, time: .omitted))")
                        .font(WinnieTypography.caption())
                        .contextTertiaryText()
                }
            }
        }
        .buttonStyle(.plain)
    }

    // MARK: - Header Section

    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: WinnieSpacing.xxs) {
                // Status badge with icon
                HStack(spacing: WinnieSpacing.xs) {
                    Image(systemName: statusIcon)
                        .font(.system(size: 14))
                        .foregroundColor(statusColor)

                    Text(statusText)
                        .font(WinnieTypography.caption())
                        .foregroundColor(statusColor)
                }

                // Scenario name
                Text(scenario.name)
                    .font(WinnieTypography.headlineS())
                    .contextPrimaryText()
                    .lineLimit(1)
            }

            Spacer()

            // Chevron
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .semibold))
                .contextTertiaryText()
        }
    }

    // MARK: - Allocation Summary Section

    private var allocationSummarySection: some View {
        HStack {
            VStack(alignment: .leading, spacing: WinnieSpacing.xxs) {
                Text("Monthly Savings Pool")
                    .font(WinnieTypography.caption())
                    .contextTertiaryText()

                Text(formatCurrency(totalAllocation))
                    .font(WinnieTypography.bodyM())
                    .fontWeight(.semibold)
                    .contextPrimaryText()
            }

            Spacer()

            Text("\(goalsInPlan.count) goals")
                .font(WinnieTypography.bodyS())
                .contextSecondaryText()
        }
    }

    // MARK: - Goal List Section (Mini Icons)

    private var goalListSection: some View {
        VStack(alignment: .leading, spacing: WinnieSpacing.s) {
            ForEach(goalsInPlan.prefix(3)) { goal in
                HStack {
                    // Goal icon
                    Image(systemName: goal.displayIcon)
                        .font(.system(size: WinnieSpacing.iconSizeS))
                        .foregroundColor(goal.displayColor)

                    // Goal name
                    Text(goal.name)
                        .font(WinnieTypography.bodyS())
                        .contextPrimaryText()
                        .lineLimit(1)

                    Spacer()

                    // Timeline or Funded status
                    if goal.isCompleted {
                        Text("Funded!")
                            .font(WinnieTypography.bodyS())
                            .fontWeight(.medium)
                            .foregroundColor(WinnieColors.success(for: colorScheme))
                    } else if let projection = projections?[goal.id], projection.isReachable {
                        Text(projection.timeToCompletionText)
                            .font(WinnieTypography.bodyS())
                            .fontWeight(.medium)
                            .contextSecondaryText()
                    } else {
                        Text("--")
                            .font(WinnieTypography.bodyS())
                            .contextTertiaryText()
                    }
                }
            }

            // Overflow indicator
            if goalsInPlan.count > 3 {
                Text("+\(goalsInPlan.count - 3) more goals")
                    .font(WinnieTypography.caption())
                    .contextTertiaryText()
            }
        }
    }

    // MARK: - Status Helpers

    private var statusIcon: String {
        switch scenario.decisionStatus {
        case .draft:
            return "pencil.circle.fill"
        case .underReview:
            return "bubble.left.and.bubble.right.fill"
        case .decided:
            return scenario.isActive ? "checkmark.seal.fill" : "checkmark.circle.fill"
        case .archived:
            return "archivebox.fill"
        }
    }

    private var statusText: String {
        switch scenario.decisionStatus {
        case .draft: return "Draft"
        case .underReview: return "Under Review"
        case .decided: return scenario.isActive ? "Active Plan" : "Decided"
        case .archived: return "Archived"
        }
    }

    private var statusColor: Color {
        switch scenario.decisionStatus {
        case .draft:
            return WinnieColors.tertiaryText(for: colorScheme)
        case .underReview:
            return WinnieColors.goldenOrange
        case .decided:
            return scenario.isActive ? WinnieColors.success(for: colorScheme) : WinnieColors.secondaryText(for: colorScheme)
        case .archived:
            return WinnieColors.tertiaryText(for: colorScheme)
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

// MARK: - Compact Variant

/// A more compact card for tighter layouts or comparison views.
struct ScenarioCardCompact: View {
    let scenario: Scenario
    let isSelected: Bool
    let onTap: () -> Void

    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        Button(action: onTap) {
            HStack {
                VStack(alignment: .leading, spacing: WinnieSpacing.xxs) {
                    HStack(spacing: WinnieSpacing.xs) {
                        // Status icon
                        Image(systemName: statusIcon)
                            .font(.system(size: 12))
                            .foregroundColor(statusColor)

                        Text(scenario.name)
                            .font(WinnieTypography.bodyM())
                            .fontWeight(.medium)
                            .foregroundColor(WinnieColors.primaryText(for: colorScheme))
                            .lineLimit(1)
                    }

                    Text(formatCurrency(scenario.allocations.totalAllocated) + "/mo")
                        .font(WinnieTypography.caption())
                        .foregroundColor(WinnieColors.secondaryText(for: colorScheme))
                }

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(WinnieColors.lavenderVeil)
                }
            }
            .padding(WinnieSpacing.m)
            .background(isSelected ? WinnieColors.lavenderVeil.opacity(0.1) : Color.clear)
            .clipShape(RoundedRectangle(cornerRadius: WinnieSpacing.inputCornerRadius))
            .overlay(
                RoundedRectangle(cornerRadius: WinnieSpacing.inputCornerRadius)
                    .stroke(isSelected ? WinnieColors.lavenderVeil : WinnieColors.border(for: colorScheme), lineWidth: isSelected ? 2 : 1)
            )
        }
        .buttonStyle(.plain)
    }

    private var statusIcon: String {
        switch scenario.decisionStatus {
        case .draft:
            return "pencil.circle.fill"
        case .underReview:
            return "bubble.left.and.bubble.right.fill"
        case .decided:
            return scenario.isActive ? "checkmark.seal.fill" : "checkmark.circle.fill"
        case .archived:
            return "archivebox.fill"
        }
    }

    private var statusColor: Color {
        switch scenario.decisionStatus {
        case .draft:
            return WinnieColors.tertiaryText(for: colorScheme)
        case .underReview:
            return WinnieColors.goldenOrange
        case .decided:
            return scenario.isActive ? WinnieColors.success(for: colorScheme) : WinnieColors.secondaryText(for: colorScheme)
        case .archived:
            return WinnieColors.tertiaryText(for: colorScheme)
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

#Preview("Scenario Card") {
    let scenario = Scenario(
        id: "1",
        name: "Aggressive House Plan",
        allocations: Allocation(),
        notes: nil,
        isActive: true,
        decisionStatus: .decided,
        createdAt: Date(),
        lastModified: Date(),
        createdBy: "user1"
    )

    return ScenarioCard(
        scenario: scenario,
        goals: [],
        projections: nil,
        onTap: {}
    )
    .padding(WinnieSpacing.l)
    .background(WinnieColors.porcelain)
}

#Preview("Compact Cards") {
    VStack(spacing: WinnieSpacing.m) {
        ScenarioCardCompact(
            scenario: Scenario(
                id: "1",
                name: "Balanced Approach",
                allocations: Allocation(),
                notes: nil,
                isActive: true,
                decisionStatus: .decided,
                createdAt: Date(),
                lastModified: Date(),
                createdBy: "user1"
            ),
            isSelected: true,
            onTap: {}
        )

        ScenarioCardCompact(
            scenario: Scenario(
                id: "2",
                name: "Aggressive Savings",
                allocations: Allocation(),
                notes: nil,
                isActive: false,
                decisionStatus: .draft,
                createdAt: Date(),
                lastModified: Date(),
                createdBy: "user1"
            ),
            isSelected: false,
            onTap: {}
        )
    }
    .padding(WinnieSpacing.l)
    .background(WinnieColors.porcelain)
}

#Preview("Dark Mode") {
    let scenario = Scenario(
        id: "1",
        name: "House Focus",
        allocations: Allocation(),
        notes: nil,
        isActive: false,
        decisionStatus: .underReview,
        createdAt: Date(),
        lastModified: Date(),
        createdBy: "user1"
    )

    return ScenarioCard(
        scenario: scenario,
        goals: [],
        projections: nil,
        onTap: {}
    )
    .padding(WinnieSpacing.l)
    .background(WinnieColors.onyx)
    .preferredColorScheme(.dark)
}
