import Foundation
import FirebaseFirestore

/// Data Transfer Object for invite code documents in Firestore
/// Stored at: /inviteCodes/{code}
/// The code (uppercase) serves as the document ID for quick lookups
struct InviteCodeDTO: Codable {

    /// The invite code (6-character alphanumeric, uppercase)
    let code: String

    /// The couple ID this code belongs to
    let coupleID: String

    /// User ID who created the invite
    let createdBy: String

    /// When the code expires
    let expiresAt: Date

    /// Whether the code has been used
    var isUsed: Bool

    /// User ID who used the code (if used)
    var usedBy: String?

    /// When the code was used (if used)
    var usedAt: Date?

    // MARK: - Coding Keys

    enum CodingKeys: String, CodingKey {
        case code
        case coupleID
        case createdBy
        case expiresAt
        case isUsed
        case usedBy
        case usedAt
    }

    // MARK: - Initializers

    /// Create a new invite code
    init(
        code: String,
        coupleID: String,
        createdBy: String,
        expiresAt: Date
    ) {
        self.code = code.uppercased()
        self.coupleID = coupleID
        self.createdBy = createdBy
        self.expiresAt = expiresAt
        self.isUsed = false
        self.usedBy = nil
        self.usedAt = nil
    }

    // MARK: - Computed Properties

    /// Whether the code is valid (not used and not expired)
    var isValid: Bool {
        !isUsed && expiresAt > Date()
    }

    /// Whether the code has expired
    var isExpired: Bool {
        expiresAt <= Date()
    }

    // MARK: - Firestore Dictionary

    /// Convert to dictionary for Firestore write operations
    var dictionary: [String: Any] {
        var dict: [String: Any] = [
            "code": code,
            "coupleID": coupleID,
            "createdBy": createdBy,
            "expiresAt": Timestamp(date: expiresAt),
            "isUsed": isUsed
        ]

        if let usedBy {
            dict["usedBy"] = usedBy
        }

        if let usedAt {
            dict["usedAt"] = Timestamp(date: usedAt)
        }

        return dict
    }
}
