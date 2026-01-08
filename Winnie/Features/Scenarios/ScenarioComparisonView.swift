//
//  ScenarioComparisonView.swift
//  Winnie
//
//  Created by Claude Code on 2026-01-08.
//

import SwiftUI

/// View for comparing two scenarios side-by-side.
///
/// Shows:
/// - Both scenario names and totals
/// - Goal-by-goal timeline comparison
/// - Difference indicators (faster/slower)
///
/// Usage:
/// ```swift
/// ScenarioComparisonView(
///     coupleID: "abc123",
///     scenarios: allScenarios,
///     goals: allGoals,
///     profile: financialProfile
/// )
/// ```
struct ScenarioComparisonView: View {
    let coupleID: String
    let scenarios: [Scenario]
    let goals: [Goal]
    let profile: FinancialProfile
    let onDismiss: () -> Void

    @State private var selectedScenarioA: Scenario?
    @State private var selectedScenarioB: Scenario?
    @State private var comparisonResult: ComparisonResult?

    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dismiss) private var dismiss

    private let engine = FinancialEngine()

    var body: some View {
        NavigationStack {
            ZStack {
                WinnieColors.background(for: colorScheme)
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: WinnieSpacing.l) {
                        // Scenario selectors
                        scenarioSelectionSection

                        // Comparison results
                        if let result = comparisonResult {
                            comparisonResultsSection(result)
                        } else if selectedScenarioA != nil && selectedScenarioB != nil {
                            ProgressView()
                                .padding(WinnieSpacing.xl)
                        } else {
                            selectBothPrompt
                        }
                    }
                    .padding(WinnieSpacing.l)
                }
            }
            .navigationTitle("Compare Plans")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") {
                        onDismiss()
                        dismiss()
                    }
                }
            }
        }
        .onChange(of: selectedScenarioA) { _, _ in calculateComparison() }
        .onChange(of: selectedScenarioB) { _, _ in calculateComparison() }
    }

    // MARK: - Scenario Selection

    private var scenarioSelectionSection: some View {
        HStack(spacing: WinnieSpacing.m) {
            // Scenario A picker
            VStack(alignment: .leading, spacing: WinnieSpacing.xs) {
                Text("Plan A")
                    .font(WinnieTypography.caption())
                    .foregroundColor(WinnieColors.tertiaryText(for: colorScheme))

                scenarioPicker(
                    selection: $selectedScenarioA,
                    excluding: selectedScenarioB,
                    accentColor: WinnieColors.lavenderVeil
                )
            }

            // VS divider
            Text("vs")
                .font(WinnieTypography.bodyS())
                .foregroundColor(WinnieColors.tertiaryText(for: colorScheme))
                .padding(.top, WinnieSpacing.l)

            // Scenario B picker
            VStack(alignment: .leading, spacing: WinnieSpacing.xs) {
                Text("Plan B")
                    .font(WinnieTypography.caption())
                    .foregroundColor(WinnieColors.tertiaryText(for: colorScheme))

                scenarioPicker(
                    selection: $selectedScenarioB,
                    excluding: selectedScenarioA,
                    accentColor: WinnieColors.goldenOrange
                )
            }
        }
    }

    private func scenarioPicker(
        selection: Binding<Scenario?>,
        excluding: Scenario?,
        accentColor: Color
    ) -> some View {
        Menu {
            ForEach(scenarios.filter { $0.id != excluding?.id }) { scenario in
                Button {
                    selection.wrappedValue = scenario
                } label: {
                    HStack {
                        Text(scenario.name)
                        if scenario.isActive {
                            Image(systemName: "star.fill")
                        }
                    }
                }
            }
        } label: {
            HStack {
                Text(selection.wrappedValue?.name ?? "Select plan")
                    .font(WinnieTypography.bodyM())
                    .foregroundColor(
                        selection.wrappedValue != nil
                            ? WinnieColors.primaryText(for: colorScheme)
                            : WinnieColors.tertiaryText(for: colorScheme)
                    )
                    .lineLimit(1)

                Spacer()

                Image(systemName: "chevron.down")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(WinnieColors.tertiaryText(for: colorScheme))
            }
            .padding(WinnieSpacing.m)
            .background(inputBackgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: WinnieSpacing.inputCornerRadius))
            .overlay(
                RoundedRectangle(cornerRadius: WinnieSpacing.inputCornerRadius)
                    .stroke(
                        selection.wrappedValue != nil ? accentColor : WinnieColors.inputBorder(for: colorScheme),
                        lineWidth: selection.wrappedValue != nil ? 2 : 1
                    )
            )
        }
    }

    // MARK: - Comparison Results

    private struct ComparisonResult {
        let outputA: EngineOutput
        let outputB: EngineOutput
        let differences: [GoalDifference]
    }

    private struct GoalDifference: Identifiable {
        let goal: Goal
        let projectionA: GoalProjection?
        let projectionB: GoalProjection?
        var id: String { goal.id }

        var monthsDifference: Int? {
            guard let monthsA = projectionA?.monthsToComplete,
                  let monthsB = projectionB?.monthsToComplete else {
                return nil
            }
            return monthsB - monthsA  // Negative = B is faster
        }

        var isFasterInB: Bool {
            guard let diff = monthsDifference else { return false }
            return diff < 0
        }

        var isSlowerInB: Bool {
            guard let diff = monthsDifference else { return false }
            return diff > 0
        }
    }

    private func calculateComparison() {
        guard let scenarioA = selectedScenarioA,
              let scenarioB = selectedScenarioB else {
            comparisonResult = nil
            return
        }

        let (outputA, outputB) = engine.compareScenarios(
            scenarioA, scenarioB,
            profile: profile,
            goals: goals
        )

        let differences = goals.map { goal in
            GoalDifference(
                goal: goal,
                projectionA: outputA.projection(for: goal.id),
                projectionB: outputB.projection(for: goal.id)
            )
        }

        comparisonResult = ComparisonResult(
            outputA: outputA,
            outputB: outputB,
            differences: differences
        )
    }

    private var selectBothPrompt: some View {
        VStack(spacing: WinnieSpacing.m) {
            Image(systemName: "arrow.left.arrow.right")
                .font(.system(size: 48))
                .foregroundColor(WinnieColors.tertiaryText(for: colorScheme))

            Text("Select two plans to compare")
                .font(WinnieTypography.bodyM())
                .foregroundColor(WinnieColors.secondaryText(for: colorScheme))
        }
        .padding(WinnieSpacing.xxl)
    }

    private func comparisonResultsSection(_ result: ComparisonResult) -> some View {
        VStack(spacing: WinnieSpacing.l) {
            // Summary header
            HStack {
                summaryColumn(
                    title: selectedScenarioA?.name ?? "Plan A",
                    total: result.outputA.totalAllocated,
                    accentColor: WinnieColors.lavenderVeil
                )

                Spacer()

                summaryColumn(
                    title: selectedScenarioB?.name ?? "Plan B",
                    total: result.outputB.totalAllocated,
                    accentColor: WinnieColors.goldenOrange
                )
            }

            Divider()
                .background(WinnieColors.border(for: colorScheme))

            // Goal comparisons
            VStack(spacing: WinnieSpacing.m) {
                ForEach(result.differences) { diff in
                    goalComparisonRow(diff)
                }
            }
        }
    }

    private func summaryColumn(title: String, total: Decimal, accentColor: Color) -> some View {
        VStack(alignment: .center, spacing: WinnieSpacing.xxs) {
            Text(title)
                .font(WinnieTypography.bodyM().weight(.medium))
                .foregroundColor(WinnieColors.primaryText(for: colorScheme))
                .lineLimit(1)

            Text(formatCurrency(total) + "/mo")
                .font(WinnieTypography.headlineS())
                .foregroundColor(accentColor)
        }
        .frame(maxWidth: .infinity)
    }

    private func goalComparisonRow(_ diff: GoalDifference) -> some View {
        HStack(spacing: WinnieSpacing.m) {
            // Plan A timeline
            VStack(alignment: .trailing, spacing: WinnieSpacing.xxs) {
                if let proj = diff.projectionA, proj.isReachable {
                    Text(proj.timeToCompletionText)
                        .font(WinnieTypography.bodyM())
                        .fontWeight(.medium)
                        .foregroundColor(WinnieColors.primaryText(for: colorScheme))
                } else {
                    Text("--")
                        .font(WinnieTypography.bodyM())
                        .foregroundColor(WinnieColors.tertiaryText(for: colorScheme))
                }
            }
            .frame(maxWidth: .infinity, alignment: .trailing)

            // Goal info (center)
            VStack(spacing: WinnieSpacing.xxs) {
                Image(systemName: diff.goal.type.iconName)
                    .font(.system(size: WinnieSpacing.iconSizeM))
                    .foregroundColor(diff.goal.displayColor)

                Text(diff.goal.name)
                    .font(WinnieTypography.caption())
                    .foregroundColor(WinnieColors.secondaryText(for: colorScheme))
                    .lineLimit(1)
            }
            .frame(width: 80)

            // Plan B timeline with difference indicator
            VStack(alignment: .leading, spacing: WinnieSpacing.xxs) {
                HStack(spacing: WinnieSpacing.xxs) {
                    if let proj = diff.projectionB, proj.isReachable {
                        Text(proj.timeToCompletionText)
                            .font(WinnieTypography.bodyM())
                            .fontWeight(.medium)
                            .foregroundColor(WinnieColors.primaryText(for: colorScheme))
                    } else {
                        Text("--")
                            .font(WinnieTypography.bodyM())
                            .foregroundColor(WinnieColors.tertiaryText(for: colorScheme))
                    }

                    // Difference indicator
                    if let monthsDiff = diff.monthsDifference, monthsDiff != 0 {
                        differenceIndicator(months: monthsDiff)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(WinnieSpacing.m)
        .background(inputBackgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: WinnieSpacing.inputCornerRadius))
    }

    private func differenceIndicator(months: Int) -> some View {
        let isFaster = months < 0
        let absMonths = abs(months)

        return HStack(spacing: 2) {
            Image(systemName: isFaster ? "arrow.down" : "arrow.up")
                .font(.system(size: 10, weight: .bold))

            Text(formatDuration(absMonths))
                .font(WinnieTypography.caption())
                .fontWeight(.semibold)
        }
        .foregroundColor(isFaster ? WinnieColors.success(for: colorScheme) : WinnieColors.warning(for: colorScheme))
    }

    // MARK: - Helpers

    private var inputBackgroundColor: Color {
        colorScheme == .dark
            ? WinnieColors.carbonBlack.opacity(0.5)
            : WinnieColors.ivory.opacity(0.5)
    }

    private func formatCurrency(_ amount: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSDecimalNumber(decimal: amount)) ?? "$0"
    }

    private func formatDuration(_ months: Int) -> String {
        if months < 12 {
            return "\(months)mo"
        } else {
            let years = months / 12
            let remainingMonths = months % 12
            if remainingMonths == 0 {
                return "\(years)y"
            } else {
                return "\(years)y \(remainingMonths)mo"
            }
        }
    }
}

// MARK: - Previews

#Preview("Comparison View") {
    ScenarioComparisonView(
        coupleID: "preview",
        scenarios: [],
        goals: [],
        profile: FinancialProfile(
            monthlyIncome: 8000,
            monthlyNeeds: 3000,
            monthlyWants: 1000,
            currentSavings: 15000
        ),
        onDismiss: {}
    )
}

#Preview("Dark Mode") {
    ScenarioComparisonView(
        coupleID: "preview",
        scenarios: [],
        goals: [],
        profile: FinancialProfile(
            monthlyIncome: 8000,
            monthlyNeeds: 3000,
            monthlyWants: 1000,
            currentSavings: 15000
        ),
        onDismiss: {}
    )
    .preferredColorScheme(.dark)
}
