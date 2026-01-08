//
//  ScenarioEditorView.swift
//  Winnie
//
//  Created by Claude Code on 2026-01-08.
//

import SwiftUI

/// The main Scenario Editor view - the core "What-If" UI.
///
/// Users can:
/// - See their monthly budget summary
/// - Adjust allocations for each goal using sliders
/// - See real-time timeline projections
/// - Save scenarios with names and notes
///
/// Usage:
/// ```swift
/// // Creating a new scenario
/// ScenarioEditorView(coupleID: "abc123", userID: "user1")
///
/// // Editing an existing scenario
/// ScenarioEditorView(coupleID: "abc123", userID: "user1", scenario: existingScenario)
/// ```
struct ScenarioEditorView: View {
    let coupleID: String
    let userID: String
    let existingScenario: Scenario?
    let onDismiss: () -> Void
    let onSave: (() -> Void)?

    @State private var viewModel: ScenarioEditorViewModel
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dismiss) private var dismiss

    @State private var showDeleteConfirmation = false
    @FocusState private var isNameFieldFocused: Bool

    // MARK: - Initialization

    init(
        coupleID: String,
        userID: String,
        scenario: Scenario? = nil,
        onDismiss: @escaping () -> Void = {},
        onSave: (() -> Void)? = nil
    ) {
        self.coupleID = coupleID
        self.userID = userID
        self.existingScenario = scenario
        self.onDismiss = onDismiss
        self.onSave = onSave
        self._viewModel = State(initialValue: ScenarioEditorViewModel(coupleID: coupleID, userID: userID))
    }

    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                WinnieColors.background(for: colorScheme)
                    .ignoresSafeArea()

                if viewModel.isLoading && viewModel.goals.isEmpty {
                    // Initial loading state
                    ProgressView()
                        .scaleEffect(1.2)
                } else {
                    // Main content
                    ScrollView {
                        VStack(spacing: WinnieSpacing.l) {
                            // Budget summary card
                            BudgetSummaryCard(
                                disposableIncome: viewModel.disposableIncome,
                                totalAllocated: viewModel.totalAllocated,
                                isOverAllocated: viewModel.isOverAllocated
                            )

                            // Goal selection section (choose which goals to include)
                            if !viewModel.goals.isEmpty {
                                GoalSelectionSection(viewModel: viewModel)
                            }

                            // Goal allocation rows (only for selected goals)
                            if viewModel.goals.isEmpty {
                                emptyGoalsState
                            } else if viewModel.hasSelectedGoals {
                                goalAllocationList
                            } else {
                                noGoalsSelectedState
                            }

                            // Scenario name and notes
                            scenarioDetailsSection

                            // Action buttons
                            actionButtonsSection
                        }
                        .padding(WinnieSpacing.l)
                    }
                }
            }
            .navigationTitle(viewModel.isEditingExisting ? "Edit Scenario" : "New Scenario")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        onDismiss()
                        dismiss()
                    }
                }

                if viewModel.isEditingExisting {
                    ToolbarItem(placement: .destructiveAction) {
                        Button(role: .destructive) {
                            showDeleteConfirmation = true
                        } label: {
                            Image(systemName: "trash")
                        }
                    }
                }
            }
            .alert("Error", isPresented: $viewModel.showError) {
                Button("OK") { viewModel.showError = false }
            } message: {
                Text(viewModel.errorMessage ?? "An error occurred")
            }
            .confirmationDialog(
                "Delete Scenario",
                isPresented: $showDeleteConfirmation,
                titleVisibility: .visible
            ) {
                Button("Delete", role: .destructive) {
                    Task {
                        if await viewModel.deleteScenario() {
                            onDismiss()
                            dismiss()
                        }
                    }
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Are you sure you want to delete this scenario? This cannot be undone.")
            }
        }
        .task {
            if let scenario = existingScenario {
                await viewModel.loadForEditing(scenario: scenario)
            } else {
                await viewModel.loadData()
            }
        }
    }

    // MARK: - Empty State

    private var emptyGoalsState: some View {
        VStack(spacing: WinnieSpacing.m) {
            Image(systemName: "target")
                .font(.system(size: 48))
                .foregroundColor(WinnieColors.tertiaryText(for: colorScheme))

            Text("No Goals Yet")
                .font(WinnieTypography.headlineS())
                .foregroundColor(WinnieColors.primaryText(for: colorScheme))

            Text("Create some goals first, then come back to plan your allocations.")
                .font(WinnieTypography.bodyM())
                .foregroundColor(WinnieColors.secondaryText(for: colorScheme))
                .multilineTextAlignment(.center)
        }
        .padding(WinnieSpacing.xl)
    }

    // MARK: - No Goals Selected State

    private var noGoalsSelectedState: some View {
        VStack(spacing: WinnieSpacing.m) {
            Image(systemName: "checklist.unchecked")
                .font(.system(size: 36))
                .foregroundColor(WinnieColors.tertiaryText(for: colorScheme))

            Text("No Goals Selected")
                .font(WinnieTypography.headlineS())
                .foregroundColor(WinnieColors.primaryText(for: colorScheme))

            Text("Select at least one goal above to set allocations.")
                .font(WinnieTypography.bodyM())
                .foregroundColor(WinnieColors.secondaryText(for: colorScheme))
                .multilineTextAlignment(.center)
        }
        .padding(WinnieSpacing.xl)
    }

    // MARK: - Goal List

    private var goalAllocationList: some View {
        VStack(spacing: WinnieSpacing.m) {
            // Section header
            HStack {
                Text("Allocations")
                    .font(WinnieTypography.labelM())
                    .foregroundColor(WinnieColors.secondaryText(for: colorScheme))

                Spacer()

                if viewModel.isCalculating {
                    ProgressView()
                        .scaleEffect(0.7)
                }
            }

            // Goal rows (only selected goals)
            ForEach(viewModel.selectedGoals) { goal in
                let context = viewModel.allocationContext(for: goal)
                GoalAllocationRow(
                    context: context,
                    allocationAmount: allocationBinding(for: goal.id),
                    maxAllocation: maxAllocationForGoal(goal),
                    onSliderChanged: { isEditing in
                        if !isEditing {
                            // Debounced recalculation happens in ViewModel
                        }
                    },
                    onMatchRequired: {
                        // Set allocation to required amount when user taps "Match Required"
                        if let required = context.requiredContribution {
                            viewModel.updateAllocation(goalID: goal.id, amount: required)
                        }
                    }
                )
            }

            // Quick actions
            if viewModel.remainingBudget > 0 {
                Button {
                    viewModel.allocateRemainingEvenly()
                } label: {
                    Label("Distribute Remaining Evenly", systemImage: "equal.circle")
                        .font(WinnieTypography.bodyS())
                }
                .foregroundColor(WinnieColors.lavenderVeil)
            }
        }
    }

    // MARK: - Scenario Details

    private var scenarioDetailsSection: some View {
        VStack(alignment: .leading, spacing: WinnieSpacing.m) {
            // Section header
            Text("Scenario Details")
                .font(WinnieTypography.labelM())
                .foregroundColor(WinnieColors.secondaryText(for: colorScheme))

            // Name field
            VStack(alignment: .leading, spacing: WinnieSpacing.xs) {
                Text("Name")
                    .font(WinnieTypography.labelS())
                    .foregroundColor(WinnieColors.tertiaryText(for: colorScheme))

                TextField("e.g., Aggressive House Plan", text: $viewModel.scenarioName)
                    .font(WinnieTypography.bodyM())
                    .padding(WinnieSpacing.m)
                    .background(inputBackgroundColor)
                    .clipShape(RoundedRectangle(cornerRadius: WinnieSpacing.inputCornerRadius))
                    .overlay(
                        RoundedRectangle(cornerRadius: WinnieSpacing.inputCornerRadius)
                            .stroke(WinnieColors.inputBorder(for: colorScheme), lineWidth: 1)
                    )
                    .focused($isNameFieldFocused)
            }

            // Notes field (optional)
            VStack(alignment: .leading, spacing: WinnieSpacing.xs) {
                Text("Notes (optional)")
                    .font(WinnieTypography.labelS())
                    .foregroundColor(WinnieColors.tertiaryText(for: colorScheme))

                TextField("Add any notes about this plan...", text: $viewModel.scenarioNotes, axis: .vertical)
                    .font(WinnieTypography.bodyM())
                    .lineLimit(3...6)
                    .padding(WinnieSpacing.m)
                    .background(inputBackgroundColor)
                    .clipShape(RoundedRectangle(cornerRadius: WinnieSpacing.inputCornerRadius))
                    .overlay(
                        RoundedRectangle(cornerRadius: WinnieSpacing.inputCornerRadius)
                            .stroke(WinnieColors.inputBorder(for: colorScheme), lineWidth: 1)
                    )
            }
        }
    }

    // MARK: - Action Buttons

    private var actionButtonsSection: some View {
        VStack(spacing: WinnieSpacing.m) {
            // Save button
            WinnieButton(
                viewModel.isEditingExisting ? "Save Changes" : "Save Scenario",
                style: .primary,
                isLoading: viewModel.isLoading,
                isEnabled: viewModel.canSave
            ) {
                Task {
                    if await viewModel.saveScenario() {
                        onSave?()
                        onDismiss()
                        dismiss()
                    }
                }
            }

            // Validation message
            if viewModel.isOverAllocated {
                HStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                    Text("Reduce allocations to stay within budget")
                }
                .font(WinnieTypography.caption())
                .foregroundColor(WinnieColors.error(for: colorScheme))
            } else if !viewModel.hasSelectedGoals {
                Text("Select at least one goal to include in this plan")
                    .font(WinnieTypography.caption())
                    .foregroundColor(WinnieColors.tertiaryText(for: colorScheme))
            } else if viewModel.scenarioName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                Text("Enter a name for your scenario")
                    .font(WinnieTypography.caption())
                    .foregroundColor(WinnieColors.tertiaryText(for: colorScheme))
            }
        }
    }

    // MARK: - Helpers

    private var inputBackgroundColor: Color {
        colorScheme == .dark
            ? WinnieColors.carbonBlack.opacity(0.5)
            : WinnieColors.ivory.opacity(0.5)
    }

    /// Create a binding for a goal's allocation amount
    private func allocationBinding(for goalID: String) -> Binding<Decimal> {
        Binding(
            get: { viewModel.workingAllocations[goalID] },
            set: { newValue in
                viewModel.updateAllocation(goalID: goalID, amount: newValue)
            }
        )
    }

    /// Calculate max allocation for a goal (remaining budget + current allocation)
    private func maxAllocationForGoal(_ goal: Goal) -> Decimal {
        let currentAllocation = viewModel.workingAllocations[goal.id]
        let availableBudget = viewModel.disposableIncome - viewModel.totalAllocated + currentAllocation
        // Cap at a reasonable maximum (e.g., 2x the disposable income)
        return min(max(availableBudget, currentAllocation), viewModel.disposableIncome * 2)
    }
}

// MARK: - Previews

#Preview("New Scenario") {
    ScenarioEditorView(
        coupleID: "preview",
        userID: "user1"
    )
}

#Preview("Dark Mode") {
    ScenarioEditorView(
        coupleID: "preview",
        userID: "user1"
    )
    .preferredColorScheme(.dark)
}
