import SwiftUI

/// The form fields for Phase 2 of goal creation.
///
/// **How It Works:**
/// - Displays target savings, current savings, category, target date, and notes
/// - All fields are bound to parent state via `@Binding`
/// - Icon/color customization is handled via the header (tap to customize)
///
/// **Usage:**
/// ```swift
/// GoalDetailsFormView(
///     targetAmountText: $targetAmountText,
///     currentAmountText: $currentAmountText,
///     selectedType: $selectedType,
///     hasTargetDate: $hasTargetDate,
///     targetDate: $targetDate,
///     notes: $notes,
///     targetAmountError: targetAmountError
/// )
/// ```
struct GoalDetailsFormView: View {
    @Binding var targetAmountText: String
    @Binding var currentAmountText: String
    @Binding var selectedType: GoalType
    @Binding var hasTargetDate: Bool
    @Binding var targetDate: Date
    @Binding var notes: String
    @Binding var accountName: String?

    let targetAmountError: String?

    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        VStack(spacing: WinnieSpacing.l) {
            // Target savings
            WinnieCurrencyField(
                "Target Savings",
                text: $targetAmountText,
                error: targetAmountError
            )

            // Current savings
            WinnieCurrencyField(
                "Current Savings",
                text: $currentAmountText
            )

            // Category dropdown (placed after current savings per requirements)
            GoalCategoryDropdown(selectedType: $selectedType)

            // Account dropdown
            AccountDropdown(selectedAccount: $accountName)

            // Target date section
            targetDateSection

            // Notes section
            notesSection
        }
        .padding(.horizontal, WinnieSpacing.screenMarginMobile)
        .padding(.top, WinnieSpacing.l)
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
                .foregroundColor(WinnieColors.cardText)
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
}

// MARK: - Preview

#Preview("Light Mode") {
    struct PreviewWrapper: View {
        @State private var targetAmount = "50000"
        @State private var currentAmount = "10000"
        @State private var selectedType: GoalType = .house
        @State private var hasTargetDate = true
        @State private var targetDate = Date()
        @State private var notes = ""
        @State private var accountName: String?

        var body: some View {
            ScrollView {
                GoalDetailsFormView(
                    targetAmountText: $targetAmount,
                    currentAmountText: $currentAmount,
                    selectedType: $selectedType,
                    hasTargetDate: $hasTargetDate,
                    targetDate: $targetDate,
                    notes: $notes,
                    accountName: $accountName,
                    targetAmountError: nil
                )
            }
            .background(Color(.systemGroupedBackground))
        }
    }
    return PreviewWrapper()
}

#Preview("With Error") {
    struct PreviewWrapper: View {
        @State private var targetAmount = ""
        @State private var currentAmount = ""
        @State private var selectedType: GoalType = .custom
        @State private var hasTargetDate = false
        @State private var targetDate = Date()
        @State private var notes = ""
        @State private var accountName: String?

        var body: some View {
            ScrollView {
                GoalDetailsFormView(
                    targetAmountText: $targetAmount,
                    currentAmountText: $currentAmount,
                    selectedType: $selectedType,
                    hasTargetDate: $hasTargetDate,
                    targetDate: $targetDate,
                    notes: $notes,
                    accountName: $accountName,
                    targetAmountError: "Target amount is required"
                )
            }
            .background(Color(.systemGroupedBackground))
        }
    }
    return PreviewWrapper()
}

#Preview("Dark Mode") {
    struct PreviewWrapper: View {
        @State private var targetAmount = "100000"
        @State private var currentAmount = "25000"
        @State private var selectedType: GoalType = .house
        @State private var hasTargetDate = true
        @State private var targetDate = Date()
        @State private var notes = "Saving for our dream home down payment"
        @State private var accountName: String? = "Savings Account"

        var body: some View {
            ScrollView {
                GoalDetailsFormView(
                    targetAmountText: $targetAmount,
                    currentAmountText: $currentAmount,
                    selectedType: $selectedType,
                    hasTargetDate: $hasTargetDate,
                    targetDate: $targetDate,
                    notes: $notes,
                    accountName: $accountName,
                    targetAmountError: nil
                )
            }
            .background(Color(.systemGroupedBackground))
            .preferredColorScheme(.dark)
        }
    }
    return PreviewWrapper()
}
