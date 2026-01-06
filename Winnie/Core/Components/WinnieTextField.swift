import SwiftUI

/// Input type variants for WinnieTextField
enum WinnieTextFieldType {
    case text           // Standard text input
    case number         // Whole numbers only
    case decimal        // Decimal numbers (for currency amounts)
    case email          // Email with appropriate keyboard
}

/// A styled text input following Winnie design system.
///
/// Usage:
/// ```swift
/// @State private var goalName = ""
/// @State private var targetAmount = ""
///
/// WinnieTextField(
///     "Goal Name",
///     text: $goalName,
///     placeholder: "e.g., Dream Home"
/// )
///
/// WinnieTextField(
///     "Target Amount",
///     text: $targetAmount,
///     placeholder: "$0",
///     type: .decimal,
///     error: targetAmount.isEmpty ? "Amount is required" : nil
/// )
/// ```
struct WinnieTextField: View {
    let label: String
    @Binding var text: String
    let placeholder: String
    let type: WinnieTextFieldType
    let error: String?

    @Environment(\.colorScheme) private var colorScheme
    @FocusState private var isFocused: Bool

    init(
        _ label: String,
        text: Binding<String>,
        placeholder: String = "",
        type: WinnieTextFieldType = .text,
        error: String? = nil
    ) {
        self.label = label
        self._text = text
        self.placeholder = placeholder
        self.type = type
        self.error = error
    }

    var body: some View {
        VStack(alignment: .leading, spacing: WinnieSpacing.xs) {
            // Label
            Text(label)
                .font(WinnieTypography.bodyS())
                .fontWeight(.medium)
                .foregroundColor(WinnieColors.secondaryText(for: colorScheme))

            // Text field
            TextField(placeholder, text: $text)
                .font(WinnieTypography.bodyM())
                .foregroundColor(WinnieColors.cardText)
                .keyboardType(keyboardType)
                .textContentType(contentType)
                .textInputAutocapitalization(autocapitalization)
                .autocorrectionDisabled(type != .text)
                .focused($isFocused)
                .padding(.horizontal, WinnieSpacing.m)
                .frame(height: WinnieSpacing.inputHeight)
                .background(WinnieColors.cardBackground(for: colorScheme))
                .clipShape(RoundedRectangle(cornerRadius: WinnieSpacing.inputCornerRadius))
                .overlay(
                    RoundedRectangle(cornerRadius: WinnieSpacing.inputCornerRadius)
                        .stroke(borderColor, lineWidth: isFocused ? 2 : 1)
                )

            // Error message
            if let error, !error.isEmpty {
                Text(error)
                    .font(WinnieTypography.caption())
                    .foregroundColor(WinnieColors.error(for: colorScheme))
            }
        }
    }

    // MARK: - Keyboard Configuration

    private var keyboardType: UIKeyboardType {
        switch type {
        case .text:
            return .default
        case .number:
            return .numberPad
        case .decimal:
            return .decimalPad
        case .email:
            return .emailAddress
        }
    }

    private var contentType: UITextContentType? {
        switch type {
        case .email:
            return .emailAddress
        default:
            return nil
        }
    }

    private var autocapitalization: TextInputAutocapitalization {
        switch type {
        case .text:
            return .words
        case .email:
            return .never
        default:
            return .never
        }
    }

    // MARK: - Border Color

    private var borderColor: Color {
        if let error, !error.isEmpty {
            return WinnieColors.error(for: colorScheme)
        } else if isFocused {
            return WinnieColors.sweetSalmon
        } else {
            return WinnieColors.inputBorder(for: colorScheme)
        }
    }
}

// MARK: - Currency Text Field

/// A specialized text field for currency input with $ prefix.
///
/// Usage:
/// ```swift
/// @State private var amount = ""
///
/// WinnieCurrencyField(
///     "Target Amount",
///     text: $amount,
///     error: amount.isEmpty ? "Required" : nil
/// )
/// ```
struct WinnieCurrencyField: View {
    let label: String
    @Binding var text: String
    let error: String?

    @Environment(\.colorScheme) private var colorScheme
    @FocusState private var isFocused: Bool

    init(
        _ label: String,
        text: Binding<String>,
        error: String? = nil
    ) {
        self.label = label
        self._text = text
        self.error = error
    }

    var body: some View {
        VStack(alignment: .leading, spacing: WinnieSpacing.xs) {
            // Label
            Text(label)
                .font(WinnieTypography.bodyS())
                .fontWeight(.medium)
                .foregroundColor(WinnieColors.secondaryText(for: colorScheme))

            // Currency field with $ prefix
            HStack(spacing: WinnieSpacing.xs) {
                Text("$")
                    .font(WinnieTypography.financialM())
                    .foregroundColor(WinnieColors.cardText)

                TextField("0", text: $text)
                    .font(WinnieTypography.financialM())
                    .foregroundColor(WinnieColors.cardText)
                    .keyboardType(.numberPad)
                    .focused($isFocused)
            }
            .padding(.horizontal, WinnieSpacing.m)
            .frame(height: WinnieSpacing.inputHeight)
            .background(WinnieColors.cardBackground(for: colorScheme))
            .clipShape(RoundedRectangle(cornerRadius: WinnieSpacing.inputCornerRadius))
            .overlay(
                RoundedRectangle(cornerRadius: WinnieSpacing.inputCornerRadius)
                    .stroke(borderColor, lineWidth: isFocused ? 2 : 1)
            )

            // Error message
            if let error, !error.isEmpty {
                Text(error)
                    .font(WinnieTypography.caption())
                    .foregroundColor(WinnieColors.error(for: colorScheme))
            }
        }
    }

    private var borderColor: Color {
        if let error, !error.isEmpty {
            return WinnieColors.error(for: colorScheme)
        } else if isFocused {
            return WinnieColors.sweetSalmon
        } else {
            return WinnieColors.inputBorder(for: colorScheme)
        }
    }
}

// MARK: - Preview

#Preview("Text Fields") {
    ScrollView {
        VStack(spacing: WinnieSpacing.l) {
            WinnieTextField(
                "Goal Name",
                text: .constant("Dream Home"),
                placeholder: "Enter goal name"
            )

            WinnieTextField(
                "Email",
                text: .constant(""),
                placeholder: "you@example.com",
                type: .email
            )

            WinnieTextField(
                "Goal Name",
                text: .constant(""),
                placeholder: "Enter goal name",
                error: "Goal name is required"
            )

            WinnieCurrencyField(
                "Target Amount",
                text: .constant("50000")
            )

            WinnieCurrencyField(
                "Current Savings",
                text: .constant(""),
                error: "Amount is required"
            )
        }
        .padding(WinnieSpacing.l)
    }
    .background(WinnieColors.ivory)
}

#Preview("Dark Mode") {
    VStack(spacing: WinnieSpacing.l) {
        WinnieTextField(
            "Goal Name",
            text: .constant("Retirement Fund"),
            placeholder: "Enter goal name"
        )

        WinnieCurrencyField(
            "Target Amount",
            text: .constant("1000000")
        )
    }
    .padding(WinnieSpacing.l)
    .background(WinnieColors.carbonBlack)
    .preferredColorScheme(.dark)
}
