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
    private var listenerRegistration: ListenerRegistrationProviding?

    // MARK: - Initialization

    /// Create a ViewModel with a couple ID.
    /// - Parameters:
    ///   - coupleID: The couple's Firestore document ID
    ///   - repository: Repository for data access (defaults to production)
    init(coupleID: String, repository: GoalRepository) {
        self.coupleID = coupleID
        self.repository = repository
    }

    /// Convenience initializer using default production repository.
    convenience init(coupleID: String) {
        self.init(coupleID: coupleID, repository: GoalRepository())
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
            // This callback runs on the main thread (Firebase behavior)
            // But we're @MainActor isolated, so direct assignment is safe
            Task { @MainActor in
                self?.goals = goals
                self?.isLoading = false
            }
        }
    }

    /// Stop listening to goals.
    /// Call this when the view disappears if you want to pause updates.
    func stopListening() {
        listenerRegistration?.remove()
        listenerRegistration = nil
    }

    // MARK: - CRUD Operations

    /// Create a new goal.
    func createGoal(_ goal: Goal) async {
        isLoading = true
        errorMessage = nil

        do {
            try await repository.createGoal(goal, coupleID: coupleID)
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
        // Log for debugging
        print("GoalsViewModel error \(context): \(error.localizedDescription)")

        // Set user-facing error message
        if let firestoreError = error as? FirestoreError {
            errorMessage = firestoreError.userMessage
        } else {
            errorMessage = "Something went wrong while \(context). Please try again."
        }

        showError = true
    }
}

// MARK: - FirestoreError Extension

private extension FirestoreError {
    /// User-friendly error message
    var userMessage: String {
        switch self {
        case .documentNotFound:
            return "The goal could not be found."
        case .decodingFailed:
            return "There was a problem loading the goal data."
        case .encodingFailed:
            return "There was a problem saving the goal."
        case .unauthorized:
            return "You don't have permission to access this goal."
        case .transactionFailed:
            return "The operation failed. Please try again."
        case .invalidData(let reason):
            return "Invalid data: \(reason)"
        case .inviteCodeExpired, .inviteCodeAlreadyUsed, .coupleAlreadyComplete:
            return "An unexpected error occurred."
        case .unknown(let error):
            return error.localizedDescription
        }
    }
}
