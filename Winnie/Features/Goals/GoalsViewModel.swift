import SwiftUI

/// ViewModel for managing goals state and operations.
///
/// Uses the modern @Observable macro (iOS 17+) for automatic change tracking.
/// All state updates are isolated to @MainActor for thread safety with SwiftUI.
///
/// ## Usage
/// ```swift
/// // In a view
/// @State private var viewModel = GoalsViewModel(coupleID: "abc123")
///
/// // Or with injected repository for testing
/// let mockRepo = GoalRepository(db: mockFirestore)
/// let viewModel = GoalsViewModel(coupleID: "test", repository: mockRepo)
/// ```
@Observable
@MainActor
final class GoalsViewModel: ErrorHandlingViewModel {

    // MARK: - Published State

    /// All goals for the couple, ordered by priority
    var goals: [Goal] = []

    /// Currently selected goal (for detail view)
    var selectedGoal: Goal?

    /// Loading state for async operations
    var isLoading = false

    /// Error message to display
    var errorMessage: String?

    /// Whether to show error alert
    var showError = false

    // MARK: - Scenario & Projection State

    /// Active scenario for projections (loaded from listener)
    private(set) var activeScenario: Scenario?

    /// Financial profile for projection calculations
    private(set) var financialProfile: FinancialProfile?

    /// Computed projections for all goals based on active scenario.
    ///
    /// Returns empty dictionary if no active scenario or financial profile.
    /// Recalculates automatically when scenario, profile, or goals change.
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

    /// Get projection for a specific goal.
    func projection(for goalID: String) -> GoalProjection? {
        projections[goalID]
    }

    // MARK: - Dependencies

    private let coupleID: String
    private let repository: GoalRepository
    private let contributionRepository: ContributionRepository
    private let scenarioRepository: ScenarioRepository
    private let coupleRepository: CoupleRepository
    private var listenerRegistration: ListenerRegistrationProviding?
    private var scenarioListener: ListenerRegistrationProviding?

    // MARK: - Initialization

    /// Create a ViewModel with a couple ID.
    /// - Parameters:
    ///   - coupleID: The couple's Firestore document ID
    ///   - repository: Repository for goal data access
    ///   - contributionRepository: Repository for contribution operations
    ///   - scenarioRepository: Repository for scenario data access
    ///   - coupleRepository: Repository for couple/profile data access
    init(
        coupleID: String,
        repository: GoalRepository,
        contributionRepository: ContributionRepository,
        scenarioRepository: ScenarioRepository,
        coupleRepository: CoupleRepository
    ) {
        self.coupleID = coupleID
        self.repository = repository
        self.contributionRepository = contributionRepository
        self.scenarioRepository = scenarioRepository
        self.coupleRepository = coupleRepository
    }

    /// Convenience initializer using default production repositories.
    convenience init(coupleID: String) {
        self.init(
            coupleID: coupleID,
            repository: GoalRepository(),
            contributionRepository: ContributionRepository(),
            scenarioRepository: ScenarioRepository(),
            coupleRepository: CoupleRepository()
        )
    }


    /// Call this to clean up resources before the ViewModel is deallocated.
    /// Typically called in .onDisappear or when navigating away.
    func cleanup() {
        listenerRegistration?.remove()
        listenerRegistration = nil
        scenarioListener?.remove()
        scenarioListener = nil
    }

    // MARK: - Real-time Listener

    /// Start listening to goals and active scenario in real-time.
    /// Call this when the view appears.
    func startListening() {
        // Avoid duplicate listeners
        guard listenerRegistration == nil else { return }

        isLoading = true

        // Listen to goals
        listenerRegistration = repository.listenToGoals(coupleID: coupleID) { [weak self] goals in
            // Firebase runs this listener on main thread, and GoalsViewModel is @MainActor,
            // so we can update state directly without wrapping in Task
            self?.goals = goals
            self?.isLoading = false
        }

        // Listen to active scenario for projections
        scenarioListener = scenarioRepository.listenToActiveScenario(coupleID: coupleID) { [weak self] scenario in
            self?.activeScenario = scenario
        }

        // Load financial profile (one-time fetch)
        Task { [weak self] in
            guard let self else { return }
            self.financialProfile = try? await self.coupleRepository.fetchFinancialProfile(coupleID: self.coupleID)
        }
    }

    /// Stop listening to goals and scenario.
    /// Call this when the view disappears if you want to pause updates.
    func stopListening() {
        listenerRegistration?.remove()
        listenerRegistration = nil
        scenarioListener?.remove()
        scenarioListener = nil
    }

    // MARK: - CRUD Operations

    /// Create a new goal, optionally with an initial contribution for starting balance.
    /// - Parameters:
    ///   - goal: The goal to create
    ///   - userID: The ID of the user creating the goal (required for initial contribution)
    func createGoal(_ goal: Goal, userID: String) async {
        isLoading = true
        errorMessage = nil

        do {
            try await repository.createGoal(goal, coupleID: coupleID)

            // Create initial contribution if there's a starting balance
            if goal.currentAmount > 0 {
                let contribution = Contribution(
                    goalId: goal.id,
                    userId: userID,
                    amount: goal.currentAmount,
                    date: goal.createdAt,
                    notes: "Starting balance"
                )
                try await contributionRepository.createContribution(
                    contribution,
                    coupleID: coupleID,
                    goalID: goal.id
                )
            }
            // Real-time listener will update the goals array
        } catch {
            handleError(error, context: "creating goal")
        }

        isLoading = false
    }

    /// Update an existing goal.
    func updateGoal(_ goal: Goal) async {
        isLoading = true
        errorMessage = nil

        do {
            try await repository.updateGoal(goal, coupleID: coupleID)
            // Real-time listener will update the goals array
        } catch {
            handleError(error, context: "updating goal")
        }

        isLoading = false
    }

    /// Delete a goal by ID.
    func deleteGoal(_ goal: Goal) async {
        isLoading = true
        errorMessage = nil

        do {
            try await repository.deleteGoal(id: goal.id, coupleID: coupleID)
            // Real-time listener will update the goals array
        } catch {
            handleError(error, context: "deleting goal")
        }

        isLoading = false
    }

    /// Delete a goal by ID.
    func deleteGoal(id: String) async {
        isLoading = true
        errorMessage = nil

        do {
            try await repository.deleteGoal(id: id, coupleID: coupleID)
        } catch {
            handleError(error, context: "deleting goal")
        }

        isLoading = false
    }

    // MARK: - Convenience Methods

    /// Refresh goals manually (one-time fetch).
    /// Usually not needed since we use real-time listener.
    func refreshGoals() async {
        isLoading = true
        errorMessage = nil

        do {
            goals = try await repository.fetchAllGoals(coupleID: coupleID)
        } catch {
            handleError(error, context: "fetching goals")
        }

        isLoading = false
    }

    /// Get a goal by ID from the current list.
    func goal(withID id: String) -> Goal? {
        goals.first { $0.id == id }
    }

}
