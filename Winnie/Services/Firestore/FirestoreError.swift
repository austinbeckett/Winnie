import Foundation

/// Shared error types for all Firestore repository operations
///
/// Conforms to `Equatable` to enable precise error assertions in tests:
/// ```swift
/// XCTAssertThrowsError(try await repo.fetch(id: "x")) { error in
///     XCTAssertEqual(error as? FirestoreError, .documentNotFound)
/// }
/// ```
enum FirestoreError: LocalizedError, Equatable {

    /// The requested document does not exist in Firestore
    case documentNotFound

    /// Failed to encode data for Firestore write
    case encodingFailed

    /// Failed to decode data from Firestore document
    case decodingFailed

    /// A Firestore transaction failed (e.g., concurrent modification)
    case transactionFailed

    /// Data validation failed with specific reason
    case invalidData(String)

    /// The invite code has expired
    case inviteCodeExpired

    /// The invite code has already been used
    case inviteCodeAlreadyUsed

    /// The couple already has two members
    case coupleAlreadyComplete

    /// User doesn't have permission for this operation
    case unauthorized

    /// An unexpected error occurred
    case unknown(Error)

    // MARK: - LocalizedError

    var errorDescription: String? {
        switch self {
        case .documentNotFound:
            return "Document not found."
        case .encodingFailed:
            return "Failed to encode data."
        case .decodingFailed:
            return "Failed to decode data."
        case .transactionFailed:
            return "Transaction failed. Please try again."
        case .invalidData(let message):
            return "Invalid data: \(message)"
        case .inviteCodeExpired:
            return "This invite code has expired."
        case .inviteCodeAlreadyUsed:
            return "This invite code has already been used."
        case .coupleAlreadyComplete:
            return "This couple already has two members."
        case .unauthorized:
            return "You don't have permission to perform this action."
        case .unknown(let error):
            return error.localizedDescription
        }
    }

    // MARK: - Equatable

    /// Custom Equatable implementation required because `Error` is not Equatable.
    /// For the `unknown` case, we compare by localizedDescription.
    static func == (lhs: FirestoreError, rhs: FirestoreError) -> Bool {
        switch (lhs, rhs) {
        case (.documentNotFound, .documentNotFound),
             (.encodingFailed, .encodingFailed),
             (.decodingFailed, .decodingFailed),
             (.transactionFailed, .transactionFailed),
             (.inviteCodeExpired, .inviteCodeExpired),
             (.inviteCodeAlreadyUsed, .inviteCodeAlreadyUsed),
             (.coupleAlreadyComplete, .coupleAlreadyComplete),
             (.unauthorized, .unauthorized):
            return true
        case (.invalidData(let lhsMsg), .invalidData(let rhsMsg)):
            return lhsMsg == rhsMsg
        case (.unknown(let lhsError), .unknown(let rhsError)):
            // Compare by localized description since Error is not Equatable
            return lhsError.localizedDescription == rhsError.localizedDescription
        default:
            return false
        }
    }
}
