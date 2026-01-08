//
//  ScenarioDetailView.swift
//  Winnie
//
//  Created by Claude Code on 2026-01-08.
//

import SwiftUI

/// Read-only detail view for a scenario/plan.
///
/// Displays all goals in the plan with their tracking status,
/// allowing users to adjust target dates or allocations directly.
///
/// Usage:
/// ```swift
/// ScenarioDetailView(scenario: scenario, coupleID: "abc123", userID: "user1")
/// ```
struct ScenarioDetailView: View {
    let scenario: Scenario
    let coupleID: String
    let userID: String
    let onScenarioUpdated: (() -> Void)?

    @State private var viewModel: ScenarioDetailViewModel
    @State private var showEditSheet = false
    @Environment(\.colorScheme) private var colorScheme

    // MARK: - Initialization

    init(
        scenario: Scenario,
        coupleID: String,
        userID: String,
        onScenarioUpdated: (() -> Void)? = nil
    ) {
        self.scenario = scenario
        self.coupleID = coupleID
        self.userID = userID
        self.onScenarioUpdated = onScenarioUpdated
        self._viewModel = State(initialValue: ScenarioDetailViewModel(
            scenario: scenario,
            coupleID: coupleID,
            userID: userID
        ))
    }

    var body: some View {
        ZStack {
            // Background
            WinnieColors.background(for: colorScheme)
                .ignoresSafeArea()

            if viewModel.isLoading && viewModel.goals.isEmpty {
                ProgressView()
                    .scaleEffect(1.2)
            } else {
                ScrollView {
                    VStack(spacing: WinnieSpacing.l) {
                        // Budget summary card
                        BudgetSummaryCard(
                            disposableIncome: viewModel.disposableIncome,
                            totalAllocated: viewModel.totalAllocated,
                            isOverAllocated: false
                        )

                        // Scenario metadata
                        scenarioInfoSection

                        // Goals section
                        if viewModel.goals.isEmpty {
                            emptyState
                        } else {
                            goalsSection
                        }
                    }
                    .padding(WinnieSpacing.l)
                }
            }
        }
        .navigationTitle(viewModel.scenario.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showEditSheet = true
                } label: {
                    Text("Edit")
                }
            }
        }
        .sheet(isPresented: $showEditSheet) {
            ScenarioEditorView(
                coupleID: coupleID,
                userID: userID,
                scenario: viewModel.scenario,
                onDismiss: {
                    // Reload scenario data after edit
                    Task {
                        await viewModel.reloadScenario()
                        onScenarioUpdated?()
                    }
                }
            )
        }
        .sheet(item: $viewModel.goalToEditAllocation) { goal in
            AllocationEditSheet(
                goal: goal,
                currentAllocation: viewModel.allocation(for: goal.id),
                maxAllocation: viewModel.maxAllocation(for: goal.id),
                onSave: { newAmount in
                    Task {
                        await viewModel.updateAllocation(for: goal.id, amount: newAmount)
                    }
                }
            )
        }
        .alert("Error", isPresented: $viewModel.showError) {
            Button("OK") { viewModel.showError = false }
        } message: {
            Text(viewModel.errorMessage ?? "An error occurred")
        }
        .task {
            await viewModel.loadData()
        }
    }

    // MARK: - Scenario Info Section

    private var scenarioInfoSection: some View {
        VStack(alignment: .leading, spacing: WinnieSpacing.s) {
            // Status badge
            HStack(spacing: WinnieSpacing.s) {
                statusBadge

                if viewModel.scenario.isActive {
                    Text("Active Plan")
                        .font(WinnieTypography.caption())
                        .fontWeight(.medium)
                        .foregroundColor(WinnieColors.success(for: colorScheme))
                        .padding(.horizontal, WinnieSpacing.s)
                        .padding(.vertical, WinnieSpacing.xxs)
                        .background(WinnieColors.success(for: colorScheme).opacity(0.12))
                        .clipShape(Capsule())
                }

                Spacer()
            }

            // Notes (if any)
            if let notes = viewModel.scenario.notes, !notes.isEmpty {
                Text(notes)
                    .font(WinnieTypography.bodyS())
                    .foregroundColor(WinnieColors.secondaryText(for: colorScheme))
            }

            // Last modified
            Text("Last updated \(Formatting.relativeDate(viewModel.scenario.lastModified))")
                .font(WinnieTypography.caption())
                .foregroundColor(WinnieColors.tertiaryText(for: colorScheme))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var statusBadge: some View {
        let statusText: String
        let statusColor: Color

        switch viewModel.scenario.decisionStatus {
        case .draft:
            statusText = "Draft"
            statusColor = WinnieColors.tertiaryText(for: colorScheme)
        case .underReview:
            statusText = "Under Review"
            statusColor = WinnieColors.warning(for: colorScheme)
        case .decided:
            statusText = "Decided"
            statusColor = WinnieColors.success(for: colorScheme)
        case .archived:
            statusText = "Archived"
            statusColor = WinnieColors.tertiaryText(for: colorScheme)
        }

        return HStack(spacing: WinnieSpacing.xxs) {
            Circle()
                .fill(statusColor)
                .frame(width: 8, height: 8)

            Text(statusText)
                .font(WinnieTypography.caption())
                .fontWeight(.medium)
                .foregroundColor(statusColor)
        }
        .padding(.horizontal, WinnieSpacing.s)
        .padding(.vertical, WinnieSpacing.xxs)
        .background(statusColor.opacity(0.12))
        .clipShape(Capsule())
    }

    // MARK: - Goals Section

    private var goalsSection: some View {
        VStack(alignment: .leading, spacing: WinnieSpacing.m) {
            // Section header
            HStack {
                Text("Goals in This Plan")
                    .font(WinnieTypography.labelM())
                    .foregroundColor(WinnieColors.secondaryText(for: colorScheme))

                Spacer()

                Text("\(viewModel.goals.count) goal\(viewModel.goals.count == 1 ? "" : "s")")
                    .font(WinnieTypography.caption())
                    .foregroundColor(WinnieColors.tertiaryText(for: colorScheme))
            }

            // Goal rows
            ForEach(viewModel.goals) { goal in
                ScenarioGoalRow(
                    goal: goal,
                    allocation: viewModel.allocation(for: goal.id),
                    projection: viewModel.projection(for: goal.id),
                    trackingStatus: viewModel.trackingStatus(for: goal),
                    onAdjustTarget: {
                        Task {
                            await viewModel.adjustTargetDate(for: goal)
                        }
                    },
                    onEditAllocation: {
                        viewModel.goalToEditAllocation = goal
                    }
                )
            }
        }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: WinnieSpacing.m) {
            Image(systemName: "target")
                .font(.system(size: 48))
                .foregroundColor(WinnieColors.tertiaryText(for: colorScheme))

            Text("No Goals in This Plan")
                .font(WinnieTypography.headlineS())
                .foregroundColor(WinnieColors.primaryText(for: colorScheme))

            Text("Tap \"Edit\" to add goals to this plan.")
                .font(WinnieTypography.bodyM())
                .foregroundColor(WinnieColors.secondaryText(for: colorScheme))
                .multilineTextAlignment(.center)
        }
        .padding(WinnieSpacing.xl)
    }
}

// MARK: - Previews

#Preview("Scenario Detail") {
    NavigationStack {
        ScenarioDetailView(
            scenario: .sample,
            coupleID: "preview",
            userID: "user1"
        )
    }
}

#Preview("Dark Mode") {
    NavigationStack {
        ScenarioDetailView(
            scenario: .sample,
            coupleID: "preview",
            userID: "user1"
        )
    }
    .preferredColorScheme(.dark)
}
