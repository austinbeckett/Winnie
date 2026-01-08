import SwiftUI

/// A color picker for selecting goal colors from a preset palette.
///
/// Usage:
/// ```swift
/// @State private var selectedColor = GoalPresetColor.coral.rawValue
///
/// GoalColorPicker(selectedHex: $selectedColor)
/// ```
struct GoalColorPicker: View {
    @Binding var selectedHex: String
    let label: String

    @Environment(\.colorScheme) private var colorScheme

    private let columns = [GridItem](repeating: GridItem(.flexible(), spacing: 12), count: 4)

    init(
        _ label: String = "Color",
        selectedHex: Binding<String>
    ) {
        self.label = label
        self._selectedHex = selectedHex
    }

    var body: some View {
        VStack(alignment: .leading, spacing: WinnieSpacing.s) {
            Text(label)
                .font(WinnieTypography.bodyS())
                .fontWeight(.medium)
                .foregroundStyle(WinnieColors.secondaryText(for: colorScheme))

            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(GoalPresetColor.allCases) { preset in
                    ColorCircle(
                        color: preset.color,
                        isSelected: selectedHex == preset.rawValue,
                        onTap: { selectedHex = preset.rawValue }
                    )
                }
            }
        }
    }
}

// MARK: - Color Circle Component

private struct ColorCircle: View {
    let color: Color
    let isSelected: Bool
    let onTap: () -> Void

    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        Button(action: onTap) {
            ZStack {
                Circle()
                    .fill(color)
                    .frame(width: 44, height: 44)

                if isSelected {
                    Circle()
                        .strokeBorder(WinnieColors.primaryText(for: colorScheme), lineWidth: 3)
                        .frame(width: 44, height: 44)

                    Image(systemName: "checkmark")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(checkmarkColor)
                }
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel(accessibilityLabel)
    }

    /// Determine checkmark color based on background luminance
    private var checkmarkColor: Color {
        // For darker colors (teal), use light checkmark
        if color == GoalPresetColor.teal.color {
            return WinnieColors.ivory
        }
        // For lighter colors, use dark checkmark
        return WinnieColors.carbonBlack
    }

    private var accessibilityLabel: String {
        let colorName = GoalPresetColor.allCases.first { $0.color == color }?.displayName ?? "Color"
        return isSelected ? "\(colorName), selected" : colorName
    }
}

// MARK: - Previews

#Preview("Goal Color Picker") {
    struct PreviewWrapper: View {
        @State private var selectedHex = GoalPresetColor.coral.rawValue

        var body: some View {
            VStack(spacing: 24) {
                GoalColorPicker(selectedHex: $selectedHex)

                Text("Selected: \(selectedHex)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding()
            .background(WinnieColors.ivory)
        }
    }

    return PreviewWrapper()
}

#Preview("Goal Color Picker - Dark") {
    struct PreviewWrapper: View {
        @State private var selectedHex = GoalPresetColor.teal.rawValue

        var body: some View {
            VStack(spacing: 24) {
                GoalColorPicker(selectedHex: $selectedHex)

                Text("Selected: \(selectedHex)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding()
            .background(WinnieColors.carbonBlack)
        }
    }

    return PreviewWrapper()
        .preferredColorScheme(.dark)
}
