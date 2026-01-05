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

    // MARK: - Progress Tracking

    /// Steps that are always shown (the "main path")
    /// Excludes splash which is the root, and conditional budgeting steps
    private var progressSteps: [OnboardingStep] {
        if onboardingState.knowsSavingsAmount {
            // Direct path: user knows their savings amount
            return [.valueProp, .goalPicker, .savingsQuestion, .savingsPool, .startingBalance, .goalDetail, .projection, .partnerInvite]
        } else {
            // Extended path: user needs help calculating savings
            return [.valueProp, .goalPicker, .savingsQuestion, .budgetingExplainer, .income, .needs, .wants, .savingsPool, .startingBalance, .goalDetail, .projection, .partnerInvite]
        }
    }

    /// Current step number for progress display (1-based)
    private func currentStepNumber(for step: OnboardingStep) -> Int {
        guard let index = progressSteps.firstIndex(of: step) else { return 0 }
        return index + 1
    }

    /// Total steps for progress display
    private var totalSteps: Int {
        progressSteps.count
    }

    /// Whether to show progress bar for this step
    private func shouldShowProgress(for step: OnboardingStep) -> Bool {
        // Hide progress on splash, nameInput, welcome, and valueProp - these are introductory screens
        step != .splash && step != .nameInput && step != .welcome && step != .valueProp
    }

    var body: some View {
        NavigationStack(path: $navigationPath) {
            // Root view: Splash
            OnboardingSplashView {
                navigateTo(.nameInput)
            }
            .navigationBarBackButtonHidden(true)
            .navigationDestination(for: OnboardingStep.self) { step in
                destinationView(for: step)
                    .navigationBarBackButtonHidden(true)
                    .safeAreaInset(edge: .top, spacing: 0) {
                        // Progress bar (only for main content steps)
                        if shouldShowProgress(for: step) {
                            OnboardingProgressBar(
                                currentStep: currentStepNumber(for: step),
                                totalSteps: totalSteps
                            )
                            .padding(.horizontal, WinnieSpacing.screenMarginMobile)
                            .padding(.top, WinnieSpacing.xs)
                            .padding(.bottom, WinnieSpacing.s)
                            .background(WinnieColors.background(for: colorScheme))
                        }
                    }
                    .toolbar {
                        // Back button (except for first step after splash)
                        if step != .valueProp {
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

        case .valueProp:
            OnboardingValuePropView {
                navigateTo(.goalPicker)
            }

        case .nameInput:
            NameInputView(appState: appState) {
                navigateTo(.welcome)
            }

        case .welcome:
            OnboardingWelcomeView(userName: appState.currentUser?.displayName ?? "there") {
                navigateTo(.valueProp)
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
                navigateTo(.startingBalance)
            }

        case .startingBalance:
            OnboardingStartingBalanceView(onboardingState: onboardingState) {
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
    case nameInput
    case welcome
    case valueProp
    case goalPicker
    case income
    case savingsQuestion
    case budgetingExplainer
    case needs
    case wants
    case savingsPool
    case startingBalance
    case goalDetail
    case projection
    case partnerInvite

    /// Human-readable step name for debugging
    var name: String {
        switch self {
        case .splash: return "Splash"
        case .nameInput: return "Name Input"
        case .welcome: return "Welcome"
        case .valueProp: return "Value Proposition"
        case .goalPicker: return "Goal Picker"
        case .income: return "Income"
        case .savingsQuestion: return "Savings Question"
        case .budgetingExplainer: return "Budgeting Explainer"
        case .needs: return "Needs"
        case .wants: return "Wants"
        case .savingsPool: return "Savings Pool"
        case .startingBalance: return "Starting Balance"
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
