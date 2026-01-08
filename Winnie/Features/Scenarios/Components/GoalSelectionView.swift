//
//  GoalSelectionView.swift
//  Winnie
//
//  Created by Claude Code on 2026-01-08.
//

import SwiftUI

/// A view that displays all goals with checkboxes for selection.
///
/// Used in the Scenario Editor to let users choose which goals
/// to include in a plan before allocating amounts.
struct GoalSelectionSection: View {
    @Bindable var viewModel: ScenarioEditorViewModel
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        VStack(alignment: .leading, spacing: WinnieSpacing.m) {
            // Section header
            HStack {
                Text("Select Goals")
                    .font(WinnieTypography.labelM())
                    .foregroundColor(WinnieColors.secondaryText(for: colorScheme))

                Spacer()

                Text("\(viewModel.selectedGoalIDs.count) of \(viewModel.goals.count) selected")
                    .font(WinnieTypography.caption())
                    .foregroundColor(WinnieColors.tertiaryText(for: colorScheme))
            }

            Text("Choose which goals to include in this plan")
                .font(WinnieTypography.bodyS())
                .foregroundColor(WinnieColors.tertiaryText(for: colorScheme))

            // Goal list with checkboxes
            VStack(spacing: 0) {
                ForEach(viewModel.goals) { goal in
                    GoalSelectionRow(
                        goal: goal,
                        isSelected: viewModel.selectedGoalIDs.contains(goal.id),
                        onToggle: { viewModel.toggleGoalSelection(goal.id) }
                    )

                    if goal.id != viewModel.goals.last?.id {
                        Divider()
                            .padding(.leading, 52) // Align with text after checkbox and icon
                    }
                }
            }
            .background(
                RoundedRectangle(cornerRadius: WinnieSpacing.cardCornerRadius)
                    .fill(cardBackgroundColor)
            )
            .clipShape(RoundedRectangle(cornerRadius: WinnieSpacing.cardCornerRadius))
        }
    }

    private var cardBackgroundColor: Color {
        colorScheme == .dark
            ? WinnieColors.carbonBlack
            : WinnieColors.ivory
    }
}

/// A single row in the goal selection list with checkbox, icon, and goal info.
struct GoalSelectionRow: View {
    let goal: Goal
    let isSelected: Bool
    let onToggle: () -> Void

    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        Button(action: onToggle) {
            HStack(spacing: WinnieSpacing.m) {
                // Checkbox
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 22))
                    .foregroundColor(isSelected ? goal.displayColor : WinnieColors.tertiaryText(for: colorScheme))

                // Goal icon
                Image(systemName: goal.type.iconName)
                    .font(.system(size: 24))
                    .foregroundColor(goal.displayColor)
                    .frame(width: 32, height: 32)

                // Goal info
                VStack(alignment: .leading, spacing: 2) {
                    Text(goal.name)
                        .font(WinnieTypography.bodyM())
                        .foregroundColor(WinnieColors.primaryText(for: colorScheme))

                    Text(Formatting.currency(goal.targetAmount) + " goal")
                        .font(WinnieTypography.caption())
                        .foregroundColor(WinnieColors.tertiaryText(for: colorScheme))
                }

                Spacer()

                // Checkmark indicator (visual confirmation)
                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(goal.displayColor)
                }
            }
            .padding(.horizontal, WinnieSpacing.m)
            .padding(.vertical, WinnieSpacing.s)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Previews

#Preview("Goal Selection") {
    VStack {
        GoalSelectionSection(
            viewModel: ScenarioEditorViewModel(coupleID: "preview", userID: "user1")
        )
    }
    .padding()
    .background(Color.gray.opacity(0.1))
}
