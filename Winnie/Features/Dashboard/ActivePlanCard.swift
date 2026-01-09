//
//  ActivePlanCard.swift
//  Winnie
//
//  Created by Claude on 2026-01-08.
//  Redesigned on 2026-01-09 for improved visual hierarchy and emotional engagement.
//

import SwiftUI

/// A confidence-inspiring card showing the active plan with hero savings amount and key stats.
///
/// New design (Jan 2026) displays:
/// - Plan name with optional "On Track" badge (positive reinforcement only)
/// - Hero total saved amount - the centerpiece
/// - Stats row: Overall progress % + Contribution streak
/// - Compact next milestone section
///
/// Design philosophy:
/// - Primary emotion: Confidence ("We're on track and in control")
/// - Balanced mix of status dashboard + celebration
/// - Positive reinforcement only - no "behind" indicators
///
/// Usage:
/// ```swift
/// ActivePlanCard(
///     scenario: viewModel.activeScenario,
///     totalSaved: viewModel.totalSavedAmount,
///     overallProgress: viewModel.overallProgress,
///     contributionStreak: viewModel.contributionStreak,
///     isOnTrack: viewModel.isOnTrack,
///     allocatedGoals: viewModel.allocatedGoals,
///     projections: viewModel.projections,
///     onTap: { ... }
/// )
/// ```
struct ActivePlanCard: View {
    let scenario: Scenario
    let totalSaved: Decimal
    let overallProgress: Double
    let contributionStreak: Int
    let isOnTrack: Bool
    let allocatedGoals: [Goal]
    let projections: [String: GoalProjection]
    let onTap: () -> Void
    var onMilestoneTap: ((Goal) -> Void)?

    @Environment(\.colorScheme) private var colorScheme

    /// Animated value for the count-up effect
    @State private var animatedSavedAmount: Double = 0

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
                VStack(alignment: .leading, spacing: WinnieSpacing.m) {
                    // Header: Plan name + On Track badge
                    headerSection

                    // Hero: Total saved amount
                    heroSection

                    // Stats row: Progress + Streak
                    statsRow

                    // Next milestone (compact)
                    if let milestone = nextMilestone {
                        Divider()
                            .background(WinnieColors.border(for: colorScheme))

                        compactMilestoneSection(goal: milestone.goal, projection: milestone.projection)
                    }
                }
            }
        }
        .buttonStyle(InteractiveCardStyle())
        .accessibilityLabel("Active plan: \(scenario.name), \(formatCurrency(totalSaved)) saved")
        .accessibilityHint("Double tap to view plan details")
    }

    // MARK: - Header Section

    private var headerSection: some View {
        HStack {
            // Active Plan badge + Plan name
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

            Spacer()

            // On Track badge (only shown when on track - positive reinforcement)
            if isOnTrack {
                HStack(spacing: WinnieSpacing.xxs) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 12))
                        .foregroundColor(WinnieColors.success(for: colorScheme))

                    Text("On Track")
                        .font(WinnieTypography.caption())
                        .foregroundColor(WinnieColors.success(for: colorScheme))
                }
            }

            // Chevron indicator for tap affordance
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .semibold))
                .contextTertiaryText()
        }
    }

    // MARK: - Hero Section (Total Saved)

    private var heroSection: some View {
        VStack(spacing: WinnieSpacing.xxs) {
            // Animated count-up amount with accent color
            Text(formatCurrency(Decimal(animatedSavedAmount)))
                .font(WinnieTypography.financialXL())
                .foregroundColor(heroAmountColor)
                .contentTransition(.numericText(countsDown: false))

            Text("saved toward your goals!")
                .font(WinnieTypography.bodyS())
                .contextSecondaryText()
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, WinnieSpacing.s)
        .onAppear {
            // Trigger count-up animation
            animatedSavedAmount = 0
            withAnimation(.easeOut(duration: 1.2)) {
                animatedSavedAmount = Double(truncating: totalSaved as NSNumber)
            }
        }
        .onChange(of: totalSaved) { _, newValue in
            // Animate when value changes
            withAnimation(.easeOut(duration: 0.8)) {
                animatedSavedAmount = Double(truncating: newValue as NSNumber)
            }
        }
    }

    // MARK: - Stats Row

    private var statsRow: some View {
        HStack(spacing: WinnieSpacing.m) {
            // Overall Progress stat box
            statBox(
                value: "\(Int(overallProgress * 100))%",
                label: "complete"
            )

            // Contribution Streak stat box
            VStack(spacing: WinnieSpacing.xxs) {
                StreakDisplay(months: contributionStreak)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, WinnieSpacing.s)
            .background(
                RoundedRectangle(cornerRadius: WinnieSpacing.s)
                    .fill(WinnieColors.primaryText(for: colorScheme).opacity(0.05))
            )
        }
    }

    private func statBox(value: String, label: String) -> some View {
        VStack(spacing: WinnieSpacing.xxs) {
            Text(value)
                .font(WinnieTypography.financialM())
                .contextPrimaryText()

            Text(label)
                .font(WinnieTypography.caption())
                .contextSecondaryText()
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, WinnieSpacing.s)
        .background(
            RoundedRectangle(cornerRadius: WinnieSpacing.s)
                .fill(WinnieColors.primaryText(for: colorScheme).opacity(0.05))
        )
    }

    // MARK: - Compact Milestone Section

    @ViewBuilder
    private func compactMilestoneSection(goal: Goal, projection: GoalProjection) -> some View {
        if let onMilestoneTap {
            Button {
                HapticFeedback.light()
                onMilestoneTap(goal)
            } label: {
                milestoneContent(goal: goal, projection: projection, showChevron: true)
            }
            .buttonStyle(InteractiveCardStyle())
            .accessibilityLabel("Next milestone: \(goal.name)")
            .accessibilityHint("Double tap to view goal details")
        } else {
            milestoneContent(goal: goal, projection: projection, showChevron: false)
        }
    }

    private func milestoneContent(goal: Goal, projection: GoalProjection, showChevron: Bool) -> some View {
        HStack(spacing: WinnieSpacing.s) {
            // "Next:" label
            Text("Next:")
                .font(WinnieTypography.caption())
                .contextTertiaryText()

            // Goal icon
            Image(systemName: goal.displayIcon)
                .font(.system(size: 14))
                .foregroundColor(goal.displayColor)

            // Goal name
            Text(goal.name)
                .font(WinnieTypography.bodyS())
                .contextPrimaryText()
                .lineLimit(1)

            // Bullet separator
            Text("·")
                .contextTertiaryText()

            // Timeline
            Text(projection.timeToCompletionText)
                .font(WinnieTypography.bodyS())
                .fontWeight(.medium)
                .contextSecondaryText()

            // Bullet separator
            Text("·")
                .contextTertiaryText()

            // Progress
            Text("\(goal.progressPercentageInt)%")
                .font(WinnieTypography.bodyS())
                .fontWeight(.medium)
                .contextSecondaryText()

            Spacer()

            // Chevron when tappable
            if showChevron {
                Image(systemName: "chevron.right")
                    .font(.system(size: 10, weight: .semibold))
                    .contextTertiaryText()
            }
        }
    }

    // MARK: - Computed Properties

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

// MARK: - Legacy Support

/// Extension to support the old API during transition
extension ActivePlanCard {
    /// Legacy initializer for backwards compatibility
    init(
        scenario: Scenario,
        savingsPool: Decimal,
        allocatedGoals: [Goal],
        projections: [String: GoalProjection],
        onTap: @escaping () -> Void,
        onMilestoneTap: ((Goal) -> Void)? = nil
    ) {
        self.scenario = scenario
        // Calculate total saved from allocated goals
        self.totalSaved = allocatedGoals.reduce(Decimal.zero) { $0 + $1.currentAmount }
        // Calculate overall progress from allocated goals
        let progress = allocatedGoals.isEmpty ? 0.0 : allocatedGoals.reduce(0.0) { $0 + $1.progressPercentage } / Double(allocatedGoals.count)
        self.overallProgress = progress
        self.contributionStreak = 0  // Placeholder until tracking is implemented
        // On track if all goals have valid projections
        self.isOnTrack = !allocatedGoals.isEmpty && allocatedGoals.allSatisfy { projections[$0.id]?.isReachable == true }
        self.allocatedGoals = allocatedGoals
        self.projections = projections
        self.onTap = onTap
        self.onMilestoneTap = onMilestoneTap
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

#Preview("Active Plan Card - New Design") {
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

    let totalSaved = goals.reduce(Decimal.zero) { $0 + $1.currentAmount }
    let overallProgress = goals.reduce(0.0) { $0 + $1.progressPercentage } / Double(goals.count)

    VStack {
        ActivePlanCard(
            scenario: scenario,
            totalSaved: totalSaved,
            overallProgress: overallProgress,
            contributionStreak: 6,
            isOnTrack: true,
            allocatedGoals: goals,
            projections: projections,
            onTap: { print("Card tapped") },
            onMilestoneTap: { goal in print("Milestone tapped: \(goal.name)") }
        )
    }
    .padding(WinnieSpacing.l)
    .background(WinnieColors.porcelain)
}

#Preview("With Long Streak") {
    let scenario = Scenario.sample
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

    VStack {
        ActivePlanCard(
            scenario: scenario,
            totalSaved: 52400,
            overallProgress: 0.68,
            contributionStreak: 27,  // 2 years, 3 months
            isOnTrack: true,
            allocatedGoals: goals,
            projections: projections,
            onTap: {}
        )
    }
    .padding(WinnieSpacing.l)
    .background(WinnieColors.porcelain)
}

#Preview("Zero Streak") {
    let scenario = Scenario.sample
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

    VStack {
        ActivePlanCard(
            scenario: scenario,
            totalSaved: 5000,
            overallProgress: 0.10,
            contributionStreak: 0,  // New user
            isOnTrack: false,       // Not on track, badge hidden
            allocatedGoals: goals,
            projections: projections,
            onTap: {}
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
            totalSaved: 35000,
            overallProgress: 0.70,
            contributionStreak: 12,
            isOnTrack: true,
            allocatedGoals: goals,
            projections: projections,
            onTap: {}
        )
    }
    .padding(WinnieSpacing.l)
    .background(WinnieColors.onyx)
    .preferredColorScheme(.dark)
}
