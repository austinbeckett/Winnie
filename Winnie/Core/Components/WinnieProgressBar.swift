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
/// ```
struct WinnieProgressBar: View {
    let progress: Double
    let color: Color
    let showLabel: Bool

    @Environment(\.colorScheme) private var colorScheme

    /// Creates a progress bar.
    /// - Parameters:
    ///   - progress: Progress value from 0.0 to 1.0
    ///   - color: Fill color (defaults to amethyst accent)
    ///   - showLabel: Whether to show percentage label (defaults to false)
    init(
        progress: Double,
        color: Color = WinnieColors.amethystSmoke,
        showLabel: Bool = false
    ) {
        // Clamp progress between 0 and 1
        self.progress = min(max(progress, 0), 1)
        self.color = color
        self.showLabel = showLabel
    }

    var body: some View {
        VStack(alignment: .trailing, spacing: WinnieSpacing.xxs) {
            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background track
                    RoundedRectangle(cornerRadius: 4)
                        .fill(WinnieColors.progressBackground(for: colorScheme))
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
                    .foregroundColor(WinnieColors.tertiaryText(for: colorScheme))
            }
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
        WinnieProgressBar(progress: progress, color: color)
    }
}

// MARK: - Preview

#Preview("Progress Bars") {
    VStack(spacing: WinnieSpacing.l) {
        VStack(alignment: .leading, spacing: WinnieSpacing.xs) {
            Text("0%")
                .font(WinnieTypography.bodyS())
            WinnieProgressBar(progress: 0)
        }

        VStack(alignment: .leading, spacing: WinnieSpacing.xs) {
            Text("25%")
                .font(WinnieTypography.bodyS())
            WinnieProgressBar(progress: 0.25)
        }

        VStack(alignment: .leading, spacing: WinnieSpacing.xs) {
            Text("50%")
                .font(WinnieTypography.bodyS())
            WinnieProgressBar(progress: 0.50, color: GoalPresetColor.blackberry.color)
        }

        VStack(alignment: .leading, spacing: WinnieSpacing.xs) {
            Text("75%")
                .font(WinnieTypography.bodyS())
            WinnieProgressBar(progress: 0.75, color: GoalPresetColor.sage.color)
        }

        VStack(alignment: .leading, spacing: WinnieSpacing.xs) {
            Text("100%")
                .font(WinnieTypography.bodyS())
            WinnieProgressBar(progress: 1.0, color: GoalPresetColor.terracotta.color)
        }

        VStack(alignment: .leading, spacing: WinnieSpacing.xs) {
            Text("With Label")
                .font(WinnieTypography.bodyS())
            WinnieProgressBar(progress: 0.65, showLabel: true)
        }
    }
    .padding(WinnieSpacing.l)
    .background(WinnieColors.parchment)
}

#Preview("Goal Preset Colors") {
    VStack(spacing: WinnieSpacing.l) {
        VStack(alignment: .leading, spacing: WinnieSpacing.xs) {
            Text("Amethyst (Default)")
                .font(WinnieTypography.bodyS())
            WinnieProgressBar(progress: 0.45, color: GoalPresetColor.amethyst.color)
        }

        VStack(alignment: .leading, spacing: WinnieSpacing.xs) {
            Text("Blackberry")
                .font(WinnieTypography.bodyS())
            WinnieProgressBar(progress: 0.30, color: GoalPresetColor.blackberry.color)
        }

        VStack(alignment: .leading, spacing: WinnieSpacing.xs) {
            Text("Sand")
                .font(WinnieTypography.bodyS())
            WinnieProgressBar(progress: 0.80, color: GoalPresetColor.sand.color)
        }

        VStack(alignment: .leading, spacing: WinnieSpacing.xs) {
            Text("Rose")
                .font(WinnieTypography.bodyS())
            WinnieProgressBar(progress: 0.60, color: GoalPresetColor.rose.color)
        }
    }
    .padding(WinnieSpacing.l)
    .background(WinnieColors.parchment)
}

#Preview("Dark Mode") {
    VStack(spacing: WinnieSpacing.l) {
        WinnieProgressBar(progress: 0.65)
        WinnieProgressBar(progress: 0.45, color: GoalPresetColor.blackberry.color)
        WinnieProgressBar(progress: 0.80, showLabel: true)
    }
    .padding(WinnieSpacing.l)
    .background(WinnieColors.blackberryCream)
    .preferredColorScheme(.dark)
}
