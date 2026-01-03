import SwiftUI

/// Goal details input screen for onboarding wizard.
///
/// Step 5 of the wizard: Asks for target amount and desired date for the selected goal.
/// The form adapts based on the selected goal type.
struct OnboardingGoalDetailView: View {

    @Bindable var onboardingState: OnboardingState
    let onContinue: () -> Void

    @Environment(\.colorScheme) private var colorScheme
    @FocusState private var isAmountFocused: Bool

    /// Local string for text field binding
    @State private var amountText: String = ""
    @State private var selectedDate: Date = Calendar.current.date(byAdding: .year, value: 2, to: Date()) ?? Date()

    private var goalType: GoalType {
        onboardingState.selectedGoalType ?? .house
    }

    var body: some View {
        ScrollView {
            VStack(spacing: WinnieSpacing.xl) {
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
                .padding(.top, WinnieSpacing.xl)

                // Target amount input
                VStack(alignment: .leading, spacing: WinnieSpacing.xs) {
                    Text(amountLabel)
                        .font(WinnieTypography.caption())
                        .foregroundColor(WinnieColors.tertiaryText(for: colorScheme))
                        .textCase(.uppercase)
                        .tracking(0.5)

                    HStack {
                        Text("$")
                            .font(WinnieTypography.financialM())
                            .foregroundColor(WinnieColors.tertiaryText(for: colorScheme))

                        TextField("0", text: $amountText)
                            .font(WinnieTypography.financialM())
                            .foregroundColor(WinnieColors.primaryText(for: colorScheme))
                            .keyboardType(.numberPad)
                            .focused($isAmountFocused)
                            .onChange(of: amountText) { _, newValue in
                                let filtered = newValue.filter { $0.isNumber }
                                if filtered != newValue {
                                    amountText = filtered
                                }
                                if let value = Decimal(string: filtered) {
                                    onboardingState.goalTargetAmount = value
                                } else {
                                    onboardingState.goalTargetAmount = 0
                                }
                            }
                    }
                    .padding(WinnieSpacing.m)
                    .background(WinnieColors.cardBackground(for: colorScheme))
                    .clipShape(RoundedRectangle(cornerRadius: WinnieSpacing.inputCornerRadius))
                    .overlay(
                        RoundedRectangle(cornerRadius: WinnieSpacing.inputCornerRadius)
                            .stroke(isAmountFocused ? WinnieColors.accent : WinnieColors.border(for: colorScheme), lineWidth: 1)
                    )
                }
                .padding(.horizontal, WinnieSpacing.screenMarginMobile)

                // Date picker
                VStack(alignment: .leading, spacing: WinnieSpacing.xs) {
                    Text(dateLabel)
                        .font(WinnieTypography.caption())
                        .foregroundColor(WinnieColors.tertiaryText(for: colorScheme))
                        .textCase(.uppercase)
                        .tracking(0.5)

                    DatePicker(
                        "",
                        selection: $selectedDate,
                        in: Date()...,
                        displayedComponents: .date
                    )
                    .datePickerStyle(.graphical)
                    .tint(WinnieColors.accent)
                    .onChange(of: selectedDate) { _, newDate in
                        onboardingState.goalDesiredDate = newDate
                    }
                }
                .padding(.horizontal, WinnieSpacing.screenMarginMobile)

                Spacer(minLength: WinnieSpacing.xxxl)
            }
        }
        .safeAreaInset(edge: .bottom) {
            WinnieButton("Continue", style: .primary) {
                isAmountFocused = false
                onContinue()
            }
            .disabled(!onboardingState.isGoalValid)
            .padding(.horizontal, WinnieSpacing.screenMarginMobile)
            .padding(.vertical, WinnieSpacing.m)
            .background(WinnieColors.background(for: colorScheme))
        }
        .background(WinnieColors.background(for: colorScheme).ignoresSafeArea())
        .onAppear {
            if onboardingState.goalTargetAmount > 0 {
                amountText = "\(NSDecimalNumber(decimal: onboardingState.goalTargetAmount).intValue)"
            }
            if let date = onboardingState.goalDesiredDate {
                selectedDate = date
            }
            onboardingState.goalDesiredDate = selectedDate
        }
        .onTapGesture {
            isAmountFocused = false
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
        case .retirement: return "How much do you want to have saved for retirement?"
        case .emergencyFund: return "How much would you like in your emergency fund?"
        default: return "What's your target for this goal?"
        }
    }

    private var amountLabel: String {
        switch goalType {
        case .house: return "Down payment amount"
        case .babyFamily: return "Baby fund target"
        case .retirement: return "Retirement target"
        case .emergencyFund: return "Emergency fund target"
        default: return "Target amount"
        }
    }

    private var dateLabel: String {
        switch goalType {
        case .house: return "When do you want to buy?"
        case .babyFamily: return "Target timeline"
        case .retirement: return "When do you want to retire?"
        case .emergencyFund: return "When do you want this funded?"
        default: return "Target date"
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

#Preview("Retirement Goal") {
    let state = OnboardingState()
    state.selectedGoalType = .retirement
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
