import SwiftUI

/// A vertical list of suggestion rows for quick goal selection in Phase 1.
///
/// **How It Works:**
/// - Displays a "Suggestions" header above a card containing suggestions
/// - Each row shows an icon and goal name
/// - Rows are separated by inset dividers (not running to card edges)
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
        VStack(alignment: .leading, spacing: WinnieSpacing.s) {
            // Section header (outside the card)
            Text("Suggestions")
                .font(WinnieTypography.bodyS())
                .fontWeight(.medium)
                .foregroundColor(WinnieColors.secondaryText(for: colorScheme))

            // Suggestions card with shadow
            VStack(spacing: 0) {
                ForEach(Array(GoalSuggestion.defaults.enumerated()), id: \.element.id) { index, suggestion in
                    suggestionRow(suggestion)

                    // Inset divider (except after last item)
                    if index < GoalSuggestion.defaults.count - 1 {
                        Divider()
                            .padding(.horizontal, WinnieSpacing.m)
                    }
                }
            }
            .background(WinnieColors.cardBackground(for: colorScheme))
            .clipShape(RoundedRectangle(cornerRadius: WinnieSpacing.cardCornerRadius))
            .shadow(
                color: WinnieColors.cardShadow(for: colorScheme),
                radius: 8,
                x: 0,
                y: 3
            )
        }
        .padding(.horizontal, WinnieSpacing.screenMarginMobile)
        .padding(.top, WinnieSpacing.l)
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
                    .foregroundColor(WinnieColors.amethystSmoke)
                    .frame(width: 32, height: 32)

                // Name
                Text(suggestion.name)
                    .font(WinnieTypography.bodyM())
                    .fontWeight(.medium)
                    .foregroundColor(WinnieColors.primaryText(for: colorScheme))

                Spacer()
            }
            .padding(.horizontal, WinnieSpacing.m)
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
