import SwiftUI

/// A card displaying a goal summary with progress.
/// Uses Ivory Bordered card style with Pine Teal border and Carbon Black text.
///
/// Usage:
/// ```swift
/// GoalCard(goal: myGoal)
///
/// // As a tappable navigation link
/// NavigationLink {
///     GoalDetailView(goal: goal, currentUser: user, partner: partner, coupleID: id, goalsViewModel: vm)
/// } label: {
///     GoalCard(goal: goal)
/// }
/// ```
struct GoalCard: View {
    let goal: Goal

    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        WinnieCard(style: .ivoryBordered) {
            VStack(alignment: .leading, spacing: WinnieSpacing.m) {
                // Header: Icon + Name
                HStack(spacing: WinnieSpacing.s) {
                    // Goal icon - uses goal color on tinted background
                    Image(systemName: goal.displayIcon)
                        .font(.system(size: 20))
                        .foregroundColor(goal.displayColor)
                        .frame(width: 32, height: 32)
                        .background(WinnieColors.pineTeal.opacity(0.15))
                        .clipShape(RoundedRectangle(cornerRadius: 8))

                    // Goal name
                    Text(goal.name)
                        .font(WinnieTypography.headlineM())
                        .contextPrimaryText()
                        .lineLimit(1)

                    Spacer()

                    // Progress percentage
                    Text("\(goal.progressPercentageInt)%")
                        .font(WinnieTypography.bodyS())
                        .fontWeight(.medium)
                        .contextSecondaryText()
                }

                // Progress bar
                WinnieProgressBar(progress: goal.progressPercentage, color: goal.displayColor)

                // Amounts: Current / Target
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Saved")
                            .font(WinnieTypography.caption())
                            .contextLabelText()
                        Text(Formatting.currency(goal.currentAmount))
                            .font(WinnieTypography.financialM())
                            .contextPrimaryText()
                            .lineLimit(1)
                            .minimumScaleFactor(0.6)
                    }

                    Spacer()

                    VStack(alignment: .trailing, spacing: 2) {
                        Text("Goal")
                            .font(WinnieTypography.caption())
                            .contextLabelText()
                        Text(Formatting.currency(goal.targetAmount))
                            .font(WinnieTypography.financialM())
                            .contextSecondaryText()
                            .lineLimit(1)
                            .minimumScaleFactor(0.6)
                    }
                }
            }
        }
    }
}

// MARK: - Compact Variant

/// A smaller goal card for lists or grids where space is limited.
struct GoalCardCompact: View {
    let goal: Goal

    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        WinnieCard(style: .ivoryBordered) {
            HStack(spacing: WinnieSpacing.m) {
                // Goal icon
                Image(systemName: goal.displayIcon)
                    .font(.system(size: 18))
                    .foregroundColor(goal.displayColor)
                    .frame(width: 28, height: 28)
                    .background(WinnieColors.pineTeal.opacity(0.15))
                    .clipShape(RoundedRectangle(cornerRadius: 6))

                // Name and progress
                VStack(alignment: .leading, spacing: WinnieSpacing.xxs) {
                    Text(goal.name)
                        .font(WinnieTypography.bodyM())
                        .fontWeight(.medium)
                        .contextPrimaryText()
                        .lineLimit(1)

                    WinnieProgressBar(progress: goal.progressPercentage, color: goal.displayColor)
                }

                // Percentage
                Text("\(goal.progressPercentageInt)%")
                    .font(WinnieTypography.bodyS())
                    .fontWeight(.medium)
                    .contextSecondaryText()
                    .frame(width: 40, alignment: .trailing)
            }
        }
    }
}

// MARK: - Preview

#Preview("Goal Cards") {
    ScrollView {
        VStack(spacing: WinnieSpacing.m) {
            GoalCard(goal: .sampleHouse)
            GoalCard(goal: .sampleRetirement)
            GoalCard(goal: .sampleVacation)
            GoalCard(goal: .sampleEmergency)
        }
        .padding(WinnieSpacing.l)
    }
    .background(WinnieColors.ivory)
}

#Preview("Compact Cards") {
    VStack(spacing: WinnieSpacing.s) {
        GoalCardCompact(goal: .sampleHouse)
        GoalCardCompact(goal: .sampleRetirement)
        GoalCardCompact(goal: .sampleVacation)
        GoalCardCompact(goal: .sampleEmergency)
    }
    .padding(WinnieSpacing.l)
    .background(WinnieColors.ivory)
}

#Preview("Dark Mode") {
    VStack(spacing: WinnieSpacing.m) {
        GoalCard(goal: .sampleHouse)
        GoalCardCompact(goal: .sampleVacation)
    }
    .padding(WinnieSpacing.l)
    .background(WinnieColors.carbonBlack)
    .preferredColorScheme(.dark)
}
