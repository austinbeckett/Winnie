import Foundation

/// Domain errors for authentication operations
enum AuthenticationError: LocalizedError, Equatable {
    case invalidCredential
    case missingNonce
    case userNotFound
    case emailAlreadyInUse
    case weakPassword
    case networkError
    case userDisabled
    case invalidEmail
    case signOutFailed
    case unknown(String)

    // MARK: - Equatable

    static func == (lhs: AuthenticationError, rhs: AuthenticationError) -> Bool {
        switch (lhs, rhs) {
        case (.invalidCredential, .invalidCredential),
             (.missingNonce, .missingNonce),
             (.userNotFound, .userNotFound),
             (.emailAlreadyInUse, .emailAlreadyInUse),
             (.weakPassword, .weakPassword),
             (.networkError, .networkError),
             (.userDisabled, .userDisabled),
             (.invalidEmail, .invalidEmail),
             (.signOutFailed, .signOutFailed):
            return true
        case (.unknown(let lhsMsg), .unknown(let rhsMsg)):
            return lhsMsg == rhsMsg
        default:
            return false
        }
    }

    var errorDescription: String? {
        switch self {
        case .invalidCredential:
            return "Invalid credentials. Please try again."
        case .missingNonce:
            return "Authentication failed. Please try again."
        case .userNotFound:
            return "No account found with this email."
        case .emailAlreadyInUse:
            return "An account already exists with this email."
        case .weakPassword:
            return "Password must be at least 8 characters."
        case .networkError:
            return "Network error. Please check your connection."
        case .userDisabled:
            return "This account has been disabled."
        case .invalidEmail:
            return "Please enter a valid email address."
        case .signOutFailed:
            return "Failed to sign out. Please try again."
        case .unknown(let message):
            return message
        }
    }

    /// Map Firebase Auth error codes to domain errors
    static func from(_ error: Error) -> AuthenticationError {
        let nsError = error as NSError

        // Firebase Auth error codes
        switch nsError.code {
        case 17004: // ERROR_INVALID_CREDENTIAL
            return .invalidCredential
        case 17011: // ERROR_USER_NOT_FOUND
            return .userNotFound
        case 17007: // ERROR_EMAIL_ALREADY_IN_USE
            return .emailAlreadyInUse
        case 17026: // ERROR_WEAK_PASSWORD
            return .weakPassword
        case 17020: // ERROR_NETWORK_REQUEST_FAILED
            return .networkError
        case 17005: // ERROR_USER_DISABLED
            return .userDisabled
        case 17008: // ERROR_INVALID_EMAIL
            return .invalidEmail
        default:
            return .unknown(error.localizedDescription)
        }
    }
}
