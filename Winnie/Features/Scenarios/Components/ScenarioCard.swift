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

    private var allocatedGoals: [Goal] {
        goals.filter { scenario.allocations[$0.id] > 0 }
    }

    var body: some View {
        Button(action: onTap) {
            WinnieCard(style: .ivoryBordered) {
                VStack(alignment: .leading, spacing: WinnieSpacing.m) {
                    // Header: Name and status
                    HStack {
                        VStack(alignment: .leading, spacing: WinnieSpacing.xxs) {
                            HStack(spacing: WinnieSpacing.xs) {
                                if scenario.isActive {
                                    Image(systemName: "star.fill")
                                        .font(.system(size: 12))
                                        .foregroundColor(WinnieColors.goldenOrange)
                                }

                                Text(scenario.name)
                                    .font(WinnieTypography.headlineS())
                                    .contextPrimaryText()
                                    .lineLimit(1)
                            }

                            Text(statusText)
                                .font(WinnieTypography.caption())
                                .foregroundColor(statusColor)
                        }

                        Spacer()

                        // Chevron
                        Image(systemName: "chevron.right")
                            .font(.system(size: 14, weight: .semibold))
                            .contextTertiaryText()
                    }

                    Divider()
                        .background(WinnieColors.border(for: colorScheme))

                    // Allocation summary
                    HStack {
                        VStack(alignment: .leading, spacing: WinnieSpacing.xxs) {
                            Text("Monthly")
                                .font(WinnieTypography.caption())
                                .contextTertiaryText()

                            Text(formatCurrency(totalAllocation))
                                .font(WinnieTypography.bodyM())
                                .fontWeight(.semibold)
                                .contextPrimaryText()
                        }

                        Spacer()

                        VStack(alignment: .trailing, spacing: WinnieSpacing.xxs) {
                            Text("Goals")
                                .font(WinnieTypography.caption())
                                .contextTertiaryText()

                            Text("\(allocatedGoals.count)")
                                .font(WinnieTypography.bodyM())
                                .fontWeight(.semibold)
                                .contextPrimaryText()
                        }
                    }

                    // Goal timeline previews (top 3)
                    if !allocatedGoals.isEmpty {
                        goalTimelinePreview
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

    // MARK: - Goal Timeline Preview

    private var goalTimelinePreview: some View {
        HStack(spacing: WinnieSpacing.s) {
            ForEach(allocatedGoals.prefix(3)) { goal in
                HStack(spacing: WinnieSpacing.xxs) {
                    Circle()
                        .fill(goal.displayColor)
                        .frame(width: 8, height: 8)

                    if let projection = projections?[goal.id], projection.isReachable {
                        Text(projection.timeToCompletionText)
                            .font(WinnieTypography.caption())
                            .contextSecondaryText()
                    } else {
                        Text("--")
                            .font(WinnieTypography.caption())
                            .contextTertiaryText()
                    }
                }
            }

            if allocatedGoals.count > 3 {
                Text("+\(allocatedGoals.count - 3)")
                    .font(WinnieTypography.caption())
                    .contextTertiaryText()
            }
        }
    }

    // MARK: - Status Helpers

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
                        if scenario.isActive {
                            Image(systemName: "star.fill")
                                .font(.system(size: 10))
                                .foregroundColor(WinnieColors.goldenOrange)
                        }

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
