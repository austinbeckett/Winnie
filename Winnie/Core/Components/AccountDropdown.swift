import SwiftUI

/// Predefined account type options
enum AccountType: String, CaseIterable, Identifiable {
    case savings = "Savings Account"
    case checking = "Checking Account"
    case brokerage = "Brokerage Account"
    case moneyMarket = "Money Market"
    case custom = "Custom..."

    var id: String { rawValue }
}

/// A dropdown menu for selecting an account type or entering a custom account name.
///
/// Displays predefined account options (Savings, Checking, etc.) plus a "Custom" option
/// that reveals a text field for entering a custom account name.
///
/// ## Usage
/// ```swift
/// @State private var accountName: String?
///
/// AccountDropdown(selectedAccount: $accountName)
/// ```
struct AccountDropdown: View {
    @Binding var selectedAccount: String?
    let label: String

    @Environment(\.colorScheme) private var colorScheme
    @State private var isCustom = false
    @State private var customText = ""
    @FocusState private var isCustomFieldFocused: Bool

    init(
        _ label: String = "Account",
        selectedAccount: Binding<String?>
    ) {
        self.label = label
        self._selectedAccount = selectedAccount
    }

    var body: some View {
        VStack(alignment: .leading, spacing: WinnieSpacing.xs) {
            Text(label)
                .font(WinnieTypography.bodyS())
                .fontWeight(.medium)
                .foregroundStyle(WinnieColors.secondaryText(for: colorScheme))

            if isCustom {
                customTextField
            } else {
                dropdownMenu
            }
        }
        .onAppear {
            initializeState()
        }
    }

    // MARK: - Dropdown Menu

    private var dropdownMenu: some View {
        Menu {
            ForEach(AccountType.allCases) { type in
                Button(type.rawValue) {
                    handleSelection(type)
                }
            }
        } label: {
            HStack {
                Text(displayText)
                    .font(WinnieTypography.bodyM())
                    .foregroundStyle(
                        selectedAccount == nil
                            ? WinnieColors.tertiaryText(for: colorScheme)
                            : WinnieColors.primaryText(for: colorScheme)
                    )

                Spacer()

                Image(systemName: "chevron.down")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(WinnieColors.secondaryText(for: colorScheme))
            }
            .padding(.horizontal, WinnieSpacing.m)
            .frame(height: WinnieSpacing.inputHeight)
            .background(WinnieColors.cardBackground(for: colorScheme))
            .clipShape(RoundedRectangle(cornerRadius: WinnieSpacing.inputCornerRadius))
            .overlay(
                RoundedRectangle(cornerRadius: WinnieSpacing.inputCornerRadius)
                    .stroke(WinnieColors.inputBorder(for: colorScheme), lineWidth: 1)
            )
        }
    }

    // MARK: - Custom Text Field

    private var customTextField: some View {
        HStack(spacing: WinnieSpacing.s) {
            TextField("Enter account name", text: $customText)
                .font(WinnieTypography.bodyM())
                .foregroundStyle(WinnieColors.primaryText(for: colorScheme))
                .focused($isCustomFieldFocused)
                .onSubmit {
                    commitCustomText()
                }
                .onChange(of: customText) { _, newValue in
                    selectedAccount = newValue.isEmpty ? nil : newValue
                }

            Button {
                cancelCustom()
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .foregroundStyle(WinnieColors.tertiaryText(for: colorScheme))
            }
        }
        .padding(.horizontal, WinnieSpacing.m)
        .frame(height: WinnieSpacing.inputHeight)
        .background(WinnieColors.cardBackground(for: colorScheme))
        .clipShape(RoundedRectangle(cornerRadius: WinnieSpacing.inputCornerRadius))
        .overlay(
            RoundedRectangle(cornerRadius: WinnieSpacing.inputCornerRadius)
                .stroke(
                    isCustomFieldFocused
                        ? WinnieColors.amethystSmoke
                        : WinnieColors.inputBorder(for: colorScheme),
                    lineWidth: isCustomFieldFocused ? 2 : 1
                )
        )
        .onAppear {
            isCustomFieldFocused = true
        }
    }

    // MARK: - Helpers

    private var displayText: String {
        if let account = selectedAccount, !account.isEmpty {
            return account
        }
        return "Select account"
    }

    private func initializeState() {
        guard let account = selectedAccount else { return }

        // Check if it's a predefined account type
        let isPredefined = AccountType.allCases
            .filter { $0 != .custom }
            .contains { $0.rawValue == account }

        if !isPredefined && !account.isEmpty {
            // It's a custom value
            isCustom = true
            customText = account
        }
    }

    private func handleSelection(_ type: AccountType) {
        if type == .custom {
            isCustom = true
            customText = ""
            selectedAccount = nil
        } else {
            selectedAccount = type.rawValue
        }
    }

    private func cancelCustom() {
        isCustom = false
        customText = ""
        selectedAccount = nil
        isCustomFieldFocused = false
    }

    private func commitCustomText() {
        if customText.isEmpty {
            cancelCustom()
        } else {
            selectedAccount = customText
            isCustomFieldFocused = false
        }
    }
}

// MARK: - Previews

#Preview("Account Dropdown") {
    struct PreviewWrapper: View {
        @State private var account: String?

        var body: some View {
            VStack(spacing: 24) {
                AccountDropdown(selectedAccount: $account)

                Text("Selected: \(account ?? "None")")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding()
        }
    }

    return PreviewWrapper()
}

#Preview("With Selection") {
    struct PreviewWrapper: View {
        @State private var account: String? = "Savings Account"

        var body: some View {
            VStack(spacing: 24) {
                AccountDropdown(selectedAccount: $account)

                Text("Selected: \(account ?? "None")")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding()
        }
    }

    return PreviewWrapper()
}

#Preview("Custom Account") {
    struct PreviewWrapper: View {
        @State private var account: String? = "My Ally HYSA"

        var body: some View {
            VStack(spacing: 24) {
                AccountDropdown(selectedAccount: $account)

                Text("Selected: \(account ?? "None")")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding()
        }
    }

    return PreviewWrapper()
}

#Preview("Dark Mode") {
    struct PreviewWrapper: View {
        @State private var account: String?

        var body: some View {
            VStack(spacing: 24) {
                AccountDropdown(selectedAccount: $account)
            }
            .padding()
            .background(WinnieColors.ink)
        }
    }

    return PreviewWrapper()
        .preferredColorScheme(.dark)
}
