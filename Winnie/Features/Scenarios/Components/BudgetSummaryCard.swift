//
//  BudgetSummaryCard.swift
//  Winnie
//
//  Created by Claude Code on 2026-01-08.
//

import SwiftUI

/// A card showing the monthly budget summary with allocation progress.
///
/// Displays:
/// - Total monthly disposable income
/// - Amount allocated vs remaining
/// - Visual progress bar
/// - Warning state when over-allocated
///
/// Usage:
/// ```swift
/// BudgetSummaryCard(
///     disposableIncome: 4000,
///     totalAllocated: 3200,
///     isOverAllocated: false
/// )
/// ```
struct BudgetSummaryCard: View {
    let disposableIncome: Decimal
    let totalAllocated: Decimal
    let isOverAllocated: Bool
    let decisionStatus: Scenario.DecisionStatus?
    let isActive: Bool

    @Environment(\.colorScheme) private var colorScheme

    /// Convenience initializer without status (for backward compatibility)
    init(
        disposableIncome: Decimal,
        totalAllocated: Decimal,
        isOverAllocated: Bool
    ) {
        self.disposableIncome = disposableIncome
        self.totalAllocated = totalAllocated
        self.isOverAllocated = isOverAllocated
        self.decisionStatus = nil
        self.isActive = false
    }

    /// Full initializer with status badges
    init(
        disposableIncome: Decimal,
        totalAllocated: Decimal,
        isOverAllocated: Bool,
        decisionStatus: Scenario.DecisionStatus,
        isActive: Bool
    ) {
        self.disposableIncome = disposableIncome
        self.totalAllocated = totalAllocated
        self.isOverAllocated = isOverAllocated
        self.decisionStatus = decisionStatus
        self.isActive = isActive
    }

    private var remaining: Decimal {
        max(disposableIncome - totalAllocated, 0)
    }

    private var progress: Double {
        guard disposableIncome > 0 else { return 0 }
        let ratio = totalAllocated / disposableIncome
        return min(Double(truncating: ratio as NSNumber), 1.0)
    }

    private var overAmount: Decimal {
        max(totalAllocated - disposableIncome, 0)
    }

    var body: some View {
        WinnieCard(style: .ivoryBordered) {
            VStack(alignment: .leading, spacing: WinnieSpacing.m) {
                // Header
                HStack {
                    Text("Monthly Budget")
                        .font(WinnieTypography.labelM())
                        .contextSecondaryText()

                    Spacer()

                    Text(formatCurrency(disposableIncome))
                        .font(WinnieTypography.headlineM())
                        .contextPrimaryText()
                }

                // Progress bar
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        // Background track
                        RoundedRectangle(cornerRadius: 4)
                            .fill(trackColor)
                            .frame(height: 8)

                        // Fill
                        RoundedRectangle(cornerRadius: 4)
                            .fill(fillColor)
                            .frame(width: geometry.size.width * progress, height: 8)
                            .animation(.spring(response: 0.3, dampingFraction: 0.8), value: progress)
                    }
                }
                .frame(height: 8)

                // Allocation details
                HStack {
                    VStack(alignment: .leading, spacing: WinnieSpacing.xxs) {
                        Text("Allocated")
                            .font(WinnieTypography.caption())
                            .contextTertiaryText()

                        Text(formatCurrency(totalAllocated))
                            .font(WinnieTypography.bodyM())
                            .fontWeight(.semibold)
                            .foregroundColor(isOverAllocated ? WinnieColors.error(for: colorScheme) : nil)
                            .contextPrimaryText()
                    }

                    Spacer()

                    if isOverAllocated {
                        VStack(alignment: .trailing, spacing: WinnieSpacing.xxs) {
                            Text("Over Budget")
                                .font(WinnieTypography.caption())
                                .foregroundColor(WinnieColors.error(for: colorScheme))

                            Text("+\(formatCurrency(overAmount))")
                                .font(WinnieTypography.bodyM())
                                .fontWeight(.semibold)
                                .foregroundColor(WinnieColors.error(for: colorScheme))
                        }
                    } else {
                        VStack(alignment: .trailing, spacing: WinnieSpacing.xxs) {
                            Text("Remaining")
                                .font(WinnieTypography.caption())
                                .contextTertiaryText()

                            Text(formatCurrency(remaining))
                                .font(WinnieTypography.bodyM())
                                .fontWeight(.semibold)
                                .contextPrimaryText()
                        }
                    }
                }

                // Status badges (only shown when decisionStatus is provided)
                if decisionStatus != nil || isActive {
                    statusBadgesRow
                }
            }
        }
    }

    // MARK: - Status Badges

    @ViewBuilder
    private var statusBadgesRow: some View {
        HStack(spacing: WinnieSpacing.s) {
            if let status = decisionStatus {
                statusBadge(for: status)
            }

            if isActive {
                activePlanBadge
            }

            Spacer()
        }
    }

    private func statusBadge(for status: Scenario.DecisionStatus) -> some View {
        let statusColor = statusColor(for: status)

        return HStack(spacing: WinnieSpacing.xxs) {
            Circle()
                .fill(statusColor)
                .frame(width: 8, height: 8)

            Text(status.displayName)
                .font(WinnieTypography.caption())
                .fontWeight(.medium)
                .foregroundColor(statusColor)
        }
        .padding(.horizontal, WinnieSpacing.s)
        .padding(.vertical, WinnieSpacing.xxs)
        .background(statusColor.opacity(0.12))
        .clipShape(Capsule())
    }

    private var activePlanBadge: some View {
        let badgeColor = WinnieColors.success(for: colorScheme)

        return HStack(spacing: WinnieSpacing.xxs) {
            Circle()
                .fill(badgeColor)
                .frame(width: 8, height: 8)

            Text("Active Plan")
                .font(WinnieTypography.caption())
                .fontWeight(.medium)
                .foregroundColor(badgeColor)
        }
        .padding(.horizontal, WinnieSpacing.s)
        .padding(.vertical, WinnieSpacing.xxs)
        .background(badgeColor.opacity(0.12))
        .clipShape(Capsule())
    }

    private func statusColor(for status: Scenario.DecisionStatus) -> Color {
        switch status {
        case .draft:
            return WinnieColors.tertiaryText(for: colorScheme)
        case .underReview:
            return WinnieColors.warning(for: colorScheme)
        case .decided:
            return WinnieColors.success(for: colorScheme)
        case .archived:
            return WinnieColors.tertiaryText(for: colorScheme)
        }
    }

    // MARK: - Colors

    private var trackColor: Color {
        colorScheme == .dark
            ? WinnieColors.ivory.opacity(0.15)
            : WinnieColors.carbonBlack.opacity(0.15)
    }

    private var fillColor: Color {
        if isOverAllocated {
            return WinnieColors.error(for: colorScheme)
        }
        return WinnieColors.lavenderVeil
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

#Preview("Under Budget") {
    VStack(spacing: WinnieSpacing.l) {
        BudgetSummaryCard(
            disposableIncome: 4000,
            totalAllocated: 3200,
            isOverAllocated: false
        )

        BudgetSummaryCard(
            disposableIncome: 4000,
            totalAllocated: 1500,
            isOverAllocated: false
        )
    }
    .padding(WinnieSpacing.l)
    .background(WinnieColors.porcelain)
}

#Preview("Over Budget") {
    BudgetSummaryCard(
        disposableIncome: 4000,
        totalAllocated: 4500,
        isOverAllocated: true
    )
    .padding(WinnieSpacing.l)
    .background(WinnieColors.porcelain)
}

#Preview("Dark Mode") {
    VStack(spacing: WinnieSpacing.l) {
        BudgetSummaryCard(
            disposableIncome: 4000,
            totalAllocated: 2800,
            isOverAllocated: false
        )

        BudgetSummaryCard(
            disposableIncome: 4000,
            totalAllocated: 4200,
            isOverAllocated: true
        )
    }
    .padding(WinnieSpacing.l)
    .background(WinnieColors.onyx)
    .preferredColorScheme(.dark)
}
