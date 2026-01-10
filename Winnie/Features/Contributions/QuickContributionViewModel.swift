import Foundation

/// Result of saving multiple contributions
struct BatchSaveResult {
    let successCount: Int
    let failureCount: Int
    let failedGoalNames: [String]

    var isFullSuccess: Bool { failureCount == 0 }
    var hasAnySuccess: Bool { successCount > 0 }
}

/// ViewModel for the quick contribution screen.
///
/// Manages input state for multiple goals and handles batch saving.
/// Uses sequential saves since Firestore doesn't support batch writes
/// across multiple subcollections.
///
/// ## Usage
/// ```swift
/// @State private var viewModel = QuickContributionViewModel(
///     goals: goals,
///     currentUserID: "user-1",
///     coupleID: "couple-1"
/// )
/// ```
@Observable
@MainActor
final class QuickContributionViewModel: ErrorHandlingViewModel {

    // MARK: - Form State

    /// Amount text for each goal, keyed by goal ID
    var amountInputs: [String: String] = [:]

    /// Shared date for all contributions (defaults to today)
    var contributionDate: Date = Date()

    // MARK: - Loading State

    var isLoading = false
    var errorMessage: String?
    var showError = false

    // MARK: - Dependencies

    let goals: [Goal]
    let allocations: Allocation
    let currentUserID: String
    let coupleID: String

    private let contributionRepository: ContributionRepository
    private let goalRepository: GoalRepository

    // MARK: - Allocation Helpers

    /// Get the monthly allocation for a specific goal from the active scenario.
    func allocation(for goalID: String) -> Decimal {
        allocations[goalID]
    }

    /// Quick-fill the input field with the goal's monthly allocation amount.
    func quickFill(goalID: String) {
        let amount = allocation(for: goalID)
        guard amount > 0 else { return }

        // Format as integer string (no decimals for whole dollar amounts)
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 0
        amountInputs[goalID] = formatter.string(from: NSDecimalNumber(decimal: amount)) ?? "\(amount)"
    }

    // MARK: - Initialization

    init(
        goals: [Goal],
        allocations: Allocation,
        currentUserID: String,
        coupleID: String,
        contributionRepository: ContributionRepository,
        goalRepository: GoalRepository
    ) {
        self.goals = goals
        self.allocations = allocations
        self.currentUserID = currentUserID
        self.coupleID = coupleID
        self.contributionRepository = contributionRepository
        self.goalRepository = goalRepository

        // Initialize empty inputs for each goal
        for goal in goals {
            amountInputs[goal.id] = ""
        }
    }

    /// Convenience initializer using default production repositories.
    /// Must be called from MainActor context.
    convenience init(
        goals: [Goal],
        allocations: Allocation,
        currentUserID: String,
        coupleID: String
    ) {
        self.init(
            goals: goals,
            allocations: allocations,
            currentUserID: currentUserID,
            coupleID: coupleID,
            contributionRepository: ContributionRepository(),
            goalRepository: GoalRepository()
        )
    }

    // MARK: - Computed Properties

    /// Goals that have valid, non-zero amounts entered
    var goalsWithAmounts: [(goal: Goal, amount: Decimal)] {
        goals.compactMap { goal in
            guard let text = amountInputs[goal.id],
                  let amount = parseAmount(text),
                  amount > 0 else {
                return nil
            }
            return (goal, amount)
        }
    }

    /// Whether the save button should be enabled
    var canSave: Bool {
        !goalsWithAmounts.isEmpty && !isLoading
    }

    /// Number of goals with amounts entered (for UI feedback)
    var enteredCount: Int {
        goalsWithAmounts.count
    }

    // MARK: - Actions

    /// Save all contributions with entered amounts.
    ///
    /// Saves each contribution sequentially, continuing even if one fails.
    /// Updates each goal's currentAmount after successful contribution save.
    ///
    /// - Returns: Result containing success/failure counts
    func saveAllContributions() async -> BatchSaveResult {
        let toSave = goalsWithAmounts
        guard !toSave.isEmpty else {
            return BatchSaveResult(successCount: 0, failureCount: 0, failedGoalNames: [])
        }

        isLoading = true

        var successCount = 0
        var failedGoalNames: [String] = []

        for (goal, amount) in toSave {
            do {
                // Create the contribution
                let contribution = Contribution(
                    goalId: goal.id,
                    userId: currentUserID,
                    amount: amount,
                    date: contributionDate,
                    notes: nil
                )

                // Save contribution to Firestore
                try await contributionRepository.createContribution(
                    contribution,
                    coupleID: coupleID,
                    goalID: goal.id
                )

                // Update goal's current amount
                let newAmount = goal.currentAmount + amount
                try await goalRepository.updateGoalProgress(
                    goalID: goal.id,
                    currentAmount: newAmount,
                    coupleID: coupleID
                )

                successCount += 1
            } catch {
                #if DEBUG
                print("QuickContributionViewModel: Failed to save contribution for \(goal.name): \(error)")
                #endif
                failedGoalNames.append(goal.name)
            }
        }

        isLoading = false

        let result = BatchSaveResult(
            successCount: successCount,
            failureCount: failedGoalNames.count,
            failedGoalNames: failedGoalNames
        )

        // If there were any failures, set error state
        if !result.isFullSuccess {
            errorMessage = "Failed to save contributions for: \(failedGoalNames.joined(separator: ", "))"
            showError = true
        }

        return result
    }

    /// Clear all entered amounts
    func clearAllAmounts() {
        for goalID in amountInputs.keys {
            amountInputs[goalID] = ""
        }
    }

    // MARK: - Amount Parsing

    /// Maximum allowed contribution amount ($999,999,999)
    private static let maxContributionAmount = Decimal(999_999_999)

    /// Parse a text string into a Decimal amount.
    ///
    /// Removes currency symbols and formatting, validates bounds.
    /// - Parameter text: The input text from a currency field
    /// - Returns: A valid Decimal amount, or nil if invalid
    func parseAmount(_ text: String) -> Decimal? {
        // Remove any non-numeric characters except decimal point
        let cleaned = text.replacingOccurrences(
            of: "[^0-9.]",
            with: "",
            options: .regularExpression
        )

        guard !cleaned.isEmpty,
              let amount = Decimal(string: cleaned) else {
            return nil
        }

        // Validate reasonable bounds
        guard amount >= 0, amount <= Self.maxContributionAmount else {
            return nil
        }

        return amount
    }
}

// MARK: - Preview Helpers

extension QuickContributionViewModel {

    /// Create a sample ViewModel for SwiftUI previews
    static var preview: QuickContributionViewModel {
        QuickContributionViewModel(
            goals: Goal.samples,
            allocations: Allocation(),
            currentUserID: "preview-user",
            coupleID: "preview-couple"
        )
    }
}
