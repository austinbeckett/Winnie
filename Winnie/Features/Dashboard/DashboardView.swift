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
/// - Compact greeting
/// - Active plan card with budget health + next milestone
/// - 2x2 goal progress circles
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
                    VStack(alignment: .leading, spacing: WinnieSpacing.l) {
                        // Compact greeting (no card)
                        greetingText

                        // Active plan card with budget health
                        if let scenario = viewModel.activeScenario {
                            ActivePlanCard(
                                scenario: scenario,
                                savingsPool: viewModel.savingsPool,
                                allocatedGoals: viewModel.allocatedGoals,
                                projections: viewModel.projections
                            )
                        } else if viewModel.savingsPool > 0 {
                            // Show empty plan card only if they have a financial profile
                            EmptyPlanCard()
                        }

                        // Goals grid (2x2 progress circles)
                        if !viewModel.goals.isEmpty {
                            goalsGrid
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
    }

    // MARK: - Compact Greeting

    private var greetingText: some View {
        Text("Hi \(currentUser.greetingName)")
            .font(WinnieTypography.headlineM())
            .foregroundColor(WinnieColors.primaryText(for: colorScheme))
    }

    // MARK: - Goals Grid (2x2 Progress Circles)

    private var goalsGrid: some View {
        VStack(alignment: .leading, spacing: WinnieSpacing.m) {
            // Section header
            Text("Your Goals")
                .font(WinnieTypography.labelM())
                .foregroundColor(WinnieColors.secondaryText(for: colorScheme))

            // 2x2 grid of progress circles
            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: WinnieSpacing.m),
                GridItem(.flexible(), spacing: WinnieSpacing.m)
            ], spacing: WinnieSpacing.m) {
                ForEach(viewModel.goals.prefix(4)) { goal in
                    GoalProgressCell(goal: goal) {
                        // TODO: Navigate to goal detail
                    }
                }
            }

            // View all link (if more than 4 goals)
            if viewModel.goals.count > 4 {
                HStack {
                    Spacer()
                    Button(action: {
                        // TODO: Switch to Goals tab
                    }) {
                        HStack(spacing: WinnieSpacing.xs) {
                            Text("View All Goals")
                                .font(WinnieTypography.bodyS())

                            Image(systemName: "chevron.right")
                                .font(.system(size: 12, weight: .semibold))
                        }
                        .foregroundColor(WinnieColors.lavenderVeil)
                    }
                    Spacer()
                }
                .padding(.top, WinnieSpacing.xs)
            }
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
