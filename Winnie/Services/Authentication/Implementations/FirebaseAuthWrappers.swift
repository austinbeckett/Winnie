import Foundation
import FirebaseAuth

// MARK: - User Wrapper

/// Wraps `FirebaseAuth.User` to conform to `AuthUserProviding`.
///
/// ## Why a Wrapper?
/// `FirebaseAuth.User` is a concrete class we can't mock or subclass.
/// This wrapper exposes only the properties we need through our protocol,
/// allowing `AuthenticationService` to work with any `AuthUserProviding`.
final class FirebaseAuthUserWrapper: AuthUserProviding {

    private let user: FirebaseAuth.User

    init(user: FirebaseAuth.User) {
        self.user = user
    }

    var uid: String {
        user.uid
    }

    var email: String? {
        user.email
    }

    var displayName: String? {
        user.displayName
    }

    func delete() async throws {
        try await user.delete()
    }
}

// MARK: - Auth Result Wrapper

/// Wraps `AuthDataResult` to conform to `AuthResultProviding`.
///
/// This is returned from sign-in operations and provides access to
/// the signed-in user and metadata like `isNewUser`.
final class FirebaseAuthResultWrapper: AuthResultProviding {

    private let result: AuthDataResult

    init(result: AuthDataResult) {
        self.result = result
    }

    var user: AuthUserProviding {
        FirebaseAuthUserWrapper(user: result.user)
    }

    var additionalUserInfo: AdditionalUserInfoProviding? {
        result.additionalUserInfo.map { FirebaseAdditionalUserInfoWrapper(info: $0) }
    }
}

// MARK: - Additional User Info Wrapper

/// Wraps `AdditionalUserInfo` to conform to `AdditionalUserInfoProviding`.
final class FirebaseAdditionalUserInfoWrapper: AdditionalUserInfoProviding {

    private let info: AdditionalUserInfo

    init(info: AdditionalUserInfo) {
        self.info = info
    }

    var isNewUser: Bool {
        info.isNewUser
    }
}

// MARK: - Credential Wrapper

/// Wraps Firebase `AuthCredential` to conform to `AuthCredentialProviding`.
///
/// ## Usage
/// Use the static factory method to create credentials for different providers:
/// ```swift
/// let credential = FirebaseAuthCredentialWrapper.appleCredential(
///     idToken: tokenString,
///     rawNonce: nonce,
///     fullName: nameComponents
/// )
/// ```
final class FirebaseAuthCredentialWrapper: AuthCredentialProviding {

    /// The underlying Firebase credential
    let credential: AuthCredential

    private init(credential: AuthCredential) {
        self.credential = credential
    }

    /// Create an Apple Sign-In credential for Firebase authentication.
    ///
    /// - Parameters:
    ///   - idToken: The identity token string from Apple (JWT)
    ///   - rawNonce: The raw (unhashed) nonce used in the sign-in request
    ///   - fullName: Optional name components (only provided on first sign-in)
    /// - Returns: A credential wrapper ready for `AuthProviding.signIn(with:)`
    static func appleCredential(
        idToken: String,
        rawNonce: String,
        fullName: PersonNameComponents?
    ) -> FirebaseAuthCredentialWrapper {
        let credential = OAuthProvider.appleCredential(
            withIDToken: idToken,
            rawNonce: rawNonce,
            fullName: fullName
        )
        return FirebaseAuthCredentialWrapper(credential: credential)
    }
}
