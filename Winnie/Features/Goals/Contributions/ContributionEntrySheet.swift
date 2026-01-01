import SwiftUI

/// Mode for the contribution entry sheet
enum ContributionEntryMode: Equatable {
    case add
    case edit(Contribution)

    var title: String {
        switch self {
        case .add: return "Add Funds"
        case .edit: return "Edit Contribution"
        }
    }

    var buttonTitle: String {
        switch self {
        case .add: return "Add Contribution"
        case .edit: return "Save Changes"
        }
    }
}

/// Sheet for adding or editing a contribution.
///
/// Displays a currency input, date picker, and optional notes field.
/// Validates that amount is greater than zero before saving.
///
/// ## Usage
/// ```swift
/// .sheet(isPresented: $showAddContribution) {
///     ContributionEntrySheet(mode: .add) { amount, date, notes in
///         Task {
///             await viewModel.addContribution(amount: amount, date: date, notes: notes)
///         }
///     }
/// }
/// ```
struct ContributionEntrySheet: View {
    let mode: ContributionEntryMode
    let onSave: (Decimal, Date, String?) -> Void

    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme

    @State private var amountText: String = ""
    @State private var date: Date = Date()
    @State private var notes: String = ""
    @State private var showError = false
    @State private var isSaving = false

    init(
        mode: ContributionEntryMode,
        onSave: @escaping (Decimal, Date, String?) -> Void
    ) {
        self.mode = mode
        self.onSave = onSave
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: WinnieSpacing.l) {
                    // Amount field
                    amountSection

                    // Date picker
                    dateSection

                    // Notes field
                    notesSection

                    Spacer(minLength: WinnieSpacing.l)

                    // Save button
                    saveButton
                }
                .padding(.horizontal, WinnieSpacing.screenMarginMobile)
                .padding(.top, WinnieSpacing.m)
            }
            .background(WinnieColors.background(for: colorScheme).ignoresSafeArea())
            .navigationTitle(mode.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
        .onAppear {
            populateEditData()
        }
    }

    // MARK: - Sections

    private var amountSection: some View {
        WinnieCurrencyField(
            "Amount",
            text: $amountText,
            error: showError && amountText.isEmpty ? "Please enter an amount" : nil
        )
    }

    private var dateSection: some View {
        VStack(alignment: .leading, spacing: WinnieSpacing.xs) {
            Text("Date")
                .font(WinnieTypography.bodyS())
                .fontWeight(.medium)
                .foregroundColor(WinnieColors.secondaryText(for: colorScheme))

            DatePicker(
                "",
                selection: $date,
                in: ...Date(),
                displayedComponents: .date
            )
            .datePickerStyle(.compact)
            .labelsHidden()
            .tint(WinnieColors.amethystSmoke)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var notesSection: some View {
        VStack(alignment: .leading, spacing: WinnieSpacing.xs) {
            Text("Notes (Optional)")
                .font(WinnieTypography.bodyS())
                .fontWeight(.medium)
                .foregroundColor(WinnieColors.secondaryText(for: colorScheme))

            TextField("e.g., Birthday money, Tax refund", text: $notes, axis: .vertical)
                .font(WinnieTypography.bodyM())
                .foregroundColor(WinnieColors.primaryText(for: colorScheme))
                .lineLimit(2...4)
                .padding(WinnieSpacing.m)
                .background(WinnieColors.cardBackground(for: colorScheme))
                .clipShape(RoundedRectangle(cornerRadius: WinnieSpacing.inputCornerRadius))
                .overlay(
                    RoundedRectangle(cornerRadius: WinnieSpacing.inputCornerRadius)
                        .stroke(WinnieColors.inputBorder(for: colorScheme), lineWidth: 1)
                )
        }
    }

    private var saveButton: some View {
        WinnieButton(mode.buttonTitle, style: .primary) {
            saveContribution()
        }
        .disabled(isSaving)
    }

    // MARK: - Actions

    private func populateEditData() {
        if case .edit(let contribution) = mode {
            amountText = formatDecimalForEditing(contribution.amount)
            date = contribution.date
            notes = contribution.notes ?? ""
        }
    }

    private func saveContribution() {
        // Validate amount
        guard let amount = parseAmount(), amount > 0 else {
            showError = true
            return
        }

        isSaving = true

        // Capture values and call sync callback
        let savedDate = date
        let savedNotes = notes.isEmpty ? nil : notes

        onSave(amount, savedDate, savedNotes)

        dismiss()
    }

    // MARK: - Helpers

    private func parseAmount() -> Decimal? {
        // Remove any non-numeric characters except decimal point
        let cleaned = amountText.replacingOccurrences(
            of: "[^0-9.]",
            with: "",
            options: .regularExpression
        )
        return Decimal(string: cleaned)
    }

    private func formatDecimalForEditing(_ decimal: Decimal) -> String {
        let number = NSDecimalNumber(decimal: decimal)
        // Check if it's a whole number by comparing with truncated value
        var rounded = decimal
        var result = Decimal()
        NSDecimalRound(&result, &rounded, 0, .plain)
        if decimal == result {
            // Whole number, no decimal places
            return String(format: "%.0f", number.doubleValue)
        } else {
            // Has decimal places
            return String(format: "%.2f", number.doubleValue)
        }
    }
}

// MARK: - Previews

#Preview("Add Mode") {
    ContributionEntrySheet(mode: .add) { amount, date, notes in
        print("Adding: \(amount) on \(date), notes: \(notes ?? "none")")
    }
}

#Preview("Edit Mode") {
    ContributionEntrySheet(
        mode: .edit(Contribution(
            goalId: "goal-1",
            userId: "user-1",
            amount: Decimal(150),
            date: Date(),
            notes: "Birthday money"
        ))
    ) { amount, date, notes in
        print("Editing: \(amount) on \(date), notes: \(notes ?? "none")")
    }
}

#Preview("Dark Mode") {
    ContributionEntrySheet(mode: .add) { _, _, _ in }
        .preferredColorScheme(.dark)
}
