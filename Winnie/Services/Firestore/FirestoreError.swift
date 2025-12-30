import Foundation

/// Shared error types for all Firestore repository operations
enum FirestoreError: LocalizedError {

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
}
