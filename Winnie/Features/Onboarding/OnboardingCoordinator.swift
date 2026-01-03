import SwiftUI

/// Coordinator for the onboarding wizard flow.
///
/// Manages navigation between onboarding steps and persists partial progress.
/// Controls the complete onboarding sequence from splash to partner invite.
struct OnboardingCoordinator: View {

    @Bindable var appState: AppState
    let onComplete: () -> Void

    @Environment(\.colorScheme) private var colorScheme

    /// Current step in the onboarding flow
    @State private var currentStep: OnboardingStep = .splash

    /// Shared onboarding state across all wizard screens
    @State private var onboardingState = OnboardingState()

    var body: some View {
        ZStack {
            // Background
            WinnieColors.background(for: colorScheme)
                .ignoresSafeArea()

            // Current step view
            stepView
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal: .move(edge: .leading).combined(with: .opacity)
                ))
                .id(currentStep)
        }
        .animation(.easeInOut(duration: 0.3), value: currentStep)
    }

    // MARK: - Step View Builder

    @ViewBuilder
    private var stepView: some View {
        switch currentStep {
        case .splash:
            OnboardingSplashView {
                advanceTo(.carousel)
            }

        case .carousel:
            OnboardingCarouselView {
                advanceTo(.goalPicker)
            }

        case .goalPicker:
            OnboardingGoalPickerView(onboardingState: onboardingState) {
                advanceTo(.income)
            }

        case .income:
            OnboardingIncomeView(onboardingState: onboardingState) {
                advanceTo(.needs)
            }

        case .needs:
            OnboardingNeedsView(onboardingState: onboardingState) {
                advanceTo(.wants)
            }

        case .wants:
            OnboardingWantsView(onboardingState: onboardingState) {
                advanceTo(.savingsPool)
            }

        case .savingsPool:
            OnboardingSavingsPoolView(onboardingState: onboardingState) {
                advanceTo(.nestEgg)
            }

        case .nestEgg:
            OnboardingNestEggView(onboardingState: onboardingState) {
                advanceTo(.goalDetail)
            }

        case .goalDetail:
            OnboardingGoalDetailView(onboardingState: onboardingState) {
                advanceTo(.projection)
            }

        case .projection:
            OnboardingProjectionView(onboardingState: onboardingState) {
                advanceTo(.tuneUp)
            }

        case .tuneUp:
            OnboardingTuneUpView(onboardingState: onboardingState) {
                advanceTo(.partnerInvite)
            }

        case .partnerInvite:
            OnboardingPartnerInviteView(
                onInvite: {
                    // TODO: Implement partner invite flow
                    completeOnboarding()
                },
                onSkip: {
                    completeOnboarding()
                }
            )
        }
    }

    // MARK: - Navigation

    private func advanceTo(_ step: OnboardingStep) {
        withAnimation {
            currentStep = step
        }
    }

    private func completeOnboarding() {
        Task {
            await saveOnboardingData()
            onComplete()
        }
    }

    // MARK: - Persistence

    private func saveOnboardingData() async {
        // Create financial profile from onboarding state
        let profile = onboardingState.toFinancialProfile()

        // Create first goal from onboarding state
        let goal = onboardingState.toGoal()

        // Save to AppState (which persists to Firestore)
        await appState.saveOnboardingData(profile: profile, goal: goal)
    }
}

// MARK: - Onboarding Step Enum

/// All steps in the onboarding wizard
enum OnboardingStep: Int, CaseIterable {
    case splash
    case carousel
    case goalPicker
    case income
    case needs
    case wants
    case savingsPool
    case nestEgg
    case goalDetail
    case projection
    case tuneUp
    case partnerInvite

    /// Human-readable step name for debugging
    var name: String {
        switch self {
        case .splash: return "Splash"
        case .carousel: return "Carousel"
        case .goalPicker: return "Goal Picker"
        case .income: return "Income"
        case .needs: return "Needs"
        case .wants: return "Wants"
        case .savingsPool: return "Savings Pool"
        case .nestEgg: return "Nest Egg"
        case .goalDetail: return "Goal Detail"
        case .projection: return "Projection"
        case .tuneUp: return "Tune Up"
        case .partnerInvite: return "Partner Invite"
        }
    }
}

// MARK: - Previews

#Preview("Onboarding Flow") {
    OnboardingCoordinator(appState: AppState()) {
        print("Onboarding complete!")
    }
}

#Preview("Dark Mode") {
    OnboardingCoordinator(appState: AppState()) {
        print("Onboarding complete!")
    }
    .preferredColorScheme(.dark)
}
