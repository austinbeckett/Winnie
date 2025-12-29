import Foundation
import Combine
import FirebaseAuth
import AuthenticationServices
import CryptoKit

/// Manages Firebase Authentication state and operations
@MainActor
final class AuthenticationService: ObservableObject {

    // MARK: - Published State

    @Published private(set) var authState: AuthState = .unknown
    @Published private(set) var currentFirebaseUser: FirebaseAuth.User?
    @Published private(set) var isLoading = false
    @Published var error: AuthenticationError?

    enum AuthState: Equatable {
        case unknown
        case signedOut
        case signedIn(uid: String)
    }

    // MARK: - Private Properties

    private var authStateHandle: AuthStateDidChangeListenerHandle?
    private var currentNonce: String?

    // MARK: - Initialization

    init() {
        startListening()
    }

    deinit {
        if let handle = authStateHandle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }

    // MARK: - Auth State Observation

    private func startListening() {
        authStateHandle = Auth.auth().addStateDidChangeListener { [weak self] _, firebaseUser in
            Task { @MainActor in
                self?.handleAuthStateChange(firebaseUser)
            }
        }
    }

    private func handleAuthStateChange(_ firebaseUser: FirebaseAuth.User?) {
        if let firebaseUser {
            currentFirebaseUser = firebaseUser
            authState = .signedIn(uid: firebaseUser.uid)
        } else {
            currentFirebaseUser = nil
            authState = .signedOut
        }
    }

    // MARK: - Current User Info

    /// Current user's UID if signed in
    var currentUserID: String? {
        currentFirebaseUser?.uid
    }

    /// Whether user is currently authenticated
    var isAuthenticated: Bool {
        if case .signedIn = authState { return true }
        return false
    }

    // MARK: - Apple Sign In

    /// Prepare for Apple Sign In - returns the hashed nonce for the request
    func prepareAppleSignIn() -> String {
        let nonce = randomNonceString()
        currentNonce = nonce
        return sha256(nonce)
    }

    /// Complete Apple Sign In with the credential from ASAuthorizationController
    func signInWithApple(credential: ASAuthorizationAppleIDCredential) async throws {
        guard let nonce = currentNonce else {
            throw AuthenticationError.missingNonce
        }

        guard let appleIDToken = credential.identityToken,
              let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
            throw AuthenticationError.invalidCredential
        }

        isLoading = true
        defer { isLoading = false }

        do {
            let firebaseCredential = OAuthProvider.appleCredential(
                withIDToken: idTokenString,
                rawNonce: nonce,
                fullName: credential.fullName
            )

            let result = try await Auth.auth().signIn(with: firebaseCredential)

            // Clear nonce after successful sign-in
            currentNonce = nil

            // Return whether this is a new user for caller to handle
            let isNewUser = result.additionalUserInfo?.isNewUser ?? false
            if isNewUser {
                // Extract name from credential (only provided on first sign-in)
                let displayName = formatDisplayName(from: credential.fullName)
                let email = credential.email

                // Caller should create user document with this info
                NotificationCenter.default.post(
                    name: .newUserSignedUp,
                    object: nil,
                    userInfo: [
                        "uid": result.user.uid,
                        "displayName": displayName as Any,
                        "email": email as Any
                    ]
                )
            }

        } catch {
            throw AuthenticationError.from(error)
        }
    }

    // MARK: - Email/Password Authentication

    /// Create a new account with email and password
    func signUp(email: String, password: String) async throws {
        isLoading = true
        defer { isLoading = false }

        do {
            _ = try await Auth.auth().createUser(withEmail: email, password: password)
        } catch {
            throw AuthenticationError.from(error)
        }
    }

    /// Sign in with existing email and password
    func signIn(email: String, password: String) async throws {
        isLoading = true
        defer { isLoading = false }

        do {
            _ = try await Auth.auth().signIn(withEmail: email, password: password)
        } catch {
            throw AuthenticationError.from(error)
        }
    }

    /// Send password reset email
    func sendPasswordReset(to email: String) async throws {
        do {
            try await Auth.auth().sendPasswordReset(withEmail: email)
        } catch {
            throw AuthenticationError.from(error)
        }
    }

    // MARK: - Sign Out

    func signOut() throws {
        do {
            try Auth.auth().signOut()
        } catch {
            throw AuthenticationError.signOutFailed
        }
    }

    // MARK: - Account Deletion

    func deleteAccount() async throws {
        guard let user = Auth.auth().currentUser else {
            throw AuthenticationError.userNotFound
        }

        do {
            try await user.delete()
        } catch {
            throw AuthenticationError.from(error)
        }
    }

    // MARK: - Private Helpers

    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        var randomBytes = [UInt8](repeating: 0, count: length)
        let errorCode = SecRandomCopyBytes(kSecRandomDefault, randomBytes.count, &randomBytes)
        precondition(errorCode == errSecSuccess)

        let charset: [Character] = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        return String(randomBytes.map { charset[Int($0) % charset.count] })
    }

    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        return hashedData.compactMap { String(format: "%02x", $0) }.joined()
    }

    private func formatDisplayName(from nameComponents: PersonNameComponents?) -> String? {
        guard let nameComponents else { return nil }
        return PersonNameComponentsFormatter.localizedString(from: nameComponents, style: .default)
    }
}

// MARK: - Notification Names

extension Notification.Name {
    static let newUserSignedUp = Notification.Name("newUserSignedUp")
}
