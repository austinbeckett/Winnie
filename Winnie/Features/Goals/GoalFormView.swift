import SwiftUI

/// A form for creating or editing a goal.
///
/// Mode is determined by whether a goal is passed in:
/// - `goal: nil` → Create mode
/// - `goal: Goal` → Edit mode
///
/// Usage:
/// ```swift
/// // Create mode
/// GoalFormView(goal: nil) { newGoal in
///     viewModel.pendingGoalToSave = newGoal
/// }
///
/// // Edit mode
/// GoalFormView(goal: existingGoal) { updatedGoal in
///     viewModel.pendingGoalToUpdate = updatedGoal
/// }
/// ```
struct GoalFormView: View {
    let existingGoal: Goal?
    let onSave: (Goal) -> Void  // Non-async callback - parent handles async work

    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dismiss) private var dismiss

    // Form state
    @State private var selectedType: GoalType = .house
    @State private var name: String = ""
    @State private var targetAmountText: String = ""
    @State private var currentAmountText: String = ""
    @State private var hasTargetDate: Bool = false
    @State private var targetDate: Date = Calendar.current.date(byAdding: .year, value: 1, to: Date()) ?? Date()
    @State private var notes: String = ""

    // Validation
    @State private var nameError: String?
    @State private var targetAmountError: String?

    // Loading state
    @State private var isSaving = false

    private var isEditMode: Bool {
        existingGoal != nil
    }

    private func dismissKeyboard() {
        UIApplication.shared.sendAction(
            #selector(UIResponder.resignFirstResponder),
            to: nil, from: nil, for: nil
        )
    }

    private var isValid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty &&
        !targetAmountText.isEmpty &&
        (Decimal(string: targetAmountText) ?? 0) > 0
    }

    init(goal: Goal?, onSave: @escaping (Goal) -> Void) {
        self.existingGoal = goal
        self.onSave = onSave

        // Pre-populate form if editing
        if let goal = goal {
            _selectedType = State(initialValue: goal.type)
            _name = State(initialValue: goal.name)
            _targetAmountText = State(initialValue: "\(goal.targetAmount)")
            _currentAmountText = State(initialValue: "\(goal.currentAmount)")
            _hasTargetDate = State(initialValue: goal.desiredDate != nil)
            _targetDate = State(initialValue: goal.desiredDate ?? Date())
            _notes = State(initialValue: goal.notes ?? "")
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: WinnieSpacing.l) {
                    // Goal type picker
                    goalTypePicker

                    // Name field
                    WinnieTextField(
                        "Goal Name",
                        text: $name,
                        placeholder: "e.g., Down Payment, Wedding, College Fund, etc.",
                        error: nameError
                    )
                    .onChange(of: name) { _, _ in
                        validateName()
                    }

                    // Target amount
                    WinnieCurrencyField(
                        "Target Savings",
                        text: $targetAmountText,
                        error: targetAmountError
                    )
                    .onChange(of: targetAmountText) { _, _ in
                        validateTargetAmount()
                    }

                    // Current progress
                    WinnieCurrencyField(
                        "Current Savings",
                        text: $currentAmountText
                    )

                    // Target date toggle and picker
                    targetDateSection

                    // Notes
                    notesSection

                    Spacer(minLength: WinnieSpacing.xl)
                }
                .padding(.horizontal, WinnieSpacing.screenMarginMobile)
                .padding(.top, WinnieSpacing.m)
            }
            .background(WinnieColors.background(for: colorScheme).ignoresSafeArea())
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done") {
                        dismissKeyboard()
                    }
                    .fontWeight(.semibold)
                }
            }
            .navigationTitle(isEditMode ? "Edit Goal" : "New Goal")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.primary)
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button(isEditMode ? "Save" : "Create") {
                        saveGoal()
                    }
                    .fontWeight(.semibold)
                    .foregroundColor(isValid ? .primary : WinnieColors.tertiaryText(for: colorScheme))
                    .disabled(!isValid || isSaving)
                }
            }
        }
    }

    // MARK: - Goal Type Picker

    private var goalTypePicker: some View {
        VStack(alignment: .leading, spacing: WinnieSpacing.s) {
            Text("Goal Category")
                .font(WinnieTypography.bodyS())
                .fontWeight(.medium)
                .foregroundColor(WinnieColors.secondaryText(for: colorScheme))

            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: WinnieSpacing.s) {
                ForEach(GoalType.allCases) { type in
                    goalTypeButton(type)
                }
            }
        }
    }

    private func goalTypeButton(_ type: GoalType) -> some View {
        Button {
            selectedType = type
        } label: {
            VStack(spacing: WinnieSpacing.xs) {
                Image(systemName: type.iconName)
                    .font(.system(size: 24))
                    .foregroundColor(selectedType == type ? .white : type.color)
                    .frame(width: 48, height: 48)
                    .background(selectedType == type ? type.color : type.color.opacity(0.15))
                    .clipShape(RoundedRectangle(cornerRadius: 12))

                Text(type.displayName)
                    .font(WinnieTypography.caption())
                    .foregroundColor(
                        selectedType == type
                            ? WinnieColors.primaryText(for: colorScheme)
                            : WinnieColors.secondaryText(for: colorScheme)
                    )
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, WinnieSpacing.s)
            .background(
                selectedType == type
                    ? WinnieColors.cardBackground(for: colorScheme)
                    : Color.clear
            )
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        selectedType == type ? type.color : Color.clear,
                        lineWidth: 2
                    )
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Target Date Section

    private var targetDateSection: some View {
        VStack(alignment: .leading, spacing: WinnieSpacing.s) {
            Toggle(isOn: $hasTargetDate) {
                Text("Set Target Date")
                    .font(WinnieTypography.bodyM())
                    .foregroundColor(WinnieColors.primaryText(for: colorScheme))
            }
            .tint(WinnieColors.amethystSmoke)

            if hasTargetDate {
                DatePicker(
                    "Target Date",
                    selection: $targetDate,
                    in: Date()...,
                    displayedComponents: .date
                )
                .datePickerStyle(.graphical)
                .tint(WinnieColors.amethystSmoke)
                .padding(WinnieSpacing.m)
                .background(WinnieColors.cardBackground(for: colorScheme))
                .clipShape(RoundedRectangle(cornerRadius: WinnieSpacing.inputCornerRadius))
            }
        }
    }

    // MARK: - Notes Section

    private var notesSection: some View {
        VStack(alignment: .leading, spacing: WinnieSpacing.xs) {
            Text("Notes (Optional)")
                .font(WinnieTypography.bodyS())
                .fontWeight(.medium)
                .foregroundColor(WinnieColors.secondaryText(for: colorScheme))

            TextEditor(text: $notes)
                .font(WinnieTypography.bodyM())
                .foregroundColor(WinnieColors.primaryText(for: colorScheme))
                .scrollContentBackground(.hidden)
                .padding(WinnieSpacing.m)
                .frame(minHeight: 100)
                .background(WinnieColors.cardBackground(for: colorScheme))
                .clipShape(RoundedRectangle(cornerRadius: WinnieSpacing.inputCornerRadius))
                .overlay(
                    RoundedRectangle(cornerRadius: WinnieSpacing.inputCornerRadius)
                        .stroke(WinnieColors.inputBorder(for: colorScheme), lineWidth: 1)
                )
        }
    }

    // MARK: - Validation

    private func validateName() {
        if name.trimmingCharacters(in: .whitespaces).isEmpty {
            nameError = "Goal name is required"
        } else {
            nameError = nil
        }
    }

    private func validateTargetAmount() {
        if targetAmountText.isEmpty {
            targetAmountError = "Target amount is required"
        } else if let amount = Decimal(string: targetAmountText), amount <= 0 {
            targetAmountError = "Amount must be greater than zero"
        } else if Decimal(string: targetAmountText) == nil {
            targetAmountError = "Please enter a valid number"
        } else {
            targetAmountError = nil
        }
    }

    // MARK: - Save

    private func saveGoal() {
        // Final validation
        validateName()
        validateTargetAmount()

        guard isValid else { return }

        isSaving = true

        let targetAmount = Decimal(string: targetAmountText) ?? 0
        let currentAmount = Decimal(string: currentAmountText) ?? 0

        let goal = Goal(
            id: existingGoal?.id ?? UUID().uuidString,
            type: selectedType,
            name: name.trimmingCharacters(in: .whitespaces),
            targetAmount: targetAmount,
            currentAmount: currentAmount,
            desiredDate: hasTargetDate ? targetDate : nil,
            customReturnRate: existingGoal?.customReturnRate,
            priority: existingGoal?.priority ?? 0,
            createdAt: existingGoal?.createdAt ?? Date(),
            isActive: existingGoal?.isActive ?? true,
            notes: notes.isEmpty ? nil : notes
        )

        // Call the synchronous callback - parent view handles async save
        onSave(goal)

        // Dismiss the sheet
        dismiss()
    }
}

// MARK: - Preview

#Preview("Create Mode") {
    GoalFormView(goal: nil) { goal in
        print("Created goal: \(goal.name)")
    }
}

#Preview("Edit Mode") {
    GoalFormView(goal: .sampleHouse) { goal in
        print("Updated goal: \(goal.name)")
    }
}

#Preview("Dark Mode") {
    GoalFormView(goal: nil) { _ in }
        .preferredColorScheme(.dark)
}
