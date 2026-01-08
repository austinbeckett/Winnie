import SwiftUI

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
final class GoalDetailViewModel: ErrorHandlingViewModel {

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

    /// Whether the add-to-plan sheet is showing
    var showAddToPlanSheet = false

    // MARK: - Dependencies

    let currentUser: User
    let partner: User?
    let coupleID: String
    private let contributionRepository: ContributionRepository
    private let goalsViewModel: GoalsViewModel

    /// Projection from the active plan (computed from parent ViewModel).
    ///
    /// This is computed rather than stored so it automatically updates
    /// when the active scenario changes.
    var projection: GoalProjection? {
        goalsViewModel.projection(for: goal.id)
    }

    /// Name of the active plan (if any).
    var activePlanName: String? {
        goalsViewModel.activeScenario?.name
    }

    /// The active scenario/plan (if any).
    var activeScenario: Scenario? {
        goalsViewModel.activeScenario
    }

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

    /// Calculate tracking status based on plan projections.
    ///
    /// Uses the projection from the active plan to determine if the goal
    /// is on track to meet its target date, or falls back to "not in plan"
    /// if no projection is available.
    var trackingStatus: GoalTrackingStatus {
        calculateTrackingStatus()
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

    /// Calculate tracking status based on plan projection.
    ///
    /// Priority order:
    /// 1. Completed - goal has reached target amount
    /// 2. No target date - can still show projected date if available
    /// 3. Not in plan - has target but no allocation
    /// 4. On track / Behind - based on projected vs target date
    private func calculateTrackingStatus() -> GoalTrackingStatus {
        // 1. Check if goal is completed
        if goal.currentAmount >= goal.targetAmount {
            return .completed
        }

        // 2. Check if there's a target date
        guard let targetDate = goal.desiredDate else {
            return .noTargetDate(projectedDate: projection?.completionDate)
        }

        // 3. Check if goal has a projection with allocation
        guard let projection = projection,
              projection.monthlyContribution > 0 else {
            return .notInPlan(targetDate: targetDate)
        }

        // 4. Check if projection is reachable
        guard let projectedDate = projection.completionDate else {
            // Unreachable goal (e.g., $0 allocation or infinite timeline)
            let required = FinancialEngine().requiredMonthlyContribution(for: goal, by: targetDate)
            return .behind(
                GoalTrackingStatus.TrackingDetails(
                    projectedDate: Date.distantFuture,
                    targetDate: targetDate,
                    monthsDifference: -999,
                    currentContribution: projection.monthlyContribution
                ),
                requiredContribution: required ?? 0
            )
        }

        // 5. Calculate months difference
        let calendar = Calendar.current
        let monthsDiff = calendar.dateComponents([.month], from: projectedDate, to: targetDate).month ?? 0

        let details = GoalTrackingStatus.TrackingDetails(
            projectedDate: projectedDate,
            targetDate: targetDate,
            monthsDifference: monthsDiff,
            currentContribution: projection.monthlyContribution
        )

        // 6. Determine if on track or behind
        // Compare at MONTH granularity to avoid drift issues from exact date comparisons.
        // Users think in terms of "March 2027" not "March 8, 2027 at 3:15:22 PM".
        let projectedComponents = calendar.dateComponents([.year, .month], from: projectedDate)
        let targetComponents = calendar.dateComponents([.year, .month], from: targetDate)

        let projectedMonths = (projectedComponents.year ?? 0) * 12 + (projectedComponents.month ?? 0)
        let targetMonths = (targetComponents.year ?? 0) * 12 + (targetComponents.month ?? 0)

        if projectedMonths <= targetMonths {
            return .onTrack(details)
        } else {
            let required = FinancialEngine().requiredMonthlyContribution(for: goal, by: targetDate)
            return .behind(details, requiredContribution: required ?? 0)
        }
    }

    /// Adjust the goal's target date to match the projected completion date.
    ///
    /// Only works when the goal is behind schedule. This allows users to
    /// accept the projected date with one tap, resolving the "behind" status.
    ///
    /// Note: Sets the target to the END of the projected month to provide
    /// a margin of safety. This ensures that any future recalculation
    /// landing in that month will still be considered "on track".
    func adjustTargetDateToProjection() async {
        guard case .behind(let details, _) = trackingStatus else { return }

        var updatedGoal = goal

        // Set target to END of the projected month for margin of safety.
        // This prevents drift issues where recalculations produce slightly
        // different dates within the same month.
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: details.projectedDate)

        if let startOfMonth = calendar.date(from: components),
           let endOfMonth = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: startOfMonth) {
            updatedGoal.desiredDate = endOfMonth
        } else {
            // Fallback to the original projected date if date math fails
            updatedGoal.desiredDate = details.projectedDate
        }

        await updateGoal(updatedGoal)
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
