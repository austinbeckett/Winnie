import SwiftUI

/// A vertical list of suggestion rows for quick goal selection in Phase 1.
///
/// **How It Works:**
/// - Displays a "Suggestions" header with a list of goal suggestions
/// - Each row shows an icon and goal name with a divider
/// - Tapping a row triggers the `onSelect` callback
/// - Parent view uses this to fill the goal name field
///
/// **Usage:**
/// ```swift
/// GoalSuggestionsView { suggestion in
///     goalName = suggestion.name
/// }
/// ```
struct GoalSuggestionsView: View {
    let onSelect: (GoalSuggestion) -> Void

    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Section header
            Text("Suggestions")
                .font(WinnieTypography.bodyS())
                .fontWeight(.medium)
                .foregroundColor(WinnieColors.secondaryText(for: colorScheme))
                .padding(.horizontal, WinnieSpacing.screenMarginMobile)
                .padding(.top, WinnieSpacing.l)
                .padding(.bottom, WinnieSpacing.s)

            // Suggestions list
            VStack(spacing: 0) {
                ForEach(GoalSuggestion.defaults) { suggestion in
                    suggestionRow(suggestion)

                    // Divider (except after last item)
                    if suggestion.id != GoalSuggestion.defaults.last?.id {
                        Divider()
                            .padding(.leading, WinnieSpacing.screenMarginMobile + 44)
                    }
                }
            }
        }
    }

    // MARK: - Suggestion Row

    private func suggestionRow(_ suggestion: GoalSuggestion) -> some View {
        Button {
            // Haptic feedback
            let impact = UIImpactFeedbackGenerator(style: .light)
            impact.impactOccurred()

            onSelect(suggestion)
        } label: {
            HStack(spacing: WinnieSpacing.s) {
                // Icon
                Image(systemName: suggestion.icon)
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(WinnieColors.peachGlow)
                    .frame(width: 32, height: 32)

                // Name
                Text(suggestion.name)
                    .font(WinnieTypography.bodyM())
                    .fontWeight(.medium)
                    .foregroundColor(WinnieColors.primaryText(for: colorScheme))

                Spacer()
            }
            .padding(.horizontal, WinnieSpacing.screenMarginMobile)
            .padding(.vertical, WinnieSpacing.m)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview

#Preview("Light Mode") {
    GoalSuggestionsView { suggestion in
        print("Selected: \(suggestion.name)")
    }
    .background(Color(.systemBackground))
}

#Preview("Dark Mode") {
    GoalSuggestionsView { suggestion in
        print("Selected: \(suggestion.name)")
    }
    .background(Color(.systemBackground))
    .preferredColorScheme(.dark)
}
