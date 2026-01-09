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

    /// Total amount saved across all goals
    var totalSavedAmount: Decimal {
        goals.reduce(Decimal.zero) { $0 + $1.currentAmount }
    }

    /// Overall progress percentage for near-term goals (desired date within 10 years)
    /// Excludes long-term goals like retirement to avoid skewing perception
    var overallProgress: Double {
        let nearTermGoals = goals.filter { goal in
            guard let desiredDate = goal.desiredDate else {
                // Goals without desired dates are considered near-term
                return true
            }
            let yearsUntilTarget = Calendar.current.dateComponents(
                [.year],
                from: Date(),
                to: desiredDate
            ).year ?? 0
            return yearsUntilTarget <= 10
        }

        guard !nearTermGoals.isEmpty else { return 0 }

        let totalProgress = nearTermGoals.reduce(0.0) { $0 + $1.progressPercentage }
        return totalProgress / Double(nearTermGoals.count)
    }

    /// Contribution streak in months (consecutive months of full allocation)
    /// TODO: Implement actual streak tracking from Firestore
    var contributionStreak: Int {
        // Placeholder: In the future, this will be tracked in Firestore
        // by comparing monthly goal progress against planned allocations
        // For now, return 0 to show the encouraging zero state
        0
    }

    /// Whether the user is on track with their goals
    /// Returns true if average goal progress meets or exceeds expected progress based on timeline
    var isOnTrack: Bool {
        // Check if allocated goals are on track based on their projections
        guard !allocatedGoals.isEmpty else { return false }

        let onTrackGoals = allocatedGoals.filter { goal in
            guard let projection = projections[goal.id],
                  projection.isReachable else {
                return false
            }
            // Goal is on track if it has a valid projection and is reachable
            return true
        }

        // On track if at least 80% of goals have valid, reachable projections
        let onTrackRatio = Double(onTrackGoals.count) / Double(allocatedGoals.count)
        return onTrackRatio >= 0.8
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
/// - Compact greeting
/// - Active plan card with budget health + next milestone
/// - 2x2 goal progress circles
struct DashboardView: View {
    let coupleID: String
    let currentUser: User
    let partner: User?

    @State private var viewModel: DashboardViewModel
    @State private var selectedGoal: Goal?
    @State private var selectedScenario: Scenario?
    @Environment(\.colorScheme) private var colorScheme
    @Environment(TabCoordinator.self) private var tabCoordinator: TabCoordinator?

    init(coupleID: String, currentUser: User, partner: User? = nil) {
        self.coupleID = coupleID
        self.currentUser = currentUser
        self.partner = partner
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
                    VStack(alignment: .leading, spacing: WinnieSpacing.l) {
                        // Active plan card
                        if let scenario = viewModel.activeScenario {
                            ActivePlanCard(
                                scenario: scenario,
                                totalSaved: viewModel.totalSavedAmount,
                                isOnTrack: viewModel.isOnTrack,
                                onTap: { selectedScenario = scenario }
                            )

                            // Grid layout: 3-card stack on left, goals card on right
                            // Math: gridHeight (392) = 3 × cardHeight (120) + 2 × spacing (16)
                            HStack(alignment: .top, spacing: WinnieSpacing.m) {
                                // Left column: 3 equal-height placeholder cards
                                VStack(spacing: WinnieSpacing.m) {
                                    DashboardPlaceholderCard(title: "Coming Soon")
                                        .frame(height: 120)

                                    DashboardPlaceholderCard(title: "Coming Soon")
                                        .frame(height: 120)

                                    DashboardPlaceholderCard(title: "Coming Soon")
                                        .frame(height: 120)
                                }
                                .frame(maxWidth: .infinity)

                                // Right column: Goals stack (same total height: 392pt)
                                if !viewModel.goals.isEmpty {
                                    GoalsStackCard(
                                        goals: viewModel.goals,
                                        onGoalTap: { goal in selectedGoal = goal }
                                    )
                                    .frame(maxWidth: .infinity)
                                }
                            }
                        } else if viewModel.savingsPool > 0 {
                            // Show empty plan card only if they have a financial profile
                            EmptyPlanCard(onTap: {
                                tabCoordinator?.switchToPlanning()
                            })
                        }

                        // Empty state for brand new users
                        if viewModel.goals.isEmpty && viewModel.activeScenario == nil && viewModel.savingsPool == 0 && !viewModel.isLoading {
                            emptyState
                        }
                    }
                    .padding(WinnieSpacing.l)
                }
            }
        }
        .navigationTitle("Dashboard")
        .navigationBarTitleDisplayMode(.inline)
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
        .navigationDestination(item: $selectedGoal) { goal in
            GoalDetailView(
                goal: goal,
                currentUser: currentUser,
                partner: partner,
                coupleID: coupleID,
                goalsViewModel: GoalsViewModel(coupleID: coupleID)
            )
        }
        .navigationDestination(item: $selectedScenario) { scenario in
            ScenarioDetailView(
                scenario: scenario,
                coupleID: coupleID,
                userID: currentUser.id
            )
        }
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
        .frame(maxWidth: .infinity)
        .padding(WinnieSpacing.xl)
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

// MARK: - Array Chunking Extension

extension Array {
    /// Splits the array into chunks of the specified size.
    ///
    /// Example:
    /// ```swift
    /// [1, 2, 3, 4, 5, 6, 7].chunked(into: 4)
    /// // Returns: [[1, 2, 3, 4], [5, 6, 7]]
    /// ```
    func chunked(into size: Int) -> [[Element]] {
        guard size > 0 else { return [] }
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0..<Swift.min($0 + size, count)])
        }
    }
}
