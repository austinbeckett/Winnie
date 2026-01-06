import SwiftUI

/// A styled currency input field following Winnie design system.
///
/// Style A: "Contained Card" - Input inside a rounded card with all elements
/// properly aligned and a clear tap target.
///
/// Usage:
/// ```swift
/// @State private var amount: Decimal = 0
/// @State private var text: String = ""
///
/// WinnieCurrencyInput(
///     value: $amount,
///     text: $text,
///     placeholder: "0",
///     suffix: "/mo"
/// )
/// ```
struct WinnieCurrencyInput: View {

    /// The Decimal value (for data binding)
    @Binding var value: Decimal

    /// The raw text string (for TextField binding)
    @Binding var text: String

    /// Placeholder text when empty
    var placeholder: String = "0"

    /// Optional suffix (e.g., "/mo", "/year")
    var suffix: String? = nil

    /// Whether to use accent color for the value (e.g., for savings display)
    var accentValue: Bool = false

    @Environment(\.colorScheme) private var colorScheme
    @FocusState private var isFocused: Bool

    var body: some View {
        HStack(spacing: WinnieSpacing.xs) {
            // Dollar sign
            Text("$")
                .font(WinnieTypography.financialL())
                .foregroundColor(isFocused ? WinnieColors.accent : WinnieColors.cardText.opacity(0.5))

            // Text field
            TextField("", text: $text, prompt: Text(placeholder).foregroundColor(WinnieColors.cardText.opacity(0.5)))
                .font(WinnieTypography.financialL())
                .foregroundColor(accentValue ? WinnieColors.accent : WinnieColors.cardText)
                .keyboardType(.numberPad)
                .multilineTextAlignment(.leading)
                .focused($isFocused)
                .onChange(of: text) { _, newValue in
                    // Filter to digits only
                    let filtered = newValue.filter { $0.isNumber }
                    if filtered != newValue {
                        text = filtered
                    }
                    // Update decimal value
                    if let decimal = Decimal(string: filtered) {
                        value = decimal
                    } else {
                        value = 0
                    }
                }

            Spacer()

            // Suffix (e.g., "/mo")
            if let suffix {
                Text(suffix)
                    .font(WinnieTypography.bodyL())
                    .foregroundColor(WinnieColors.cardText.opacity(0.5))
            }
        }
        .padding(.horizontal, WinnieSpacing.l)
        .padding(.vertical, WinnieSpacing.m)
        .background(WinnieColors.cardBackground(for: colorScheme))
        .clipShape(RoundedRectangle(cornerRadius: WinnieSpacing.cardCornerRadius))
        .overlay(
            RoundedRectangle(cornerRadius: WinnieSpacing.cardCornerRadius)
                .stroke(
                    isFocused ? WinnieColors.accent : WinnieColors.tertiaryText(for: colorScheme).opacity(0.3),
                    lineWidth: isFocused ? 2 : 1
                )
        )
        .shadow(
            color: WinnieColors.cardShadow(for: colorScheme),
            radius: 4,
            x: 0,
            y: 2
        )
        .animation(.easeInOut(duration: 0.15), value: isFocused)
        .onTapGesture {
            isFocused = true
        }
    }

    /// Programmatically focus the input
    func focus() {
        isFocused = true
    }
}

// MARK: - Convenience Initializer

extension WinnieCurrencyInput {
    /// Creates a currency input with a default suffix of "/mo"
    static func monthly(
        value: Binding<Decimal>,
        text: Binding<String>,
        accentValue: Bool = false
    ) -> WinnieCurrencyInput {
        WinnieCurrencyInput(
            value: value,
            text: text,
            suffix: "/mo",
            accentValue: accentValue
        )
    }
}

// MARK: - Previews

#Preview("Default") {
    VStack(spacing: WinnieSpacing.l) {
        WinnieCurrencyInput(
            value: .constant(7500),
            text: .constant("7500"),
            suffix: "/mo"
        )

        WinnieCurrencyInput(
            value: .constant(0),
            text: .constant(""),
            suffix: "/mo"
        )
    }
    .padding(WinnieSpacing.l)
    .background(WinnieColors.ivory)
}

#Preview("Accent Value") {
    WinnieCurrencyInput(
        value: .constant(3175),
        text: .constant("3175"),
        suffix: "/mo",
        accentValue: true
    )
    .padding(WinnieSpacing.l)
    .background(WinnieColors.ivory)
}

#Preview("Dark Mode") {
    VStack(spacing: WinnieSpacing.l) {
        WinnieCurrencyInput(
            value: .constant(7500),
            text: .constant("7500"),
            suffix: "/mo"
        )

        WinnieCurrencyInput(
            value: .constant(3175),
            text: .constant("3175"),
            suffix: "/mo",
            accentValue: true
        )
    }
    .padding(WinnieSpacing.l)
    .background(WinnieColors.carbonBlack)
    .preferredColorScheme(.dark)
}
