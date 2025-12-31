import SwiftUI

/// The current phase of goal creation.
enum GoalCreationPhase {
    case nameEntry    // Phase 1: Enter goal name, see suggestions
    case detailsEntry // Phase 2: Enter savings, date, notes
}

/// A two-phase goal creation modal with dynamic icon and suggestions.
///
/// **How It Works:**
/// - Phase 1: User enters a goal name or selects from suggestions
/// - Phase 2: User enters target savings, current savings, date, notes
/// - The header persists across both phases with an animated icon
/// - Saves the goal using the provided callback
///
/// **Usage:**
/// ```swift
/// .sheet(isPresented: $showCreateGoal) {
///     GoalCreationView { newGoal in
///         Task {
///             await viewModel.createGoal(newGoal)
///         }
///     }
/// }
/// ```
struct GoalCreationView: View {
    let onSave: (Goal) -> Void

    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dismiss) private var dismiss

    // MARK: - Phase State

    @State private var phase: GoalCreationPhase = .nameEntry

    // MARK: - Form State

    @State private var goalName: String = ""
    @State private var targetAmountText: String = ""
    @State private var currentAmountText: String = ""
    @State private var hasTargetDate: Bool = false
    @State private var targetDate: Date = Calendar.current.date(byAdding: .year, value: 1, to: Date()) ?? Date()
    @State private var notes: String = ""

    // MARK: - Focus State

    @FocusState private var isNameFieldFocused: Bool

    // MARK: - Validation State

    @State private var targetAmountError: String?
    @State private var isSaving: Bool = false

    // MARK: - Computed Properties

    /// Whether the user can proceed from Phase 1 to Phase 2.
    private var canContinue: Bool {
        !goalName.trimmingCharacters(in: .whitespaces).isEmpty
    }

    /// Whether the form is valid for saving.
    private var canCreate: Bool {
        canContinue &&
        !targetAmountText.isEmpty &&
        (Decimal(string: targetAmountText) ?? 0) > 0
    }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Persistent header
                GoalCreationHeaderView(
                    goalName: $goalName,
                    isFocused: $isNameFieldFocused
                )

                // Scrollable content
                ScrollView {
                    switch phase {
                    case .nameEntry:
                        GoalSuggestionsView { suggestion in
                            goalName = suggestion.name
                        }

                    case .detailsEntry:
                        GoalDetailsFormView(
                            targetAmountText: $targetAmountText,
                            currentAmountText: $currentAmountText,
                            hasTargetDate: $hasTargetDate,
                            targetDate: $targetDate,
                            notes: $notes,
                            targetAmountError: targetAmountError
                        )
                        .onChange(of: targetAmountText) { _, _ in
                            validateTargetAmount()
                        }
                    }

                    // Extra padding at bottom for button
                    Spacer(minLength: 100)
                }
                .scrollDismissesKeyboard(.interactively)

                // Bottom button
                bottomButton
            }
            .background(WinnieColors.background(for: colorScheme).ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .onAppear {
            // Auto-focus the name field when the modal appears
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                isNameFieldFocused = true
            }
        }
    }

    // MARK: - Bottom Button

    private var bottomButton: some View {
        VStack(spacing: 0) {
            switch phase {
            case .nameEntry:
                peachGlowButton("Continue", isEnabled: canContinue) {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                        phase = .detailsEntry
                    }
                    dismissKeyboard()
                }

            case .detailsEntry:
                peachGlowButton("Create Goal", isEnabled: canCreate && !isSaving) {
                    saveGoal()
                }
            }
        }
        .padding(.horizontal, WinnieSpacing.screenMarginMobile)
        .padding(.vertical, WinnieSpacing.m)
        .background(WinnieColors.background(for: colorScheme))
    }

    private func peachGlowButton(_ title: String, isEnabled: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(WinnieTypography.bodyM())
                .fontWeight(.semibold)
                .foregroundColor(WinnieColors.snow)
                .frame(maxWidth: .infinity)
                .frame(height: WinnieSpacing.buttonHeight)
                .background(WinnieColors.peachGlow)
                .clipShape(RoundedRectangle(cornerRadius: WinnieSpacing.buttonCornerRadius))
        }
        .disabled(!isEnabled)
        .opacity(isEnabled ? 1.0 : 0.5)
        .buttonStyle(PeachGlowButtonStyle())
    }

    // MARK: - Validation

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
        validateTargetAmount()

        guard canCreate else { return }

        isSaving = true

        // Infer the goal type from the name
        let inferredType = GoalIconMapper.inferGoalType(from: goalName)

        let targetAmount = Decimal(string: targetAmountText) ?? 0
        let currentAmount = Decimal(string: currentAmountText) ?? 0

        let goal = Goal(
            id: UUID().uuidString,
            type: inferredType,
            name: goalName.trimmingCharacters(in: .whitespaces),
            targetAmount: targetAmount,
            currentAmount: currentAmount,
            desiredDate: hasTargetDate ? targetDate : nil,
            customReturnRate: nil,
            priority: 0,
            createdAt: Date(),
            isActive: true,
            notes: notes.isEmpty ? nil : notes
        )

        // Call the callback - parent handles async save
        onSave(goal)

        // Dismiss the modal
        dismiss()
    }

    // MARK: - Helpers

    private func dismissKeyboard() {
        UIApplication.shared.sendAction(
            #selector(UIResponder.resignFirstResponder),
            to: nil, from: nil, for: nil
        )
    }
}

// MARK: - Button Style

/// Custom button style with scale animation for the Peach Glow buttons.
private struct PeachGlowButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

// MARK: - Preview

#Preview("Phase 1 - Empty") {
    GoalCreationView { goal in
        print("Created goal: \(goal.name)")
    }
}

#Preview("Phase 1 - With Name") {
    struct PreviewWrapper: View {
        var body: some View {
            GoalCreationView { goal in
                print("Created goal: \(goal.name)")
            }
        }
    }
    return PreviewWrapper()
}

#Preview("Dark Mode") {
    GoalCreationView { _ in }
        .preferredColorScheme(.dark)
}
