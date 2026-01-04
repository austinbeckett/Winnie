import SwiftUI

/// Coordinator for the onboarding wizard flow.
///
/// Uses NavigationStack with path-based navigation for smooth, native push/pop transitions.
/// Controls the complete onboarding sequence from splash to partner invite.
struct OnboardingCoordinator: View {

    @Bindable var appState: AppState
    let onComplete: () -> Void

    @Environment(\.colorScheme) private var colorScheme

    /// Navigation path for the onboarding flow
    @State private var navigationPath: [OnboardingStep] = []

    /// Shared onboarding state across all wizard screens
    @State private var onboardingState = OnboardingState()

    var body: some View {
        NavigationStack(path: $navigationPath) {
            // Root view: Splash
            OnboardingSplashView {
                navigateTo(.carousel)
            }
            .navigationBarBackButtonHidden(true)
            .navigationDestination(for: OnboardingStep.self) { step in
                destinationView(for: step)
                    .navigationBarBackButtonHidden(true)
                    .toolbar {
                        // Back button (except for first step after splash)
                        if step != .carousel {
                            ToolbarItem(placement: .topBarLeading) {
                                Button {
                                    goBack()
                                } label: {
                                    Image(systemName: "chevron.left")
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(WinnieColors.primaryText(for: colorScheme))
                                }
                            }
                        }
                    }
            }
        }
        .tint(WinnieColors.accent)
    }

    // MARK: - Destination Views

    @ViewBuilder
    private func destinationView(for step: OnboardingStep) -> some View {
        switch step {
        case .splash:
            // Should never navigate here, it's the root
            EmptyView()

        case .carousel:
            OnboardingCarouselView {
                navigateTo(.goalPicker)
            }

        case .goalPicker:
            OnboardingGoalPickerView(onboardingState: onboardingState) {
                navigateTo(.savingsQuestion)
            }

        case .income:
            OnboardingIncomeView(onboardingState: onboardingState) {
                navigateTo(.needs)
            }

        case .savingsQuestion:
            OnboardingSavingsQuestionView(
                onKnowsSavings: {
                    onboardingState.knowsSavingsAmount = true
                    navigateTo(.savingsPool)
                },
                onNeedHelp: {
                    onboardingState.knowsSavingsAmount = false
                    navigateTo(.budgetingExplainer)
                }
            )

        case .budgetingExplainer:
            OnboardingBudgetingExplainerView {
                navigateTo(.income)
            }

        case .needs:
            OnboardingNeedsView(onboardingState: onboardingState) {
                navigateTo(.wants)
            }

        case .wants:
            OnboardingWantsView(onboardingState: onboardingState) {
                navigateTo(.savingsPool)
            }

        case .savingsPool:
            OnboardingSavingsPoolView(onboardingState: onboardingState) {
                navigateTo(.nestEgg)
            }

        case .nestEgg:
            OnboardingNestEggView(onboardingState: onboardingState) {
                navigateTo(.goalDetail)
            }

        case .goalDetail:
            OnboardingGoalDetailView(onboardingState: onboardingState) {
                navigateTo(.projection)
            }

        case .projection:
            OnboardingProjectionView(onboardingState: onboardingState) {
                navigateTo(.partnerInvite)
            }

        case .partnerInvite:
            OnboardingPartnerInviteView(
                onInvite: {
                    completeOnboarding()
                },
                onSkip: {
                    completeOnboarding()
                }
            )
        }
    }

    // MARK: - Navigation

    private func navigateTo(_ step: OnboardingStep) {
        navigationPath.append(step)
    }

    private func goBack() {
        if !navigationPath.isEmpty {
            navigationPath.removeLast()
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
        let profile = onboardingState.toFinancialProfile()
        let goal = onboardingState.toGoal()
        await appState.saveOnboardingData(profile: profile, goal: goal)
    }
}

// MARK: - Onboarding Step Enum

/// All steps in the onboarding wizard
enum OnboardingStep: Int, CaseIterable, Hashable {
    case splash
    case carousel
    case goalPicker
    case income
    case savingsQuestion
    case budgetingExplainer
    case needs
    case wants
    case savingsPool
    case nestEgg
    case goalDetail
    case projection
    case partnerInvite

    /// Human-readable step name for debugging
    var name: String {
        switch self {
        case .splash: return "Splash"
        case .carousel: return "Carousel"
        case .goalPicker: return "Goal Picker"
        case .income: return "Income"
        case .savingsQuestion: return "Savings Question"
        case .budgetingExplainer: return "Budgeting Explainer"
        case .needs: return "Needs"
        case .wants: return "Wants"
        case .savingsPool: return "Savings Pool"
        case .nestEgg: return "Nest Egg"
        case .goalDetail: return "Goal Detail"
        case .projection: return "Projection"
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
