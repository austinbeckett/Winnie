//
//  DashboardView.swift
//  Winnie
//
//  Created by Austin Beckett on 2026-01-02.
//

import SwiftUI

/// ViewModel for the Dashboard view.
@Observable
@MainActor
final class DashboardViewModel: ErrorHandlingViewModel {

    // MARK: - Published State

    var financialProfile: FinancialProfile?
    var activeScenario: Scenario?
    var goals: [Goal] = []
    var isLoading: Bool = false
    var errorMessage: String?
    var showError: Bool = false

    // MARK: - Computed Properties

    /// Monthly disposable income (savings pool)
    var savingsPool: Decimal {
        financialProfile?.monthlyDisposable ?? 0
    }

    /// Active scenario projections
    var projections: [String: GoalProjection] {
        guard let profile = financialProfile,
              let scenario = activeScenario else {
            return [:]
        }

        let engine = FinancialEngine()
        let input = EngineInput(
            profile: profile,
            goals: goals,
            allocations: scenario.allocations
        )

        return engine.calculate(input: input).projections
    }

    /// Goals with allocations from active scenario
    var allocatedGoals: [Goal] {
        guard let scenario = activeScenario else { return [] }
        return goals.filter { scenario.allocations[$0.id] > 0 }
    }

    /// Get allocation amount for a goal
    func allocation(for goalID: String) -> Decimal {
        activeScenario?.allocations[goalID] ?? 0
    }

    // MARK: - Dependencies

    private let coupleID: String
    private let coupleRepository: CoupleRepository
    private let scenarioRepository: ScenarioRepository
    private let goalRepository: GoalRepository
    private var profileListener: ListenerRegistrationProviding?
    private var scenarioListener: ListenerRegistrationProviding?
    private var goalsListener: ListenerRegistrationProviding?

    // MARK: - Initialization

    init(
        coupleID: String,
        coupleRepository: CoupleRepository? = nil,
        scenarioRepository: ScenarioRepository? = nil,
        goalRepository: GoalRepository? = nil
    ) {
        self.coupleID = coupleID
        self.coupleRepository = coupleRepository ?? CoupleRepository()
        self.scenarioRepository = scenarioRepository ?? ScenarioRepository()
        self.goalRepository = goalRepository ?? GoalRepository()
    }

    // MARK: - Data Loading

    func startListening() {
        isLoading = true

        // Listen to active scenario
        scenarioListener = scenarioRepository.listenToActiveScenario(coupleID: coupleID) { [weak self] scenario in
            self?.activeScenario = scenario
            self?.isLoading = false
        }

        // Listen to goals
        goalsListener = goalRepository.listenToGoals(coupleID: coupleID) { [weak self] goals in
            self?.goals = goals.filter { $0.isActive }
        }

        // Load financial profile (one-time)
        Task {
            do {
                financialProfile = try await coupleRepository.fetchFinancialProfile(coupleID: coupleID)
            } catch {
                // Profile might not exist yet - that's OK
                #if DEBUG
                print("Could not load financial profile: \(error)")
                #endif
            }
            isLoading = false
        }
    }

    func stopListening() {
        profileListener?.remove()
        scenarioListener?.remove()
        goalsListener?.remove()
        profileListener = nil
        scenarioListener = nil
        goalsListener = nil
    }
}

// MARK: - Dashboard View

/// Main dashboard view showing financial overview.
///
/// Displays:
/// - Welcome greeting with savings pool summary
/// - Active plan overview (if exists)
/// - Goal progress cards
/// - Quick actions
struct DashboardView: View {
    let coupleID: String
    let currentUser: User

    @State private var viewModel: DashboardViewModel
    @Environment(\.colorScheme) private var colorScheme

    init(coupleID: String, currentUser: User) {
        self.coupleID = coupleID
        self.currentUser = currentUser
        self._viewModel = State(initialValue: DashboardViewModel(coupleID: coupleID))
    }

    var body: some View {
        ZStack {
            WinnieColors.background(for: colorScheme)
                .ignoresSafeArea()

            if viewModel.isLoading && viewModel.goals.isEmpty {
                ProgressView()
                    .scaleEffect(1.2)
            } else {
                ScrollView {
                    VStack(spacing: WinnieSpacing.l) {
                        // Welcome card
                        welcomeCard

                        // Active plan summary
                        if viewModel.activeScenario != nil {
                            activePlanCard
                        }

                        // Goals overview
                        if !viewModel.goals.isEmpty {
                            goalsSection
                        }

                        // Empty state for new users
                        if viewModel.goals.isEmpty && viewModel.activeScenario == nil && !viewModel.isLoading {
                            emptyState
                        }
                    }
                    .padding(WinnieSpacing.l)
                }
            }
        }
        .navigationTitle("Dashboard")
        .navigationBarTitleDisplayMode(.large)
        .alert("Error", isPresented: $viewModel.showError) {
            Button("OK") { viewModel.showError = false }
        } message: {
            Text(viewModel.errorMessage ?? "An error occurred")
        }
        .onAppear {
            viewModel.startListening()
        }
        .onDisappear {
            viewModel.stopListening()
        }
    }

    // MARK: - Welcome Card

    private var welcomeCard: some View {
        WinnieCard(style: .ivoryBordered) {
            VStack(alignment: .leading, spacing: WinnieSpacing.m) {
                // Greeting
                Text("Hi \(currentUser.greetingName)!")
                    .font(WinnieTypography.headlineM())
                    .contextPrimaryText()

                // Savings pool summary
                if viewModel.savingsPool > 0 {
                    HStack {
                        VStack(alignment: .leading, spacing: WinnieSpacing.xxs) {
                            Text("Monthly savings pool")
                                .font(WinnieTypography.caption())
                                .contextSecondaryText()

                            Text(formatCurrency(viewModel.savingsPool))
                                .font(WinnieTypography.displayS())
                                .contextPrimaryText()
                        }

                        Spacer()

                        Image(systemName: "leaf.fill")
                            .font(.system(size: WinnieSpacing.iconSizeL))
                            .foregroundColor(WinnieColors.lavenderVeil)
                    }
                } else {
                    Text("Complete your financial profile to see your savings potential.")
                        .font(WinnieTypography.bodyS())
                        .contextSecondaryText()
                }
            }
        }
    }

    // MARK: - Active Plan Card

    private var activePlanCard: some View {
        WinnieCard(style: .ivoryBordered) {
            VStack(alignment: .leading, spacing: WinnieSpacing.m) {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: WinnieSpacing.xxs) {
                        HStack(spacing: WinnieSpacing.xs) {
                            Image(systemName: "star.fill")
                                .font(.system(size: 12))
                                .foregroundColor(WinnieColors.goldenOrange)

                            Text("Active Plan")
                                .font(WinnieTypography.caption())
                                .contextSecondaryText()
                        }

                        Text(viewModel.activeScenario?.name ?? "")
                            .font(WinnieTypography.headlineS())
                            .contextPrimaryText()
                    }

                    Spacer()

                    VStack(alignment: .trailing, spacing: WinnieSpacing.xxs) {
                        Text("Monthly")
                            .font(WinnieTypography.caption())
                            .contextTertiaryText()

                        Text(formatCurrency(viewModel.activeScenario?.allocations.totalAllocated ?? 0))
                            .font(WinnieTypography.bodyM())
                            .fontWeight(.semibold)
                            .contextPrimaryText()
                    }
                }

                // Goal timelines preview (top 3)
                if !viewModel.allocatedGoals.isEmpty {
                    Divider()
                        .background(WinnieColors.border(for: colorScheme))

                    VStack(spacing: WinnieSpacing.s) {
                        ForEach(viewModel.allocatedGoals.prefix(3)) { goal in
                            HStack {
                                Image(systemName: goal.type.iconName)
                                    .font(.system(size: WinnieSpacing.iconSizeS))
                                    .foregroundColor(goal.displayColor)

                                Text(goal.name)
                                    .font(WinnieTypography.bodyS())
                                    .contextPrimaryText()
                                    .lineLimit(1)

                                Spacer()

                                if let projection = viewModel.projections[goal.id], projection.isReachable {
                                    Text(projection.timeToCompletionText)
                                        .font(WinnieTypography.bodyS())
                                        .fontWeight(.medium)
                                        .contextSecondaryText()
                                }
                            }
                        }
                    }

                    if viewModel.allocatedGoals.count > 3 {
                        Text("+\(viewModel.allocatedGoals.count - 3) more goals")
                            .font(WinnieTypography.caption())
                            .contextTertiaryText()
                    }
                }
            }
        }
    }

    // MARK: - Goals Section

    private var goalsSection: some View {
        VStack(alignment: .leading, spacing: WinnieSpacing.m) {
            // Section header
            Text("Your Goals")
                .font(WinnieTypography.labelM())
                .foregroundColor(WinnieColors.secondaryText(for: colorScheme))

            // Goal cards
            ForEach(viewModel.goals.prefix(5)) { goal in
                goalProgressCard(goal)
            }

            if viewModel.goals.count > 5 {
                Text("View all \(viewModel.goals.count) goals in the Goals tab")
                    .font(WinnieTypography.caption())
                    .foregroundColor(WinnieColors.tertiaryText(for: colorScheme))
            }
        }
    }

    private func goalProgressCard(_ goal: Goal) -> some View {
        HStack(spacing: WinnieSpacing.m) {
            // Goal icon
            Circle()
                .fill(goal.displayColor.opacity(0.2))
                .frame(width: 44, height: 44)
                .overlay(
                    Image(systemName: goal.type.iconName)
                        .font(.system(size: WinnieSpacing.iconSizeM))
                        .foregroundColor(goal.displayColor)
                )

            // Goal info
            VStack(alignment: .leading, spacing: WinnieSpacing.xxs) {
                Text(goal.name)
                    .font(WinnieTypography.bodyM())
                    .fontWeight(.medium)
                    .foregroundColor(WinnieColors.primaryText(for: colorScheme))
                    .lineLimit(1)

                HStack(spacing: WinnieSpacing.xs) {
                    Text(formatCurrency(goal.currentAmount))
                        .font(WinnieTypography.caption())
                        .foregroundColor(WinnieColors.secondaryText(for: colorScheme))

                    Text("of \(formatCurrency(goal.targetAmount))")
                        .font(WinnieTypography.caption())
                        .foregroundColor(WinnieColors.tertiaryText(for: colorScheme))
                }
            }

            Spacer()

            // Progress percentage
            Text("\(Int(goal.progressPercentage * 100))%")
                .font(WinnieTypography.bodyS())
                .fontWeight(.semibold)
                .foregroundColor(goal.displayColor)
        }
        .padding(WinnieSpacing.m)
        .background(cardBackgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: WinnieSpacing.inputCornerRadius))
        .overlay(
            RoundedRectangle(cornerRadius: WinnieSpacing.inputCornerRadius)
                .stroke(WinnieColors.border(for: colorScheme), lineWidth: 1)
        )
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: WinnieSpacing.l) {
            Image(systemName: "sparkles")
                .font(.system(size: 48))
                .foregroundColor(WinnieColors.lavenderVeil)

            VStack(spacing: WinnieSpacing.s) {
                Text("Welcome to Winnie!")
                    .font(WinnieTypography.headlineM())
                    .foregroundColor(WinnieColors.primaryText(for: colorScheme))

                Text("Create your first goal to start planning your financial future together.")
                    .font(WinnieTypography.bodyM())
                    .foregroundColor(WinnieColors.secondaryText(for: colorScheme))
                    .multilineTextAlignment(.center)
            }
        }
        .padding(WinnieSpacing.xl)
    }

    // MARK: - Helpers

    private var cardBackgroundColor: Color {
        colorScheme == .dark
            ? WinnieColors.carbonBlack.opacity(0.5)
            : WinnieColors.ivory.opacity(0.5)
    }

    private func formatCurrency(_ amount: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSDecimalNumber(decimal: amount)) ?? "$0"
    }
}

// MARK: - Previews

#Preview("Dashboard") {
    NavigationStack {
        DashboardView(coupleID: "preview", currentUser: .sample)
    }
}

#Preview("Dark Mode") {
    NavigationStack {
        DashboardView(coupleID: "preview", currentUser: .sample)
    }
    .preferredColorScheme(.dark)
}
