import SwiftUI

/// A screen for quickly logging contributions to multiple goals at once.
///
/// Shows all goals with inline amount fields, monthly allocation info, and quick-add buttons.
/// Saves all entered contributions in one batch operation.
///
/// ## Usage
/// ```swift
/// NavigationStack {
///     QuickContributionView(
///         goals: goals,
///         allocations: scenario.allocations,
///         currentUserID: "user-1",
///         coupleID: "couple-1"
///     )
/// }
/// ```
struct QuickContributionView: View {

    @State private var viewModel: QuickContributionViewModel
    @StateObject private var keyboard: KeyboardObserver
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme

    init(goals: [Goal], allocations: Allocation, currentUserID: String, coupleID: String) {
        _viewModel = State(initialValue: QuickContributionViewModel(
            goals: goals,
            allocations: allocations,
            currentUserID: currentUserID,
            coupleID: coupleID
        ))
        _keyboard = StateObject(wrappedValue: KeyboardObserver())
    }

    var body: some View {
        ZStack {
            // Background
            WinnieColors.background(for: colorScheme)
                .ignoresSafeArea()

            if viewModel.goals.isEmpty {
                emptyState
            } else {
                goalsList
            }
        }
        .navigationTitle("Log Contributions")
        .navigationBarTitleDisplayMode(.inline)
        .winnieKeyboardDoneToolbar()
        .alert("Save Error", isPresented: $viewModel.showError) {
            Button("OK") { viewModel.showError = false }
        } message: {
            if let error = viewModel.errorMessage {
                Text(error)
            }
        }
    }

    // MARK: - Goals List

    private var goalsList: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Date picker section
                datePickerSection
                    .padding(.bottom, WinnieSpacing.m)

                // Goal rows with dividers
                ForEach(Array(viewModel.goals.enumerated()), id: \.element.id) { index, goal in
                    GoalContributionRow(
                        goal: goal,
                        monthlyAllocation: viewModel.allocation(for: goal.id),
                        amountText: Binding(
                            get: { viewModel.amountInputs[goal.id] ?? "" },
                            set: { viewModel.amountInputs[goal.id] = $0 }
                        ),
                        onQuickAdd: { viewModel.quickFill(goalID: goal.id) }
                    )

                    // Divider between rows (not after last)
                    if index < viewModel.goals.count - 1 {
                        Divider()
                    }
                }

                // Save button (inline with content)
                saveButtonSection
                    .padding(.top, WinnieSpacing.xl)
            }
            .padding(.horizontal, WinnieSpacing.screenMarginMobile)
            .padding(.top, WinnieSpacing.m)
            // Ensure the bottom content (including Save All) can scroll above the keyboard.
            .padding(.bottom, WinnieSpacing.xl + keyboard.height)
        }
        .scrollDismissesKeyboard(.interactively)
    }

    // MARK: - Date Picker Section

    private var datePickerSection: some View {
        VStack(alignment: .leading, spacing: WinnieSpacing.xs) {
            Text("Contribution Date")
                .font(WinnieTypography.bodyS())
                .fontWeight(.medium)
                .foregroundColor(WinnieColors.secondaryText(for: colorScheme))

            DatePicker(
                "",
                selection: $viewModel.contributionDate,
                in: ...Date(),
                displayedComponents: .date
            )
            .datePickerStyle(.compact)
            .labelsHidden()
            .tint(WinnieColors.lavenderVeil)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Save Button Section

    private var saveButtonSection: some View {
        VStack(spacing: WinnieSpacing.s) {
            // Count indicator
            if viewModel.enteredCount > 0 {
                Text("\(viewModel.enteredCount) goal\(viewModel.enteredCount == 1 ? "" : "s") to update")
                    .font(WinnieTypography.caption())
                    .foregroundColor(WinnieColors.secondaryText(for: colorScheme))
            }

            WinnieButton("Save All", style: .primary) {
                Task {
                    let result = await viewModel.saveAllContributions()
                    if result.isFullSuccess {
                        dismiss()
                    }
                    // If partial failure, error alert will show but stay on screen
                }
            }
            .disabled(!viewModel.canSave)
        }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: WinnieSpacing.m) {
            Image(systemName: "target")
                .font(.system(size: 48))
                .foregroundColor(WinnieColors.tertiaryText(for: colorScheme))

            Text("No Goals Yet")
                .font(WinnieTypography.headlineS())
                .foregroundColor(WinnieColors.primaryText(for: colorScheme))

            Text("Create a goal first to log contributions.")
                .font(WinnieTypography.bodyM())
                .foregroundColor(WinnieColors.secondaryText(for: colorScheme))
                .multilineTextAlignment(.center)
        }
        .padding(WinnieSpacing.xl)
    }
}

// MARK: - Goal Contribution Row

/// A compact single-line row for quick contribution entry.
///
/// Layout: [Icon] Goal Name ... [+$X button] [$ input]
private struct GoalContributionRow: View {

    let goal: Goal
    let monthlyAllocation: Decimal
    @Binding var amountText: String
    let onQuickAdd: () -> Void

    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        HStack(spacing: WinnieSpacing.s) {
            // Goal icon (compact)
            goalIcon

            // Goal name (flexible width)
            Text(goal.name)
                .font(WinnieTypography.bodyM())
                .fontWeight(.medium)
                .foregroundColor(WinnieColors.primaryText(for: colorScheme))
                .lineLimit(1)

            Spacer(minLength: WinnieSpacing.xs)

            // Quick-add pill button (only if allocation > 0)
            if monthlyAllocation > 0 {
                Button(action: onQuickAdd) {
                    Text("+\(formatCurrencyCompact(monthlyAllocation))")
                        .font(WinnieTypography.caption())
                        .fontWeight(.semibold)
                        .foregroundColor(WinnieColors.lavenderVeil)
                        .padding(.horizontal, WinnieSpacing.s)
                        .padding(.vertical, 6)
                        .background(WinnieColors.lavenderVeil.opacity(0.15))
                        .clipShape(Capsule())
                }
            }

            // Amount input (compact)
            amountInput
        }
        .padding(.vertical, WinnieSpacing.s)
    }

    // MARK: - Subviews

    private var goalIcon: some View {
        ZStack {
            Circle()
                .fill(goal.displayColor.opacity(0.2))
                .frame(width: 32, height: 32)

            Image(systemName: goal.displayIcon)
                .font(.system(size: 14))
                .foregroundColor(goal.displayColor)
        }
    }

    private var amountInput: some View {
        HStack(spacing: 2) {
            Text("$")
                .font(WinnieTypography.bodyS())
                .foregroundColor(WinnieColors.secondaryText(for: colorScheme))

            TextField("0", text: $amountText)
                .font(WinnieTypography.bodyS())
                .fontWeight(.medium)
                .foregroundColor(WinnieColors.primaryText(for: colorScheme))
                .keyboardType(.numberPad)
                .multilineTextAlignment(.trailing)
                .frame(width: 50)
        }
        .padding(.horizontal, WinnieSpacing.xs)
        .padding(.vertical, 6)
        .background(WinnieColors.primaryText(for: colorScheme).opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    // MARK: - Helpers

    /// Format currency without "$" symbol for compact display
    private func formatCurrencyCompact(_ amount: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSDecimalNumber(decimal: amount)) ?? "$0"
    }
}

// MARK: - Previews

#Preview("With Goals") {
    // Create sample allocations matching Goal.samples
    var sampleAllocations = Allocation()
    for (index, goal) in Goal.samples.enumerated() {
        // Assign sample monthly amounts: $500, $250, $800, etc.
        sampleAllocations[goal.id] = Decimal(500 + index * 250)
    }

    return NavigationStack {
        QuickContributionView(
            goals: Goal.samples,
            allocations: sampleAllocations,
            currentUserID: "preview-user",
            coupleID: "preview-couple"
        )
    }
}

#Preview("Empty State") {
    NavigationStack {
        QuickContributionView(
            goals: [],
            allocations: Allocation(),
            currentUserID: "preview-user",
            coupleID: "preview-couple"
        )
    }
}

#Preview("Dark Mode") {
    var sampleAllocations = Allocation()
    for (index, goal) in Goal.samples.enumerated() {
        sampleAllocations[goal.id] = Decimal(500 + index * 250)
    }

    return NavigationStack {
        QuickContributionView(
            goals: Goal.samples,
            allocations: sampleAllocations,
            currentUserID: "preview-user",
            coupleID: "preview-couple"
        )
    }
    .preferredColorScheme(.dark)
}
