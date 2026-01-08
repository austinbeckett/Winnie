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

    @Environment(\.colorScheme) private var colorScheme

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
            }
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
