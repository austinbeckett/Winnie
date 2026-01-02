import SwiftUI

/// Status of goal progress relative to target date
enum OnTrackStatus: Equatable {
    case onTrack
    case behind
    case noTarget
    case completed
}

/// ViewModel for managing goal detail state including contributions.
///
/// Uses @Observable for automatic change tracking and @MainActor for thread safety.
/// Manages real-time contribution updates and syncs goal progress.
///
/// ## Usage
/// ```swift
/// @State private var viewModel = GoalDetailViewModel(
///     goal: goal,
///     currentUser: user,
///     partner: partner,
///     coupleID: "abc123",
///     goalsViewModel: goalsVM
/// )
/// ```
@Observable
@MainActor
final class GoalDetailViewModel {

    // MARK: - Published State

    /// The goal being displayed
    var goal: Goal

    /// All contributions for this goal, ordered by date (newest first)
    var contributions: [Contribution] = []

    /// Loading state for async operations
    var isLoading = false

    /// Error message to display
    var errorMessage: String?

    /// Whether to show error alert
    var showError = false

    /// Whether the add contribution sheet is showing
    var showAddContribution = false

    /// Contribution being edited (nil for new contribution)
    var contributionToEdit: Contribution?

    // MARK: - Dependencies

    let currentUser: User
    let partner: User?
    private let coupleID: String
    private let contributionRepository: ContributionRepository
    private let goalsViewModel: GoalsViewModel

    // MARK: - Initialization

    /// Create a ViewModel for goal detail.
    /// - Parameters:
    ///   - goal: The goal to display
    ///   - currentUser: The currently logged-in user
    ///   - partner: The user's partner (if connected)
    ///   - coupleID: The couple's Firestore document ID
    ///   - goalsViewModel: Parent ViewModel for updating goals
    ///   - contributionRepository: Repository for contribution data (defaults to production)
    init(
        goal: Goal,
        currentUser: User,
        partner: User?,
        coupleID: String,
        goalsViewModel: GoalsViewModel,
        contributionRepository: ContributionRepository? = nil
    ) {
        self.goal = goal
        self.currentUser = currentUser
        self.partner = partner
        self.coupleID = coupleID
        self.goalsViewModel = goalsViewModel
        self.contributionRepository = contributionRepository ?? ContributionRepository()
    }

    /// Clean up resources before deallocation.
    func cleanup() {
        // No listener to clean up
    }

    // MARK: - Computed Properties

    /// Current user's ID
    var currentUserID: String {
        currentUser.id
    }

    /// Current user's display name
    var currentUserName: String {
        currentUser.firstName ?? "You"
    }

    /// Partner's display name
    var partnerName: String {
        partner?.firstName ?? "Partner"
    }

    /// Total amount contributed by current user
    var currentUserTotal: Decimal {
        contributions
            .filter { $0.userId == currentUser.id }
            .reduce(Decimal.zero) { $0 + $1.amount }
    }

    /// Total amount contributed by partner
    var partnerTotal: Decimal {
        guard let partner else { return Decimal.zero }
        return contributions
            .filter { $0.userId == partner.id }
            .reduce(Decimal.zero) { $0 + $1.amount }
    }

    /// Recent contributions (first 5)
    var recentContributions: [Contribution] {
        Array(contributions.prefix(5))
    }

    /// Whether there are more contributions than shown in recent
    var hasMoreContributions: Bool {
        contributions.count > 5
    }

    /// Calculate on-track status based on linear progress
    var onTrackStatus: OnTrackStatus {
        calculateOnTrackStatus()
    }

    /// Check if a contribution belongs to the current user
    func isCurrentUserContribution(_ contribution: Contribution) -> Bool {
        contribution.userId == currentUser.id
    }

    /// Get display name for a contribution's user
    func displayName(for contribution: Contribution) -> String {
        if contribution.userId == currentUser.id {
            return currentUserName
        } else if contribution.userId == partner?.id {
            return partnerName
        } else {
            return "Unknown"
        }
    }

    /// Get initials for a user ID
    func initials(for userId: String) -> String {
        if userId == currentUser.id {
            return UserInitialsAvatar.extractInitials(from: currentUser.displayName)
        } else if userId == partner?.id {
            return UserInitialsAvatar.extractInitials(from: partner?.displayName)
        }
        return "?"
    }

    // MARK: - Data Loading

    /// Load contributions once on appear.
    func startListening() {
        guard !hasLoadedContributions else { return }
        hasLoadedContributions = true

        isLoading = true

        Task {
            do {
                let fetched = try await contributionRepository.fetchContributions(
                    coupleID: coupleID,
                    goalID: goal.id
                )
                contributions = fetched
            } catch {
                handleError(error, context: "loading contributions")
            }
            isLoading = false
        }
    }

    /// No-op for now (no listener to stop).
    func stopListening() {
        // No listener to remove
    }

    /// Track if we've loaded contributions
    private var hasLoadedContributions = false

    // MARK: - Contribution CRUD

    /// Add a new contribution from the current user.
    func addContribution(amount: Decimal, date: Date, notes: String?) async {
        isLoading = true
        errorMessage = nil

        let contribution = Contribution(
            goalId: goal.id,
            userId: currentUser.id,
            amount: amount,
            date: date,
            notes: notes
        )

        do {
            try await contributionRepository.createContribution(
                contribution,
                coupleID: coupleID,
                goalID: goal.id
            )
            // Add to local array immediately for instant UI update
            contributions.insert(contribution, at: 0)
            // Add contribution amount to current total
            await updateGoalAmount(by: amount)
        } catch {
            handleError(error, context: "adding contribution")
        }

        isLoading = false
    }

    /// Update an existing contribution.
    func updateContribution(_ contribution: Contribution) async {
        guard isCurrentUserContribution(contribution) else {
            errorMessage = "You can only edit your own contributions."
            showError = true
            return
        }

        isLoading = true
        errorMessage = nil

        // Find the old amount to calculate the difference
        let oldAmount = contributions.first { $0.id == contribution.id }?.amount ?? Decimal.zero
        let difference = contribution.amount - oldAmount

        do {
            try await contributionRepository.updateContribution(
                contribution,
                coupleID: coupleID,
                goalID: goal.id
            )
            // Update local array immediately for instant UI update
            if let index = contributions.firstIndex(where: { $0.id == contribution.id }) {
                contributions[index] = contribution
            }
            // Adjust by the difference between new and old amount
            await updateGoalAmount(by: difference)
        } catch {
            handleError(error, context: "updating contribution")
        }

        isLoading = false
    }

    /// Delete a contribution.
    func deleteContribution(_ contribution: Contribution) async {
        guard isCurrentUserContribution(contribution) else {
            errorMessage = "You can only delete your own contributions."
            showError = true
            return
        }

        isLoading = true
        errorMessage = nil

        do {
            try await contributionRepository.deleteContribution(
                id: contribution.id,
                coupleID: coupleID,
                goalID: goal.id
            )
            // Remove from local array immediately for instant UI update
            contributions.removeAll { $0.id == contribution.id }
            // Subtract the deleted contribution amount
            await updateGoalAmount(by: -contribution.amount)
        } catch {
            handleError(error, context: "deleting contribution")
        }

        isLoading = false
    }

    // MARK: - Goal Sync

    /// Update the goal's currentAmount by a delta (positive to add, negative to subtract).
    private func updateGoalAmount(by delta: Decimal) async {
        guard delta != 0 else { return }

        var updatedGoal = goal
        updatedGoal.currentAmount = goal.currentAmount + delta
        goal = updatedGoal
        await goalsViewModel.updateGoal(updatedGoal)
    }

    /// Update the goal (e.g., account name).
    func updateGoal(_ updatedGoal: Goal) async {
        goal = updatedGoal
        await goalsViewModel.updateGoal(updatedGoal)
    }

    // MARK: - Status Calculation

    private func calculateOnTrackStatus() -> OnTrackStatus {
        // Check if goal is completed
        if goal.currentAmount >= goal.targetAmount {
            return .completed
        }

        // Check if there's a target date
        guard let targetDate = goal.desiredDate else {
            return .noTarget
        }

        let now = Date()

        // If past target date
        guard targetDate > now else {
            return goal.currentAmount >= goal.targetAmount ? .completed : .behind
        }

        // Calculate linear progress expectation
        let totalDuration = targetDate.timeIntervalSince(goal.createdAt)
        guard totalDuration > 0 else { return .onTrack }

        let elapsed = now.timeIntervalSince(goal.createdAt)
        guard elapsed > 0 else { return .onTrack }

        let expectedProgress = elapsed / totalDuration
        let expectedAmount = goal.targetAmount * Decimal(expectedProgress)

        return goal.currentAmount >= expectedAmount ? .onTrack : .behind
    }

    // MARK: - Error Handling

    private func handleError(_ error: Error, context: String) {
        #if DEBUG
        print("GoalDetailViewModel error \(context): \(error.localizedDescription)")
        #endif

        if let firestoreError = error as? FirestoreError {
            errorMessage = firestoreError.userMessage
        } else {
            errorMessage = "Something went wrong while \(context). Please try again."
        }

        showError = true
    }
}

// MARK: - Preview Helpers

extension GoalDetailViewModel {

    /// Create a preview ViewModel with sample data
    @MainActor
    static func preview(
        goal: Goal? = nil,
        contributions: [Contribution] = []
    ) -> GoalDetailViewModel {
        let previewGoal = goal ?? .sampleHouse
        let vm = GoalDetailViewModel(
            goal: previewGoal,
            currentUser: .sample,
            partner: .samplePartner,
            coupleID: "preview-couple",
            goalsViewModel: GoalsViewModel(coupleID: "preview-couple")
        )
        vm.contributions = contributions.isEmpty
            ? Contribution.samples(goalId: previewGoal.id, userIds: [User.sample.id, User.samplePartner.id])
            : contributions
        return vm
    }
}
