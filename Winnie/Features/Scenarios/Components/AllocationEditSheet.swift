//
//  AllocationEditSheet.swift
//  Winnie
//
//  Created by Claude Code on 2026-01-08.
//

import SwiftUI

/// A sheet for quickly editing a single goal's allocation.
///
/// Provides a slider and text input for adjusting the monthly allocation
/// without opening the full scenario editor.
struct AllocationEditSheet: View {
    let goal: Goal
    let currentAllocation: Decimal
    let maxAllocation: Decimal
    let onSave: (Decimal) async -> Void

    @State private var amount: Decimal
    @State private var isSaving = false
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme

    init(
        goal: Goal,
        currentAllocation: Decimal,
        maxAllocation: Decimal,
        onSave: @escaping (Decimal) async -> Void
    ) {
        self.goal = goal
        self.currentAllocation = currentAllocation
        self.maxAllocation = maxAllocation
        self.onSave = onSave
        self._amount = State(initialValue: currentAllocation)
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: WinnieSpacing.l) {
                // Goal header
                goalHeader

                Spacer()

                // Amount display
                amountDisplay

                // Slider
                allocationSlider

                // Quick amount buttons
                quickAmountButtons

                Spacer()

                // Save button
                WinnieButton(
                    "Save Allocation",
                    style: .primary,
                    isLoading: isSaving,
                    isEnabled: !isSaving
                ) {
                    Task {
                        isSaving = true
                        await onSave(amount)
                        isSaving = false
                        dismiss()
                    }
                }
            }
            .padding(WinnieSpacing.l)
            .background(WinnieColors.background(for: colorScheme))
            .navigationTitle("Edit Allocation")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
        .presentationDetents([.medium])
    }

    // MARK: - Goal Header

    private var goalHeader: some View {
        HStack(spacing: WinnieSpacing.m) {
            // Goal icon - uses user's custom icon if set
            Image(systemName: goal.displayIcon)
                .font(.system(size: 24))
                .foregroundColor(goal.displayColor)
                .frame(width: 48, height: 48)
                .background(goal.displayColor.opacity(0.15))
                .clipShape(RoundedRectangle(cornerRadius: 12))

            VStack(alignment: .leading, spacing: 2) {
                Text(goal.name)
                    .font(WinnieTypography.headlineS())
                    .foregroundColor(WinnieColors.primaryText(for: colorScheme))

                Text(Formatting.currency(goal.targetAmount) + " goal")
                    .font(WinnieTypography.bodyS())
                    .foregroundColor(WinnieColors.secondaryText(for: colorScheme))
            }

            Spacer()
        }
    }

    // MARK: - Amount Display

    private var amountDisplay: some View {
        VStack(spacing: WinnieSpacing.xs) {
            Text(Formatting.currency(amount))
                .font(WinnieTypography.financialXL())
                .foregroundColor(WinnieColors.primaryText(for: colorScheme))

            Text("per month")
                .font(WinnieTypography.bodyS())
                .foregroundColor(WinnieColors.secondaryText(for: colorScheme))
        }
    }

    // MARK: - Allocation Slider

    private var allocationSlider: some View {
        VStack(spacing: WinnieSpacing.s) {
            // Slider
            Slider(
                value: Binding(
                    get: { Double(truncating: amount as NSNumber) },
                    set: { amount = Decimal($0) }
                ),
                in: 0...Double(truncating: maxAllocation as NSNumber),
                step: 50
            )
            .tint(goal.displayColor)

            // Min/Max labels
            HStack {
                Text("$0")
                    .font(WinnieTypography.caption())
                    .foregroundColor(WinnieColors.tertiaryText(for: colorScheme))

                Spacer()

                Text(Formatting.currency(maxAllocation))
                    .font(WinnieTypography.caption())
                    .foregroundColor(WinnieColors.tertiaryText(for: colorScheme))
            }
        }
    }

    // MARK: - Quick Amount Buttons

    private var quickAmountButtons: some View {
        HStack(spacing: WinnieSpacing.s) {
            quickAmountButton(increment: -100)
            quickAmountButton(increment: -50)
            quickAmountButton(increment: 50)
            quickAmountButton(increment: 100)
        }
    }

    private func quickAmountButton(increment: Int) -> some View {
        Button {
            let newAmount = amount + Decimal(increment)
            amount = max(0, min(newAmount, maxAllocation))
        } label: {
            Text(increment > 0 ? "+\(increment)" : "\(increment)")
                .font(WinnieTypography.bodyS())
                .fontWeight(.medium)
                .foregroundColor(WinnieColors.primaryText(for: colorScheme))
                .frame(maxWidth: .infinity)
                .padding(.vertical, WinnieSpacing.s)
                .background(WinnieColors.tertiaryText(for: colorScheme).opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Previews

#Preview("Edit Allocation") {
    AllocationEditSheet(
        goal: .sampleHouse,
        currentAllocation: 1500,
        maxAllocation: 5000,
        onSave: { _ in }
    )
}
