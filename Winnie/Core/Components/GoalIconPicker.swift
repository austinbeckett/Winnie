import SwiftUI

/// A grid picker for selecting a goal icon from a curated set of SF Symbols.
///
/// Includes an "Auto" option that signals the icon should be derived from the goal name.
/// The `selectedIcon` binding uses `nil` to represent the auto state.
///
/// Usage:
/// ```swift
/// @State private var selectedIcon: String? = nil  // nil = auto mode
///
/// GoalIconPicker(
///     selectedIcon: $selectedIcon,
///     autoIcon: GoalIconMapper.icon(for: goalName)
/// )
/// ```
struct GoalIconPicker: View {
    /// The currently selected icon, or nil for auto mode.
    @Binding var selectedIcon: String?

    /// The auto-generated icon based on goal name (shown in auto mode preview).
    let autoIcon: String

    let label: String

    @Environment(\.colorScheme) private var colorScheme

    /// Curated set of icons for manual selection.
    private static let availableIcons: [(icon: String, label: String)] = [
        // Home & Property
        ("house.fill", "House"),
        ("building.2.fill", "Building"),
        ("key.fill", "Keys"),

        // Travel & Transport
        ("airplane", "Travel"),
        ("car.fill", "Car"),
        ("beach.umbrella.fill", "Beach"),

        // Finance & Growth
        ("chart.line.uptrend.xyaxis", "Growth"),
        ("banknote.fill", "Savings"),
        ("shield.fill", "Shield"),

        // Family & Life
        ("heart.fill", "Heart"),
        ("figure.2.and.child.holdinghands", "Family"),
        ("gift.fill", "Gift"),

        // Education & Career
        ("graduationcap.fill", "Education"),
        ("briefcase.fill", "Business"),
        ("lightbulb.fill", "Idea"),

        // Lifestyle
        ("pawprint.fill", "Pet"),
        ("sparkles", "Dream"),
        ("star.fill", "Star"),
        ("target", "Goal"),
        ("birthday.cake.fill", "Celebration")
    ]

    private let columns = [GridItem](repeating: GridItem(.flexible(), spacing: 12), count: 5)

    init(
        _ label: String = "Icon",
        selectedIcon: Binding<String?>,
        autoIcon: String
    ) {
        self.label = label
        self._selectedIcon = selectedIcon
        self.autoIcon = autoIcon
    }

    var body: some View {
        VStack(alignment: .leading, spacing: WinnieSpacing.s) {
            Text(label)
                .font(WinnieTypography.bodyS())
                .fontWeight(.medium)
                .foregroundStyle(WinnieColors.secondaryText(for: colorScheme))

            LazyVGrid(columns: columns, spacing: 12) {
                // Auto option first
                IconButton(
                    icon: autoIcon,
                    label: "Auto",
                    isSelected: selectedIcon == nil,
                    isAuto: true,
                    onTap: { selectedIcon = nil }
                )

                // Manual icon options
                ForEach(Self.availableIcons, id: \.icon) { item in
                    IconButton(
                        icon: item.icon,
                        label: item.label,
                        isSelected: selectedIcon == item.icon,
                        isAuto: false,
                        onTap: { selectedIcon = item.icon }
                    )
                }
            }
        }
    }
}

// MARK: - Icon Button Component

private struct IconButton: View {
    let icon: String
    let label: String
    let isSelected: Bool
    let isAuto: Bool
    let onTap: () -> Void

    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        Button(action: onTap) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected
                          ? WinnieColors.amethystSmoke
                          : WinnieColors.cardBackground(for: colorScheme))
                    .frame(width: 52, height: 52)

                VStack(spacing: 2) {
                    Image(systemName: icon)
                        .font(.system(size: 20))
                        .foregroundStyle(isSelected ? .white : WinnieColors.primaryText(for: colorScheme))

                    if isAuto {
                        Text("Auto")
                            .font(.system(size: 8, weight: .medium))
                            .foregroundStyle(isSelected ? .white.opacity(0.8) : WinnieColors.tertiaryText(for: colorScheme))
                    }
                }

                if isSelected {
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(WinnieColors.primaryText(for: colorScheme), lineWidth: 2)
                        .frame(width: 52, height: 52)
                }
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel(isAuto ? "Auto icon based on goal name" : label)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

// MARK: - Previews

#Preview("Icon Picker - Auto Selected") {
    struct PreviewWrapper: View {
        @State private var selectedIcon: String? = nil

        var body: some View {
            VStack(spacing: 24) {
                GoalIconPicker(
                    selectedIcon: $selectedIcon,
                    autoIcon: "house.fill"
                )

                Text("Selected: \(selectedIcon ?? "Auto")")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding()
        }
    }

    return PreviewWrapper()
}

#Preview("Icon Picker - Manual Selected") {
    struct PreviewWrapper: View {
        @State private var selectedIcon: String? = "heart.fill"

        var body: some View {
            VStack(spacing: 24) {
                GoalIconPicker(
                    selectedIcon: $selectedIcon,
                    autoIcon: "star.fill"
                )

                Text("Selected: \(selectedIcon ?? "Auto")")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding()
        }
    }

    return PreviewWrapper()
}

#Preview("Icon Picker - Dark") {
    struct PreviewWrapper: View {
        @State private var selectedIcon: String? = "airplane"

        var body: some View {
            VStack(spacing: 24) {
                GoalIconPicker(
                    selectedIcon: $selectedIcon,
                    autoIcon: "star.fill"
                )

                Text("Selected: \(selectedIcon ?? "Auto")")
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
