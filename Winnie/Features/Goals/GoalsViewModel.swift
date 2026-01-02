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
final class GoalsViewModel {

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

    // MARK: - Dependencies

    private let coupleID: String
    private let repository: GoalRepository
    private let contributionRepository: ContributionRepository
    private var listenerRegistration: ListenerRegistrationProviding?

    // MARK: - Initialization

    /// Create a ViewModel with a couple ID.
    /// - Parameters:
    ///   - coupleID: The couple's Firestore document ID
    ///   - repository: Repository for data access
    ///   - contributionRepository: Repository for contribution operations
    init(coupleID: String, repository: GoalRepository, contributionRepository: ContributionRepository) {
        self.coupleID = coupleID
        self.repository = repository
        self.contributionRepository = contributionRepository
    }

    /// Convenience initializer using default production repositories.
    convenience init(coupleID: String) {
        self.init(coupleID: coupleID, repository: GoalRepository(), contributionRepository: ContributionRepository())
    }

    /// Call this to clean up resources before the ViewModel is deallocated.
    /// Typically called in .onDisappear or when navigating away.
    func cleanup() {
        listenerRegistration?.remove()
        listenerRegistration = nil
    }

    // MARK: - Real-time Listener

    /// Start listening to goals in real-time.
    /// Call this when the view appears.
    func startListening() {
        // Avoid duplicate listeners
        guard listenerRegistration == nil else { return }

        isLoading = true

        listenerRegistration = repository.listenToGoals(coupleID: coupleID) { [weak self] goals in
            // Firebase runs this listener on main thread, and GoalsViewModel is @MainActor,
            // so we can update state directly without wrapping in Task
            self?.goals = goals
            self?.isLoading = false
        }
    }

    /// Stop listening to goals.
    /// Call this when the view disappears if you want to pause updates.
    func stopListening() {
        listenerRegistration?.remove()
        listenerRegistration = nil
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

    // MARK: - Error Handling

    private func handleError(_ error: Error, context: String) {
        #if DEBUG
        print("GoalsViewModel error \(context): \(error.localizedDescription)")
        #endif

        // Set user-facing error message
        if let firestoreError = error as? FirestoreError {
            errorMessage = firestoreError.userMessage
        } else {
            errorMessage = "Something went wrong while \(context). Please try again."
        }

        showError = true
    }
}
