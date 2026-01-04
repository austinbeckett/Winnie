import SwiftUI

/// Developer gallery view for previewing all onboarding screens at a glance.
///
/// Displays a scrollable grid of all onboarding steps with thumbnail previews.
/// Tap any card to view that screen in full detail. Useful for rapid iteration
/// during development without going through the full onboarding flow.
struct OnboardingGalleryView: View {

    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme

    /// Currently selected step to view in detail
    @State private var selectedStep: OnboardingStep?

    /// Shared sample state for views that need it
    @State private var sampleState = OnboardingGalleryView.createSampleState()

    /// Whether to use dark mode for previews
    @State private var previewInDarkMode = false

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: WinnieSpacing.m) {
                    ForEach(OnboardingStep.allCases, id: \.self) { step in
                        stepCard(for: step)
                    }
                }
                .padding(WinnieSpacing.screenMarginMobile)
            }
            .background(WinnieColors.background(for: colorScheme).ignoresSafeArea())
            .navigationTitle("Onboarding Gallery")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        previewInDarkMode.toggle()
                    } label: {
                        Image(systemName: previewInDarkMode ? "moon.fill" : "sun.max.fill")
                            .foregroundColor(WinnieColors.accent)
                    }
                }
            }
            .fullScreenCover(item: $selectedStep) { step in
                stepDetailView(for: step)
            }
        }
    }

    // MARK: - Step Card

    @ViewBuilder
    private func stepCard(for step: OnboardingStep) -> some View {
        Button {
            selectedStep = step
        } label: {
            VStack(spacing: WinnieSpacing.xs) {
                // Mini preview area
                ZStack {
                    RoundedRectangle(cornerRadius: WinnieSpacing.cardCornerRadius)
                        .fill(previewInDarkMode
                              ? WinnieColors.background(for: .dark)
                              : WinnieColors.background(for: .light))
                        .frame(height: 120)

                    // Icon representation of the step
                    VStack(spacing: WinnieSpacing.xxs) {
                        Image(systemName: iconName(for: step))
                            .font(.system(size: 28))
                            .foregroundColor(WinnieColors.accent)

                        Text(step.name)
                            .font(WinnieTypography.caption())
                            .foregroundColor(previewInDarkMode
                                             ? WinnieColors.secondaryText(for: .dark)
                                             : WinnieColors.secondaryText(for: .light))
                            .lineLimit(1)
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: WinnieSpacing.cardCornerRadius))
                .overlay(
                    RoundedRectangle(cornerRadius: WinnieSpacing.cardCornerRadius)
                        .stroke(WinnieColors.border(for: colorScheme), lineWidth: 1)
                )

                // Step number and name
                HStack {
                    Text("\(step.rawValue + 1)")
                        .font(WinnieTypography.caption().weight(.bold))
                        .foregroundColor(.white)
                        .frame(width: 20, height: 20)
                        .background(WinnieColors.accent)
                        .clipShape(Circle())

                    Text(step.name)
                        .font(WinnieTypography.bodyS())
                        .foregroundColor(WinnieColors.primaryText(for: colorScheme))
                        .lineLimit(1)

                    Spacer()
                }
            }
            .padding(WinnieSpacing.xs)
            .background(WinnieColors.cardBackground(for: colorScheme))
            .clipShape(RoundedRectangle(cornerRadius: WinnieSpacing.cardCornerRadius))
            .shadow(color: WinnieColors.cardShadow(for: colorScheme), radius: 4, x: 0, y: 2)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Step Detail View

    @ViewBuilder
    private func stepDetailView(for step: OnboardingStep) -> some View {
        NavigationStack {
            Group {
                switch step {
                case .splash:
                    OnboardingSplashView { }

                case .valueProp:
                    OnboardingValuePropView { }

                case .goalPicker:
                    OnboardingGoalPickerView(onboardingState: sampleState) { }

                case .income:
                    OnboardingIncomeView(onboardingState: sampleState) { }

                case .savingsQuestion:
                    OnboardingSavingsQuestionView(
                        onKnowsSavings: { },
                        onNeedHelp: { }
                    )

                case .budgetingExplainer:
                    OnboardingBudgetingExplainerView { }

                case .needs:
                    OnboardingNeedsView(onboardingState: sampleState) { }

                case .wants:
                    OnboardingWantsView(onboardingState: sampleState) { }

                case .savingsPool:
                    OnboardingSavingsPoolView(onboardingState: sampleState) { }

                case .nestEgg:
                    OnboardingNestEggView(onboardingState: sampleState) { }

                case .goalDetail:
                    OnboardingGoalDetailView(onboardingState: sampleState) { }

                case .projection:
                    OnboardingProjectionView(onboardingState: sampleState) { }

                case .partnerInvite:
                    OnboardingPartnerInviteView(
                        onInvite: { },
                        onSkip: { }
                    )
                }
            }
            .preferredColorScheme(previewInDarkMode ? .dark : .light)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        selectedStep = nil
                    } label: {
                        HStack(spacing: WinnieSpacing.xxs) {
                            Image(systemName: "chevron.left")
                            Text("Gallery")
                        }
                    }
                }

                ToolbarItem(placement: .principal) {
                    Text(step.name)
                        .font(WinnieTypography.bodyM().weight(.semibold))
                }

                ToolbarItem(placement: .topBarTrailing) {
                    HStack(spacing: WinnieSpacing.s) {
                        // Previous step
                        if step.rawValue > 0 {
                            Button {
                                if let previous = OnboardingStep(rawValue: step.rawValue - 1) {
                                    selectedStep = previous
                                }
                            } label: {
                                Image(systemName: "arrow.left.circle")
                            }
                        }

                        // Next step
                        if step.rawValue < OnboardingStep.allCases.count - 1 {
                            Button {
                                if let next = OnboardingStep(rawValue: step.rawValue + 1) {
                                    selectedStep = next
                                }
                            } label: {
                                Image(systemName: "arrow.right.circle")
                            }
                        }
                    }
                }
            }
        }
    }

    // MARK: - Helpers

    private func iconName(for step: OnboardingStep) -> String {
        switch step {
        case .splash: return "sparkle"
        case .valueProp: return "square.stack.3d.up"
        case .goalPicker: return "flag.fill"
        case .income: return "dollarsign.circle.fill"
        case .savingsQuestion: return "questionmark.circle.fill"
        case .budgetingExplainer: return "chart.pie.fill"
        case .needs: return "house.fill"
        case .wants: return "cart.fill"
        case .savingsPool: return "banknote.fill"
        case .nestEgg: return "leaf.fill"
        case .goalDetail: return "target"
        case .projection: return "chart.line.uptrend.xyaxis"
        case .partnerInvite: return "person.2.fill"
        }
    }

    /// Creates sample state with realistic data for previewing onboarding views
    static func createSampleState() -> OnboardingState {
        let state = OnboardingState()
        state.selectedGoalType = .house
        state.monthlyIncome = 8500
        state.monthlyNeeds = 3200
        state.monthlyWants = 1800
        state.directSavingsPool = 2000
        state.knowsSavingsAmount = false
        state.nestEgg = 25000
        state.goalTargetAmount = 100000
        state.goalDesiredDate = Calendar.current.date(byAdding: .year, value: 3, to: Date())
        state.goalName = "Dream Home Down Payment"
        return state
    }
}

// MARK: - OnboardingStep Identifiable Conformance

extension OnboardingStep: Identifiable {
    var id: Int { rawValue }
}

// MARK: - Previews

#Preview("Gallery") {
    OnboardingGalleryView()
}

#Preview("Dark Mode") {
    OnboardingGalleryView()
        .preferredColorScheme(.dark)
}
