import Foundation

/// Shared container for a couple's financial data
/// This is the primary Firestore document that contains goals and scenarios
struct Couple: Codable, Identifiable, Equatable {

    /// Unique couple identifier (Firestore document ID)
    let id: String

    /// Array of user IDs (1-2 users)
    var memberIDs: [String]

    /// Shared financial profile
    var financialProfile: FinancialProfile

    /// Creation timestamp
    let createdAt: Date

    /// Partner invitation code (for joining)
    var inviteCode: String?

    /// Invite code expiration date
    var inviteCodeExpiresAt: Date?

    // MARK: - Computed Properties

    /// Number of members (1 = solo, 2 = couple)
    var memberCount: Int {
        memberIDs.count
    }

    /// Whether the couple is complete (two members)
    var isComplete: Bool {
        memberIDs.count == 2
    }

    /// Whether there's a valid, non-expired invite code
    var hasValidInviteCode: Bool {
        guard let code = inviteCode, !code.isEmpty,
              let expiresAt = inviteCodeExpiresAt else {
            return false
        }
        return expiresAt > Date()
    }

    // MARK: - Initializer

    init(
        id: String = UUID().uuidString,
        memberIDs: [String],
        financialProfile: FinancialProfile = FinancialProfile(),
        createdAt: Date = Date(),
        inviteCode: String? = nil,
        inviteCodeExpiresAt: Date? = nil
    ) {
        self.id = id
        self.memberIDs = memberIDs
        self.financialProfile = financialProfile
        self.createdAt = createdAt
        self.inviteCode = inviteCode
        self.inviteCodeExpiresAt = inviteCodeExpiresAt
    }

    // MARK: - Methods

    /// Generate a new invite code with 7-day expiration
    mutating func generateInviteCode() {
        inviteCode = generateRandomCode()
        inviteCodeExpiresAt = Calendar.current.date(byAdding: .day, value: 7, to: Date())
    }

    /// Clear the invite code
    mutating func clearInviteCode() {
        inviteCode = nil
        inviteCodeExpiresAt = nil
    }

    /// Add a partner to the couple
    mutating func addPartner(_ userID: String) {
        guard !memberIDs.contains(userID), memberIDs.count < 2 else { return }
        memberIDs.append(userID)
        clearInviteCode()
    }

    /// Check if a user is a member of this couple
    func isMember(_ userID: String) -> Bool {
        memberIDs.contains(userID)
    }

    /// Get the partner's user ID for a given user
    func partnerID(for userID: String) -> String? {
        guard isMember(userID), memberIDs.count == 2 else { return nil }
        return memberIDs.first { $0 != userID }
    }

    // MARK: - Private Helpers

    /// Generate a random 6-character alphanumeric invite code
    private func generateRandomCode() -> String {
        let characters = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789"  // Excludes ambiguous: I, O, 0, 1
        return String((0..<6).map { _ in characters.randomElement()! })
    }
}

// MARK: - Sample Data

extension Couple {

    /// Sample couple for previews
    static let sample = Couple(
        id: "couple789",
        memberIDs: [User.sample.id, User.samplePartner.id],
        financialProfile: .sample
    )

    /// Solo user (no partner yet)
    static let sampleSolo = Couple(
        memberIDs: [User.sample.id],
        financialProfile: .sample
    )
}
