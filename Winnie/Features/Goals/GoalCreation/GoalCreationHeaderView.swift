import SwiftUI

/// The accent-colored header for goal creation with dynamic icon and name field.
///
/// **How It Works:**
/// - Displays a colored background based on selectedColor
/// - Shows a large icon (64x64) that updates based on goal name or manual selection
/// - In Phase 2, the icon is tappable (shows pencil badge) to open customization
/// - Contains a text field for entering/editing the goal name
///
/// **Usage:**
/// ```swift
/// GoalCreationHeaderView(
///     goalName: $goalName,
///     isFocused: $isNameFieldFocused,
///     selectedIcon: selectedIcon,
///     selectedColor: selectedColor,
///     isCustomizable: phase == .detailsEntry,
///     onCustomizeTapped: { showAppearanceSheet = true }
/// )
/// ```
struct GoalCreationHeaderView: View {
    @Binding var goalName: String
    var isFocused: FocusState<Bool>.Binding

    /// The manually selected icon, or nil for auto mode
    let selectedIcon: String?

    /// The selected goal color
    let selectedColor: GoalPresetColor

    /// Whether the icon is tappable (true in Phase 2)
    let isCustomizable: Bool

    /// Callback when the icon is tapped for customization
    let onCustomizeTapped: (() -> Void)?

    @Environment(\.colorScheme) private var colorScheme

    /// Compute the current icon - use selected if available, otherwise auto-generate
    private var currentIcon: String {
        selectedIcon ?? GoalIconMapper.icon(for: goalName)
    }

    /// Text color for the header - snow in light mode for contrast, ink in dark mode
    private var headerTextColor: Color {
        colorScheme == .light ? WinnieColors.snow : WinnieColors.ink
    }

    // Convenience initializer for backward compatibility (Phase 1)
    init(
        goalName: Binding<String>,
        isFocused: FocusState<Bool>.Binding,
        selectedIcon: String? = nil,
        selectedColor: GoalPresetColor = .amethyst,
        isCustomizable: Bool = false,
        onCustomizeTapped: (() -> Void)? = nil
    ) {
        self._goalName = goalName
        self.isFocused = isFocused
        self.selectedIcon = selectedIcon
        self.selectedColor = selectedColor
        self.isCustomizable = isCustomizable
        self.onCustomizeTapped = onCustomizeTapped
    }

    var body: some View {
        HStack(spacing: WinnieSpacing.m) {
            // Icon container (tappable in Phase 2)
            if isCustomizable {
                Button(action: { onCustomizeTapped?() }) {
                    iconContainer
                }
                .buttonStyle(.plain)
            } else {
                iconContainer
            }

            // Text field
            nameTextField
        }
        .padding(.horizontal, WinnieSpacing.screenMarginMobile)
        .padding(.top, WinnieSpacing.xxl)
        .padding(.bottom, WinnieSpacing.xl)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(selectedColor.color)
    }

    // MARK: - Icon Container

    private var iconContainer: some View {
        ZStack(alignment: .bottomTrailing) {
            Image(systemName: currentIcon)
                .font(.system(size: WinnieSpacing.iconSizeL, weight: .medium))
                .foregroundColor(selectedColor.color)
                .frame(width: 64, height: 64)
                .background(WinnieColors.cardBackground(for: colorScheme))
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(WinnieColors.snow, lineWidth: 3)
                )
                .shadow(color: WinnieColors.ink.opacity(0.1), radius: 4, y: 2)
                .contentTransition(.symbolEffect(.replace))
                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: currentIcon)

            // Pencil badge (only in Phase 2)
            if isCustomizable {
                pencilBadge
            }
        }
    }

    // MARK: - Pencil Badge

    private var pencilBadge: some View {
        Image(systemName: "pencil")
            .font(.system(size: 10, weight: .bold))
            .foregroundColor(WinnieColors.contrastText)
            .frame(width: 22, height: 22)
            .background(WinnieColors.ink.opacity(0.7))
            .clipShape(Circle())
            .overlay(
                Circle()
                    .stroke(WinnieColors.snow, lineWidth: 2)
            )
            .offset(x: 4, y: 4)
    }

    // MARK: - Name Text Field

    private var nameTextField: some View {
        TextField("What are you saving for?", text: $goalName)
            .font(WinnieTypography.headlineM())
            .foregroundColor(headerTextColor)
            .tint(headerTextColor)
            .focused(isFocused)
            .textInputAutocapitalization(.words)
            .autocorrectionDisabled(false)
    }
}

// MARK: - Preview

#Preview("Phase 1 - Empty") {
    struct PreviewWrapper: View {
        @State private var goalName = ""
        @FocusState private var isFocused: Bool

        var body: some View {
            VStack(spacing: 0) {
                GoalCreationHeaderView(
                    goalName: $goalName,
                    isFocused: $isFocused
                )
                Spacer()
            }
            .background(Color(.systemGroupedBackground))
        }
    }
    return PreviewWrapper()
}

#Preview("Phase 1 - With Name") {
    struct PreviewWrapper: View {
        @State private var goalName = "Down Payment"
        @FocusState private var isFocused: Bool

        var body: some View {
            VStack(spacing: 0) {
                GoalCreationHeaderView(
                    goalName: $goalName,
                    isFocused: $isFocused
                )
                Spacer()
            }
            .background(Color(.systemGroupedBackground))
        }
    }
    return PreviewWrapper()
}

#Preview("Phase 2 - Customizable") {
    struct PreviewWrapper: View {
        @State private var goalName = "Dream Vacation"
        @FocusState private var isFocused: Bool

        var body: some View {
            VStack(spacing: 0) {
                GoalCreationHeaderView(
                    goalName: $goalName,
                    isFocused: $isFocused,
                    selectedIcon: nil,
                    selectedColor: .sage,
                    isCustomizable: true,
                    onCustomizeTapped: { print("Customize tapped") }
                )
                Spacer()
            }
            .background(Color(.systemGroupedBackground))
        }
    }
    return PreviewWrapper()
}

#Preview("Phase 2 - Custom Icon & Color") {
    struct PreviewWrapper: View {
        @State private var goalName = "Wedding Fund"
        @FocusState private var isFocused: Bool

        var body: some View {
            VStack(spacing: 0) {
                GoalCreationHeaderView(
                    goalName: $goalName,
                    isFocused: $isFocused,
                    selectedIcon: "heart.fill",
                    selectedColor: .rose,
                    isCustomizable: true,
                    onCustomizeTapped: { print("Customize tapped") }
                )
                Spacer()
            }
            .background(Color(.systemGroupedBackground))
        }
    }
    return PreviewWrapper()
}

#Preview("Dark Mode") {
    struct PreviewWrapper: View {
        @State private var goalName = "Emergency Fund"
        @FocusState private var isFocused: Bool

        var body: some View {
            VStack(spacing: 0) {
                GoalCreationHeaderView(
                    goalName: $goalName,
                    isFocused: $isFocused,
                    selectedIcon: "shield.fill",
                    selectedColor: .slate,
                    isCustomizable: true,
                    onCustomizeTapped: { print("Customize tapped") }
                )
                Spacer()
            }
            .background(Color(.systemGroupedBackground))
            .preferredColorScheme(.dark)
        }
    }
    return PreviewWrapper()
}
