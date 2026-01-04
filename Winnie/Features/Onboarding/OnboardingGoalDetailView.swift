import SwiftUI

/// Goal amount input screen for onboarding wizard.
///
/// Asks for target amount for the selected goal. Date selection happens
/// after viewing the projection, allowing users to see feasibility first.
struct OnboardingGoalDetailView: View {

    @Bindable var onboardingState: OnboardingState
    let onContinue: () -> Void

    @Environment(\.colorScheme) private var colorScheme
    @FocusState private var isAmountFocused: Bool

    /// Local string for text field binding
    @State private var amountText: String = ""

    private var goalType: GoalType {
        onboardingState.selectedGoalType ?? .house
    }

    var body: some View {
        ScrollView {
            VStack(spacing: WinnieSpacing.xl) {
                Spacer(minLength: WinnieSpacing.xl)

                // Header
                VStack(spacing: WinnieSpacing.s) {
                    Image(systemName: goalType.iconName)
                        .font(.system(size: 48))
                        .foregroundColor(WinnieColors.accent)

                    Text(headerTitle)
                        .font(WinnieTypography.headlineL())
                        .foregroundColor(WinnieColors.primaryText(for: colorScheme))

                    Text(headerSubtitle)
                        .font(WinnieTypography.bodyL())
                        .foregroundColor(WinnieColors.secondaryText(for: colorScheme))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, WinnieSpacing.m)
                }

                // Target amount input
                VStack(spacing: WinnieSpacing.s) {
                    WinnieCurrencyInput(
                        value: $onboardingState.goalTargetAmount,
                        text: $amountText
                    )
                    .padding(.horizontal, WinnieSpacing.screenMarginMobile)

                    Text("We'll show you when you can reach this based on your savings.")
                        .font(WinnieTypography.bodyS())
                        .foregroundColor(WinnieColors.tertiaryText(for: colorScheme))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, WinnieSpacing.screenMarginMobile) // Fixed padding
                }

                Spacer(minLength: WinnieSpacing.xxxl)
            }
        }
        .scrollDismissesKeyboard(.interactively) // Enable keyboard dismissal
        .safeAreaInset(edge: .bottom) {
            WinnieButton("See my projection", style: .primary) {
                isAmountFocused = false
                onContinue()
            }
            .disabled(onboardingState.goalTargetAmount <= 0)
            .padding(.horizontal, WinnieSpacing.screenMarginMobile)
            .padding(.vertical, WinnieSpacing.m)
            .background(WinnieColors.background(for: colorScheme))
        }
        .background(WinnieColors.background(for: colorScheme).ignoresSafeArea())
        .onAppear {
            if onboardingState.goalTargetAmount > 0 {
                amountText = "\(NSDecimalNumber(decimal: onboardingState.goalTargetAmount).intValue)"
            }
        }
    }

    // MARK: - Dynamic Content

    private var headerTitle: String {
        switch goalType {
        case .house: return "Your home fund"
        case .babyFamily: return "Growing your family"
        case .retirement: return "Your retirement"
        case .emergencyFund: return "Your safety net"
        default: return "Your \(goalType.displayName.lowercased())"
        }
    }

    private var headerSubtitle: String {
        switch goalType {
        case .house: return "How much do you need for a down payment?"
        case .babyFamily: return "What's your budget for baby expenses?"
        case .retirement: return "How much do you want to have saved?"
        case .emergencyFund: return "How much would you like in your emergency fund?"
        default: return "What's your target for this goal?"
        }
    }
}

// MARK: - Previews

#Preview("House Goal") {
    let state = OnboardingState()
    state.selectedGoalType = .house
    return OnboardingGoalDetailView(onboardingState: state) {
        print("Continue tapped")
    }
}

#Preview("Dark Mode") {
    let state = OnboardingState()
    state.selectedGoalType = .house
    return OnboardingGoalDetailView(onboardingState: state) {
        print("Continue tapped")
    }
    .preferredColorScheme(.dark)
}
