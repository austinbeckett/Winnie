import SwiftUI

/// The accent-colored header for goal creation with dynamic icon and name field.
///
/// **How It Works:**
/// - Displays an Amethyst Smoke background (sheet provides rounded top corners)
/// - Shows a large icon (64x64) that updates based on the goal name
/// - Contains a text field for entering/editing the goal name
/// - The icon animates smoothly when it changes
///
/// **Usage:**
/// ```swift
/// GoalCreationHeaderView(
///     goalName: $goalName,
///     isFocused: $isNameFieldFocused
/// )
/// ```
struct GoalCreationHeaderView: View {
    @Binding var goalName: String
    var isFocused: FocusState<Bool>.Binding

    @Environment(\.colorScheme) private var colorScheme

    /// Compute the current icon based on the goal name.
    private var currentIcon: String {
        GoalIconMapper.icon(for: goalName)
    }

    var body: some View {
        HStack(spacing: WinnieSpacing.m) {
            // Icon container
            iconContainer

            // Text field
            nameTextField
        }
        .padding(.horizontal, WinnieSpacing.screenMarginMobile)
        .padding(.top, WinnieSpacing.xxl)
        .padding(.bottom, WinnieSpacing.xl)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(WinnieColors.amethystSmoke)
    }

    // MARK: - Icon Container

    private var iconContainer: some View {
        Image(systemName: currentIcon)
            .font(.system(size: 32, weight: .medium))
            .foregroundColor(WinnieColors.amethystSmoke)
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
    }

    // MARK: - Name Text Field

    private var nameTextField: some View {
        TextField("What are you saving for?", text: $goalName)
            .font(WinnieTypography.headlineM())
            .foregroundColor(WinnieColors.ink)
            .tint(WinnieColors.ink)
            .focused(isFocused)
            .textInputAutocapitalization(.words)
            .autocorrectionDisabled(false)
    }
}

// MARK: - Preview

#Preview("Empty State") {
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

#Preview("With Name") {
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

#Preview("Vacation Goal") {
    struct PreviewWrapper: View {
        @State private var goalName = "Dream Vacation"
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
