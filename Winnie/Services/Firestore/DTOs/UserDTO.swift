import Foundation
import FirebaseFirestore

/// Data Transfer Object for User documents in Firestore
struct UserDTO: Codable {

    let id: String
    var displayName: String?
    var email: String?
    var partnerID: String?
    var coupleID: String?
    let createdAt: Date
    var lastLoginAt: Date?
    var hasCompletedOnboarding: Bool
    var lastSyncedAt: Date?

    // MARK: - Coding Keys

    enum CodingKeys: String, CodingKey {
        case id
        case displayName
        case email
        case partnerID
        case coupleID
        case createdAt
        case lastLoginAt
        case hasCompletedOnboarding
        case lastSyncedAt
    }

    // MARK: - Initializers

    /// Create from domain model
    init(from user: User) {
        self.id = user.id
        self.displayName = user.displayName
        self.email = user.email
        self.partnerID = user.partnerID
        self.coupleID = user.coupleID
        self.createdAt = user.createdAt
        self.lastLoginAt = user.lastLoginAt
        self.hasCompletedOnboarding = user.hasCompletedOnboarding
        self.lastSyncedAt = Date()
    }

    /// Create new user for sign-up
    init(
        id: String,
        displayName: String? = nil,
        email: String? = nil
    ) {
        self.id = id
        self.displayName = displayName
        self.email = email
        self.partnerID = nil
        self.coupleID = nil
        self.createdAt = Date()
        self.lastLoginAt = Date()
        self.hasCompletedOnboarding = false
        self.lastSyncedAt = Date()
    }

    // MARK: - Conversion to Domain Model

    func toUser() -> User {
        User(
            id: id,
            displayName: displayName,
            email: email,
            partnerID: partnerID,
            coupleID: coupleID,
            createdAt: createdAt,
            lastLoginAt: lastLoginAt,
            hasCompletedOnboarding: hasCompletedOnboarding
        )
    }

    // MARK: - Firestore Dictionary

    /// Convert to dictionary for Firestore write operations
    var dictionary: [String: Any] {
        var dict: [String: Any] = [
            "id": id,
            "createdAt": Timestamp(date: createdAt),
            "hasCompletedOnboarding": hasCompletedOnboarding
        ]

        if let displayName { dict["displayName"] = displayName }
        if let email { dict["email"] = email }
        if let partnerID { dict["partnerID"] = partnerID }
        if let coupleID { dict["coupleID"] = coupleID }
        if let lastLoginAt { dict["lastLoginAt"] = Timestamp(date: lastLoginAt) }
        if let lastSyncedAt { dict["lastSyncedAt"] = Timestamp(date: lastSyncedAt) }

        return dict
    }
}
