import Foundation
import FirebaseFirestore

/// Data Transfer Object for Couple documents in Firestore
/// Stored at: /couples/{coupleId}
/// Note: FinancialProfile is stored separately at /couples/{coupleId}/financialProfile/profile
struct CoupleDTO: Codable {

    /// Unique couple identifier (Firestore document ID)
    let id: String

    /// Array of user IDs (1-2 users)
    var memberIDs: [String]

    /// Partner invitation code (for joining)
    var inviteCode: String?

    /// Invite code expiration date
    var inviteCodeExpiresAt: Date?

    /// Creation timestamp
    let createdAt: Date

    /// Last sync timestamp for cache invalidation
    var lastSyncedAt: Date?

    // MARK: - Coding Keys

    enum CodingKeys: String, CodingKey {
        case id
        case memberIDs
        case inviteCode
        case inviteCodeExpiresAt
        case createdAt
        case lastSyncedAt
    }

    // MARK: - Initializers

    /// Create from domain model
    /// Note: Does not include financialProfile (stored separately)
    init(from couple: Couple) {
        self.id = couple.id
        self.memberIDs = couple.memberIDs
        self.inviteCode = couple.inviteCode
        self.inviteCodeExpiresAt = couple.inviteCodeExpiresAt
        self.createdAt = couple.createdAt
        self.lastSyncedAt = Date()
    }

    /// Create new couple for a user (starts with 1 member)
    init(id: String, creatorUserID: String) {
        self.id = id
        self.memberIDs = [creatorUserID]
        self.inviteCode = nil
        self.inviteCodeExpiresAt = nil
        self.createdAt = Date()
        self.lastSyncedAt = Date()
    }

    // MARK: - Conversion to Domain Model

    /// Convert to domain model
    /// Requires financialProfile to be passed in (fetched separately from subcollection)
    func toCouple(financialProfile: FinancialProfile) -> Couple {
        Couple(
            id: id,
            memberIDs: memberIDs,
            financialProfile: financialProfile,
            createdAt: createdAt,
            inviteCode: inviteCode,
            inviteCodeExpiresAt: inviteCodeExpiresAt
        )
    }

    // MARK: - Firestore Dictionary

    /// Convert to dictionary for Firestore write operations
    var dictionary: [String: Any] {
        var dict: [String: Any] = [
            "id": id,
            "memberIDs": memberIDs,
            "createdAt": Timestamp(date: createdAt)
        ]

        if let inviteCode {
            dict["inviteCode"] = inviteCode
        }

        if let inviteCodeExpiresAt {
            dict["inviteCodeExpiresAt"] = Timestamp(date: inviteCodeExpiresAt)
        }

        if let lastSyncedAt {
            dict["lastSyncedAt"] = Timestamp(date: lastSyncedAt)
        }

        return dict
    }
}
