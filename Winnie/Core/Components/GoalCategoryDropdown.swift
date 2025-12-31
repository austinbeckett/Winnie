import SwiftUI

/// A dropdown menu for selecting a goal category.
///
/// Displays as a styled button that looks like a text field. When tapped,
/// shows a menu with all GoalType options (text only, no icons).
///
/// Usage:
/// ```swift
/// @State private var selectedType: GoalType = .house
///
/// GoalCategoryDropdown(selectedType: $selectedType)
/// ```
struct GoalCategoryDropdown: View {
    @Binding var selectedType: GoalType
    let label: String

    @Environment(\.colorScheme) private var colorScheme

    init(
        _ label: String = "Category",
        selectedType: Binding<GoalType>
    ) {
        self.label = label
        self._selectedType = selectedType
    }

    var body: some View {
        VStack(alignment: .leading, spacing: WinnieSpacing.xs) {
            Text(label)
                .font(WinnieTypography.bodyS())
                .fontWeight(.medium)
                .foregroundStyle(WinnieColors.secondaryText(for: colorScheme))

            Menu {
                ForEach(GoalType.allCases) { type in
                    Button(type.displayName) {
                        selectedType = type
                    }
                }
            } label: {
                HStack {
                    Text(selectedType.displayName)
                        .font(WinnieTypography.bodyM())
                        .foregroundStyle(WinnieColors.primaryText(for: colorScheme))

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
    }
}

// MARK: - Previews

#Preview("Category Dropdown") {
    struct PreviewWrapper: View {
        @State private var selectedType: GoalType = .house

        var body: some View {
            VStack(spacing: 24) {
                GoalCategoryDropdown(selectedType: $selectedType)

                Text("Selected: \(selectedType.displayName)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding()
        }
    }

    return PreviewWrapper()
}

#Preview("Category Dropdown - Dark") {
    struct PreviewWrapper: View {
        @State private var selectedType: GoalType = .vacation

        var body: some View {
            VStack(spacing: 24) {
                GoalCategoryDropdown(selectedType: $selectedType)

                Text("Selected: \(selectedType.displayName)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding()
            .background(WinnieColors.ink)
        }
    }

    return PreviewWrapper()
        .preferredColorScheme(.dark)
}
