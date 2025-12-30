import SwiftUI

/// Detail view for a single goal showing full information.
///
/// Displays progress, amounts, dates, notes, and provides
/// edit and delete actions.
struct GoalDetailView: View {
    let goal: Goal
    let viewModel: GoalsViewModel

    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dismiss) private var dismiss

    @State private var showEditSheet = false
    @State private var showDeleteConfirmation = false

    var body: some View {
        ScrollView {
            VStack(spacing: WinnieSpacing.l) {
                // Header card with progress
                headerCard

                // Details card
                detailsCard

                // Notes card (if present)
                if let notes = goal.notes, !notes.isEmpty {
                    notesCard(notes)
                }

                // Action buttons
                actionButtons

                Spacer(minLength: WinnieSpacing.xxl)
            }
            .padding(.horizontal, WinnieSpacing.screenMarginMobile)
            .padding(.top, WinnieSpacing.m)
        }
        .background(WinnieColors.background(for: colorScheme).ignoresSafeArea())
        .navigationTitle(goal.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                editButton
            }
        }
        .sheet(isPresented: $showEditSheet) {
            GoalFormView(goal: goal) { updatedGoal in
                // Handle async save in a Task - form uses sync callback
                Task {
                    await viewModel.updateGoal(updatedGoal)
                }
            }
        }
        .alert("Delete Goal", isPresented: $showDeleteConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                Task {
                    await viewModel.deleteGoal(goal)
                    dismiss()
                }
            }
        } message: {
            Text("Are you sure you want to delete \"\(goal.name)\"? This action cannot be undone.")
        }
    }

    // MARK: - Header Card

    private var headerCard: some View {
        WinnieCard(accentColor: goal.type.color) {
            VStack(spacing: WinnieSpacing.l) {
                // Icon and type
                HStack(spacing: WinnieSpacing.s) {
                    Image(systemName: goal.type.iconName)
                        .font(.system(size: 24))
                        .foregroundColor(goal.type.color)
                        .frame(width: 44, height: 44)
                        .background(goal.type.color.opacity(0.15))
                        .clipShape(RoundedRectangle(cornerRadius: 12))

                    VStack(alignment: .leading, spacing: 2) {
                        Text(goal.type.displayName)
                            .font(WinnieTypography.bodyS())
                            .foregroundColor(WinnieColors.tertiaryText(for: colorScheme))

                        Text(goal.name)
                            .font(WinnieTypography.headlineM())
                            .foregroundColor(WinnieColors.primaryText(for: colorScheme))
                    }

                    Spacer()
                }

                // Progress section
                VStack(spacing: WinnieSpacing.s) {
                    // Progress bar
                    WinnieProgressBar(progress: goal.progressPercentage, color: goal.type.color)

                    // Progress label
                    HStack {
                        Text("\(goal.progressPercentageInt)% complete")
                            .font(WinnieTypography.bodyS())
                            .foregroundColor(WinnieColors.secondaryText(for: colorScheme))

                        Spacer()

                        if goal.isCompleted {
                            Label("Goal Reached!", systemImage: "checkmark.circle.fill")
                                .font(WinnieTypography.bodyS())
                                .foregroundColor(WinnieColors.successMint)
                        }
                    }
                }

                // Amounts
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Saved")
                            .font(WinnieTypography.caption())
                            .foregroundColor(WinnieColors.tertiaryText(for: colorScheme))
                        Text(formatCurrency(goal.currentAmount))
                            .font(WinnieTypography.financialL())
                            .foregroundColor(WinnieColors.primaryText(for: colorScheme))
                    }

                    Spacer()

                    VStack(alignment: .trailing, spacing: 4) {
                        Text("Goal")
                            .font(WinnieTypography.caption())
                            .foregroundColor(WinnieColors.tertiaryText(for: colorScheme))
                        Text(formatCurrency(goal.targetAmount))
                            .font(WinnieTypography.financialL())
                            .foregroundColor(WinnieColors.secondaryText(for: colorScheme))
                    }
                }

                // Remaining amount
                if !goal.isCompleted {
                    HStack {
                        Text("Remaining")
                            .font(WinnieTypography.bodyS())
                            .foregroundColor(WinnieColors.tertiaryText(for: colorScheme))
                        Spacer()
                        Text(formatCurrency(goal.remainingAmount))
                            .font(WinnieTypography.bodyM())
                            .fontWeight(.semibold)
                            .foregroundColor(WinnieColors.primaryText(for: colorScheme))
                    }
                    .padding(.top, WinnieSpacing.xs)
                }
            }
        }
    }

    // MARK: - Details Card

    private var detailsCard: some View {
        WinnieCard {
            VStack(spacing: WinnieSpacing.m) {
                Text("Details")
                    .font(WinnieTypography.headlineM())
                    .foregroundColor(WinnieColors.primaryText(for: colorScheme))
                    .frame(maxWidth: .infinity, alignment: .leading)

                Divider()

                // Target date
                detailRow(
                    label: "Target Date",
                    value: goal.desiredDate.map { formatDate($0) } ?? "Not set"
                )

                // Priority
                detailRow(
                    label: "Priority",
                    value: "#\(goal.priority + 1)"
                )

                // Expected return rate
                detailRow(
                    label: "Expected Return",
                    value: formatPercentage(goal.effectiveReturnRate)
                )

                // Suggested vehicle
                detailRow(
                    label: "Suggested Account",
                    value: goal.type.suggestedVehicle
                )

                // Created date
                detailRow(
                    label: "Created",
                    value: formatDate(goal.createdAt)
                )
            }
        }
    }

    private func detailRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(WinnieTypography.bodyM())
                .foregroundColor(WinnieColors.secondaryText(for: colorScheme))
            Spacer()
            Text(value)
                .font(WinnieTypography.bodyM())
                .foregroundColor(WinnieColors.primaryText(for: colorScheme))
        }
    }

    // MARK: - Notes Card

    private func notesCard(_ notes: String) -> some View {
        WinnieCard {
            VStack(alignment: .leading, spacing: WinnieSpacing.s) {
                Text("Notes")
                    .font(WinnieTypography.headlineM())
                    .foregroundColor(WinnieColors.primaryText(for: colorScheme))

                Text(notes)
                    .font(WinnieTypography.bodyM())
                    .foregroundColor(WinnieColors.secondaryText(for: colorScheme))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    // MARK: - Action Buttons

    private var actionButtons: some View {
        VStack(spacing: WinnieSpacing.s) {
            WinnieButton("Edit Goal", style: .secondary) {
                showEditSheet = true
            }

            WinnieButton("Delete Goal", style: .text) {
                showDeleteConfirmation = true
            }
        }
    }

    // MARK: - Edit Button

    private var editButton: some View {
        Button {
            showEditSheet = true
        } label: {
            Text("Edit")
                .font(WinnieTypography.bodyM())
                .foregroundColor(WinnieColors.amethystSmoke)
        }
    }

    // MARK: - Formatting Helpers

    private func formatCurrency(_ amount: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        formatter.maximumFractionDigits = 0
        let number = NSDecimalNumber(decimal: amount)
        return formatter.string(from: number) ?? "$0"
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }

    private func formatPercentage(_ decimal: Decimal) -> String {
        let percentage = NSDecimalNumber(decimal: decimal * 100).doubleValue
        return String(format: "%.1f%%", percentage)
    }
}

// MARK: - Preview

#Preview("House Goal") {
    NavigationStack {
        GoalDetailView(
            goal: .sampleHouse,
            viewModel: GoalsViewModel(coupleID: "preview")
        )
    }
}

#Preview("Retirement Goal") {
    NavigationStack {
        GoalDetailView(
            goal: .sampleRetirement,
            viewModel: GoalsViewModel(coupleID: "preview")
        )
    }
}

#Preview("Dark Mode") {
    NavigationStack {
        GoalDetailView(
            goal: .sampleVacation,
            viewModel: GoalsViewModel(coupleID: "preview")
        )
    }
    .preferredColorScheme(.dark)
}
