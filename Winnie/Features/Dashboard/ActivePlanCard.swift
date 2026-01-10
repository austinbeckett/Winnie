//
//  ActivePlanCard.swift
//  Winnie
//
//  Created by Claude on 2026-01-08.
//  Redesigned on 2026-01-09 for improved visual hierarchy and emotional engagement.
//

import SwiftUI

/// A confidence-inspiring card showing the active plan with hero savings amount.
///
/// Displays:
/// - Plan name with "Active Plan" badge
/// - Hero total saved amount - the centerpiece
/// - "saved toward your goals!" subtitle
///
/// Design philosophy:
/// - Primary emotion: Confidence ("We're making progress")
/// - Clean, focused display of total progress
/// - Chevron in top corner for navigation affordance
///
/// Usage:
/// ```swift
/// ActivePlanCard(
///     scenario: viewModel.activeScenario,
///     totalSaved: viewModel.totalSavedAmount,
///     onTap: { ... }
/// )
/// ```
struct ActivePlanCard: View {
    let scenario: Scenario
    let totalSaved: Decimal
    let onTap: () -> Void

    @Environment(\.colorScheme) private var colorScheme

    /// Triggers the fade + pop animation on appear
    @State private var showAmount: Bool = false

    /// Color for the hero amount - Pine Teal in light mode, Lavender Veil in dark mode
    private var heroAmountColor: Color {
        colorScheme == .dark ? WinnieColors.lavenderVeil : WinnieColors.pineTeal
    }

    var body: some View {
        Button(action: {
            HapticFeedback.light()
            onTap()
        }) {
            WinnieCard(style: .ivoryBordered) {
                VStack(alignment: .leading, spacing: WinnieSpacing.s) {
                    // Header: Plan name + On Track badge
                    headerSection

                    // Hero: Total saved amount
                    heroSection
                }
            }
        }
        .buttonStyle(InteractiveCardStyle())
        .accessibilityLabel("Active plan: \(scenario.name), \(formatCurrency(totalSaved)) saved")
        .accessibilityHint("Double tap to view plan details")
    }

    // MARK: - Header Section

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: WinnieSpacing.xxs) {
            // Active Plan badge with seal checkmark
            HStack(spacing: WinnieSpacing.xxs) {
                Image(systemName: "checkmark.seal.fill")
                    .font(.system(size: 12))
                    .foregroundColor(WinnieColors.success(for: colorScheme))

                Text("Active Plan")
                    .font(WinnieTypography.caption())
                    .foregroundColor(WinnieColors.success(for: colorScheme))
            }

            Text(scenario.name)
                .font(WinnieTypography.headlineS())
                .contextPrimaryText()
                .lineLimit(1)
        }
    }

    // MARK: - Hero Section (Total Saved)

    private var heroSection: some View {
        VStack(spacing: WinnieSpacing.xxs) {
            // Hero amount with fade + pop animation (centered)
            Text(formatCurrency(totalSaved))
                .font(WinnieTypography.financialHero())
                .foregroundColor(heroAmountColor)
                .opacity(showAmount ? 1 : 0)
                .scaleEffect(showAmount ? 1.0 : 0.85)
                .animation(.spring(response: 0.5, dampingFraction: 0.6), value: showAmount)

            // Subtitle
            Text("saved toward your goals!")
                .font(WinnieTypography.bodyS())
                .contextSecondaryText()
        }
        .frame(maxWidth: .infinity)
        .onAppear {
            // Small delay for visual polish, then trigger animation
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                showAmount = true
            }
        }
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
    var onTap: (() -> Void)?

    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        if let onTap {
            Button(action: {
                HapticFeedback.light()
                onTap()
            }) {
                cardContent
            }
            .buttonStyle(InteractiveCardStyle())
            .accessibilityLabel("No active plan")
            .accessibilityHint("Double tap to create a plan")
        } else {
            cardContent
        }
    }

    private var cardContent: some View {
        WinnieCard(style: .ivoryBordered) {
            VStack(spacing: WinnieSpacing.m) {
                Text("No active plan yet")
                    .font(WinnieTypography.headlineS())
                    .contextPrimaryText()

                Text("Tap to create your first plan and start tracking your goals.")
                    .font(WinnieTypography.bodyS())
                    .contextSecondaryText()
                    .multilineTextAlignment(.center)

                // Visual indicator when tappable
                if onTap != nil {
                    HStack(spacing: WinnieSpacing.xs) {
                        Text("Get Started")
                            .font(WinnieTypography.bodyS())
                            .fontWeight(.medium)

                        Image(systemName: "chevron.right")
                            .font(.system(size: 12, weight: .semibold))
                    }
                    .foregroundColor(WinnieColors.lavenderVeil)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, WinnieSpacing.s)
        }
    }
}

// MARK: - Previews

#Preview("Active Plan Card") {
    VStack {
        ActivePlanCard(
            scenario: Scenario.sample,
            totalSaved: 131683,
            onTap: { print("Card tapped") }
        )
    }
    .padding(WinnieSpacing.l)
    .background(WinnieColors.porcelain)
}

#Preview("Empty Plan Card") {
    VStack {
        EmptyPlanCard()
    }
    .padding(WinnieSpacing.l)
    .background(WinnieColors.porcelain)
}

#Preview("Dark Mode") {
    VStack {
        ActivePlanCard(
            scenario: Scenario.sample,
            totalSaved: 35000,
            onTap: {}
        )
    }
    .padding(WinnieSpacing.l)
    .background(WinnieColors.onyx)
    .preferredColorScheme(.dark)
}
