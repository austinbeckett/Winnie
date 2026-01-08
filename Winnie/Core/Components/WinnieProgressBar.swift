import SwiftUI

/// An animated progress bar following Winnie design system.
///
/// Usage:
/// ```swift
/// // Basic usage (0.0 to 1.0)
/// WinnieProgressBar(progress: 0.65)
///
/// // With custom color
/// WinnieProgressBar(progress: goal.progressPercentage, color: goal.displayColor)
///
/// // Show percentage label
/// WinnieProgressBar(progress: 0.75, showLabel: true)
///
/// // On card background (uses ivory track)
/// WinnieProgressBar(progress: 0.5, onCard: true)
/// ```
struct WinnieProgressBar: View {
    let progress: Double
    let color: Color
    let showLabel: Bool
    let onCard: Bool

    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.cardContext) private var cardContext

    /// Creates a progress bar.
    /// - Parameters:
    ///   - progress: Progress value from 0.0 to 1.0
    ///   - color: Fill color (defaults to Sweet Salmon accent)
    ///   - showLabel: Whether to show percentage label (defaults to false)
    ///   - onCard: Whether displayed on a Pine Teal card (affects track color)
    init(
        progress: Double,
        color: Color = WinnieColors.sweetSalmon,
        showLabel: Bool = false,
        onCard: Bool = true
    ) {
        // Clamp progress between 0 and 1
        self.progress = min(max(progress, 0), 1)
        self.color = color
        self.showLabel = showLabel
        self.onCard = onCard
    }

    var body: some View {
        VStack(alignment: .trailing, spacing: WinnieSpacing.xxs) {
            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background track
                    RoundedRectangle(cornerRadius: 4)
                        .fill(trackColor)
                        .frame(height: 8)

                    // Fill
                    RoundedRectangle(cornerRadius: 4)
                        .fill(color)
                        .frame(width: geometry.size.width * progress, height: 8)
                        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: progress)
                }
            }
            .frame(height: 8)

            // Optional percentage label
            if showLabel {
                Text("\(Int(progress * 100))%")
                    .font(WinnieTypography.caption())
                    .foregroundColor(labelColor)
            }
        }
    }

    private var trackColor: Color {
        if let style = cardContext {
            // Inside a card - choose track color based on card style
            switch style {
            case .pineTeal, .carbon:
                // Dark backgrounds: use semi-transparent ivory
                return WinnieColors.ivory.opacity(0.2)
            case .ivory, .ivoryBordered:
                // Adapts to color scheme - dark on light bg, light on dark
                return colorScheme == .dark
                    ? WinnieColors.ivory.opacity(0.15)
                    : WinnieColors.carbonBlack.opacity(0.15)
            }
        } else if onCard {
            // Fallback for legacy onCard usage without context
            return WinnieColors.ivory.opacity(0.2)
        } else {
            // On main background, use standard progress background
            return WinnieColors.progressBackground(for: colorScheme)
        }
    }

    private var labelColor: Color {
        if onCard {
            return WinnieColors.cardText.opacity(0.6)
        } else {
            return WinnieColors.tertiaryText(for: colorScheme)
        }
    }
}

// MARK: - Goal Progress Bar

/// A progress bar styled specifically for goals, using the goal type's color.
///
/// Usage:
/// ```swift
/// GoalProgressBar(goal: myGoal)
/// ```
struct GoalProgressBar: View {
    let current: Decimal
    let target: Decimal
    let color: Color

    init(goal: Goal) {
        self.current = goal.currentAmount
        self.target = goal.targetAmount
        self.color = goal.displayColor
    }

    init(current: Decimal, target: Decimal, color: Color) {
        self.current = current
        self.target = target
        self.color = color
    }

    private var progress: Double {
        guard target > 0 else { return 0 }
        let ratio = current / target
        return Double(truncating: ratio as NSNumber)
    }

    var body: some View {
        WinnieProgressBar(progress: progress, color: color, onCard: true)
    }
}

// MARK: - Preview

#Preview("Progress Bars on Cards") {
    VStack(spacing: WinnieSpacing.m) {
        WinnieCard {
            VStack(alignment: .leading, spacing: WinnieSpacing.xs) {
                Text("25% Progress")
                    .font(WinnieTypography.bodyS())
                    .foregroundColor(WinnieColors.cardText)
                WinnieProgressBar(progress: 0.25, onCard: true)
            }
        }

        WinnieCard {
            VStack(alignment: .leading, spacing: WinnieSpacing.xs) {
                Text("50% Progress")
                    .font(WinnieTypography.bodyS())
                    .foregroundColor(WinnieColors.cardText)
                WinnieProgressBar(progress: 0.50, color: GoalPresetColor.gold.color, onCard: true)
            }
        }

        WinnieCard {
            VStack(alignment: .leading, spacing: WinnieSpacing.xs) {
                Text("75% Progress")
                    .font(WinnieTypography.bodyS())
                    .foregroundColor(WinnieColors.cardText)
                WinnieProgressBar(progress: 0.75, color: GoalPresetColor.sage.color, showLabel: true, onCard: true)
            }
        }
    }
    .padding(WinnieSpacing.l)
    .background(WinnieColors.ivory)
}

#Preview("Progress Bars on Background") {
    VStack(spacing: WinnieSpacing.l) {
        VStack(alignment: .leading, spacing: WinnieSpacing.xs) {
            Text("25%")
                .font(WinnieTypography.bodyS())
            WinnieProgressBar(progress: 0.25, onCard: false)
        }

        VStack(alignment: .leading, spacing: WinnieSpacing.xs) {
            Text("50%")
                .font(WinnieTypography.bodyS())
            WinnieProgressBar(progress: 0.50, color: GoalPresetColor.teal.color, onCard: false)
        }

        VStack(alignment: .leading, spacing: WinnieSpacing.xs) {
            Text("75%")
                .font(WinnieTypography.bodyS())
            WinnieProgressBar(progress: 0.75, color: GoalPresetColor.gold.color, onCard: false)
        }

        VStack(alignment: .leading, spacing: WinnieSpacing.xs) {
            Text("100%")
                .font(WinnieTypography.bodyS())
            WinnieProgressBar(progress: 1.0, color: GoalPresetColor.clay.color, onCard: false)
        }
    }
    .padding(WinnieSpacing.l)
    .background(WinnieColors.ivory)
}

#Preview("Goal Preset Colors") {
    VStack(spacing: WinnieSpacing.l) {
        ForEach(GoalPresetColor.allCases) { preset in
            VStack(alignment: .leading, spacing: WinnieSpacing.xs) {
                Text(preset.displayName)
                    .font(WinnieTypography.bodyS())
                WinnieProgressBar(progress: 0.6, color: preset.color, onCard: false)
            }
        }
    }
    .padding(WinnieSpacing.l)
    .background(WinnieColors.ivory)
}

#Preview("Dark Mode") {
    VStack(spacing: WinnieSpacing.m) {
        WinnieCard {
            VStack(alignment: .leading, spacing: WinnieSpacing.xs) {
                Text("On Card")
                    .font(WinnieTypography.bodyS())
                    .foregroundColor(WinnieColors.cardText)
                WinnieProgressBar(progress: 0.65, onCard: true)
            }
        }

        VStack(alignment: .leading, spacing: WinnieSpacing.xs) {
            Text("On Background")
                .font(WinnieTypography.bodyS())
            WinnieProgressBar(progress: 0.45, color: GoalPresetColor.gold.color, onCard: false)
        }
    }
    .padding(WinnieSpacing.l)
    .background(WinnieColors.carbonBlack)
    .preferredColorScheme(.dark)
}
