import SwiftUI

/// A circular progress ring following Winnie design system.
///
/// Usage:
/// ```swift
/// // Basic usage (0.0 to 1.0)
/// CircularProgressRing(progress: 0.75, color: goal.displayColor)
///
/// // With center icon
/// CircularProgressRing(
///     progress: goal.progressPercentage,
///     color: goal.displayColor,
///     icon: goal.displayIcon
/// )
///
/// // Custom sizes
/// CircularProgressRing(
///     progress: 0.5,
///     color: .blue,
///     lineWidth: 8,
///     size: 80
/// )
/// ```
struct CircularProgressRing: View {
    let progress: Double
    let color: Color
    let lineWidth: CGFloat
    let size: CGFloat
    let icon: String?
    let iconColor: Color?
    let percentageText: String?

    @Environment(\.colorScheme) private var colorScheme

    /// Creates a circular progress ring.
    /// - Parameters:
    ///   - progress: Progress value from 0.0 to 1.0
    ///   - color: Fill color for the progress arc
    ///   - lineWidth: Stroke width of the ring (defaults to 6pt)
    ///   - size: Outer diameter of the ring (defaults to 60pt)
    ///   - icon: Optional SF Symbol name to display in center
    ///   - iconColor: Color for the center icon (defaults to ring color)
    ///   - percentageText: Optional percentage text to display below the icon
    init(
        progress: Double,
        color: Color = WinnieColors.lavenderVeil,
        lineWidth: CGFloat = 6,
        size: CGFloat = 60,
        icon: String? = nil,
        iconColor: Color? = nil,
        percentageText: String? = nil
    ) {
        // Clamp progress between 0 and 1
        self.progress = min(max(progress, 0), 1)
        self.color = color
        self.lineWidth = lineWidth
        self.size = size
        self.icon = icon
        self.iconColor = iconColor
        self.percentageText = percentageText
    }

    var body: some View {
        ZStack {
            // Background track (full circle)
            Circle()
                .stroke(
                    trackColor,
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )

            // Progress arc
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    color,
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                // Start at 12 o'clock (-90 degrees from default 3 o'clock)
                .rotationEffect(.degrees(-90))
                .animation(.spring(response: 0.4, dampingFraction: 0.8), value: progress)

            // Center content: icon + optional percentage stacked vertically
            if icon != nil || percentageText != nil {
                VStack(spacing: 2) {
                    if let iconName = icon {
                        Image(systemName: iconName)
                            .font(.system(size: percentageText != nil ? size * 0.25 : size * 0.33, weight: .medium))
                            .foregroundColor(iconColor ?? color)
                    }
                    if let percentage = percentageText {
                        Text(percentage)
                            .font(.system(size: size * 0.18, weight: .semibold))
                            .foregroundColor(iconColor ?? color)
                    }
                }
            }
        }
        .frame(width: size, height: size)
    }

    private var trackColor: Color {
        WinnieColors.progressBackground(for: colorScheme)
    }
}

// MARK: - Goal Progress Ring

/// A circular progress ring styled specifically for goals.
///
/// Usage:
/// ```swift
/// GoalProgressRing(goal: myGoal)
/// GoalProgressRing(goal: myGoal, size: 80, lineWidth: 8)
/// ```
struct GoalProgressRing: View {
    let goal: Goal
    let size: CGFloat
    let lineWidth: CGFloat
    let showPercentage: Bool

    init(goal: Goal, size: CGFloat = 60, lineWidth: CGFloat = 6, showPercentage: Bool = false) {
        self.goal = goal
        self.size = size
        self.lineWidth = lineWidth
        self.showPercentage = showPercentage
    }

    var body: some View {
        CircularProgressRing(
            progress: goal.progressPercentage,
            color: goal.displayColor,
            lineWidth: lineWidth,
            size: size,
            icon: goal.displayIcon,
            iconColor: goal.displayColor,
            percentageText: showPercentage ? "\(goal.progressPercentageInt)%" : nil
        )
    }
}

// MARK: - Goal Progress Cell

/// A complete goal cell with circular progress ring, name, and percentage.
/// Used in the dashboard 2x2 grid layout.
///
/// Usage:
/// ```swift
/// GoalProgressCell(goal: myGoal)
/// GoalProgressCell(goal: myGoal, onTap: { navigateToGoal() })
/// ```
struct GoalProgressCell: View {
    let goal: Goal
    let onTap: (() -> Void)?

    @Environment(\.colorScheme) private var colorScheme

    init(goal: Goal, onTap: (() -> Void)? = nil) {
        self.goal = goal
        self.onTap = onTap
    }

    var body: some View {
        Button(action: {
            HapticFeedback.light()
            onTap?()
        }) {
            VStack(spacing: WinnieSpacing.xs) {
                // Circular progress ring with icon AND percentage inside
                GoalProgressRing(goal: goal, size: 55, lineWidth: 6, showPercentage: true)

                // Goal name only (percentage moved inside circle)
                Text(goal.name)
                    .font(WinnieTypography.caption())
                    .foregroundColor(WinnieColors.primaryText(for: colorScheme))
                    .lineLimit(1)
                    .truncationMode(.tail)
            }
            .frame(minWidth: WinnieSpacing.minTouchTarget, minHeight: WinnieSpacing.minTouchTarget)
        }
        .buttonStyle(InteractiveCardStyle())
        .accessibilityLabel("\(goal.name), \(goal.progressPercentageInt) percent complete")
        .accessibilityHint("Double tap to view goal details")
    }
}

// MARK: - Previews

#Preview("Circular Progress Rings") {
    VStack(spacing: WinnieSpacing.l) {
        HStack(spacing: WinnieSpacing.l) {
            CircularProgressRing(progress: 0.25)
            CircularProgressRing(progress: 0.50, color: GoalPresetColor.gold.color)
            CircularProgressRing(progress: 0.75, color: GoalPresetColor.sage.color)
            CircularProgressRing(progress: 1.0, color: GoalPresetColor.teal.color)
        }

        HStack(spacing: WinnieSpacing.l) {
            CircularProgressRing(
                progress: 0.65,
                color: GoalPresetColor.coral.color,
                icon: "house.fill"
            )
            CircularProgressRing(
                progress: 0.40,
                color: GoalPresetColor.slate.color,
                icon: "shield.fill"
            )
            CircularProgressRing(
                progress: 0.85,
                color: GoalPresetColor.gold.color,
                icon: "airplane"
            )
        }
    }
    .padding(WinnieSpacing.l)
    .background(WinnieColors.porcelain)
}

#Preview("Goal Progress Cells - 2x2 Grid") {
    let goals = [
        Goal.sampleHouse,
        Goal(
            id: "2",
            type: .emergencyFund,
            name: "Emergency Fund",
            targetAmount: 10000,
            currentAmount: 6000
        ),
        Goal(
            id: "3",
            type: .vacation,
            name: "Hawaii Trip",
            targetAmount: 5000,
            currentAmount: 1550
        ),
        Goal(
            id: "4",
            type: .retirement,
            name: "Retirement",
            targetAmount: 500000,
            currentAmount: 25000
        )
    ]

    LazyVGrid(columns: [
        GridItem(.flexible(), spacing: WinnieSpacing.m),
        GridItem(.flexible(), spacing: WinnieSpacing.m)
    ], spacing: WinnieSpacing.m) {
        ForEach(goals) { goal in
            GoalProgressCell(goal: goal)
        }
    }
    .padding(WinnieSpacing.l)
    .background(WinnieColors.porcelain)
}

#Preview("Different Sizes") {
    HStack(spacing: WinnieSpacing.l) {
        CircularProgressRing(
            progress: 0.6,
            color: GoalPresetColor.lavender.color,
            lineWidth: 4,
            size: 40,
            icon: "star.fill"
        )

        CircularProgressRing(
            progress: 0.6,
            color: GoalPresetColor.lavender.color,
            lineWidth: 6,
            size: 60,
            icon: "star.fill"
        )

        CircularProgressRing(
            progress: 0.6,
            color: GoalPresetColor.lavender.color,
            lineWidth: 8,
            size: 80,
            icon: "star.fill"
        )
    }
    .padding(WinnieSpacing.l)
    .background(WinnieColors.porcelain)
}

#Preview("Dark Mode") {
    VStack(spacing: WinnieSpacing.l) {
        HStack(spacing: WinnieSpacing.l) {
            CircularProgressRing(
                progress: 0.75,
                color: GoalPresetColor.coral.color,
                icon: "house.fill"
            )
            CircularProgressRing(
                progress: 0.50,
                color: GoalPresetColor.gold.color,
                icon: "shield.fill"
            )
        }

        GoalProgressCell(goal: Goal.sampleHouse)
    }
    .padding(WinnieSpacing.l)
    .background(WinnieColors.onyx)
    .preferredColorScheme(.dark)
}

#Preview("All Goal Colors") {
    LazyVGrid(columns: [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ], spacing: WinnieSpacing.m) {
        ForEach(GoalPresetColor.allCases) { preset in
            VStack(spacing: WinnieSpacing.xs) {
                CircularProgressRing(
                    progress: 0.65,
                    color: preset.color,
                    icon: "star.fill"
                )
                Text(preset.displayName)
                    .font(WinnieTypography.caption())
            }
        }
    }
    .padding(WinnieSpacing.l)
    .background(WinnieColors.porcelain)
}
