import SwiftUI

/// A TextField styled for use inside WinnieCard containers.
/// Automatically uses ivory text and placeholder colors for visibility on dark backgrounds.
///
/// Usage:
/// ```swift
/// WinnieCard {
///     WinnieCardTextField(placeholder: "Enter name", text: $name)
/// }
/// ```
struct WinnieCardTextField: View {
    let placeholder: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default
    var alignment: TextAlignment = .leading

    var body: some View {
        TextField(
            "",
            text: $text,
            prompt: Text(placeholder)
                .foregroundColor(WinnieColors.cardText.opacity(WinnieColors.Opacity.tertiary))
        )
        .font(WinnieTypography.bodyS())
        .foregroundColor(WinnieColors.cardText)
        .keyboardType(keyboardType)
        .multilineTextAlignment(alignment)
    }
}

/// A number input field styled for use inside WinnieCard containers.
/// Shows empty field when value is 0, with "0" as placeholder.
/// Includes optional prefix (default "$") and styled container.
///
/// Usage:
/// ```swift
/// WinnieCard {
///     WinnieCardNumberField(value: $amount)
///         .frame(width: 80)
///
///     // With onChange callback
///     WinnieCardNumberField(value: $amount) {
///         recalculateTotal()
///     }
/// }
/// ```
struct WinnieCardNumberField: View {
    @Binding var value: Decimal
    var placeholder: String = "0"
    var prefix: String? = "$"
    var showContainer: Bool = true
    var onChange: (() -> Void)?

    /// Creates a number field with optional onChange callback.
    init(
        value: Binding<Decimal>,
        placeholder: String = "0",
        prefix: String? = "$",
        showContainer: Bool = true,
        onChange: (() -> Void)? = nil
    ) {
        self._value = value
        self.placeholder = placeholder
        self.prefix = prefix
        self.showContainer = showContainer
        self.onChange = onChange
    }

    var body: some View {
        let content = HStack(spacing: 2) {
            if let prefix {
                Text(prefix)
                    .font(WinnieTypography.bodyS())
                    .foregroundColor(WinnieColors.cardText)
            }

            TextField(
                "",
                text: Binding(
                    get: {
                        value == 0 ? "" : "\(NSDecimalNumber(decimal: value).intValue)"
                    },
                    set: { newValue in
                        if let intValue = Int(newValue) {
                            value = Decimal(intValue)
                        } else if newValue.isEmpty {
                            value = 0
                        }
                        onChange?()
                    }
                ),
                prompt: Text(placeholder)
                    .foregroundColor(WinnieColors.cardText.opacity(WinnieColors.Opacity.tertiary))
            )
            .font(WinnieTypography.bodyS())
            .foregroundColor(WinnieColors.cardText)
            .keyboardType(.numberPad)
            .multilineTextAlignment(.trailing)
        }

        if showContainer {
            content
                .padding(.horizontal, WinnieSpacing.xs)
                .padding(.vertical, 6)
                .background(WinnieColors.cardText.opacity(0.15))
                .clipShape(RoundedRectangle(cornerRadius: 8))
        } else {
            content
        }
    }
}

// MARK: - Previews

#Preview("Card TextField") {
    VStack(spacing: WinnieSpacing.m) {
        WinnieCard {
            VStack(alignment: .leading, spacing: WinnieSpacing.s) {
                Text("Text Field Example")
                    .font(WinnieTypography.headlineM())
                    .foregroundColor(WinnieColors.cardText)

                WinnieCardTextField(
                    placeholder: "Enter your name",
                    text: .constant("")
                )

                WinnieCardTextField(
                    placeholder: "Enter your name",
                    text: .constant("John Doe")
                )
            }
        }
    }
    .padding(WinnieSpacing.l)
    .background(WinnieColors.ivory)
}

#Preview("Number Field") {
    VStack(spacing: WinnieSpacing.m) {
        WinnieCard {
            VStack(alignment: .leading, spacing: WinnieSpacing.s) {
                Text("Number Field Examples")
                    .font(WinnieTypography.headlineM())
                    .foregroundColor(WinnieColors.cardText)

                HStack {
                    Text("Rent")
                        .font(WinnieTypography.bodyS())
                        .foregroundColor(WinnieColors.cardText)
                    Spacer()
                    WinnieCardNumberField(value: .constant(0))
                        .frame(width: 80)
                }

                HStack {
                    Text("Utilities")
                        .font(WinnieTypography.bodyS())
                        .foregroundColor(WinnieColors.cardText)
                    Spacer()
                    WinnieCardNumberField(value: .constant(150))
                        .frame(width: 80)
                }
            }
        }
    }
    .padding(WinnieSpacing.l)
    .background(WinnieColors.ivory)
}
