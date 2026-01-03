import SwiftUI

/// Goal selection screen for onboarding.
///
/// Presents a vertical scrolling list of illustrated goal cards.
/// Users select their primary focus to personalize the onboarding experience.
struct OnboardingGoalPickerView: View {

    @Bindable var onboardingState: OnboardingState
    let onContinue: () -> Void

    @Environment(\.colorScheme) private var colorScheme

    /// Goal types shown during onboarding (curated subset)
    private let onboardingGoalTypes: [GoalType] = [
        .house,
        .babyFamily,
        .retirement,
        .emergencyFund,
        .vacation,
        .car,
        .debt,
        .custom
    ]

    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(spacing: WinnieSpacing.s) {
                Text("Let's set up your first financial goal.")
                    .font(WinnieTypography.headlineL())
                    .foregroundColor(WinnieColors.primaryText(for: colorScheme))
                    .multilineTextAlignment(.center)

                Text("You can always add more goals later but let's start with one!")
                    .font(WinnieTypography.bodyL())
                    .foregroundColor(WinnieColors.secondaryText(for: colorScheme))
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, WinnieSpacing.screenMarginMobile)
            .padding(.top, WinnieSpacing.l)
            .padding(.bottom, WinnieSpacing.m)

            // Goal cards (vertical scroll)
            ScrollView {
                VStack(spacing: WinnieSpacing.m) {
                    ForEach(onboardingGoalTypes) { goalType in
                        goalCard(for: goalType)
                    }
                }
                .padding(.horizontal, WinnieSpacing.screenMarginMobile)
                .padding(.bottom, WinnieSpacing.xl)
            }
        }
        .safeAreaInset(edge: .bottom) {
            WinnieButton("Continue", style: .primary) {
                onContinue()
            }
            .disabled(onboardingState.selectedGoalType == nil)
            .padding(.horizontal, WinnieSpacing.screenMarginMobile)
            .padding(.vertical, WinnieSpacing.m)
            .background(WinnieColors.background(for: colorScheme))
        }
        .background(WinnieColors.background(for: colorScheme).ignoresSafeArea())
    }

    // MARK: - Goal Card

    @ViewBuilder
    private func goalCard(for goalType: GoalType) -> some View {
        let isSelected = onboardingState.selectedGoalType == goalType

        Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                onboardingState.selectedGoalType = goalType
            }
        } label: {
            VStack(spacing: 0) {
                // Illustration area (SF Symbol placeholder)
                ZStack {
                    Rectangle()
                        .fill(illustrationBackground(for: goalType))
                        .frame(height: 100)

                    Image(systemName: iconName(for: goalType))
                        .font(.system(size: 40))
                        .foregroundColor(isSelected ? .white : WinnieColors.accent)
                }

                // Text area
                VStack(alignment: .leading, spacing: WinnieSpacing.xxs) {
                    Text(title(for: goalType))
                        .font(WinnieTypography.bodyL().weight(.semibold))
                        .foregroundColor(WinnieColors.primaryText(for: colorScheme))

                    Text(subtitle(for: goalType))
                        .font(WinnieTypography.bodyS())
                        .foregroundColor(WinnieColors.secondaryText(for: colorScheme))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(WinnieSpacing.m)
                .background(WinnieColors.cardBackground(for: colorScheme))
            }
            .clipShape(RoundedRectangle(cornerRadius: WinnieSpacing.cardCornerRadius))
            .overlay(
                RoundedRectangle(cornerRadius: WinnieSpacing.cardCornerRadius)
                    .stroke(isSelected ? WinnieColors.accent : WinnieColors.border(for: colorScheme),
                            lineWidth: isSelected ? 2 : 1)
            )
            .shadow(
                color: WinnieColors.cardShadow(for: colorScheme),
                radius: isSelected ? 8 : 4,
                x: 0,
                y: 2
            )
            .scaleEffect(isSelected ? 1.02 : 1.0)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Card Content

    private func iconName(for goalType: GoalType) -> String {
        switch goalType {
        case .house: return "house.fill"
        case .babyFamily: return "figure.2.and.child.holdinghands"
        case .retirement: return "beach.umbrella.fill"
        case .emergencyFund: return "shield.fill"
        case .vacation: return "airplane"
        case .car: return "car.fill"
        case .debt: return "creditcard.fill"
        case .custom: return "sparkles"
        default: return goalType.iconName
        }
    }

    private func title(for goalType: GoalType) -> String {
        switch goalType {
        case .house: return "Buy a Home"
        case .babyFamily: return "Start a Family"
        case .retirement: return "Retire Comfortably"
        case .emergencyFund: return "Emergency Fund"
        case .vacation: return "Dream Vacation"
        case .car: return "New Vehicle"
        case .debt: return "Pay Off Debt"
        case .custom: return "Something Else"
        default: return goalType.displayName
        }
    }

    private func subtitle(for goalType: GoalType) -> String {
        switch goalType {
        case .house: return "Save for your down payment"
        case .babyFamily: return "Prepare for your growing family"
        case .retirement: return "Build your retirement nest egg"
        case .emergencyFund: return "Create your financial safety net"
        case .vacation: return "Plan your next big adventure"
        case .car: return "Save for your next car"
        case .debt: return "Become debt-free faster"
        case .custom: return "Create a custom goal"
        default: return "Set your target and timeline"
        }
    }

    private func illustrationBackground(for goalType: GoalType) -> Color {
        let isSelected = onboardingState.selectedGoalType == goalType
        if isSelected {
            return WinnieColors.accent
        }
        // Subtle tint based on goal type
        return WinnieColors.cardBackground(for: colorScheme)
    }
}

// MARK: - Previews

#Preview("Light Mode") {
    OnboardingGoalPickerView(onboardingState: OnboardingState()) {
        print("Continue tapped")
    }
}

#Preview("Dark Mode") {
    OnboardingGoalPickerView(onboardingState: OnboardingState()) {
        print("Continue tapped")
    }
    .preferredColorScheme(.dark)
}

#Preview("With Selection") {
    let state = OnboardingState()
    state.selectedGoalType = .house
    return OnboardingGoalPickerView(onboardingState: state) {
        print("Continue tapped")
    }
}
