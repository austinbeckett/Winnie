import XCTest
@testable import Winnie

/// Comprehensive unit tests for AuthenticationService using MockAuthProvider.
///
/// These tests verify that AuthenticationService correctly:
/// - Manages auth state through the listener pattern
/// - Handles email/password sign up and sign in
/// - Handles Apple Sign In flow
/// - Handles sign out and account deletion
/// - Maps Firebase errors to AuthenticationError
///
/// ## Test Pattern
/// All tests follow AAA (Arrange-Act-Assert):
/// 1. **Arrange**: Set up mock state and expectations
/// 2. **Act**: Call the service method
/// 3. **Assert**: Verify state and mock calls
///
/// ## Thread Safety
/// This class is `@MainActor` because `AuthenticationService` is `@MainActor`.
/// This ensures test code runs on the same actor as the service.
@MainActor
final class AuthenticationServiceTests: XCTestCase {

    // MARK: - Properties

    var mockAuthProvider: MockAuthProvider!
    var service: AuthenticationService!

    // MARK: - Setup & Teardown

    override func setUp() {
        super.setUp()
        mockAuthProvider = MockAuthProvider()
        service = AuthenticationService(authProvider: mockAuthProvider)
    }

    override func tearDown() {
        mockAuthProvider = nil
        service = nil
        super.tearDown()
    }

    // MARK: - Initial State Tests

    func test_initialState_isSignedOutWhenNoUser() {
        // The mock starts with no user, listener fires immediately with nil
        // This causes authState to be .signedOut
        XCTAssertEqual(service.authState, .signedOut)
        XCTAssertNil(service.currentFirebaseUser)
        XCTAssertFalse(service.isLoading)
        XCTAssertNil(service.error)
        XCTAssertFalse(service.isAuthenticated)
    }

    func test_initialState_isSignedInWhenUserExists() {
        // Arrange - Set up mock with existing user BEFORE creating service
        let user = TestFixtures.makeAuthUser(uid: "user-123", email: "test@example.com")
        mockAuthProvider.mockCurrentUser = user

        // Act - Create new service (listener fires with current user)
        let newService = AuthenticationService(authProvider: mockAuthProvider)

        // Assert
        XCTAssertEqual(newService.authState, .signedIn(uid: "user-123"))
        XCTAssertNotNil(newService.currentFirebaseUser)
        XCTAssertEqual(newService.currentUserID, "user-123")
        XCTAssertTrue(newService.isAuthenticated)
    }

    // MARK: - Auth State Listener Tests

    func test_authStateChange_updatesWhenUserSignsIn() {
        // Arrange - Start signed out
        XCTAssertEqual(service.authState, .signedOut)

        // Act - Simulate sign in
        let user = TestFixtures.makeAuthUser(uid: "user-456", email: "new@test.com")
        mockAuthProvider.simulateAuthStateChange(user: user)

        // Assert
        XCTAssertEqual(service.authState, .signedIn(uid: "user-456"))
        XCTAssertEqual(service.currentUserID, "user-456")
        XCTAssertTrue(service.isAuthenticated)
    }

    func test_authStateChange_updatesWhenUserSignsOut() {
        // Arrange - Start signed in
        let user = TestFixtures.makeAuthUser(uid: "user-123")
        mockAuthProvider.simulateAuthStateChange(user: user)
        XCTAssertTrue(service.isAuthenticated)

        // Act - Simulate sign out
        mockAuthProvider.simulateAuthStateChange(user: nil)

        // Assert
        XCTAssertEqual(service.authState, .signedOut)
        XCTAssertNil(service.currentUserID)
        XCTAssertFalse(service.isAuthenticated)
    }

    // MARK: - Email/Password Sign Up Tests

    func test_signUp_callsCreateUserWithCorrectCredentials() async throws {
        // Act
        try await service.signUp(email: "test@example.com", password: "password123")

        // Assert
        XCTAssertEqual(mockAuthProvider.createUserCalls.count, 1)
        XCTAssertEqual(mockAuthProvider.createUserCalls.first?.email, "test@example.com")
        XCTAssertEqual(mockAuthProvider.createUserCalls.first?.password, "password123")
    }

    func test_signUp_setsLoadingFalseAfterCompletion() async throws {
        // Act
        try await service.signUp(email: "test@example.com", password: "password123")

        // Assert - Loading should be false after completion
        XCTAssertFalse(service.isLoading)
    }

    func test_signUp_throwsEmailAlreadyInUse() async {
        // Arrange - Firebase error code 17007 = email already in use
        let nsError = NSError(domain: "FIRAuthErrorDomain", code: 17007, userInfo: nil)
        mockAuthProvider.errorToThrow = nsError

        // Act & Assert
        do {
            try await service.signUp(email: "existing@test.com", password: "password")
            XCTFail("Expected emailAlreadyInUse error")
        } catch AuthenticationError.emailAlreadyInUse {
            // Expected
        } catch {
            XCTFail("Wrong error type: \(error)")
        }
    }

    func test_signUp_throwsWeakPassword() async {
        // Arrange - Firebase error code 17026 = weak password
        let nsError = NSError(domain: "FIRAuthErrorDomain", code: 17026, userInfo: nil)
        mockAuthProvider.errorToThrow = nsError

        // Act & Assert
        do {
            try await service.signUp(email: "test@test.com", password: "123")
            XCTFail("Expected weakPassword error")
        } catch AuthenticationError.weakPassword {
            // Expected
        } catch {
            XCTFail("Wrong error type: \(error)")
        }
    }

    // MARK: - Email/Password Sign In Tests

    func test_signIn_callsSignInWithCorrectCredentials() async throws {
        // Act
        try await service.signIn(email: "user@test.com", password: "secret")

        // Assert
        XCTAssertEqual(mockAuthProvider.signInCalls.count, 1)
        XCTAssertEqual(mockAuthProvider.signInCalls.first?.email, "user@test.com")
        XCTAssertEqual(mockAuthProvider.signInCalls.first?.password, "secret")
    }

    func test_signIn_throwsUserNotFound() async {
        // Arrange - Firebase error code 17011 = user not found
        let nsError = NSError(domain: "FIRAuthErrorDomain", code: 17011, userInfo: nil)
        mockAuthProvider.errorToThrow = nsError

        // Act & Assert
        do {
            try await service.signIn(email: "unknown@test.com", password: "password")
            XCTFail("Expected userNotFound error")
        } catch AuthenticationError.userNotFound {
            // Expected
        } catch {
            XCTFail("Wrong error type: \(error)")
        }
    }

    func test_signIn_throwsInvalidCredential() async {
        // Arrange - Firebase error code 17004 = invalid credential
        let nsError = NSError(domain: "FIRAuthErrorDomain", code: 17004, userInfo: nil)
        mockAuthProvider.errorToThrow = nsError

        // Act & Assert
        do {
            try await service.signIn(email: "user@test.com", password: "wrong")
            XCTFail("Expected invalidCredential error")
        } catch AuthenticationError.invalidCredential {
            // Expected
        } catch {
            XCTFail("Wrong error type: \(error)")
        }
    }

    func test_signIn_throwsNetworkError() async {
        // Arrange - Firebase error code 17020 = network error
        let nsError = NSError(domain: "FIRAuthErrorDomain", code: 17020, userInfo: nil)
        mockAuthProvider.errorToThrow = nsError

        // Act & Assert
        do {
            try await service.signIn(email: "user@test.com", password: "password")
            XCTFail("Expected networkError")
        } catch AuthenticationError.networkError {
            // Expected
        } catch {
            XCTFail("Wrong error type: \(error)")
        }
    }

    // MARK: - Password Reset Tests

    func test_sendPasswordReset_callsProviderWithEmail() async throws {
        // Act
        try await service.sendPasswordReset(to: "forgot@test.com")

        // Assert
        XCTAssertEqual(mockAuthProvider.sendPasswordResetCalls, ["forgot@test.com"])
    }

    func test_sendPasswordReset_throwsInvalidEmail() async {
        // Arrange - Firebase error code 17008 = invalid email
        let nsError = NSError(domain: "FIRAuthErrorDomain", code: 17008, userInfo: nil)
        mockAuthProvider.errorToThrow = nsError

        // Act & Assert
        do {
            try await service.sendPasswordReset(to: "not-an-email")
            XCTFail("Expected invalidEmail error")
        } catch AuthenticationError.invalidEmail {
            // Expected
        } catch {
            XCTFail("Wrong error type: \(error)")
        }
    }

    // MARK: - Apple Sign In Tests

    func test_prepareAppleSignIn_returnsHashedNonce() {
        // Act
        let hashedNonce = service.prepareAppleSignIn()

        // Assert - Should be a 64-character hex string (SHA256 output)
        XCTAssertEqual(hashedNonce.count, 64)
        XCTAssertTrue(hashedNonce.allSatisfy { $0.isHexDigit })
    }

    func test_prepareAppleSignIn_generatesNewNonceEachTime() {
        // Act
        let nonce1 = service.prepareAppleSignIn()
        let nonce2 = service.prepareAppleSignIn()

        // Assert - Each call should generate a unique nonce
        XCTAssertNotEqual(nonce1, nonce2)
    }

    func test_signInWithApple_throwsMissingNonceIfNotPrepared() async {
        // Arrange - Don't call prepareAppleSignIn()
        let data = TestFixtures.makeAppleCredentialData()

        // Act & Assert
        do {
            try await service.signInWithApple(data: data)
            XCTFail("Expected missingNonce error")
        } catch AuthenticationError.missingNonce {
            // Expected
        } catch {
            XCTFail("Wrong error type: \(error)")
        }
    }

    func test_signInWithApple_throwsInvalidCredentialIfNoToken() async {
        // Arrange - Prepare nonce but credential has no token
        _ = service.prepareAppleSignIn()
        let data = AppleCredentialData(
            identityToken: nil,  // Missing token
            fullName: nil,
            email: nil
        )

        // Act & Assert
        do {
            try await service.signInWithApple(data: data)
            XCTFail("Expected invalidCredential error")
        } catch AuthenticationError.invalidCredential {
            // Expected
        } catch {
            XCTFail("Wrong error type: \(error)")
        }
    }

    func test_signInWithApple_callsSignInWithCredential() async throws {
        // Arrange
        _ = service.prepareAppleSignIn()
        let data = TestFixtures.makeAppleCredentialData()

        // Act
        try await service.signInWithApple(data: data)

        // Assert
        XCTAssertEqual(mockAuthProvider.signInWithCredentialCalls.count, 1)
    }

    func test_signInWithApple_returnsNewUserInfoForNewUser() async throws {
        // Arrange
        mockAuthProvider.simulateNewUser = true
        let user = TestFixtures.makeAuthUser(uid: "new-apple-user", email: "apple@test.com")
        mockAuthProvider.mockCurrentUser = user

        _ = service.prepareAppleSignIn()
        let data = TestFixtures.makeAppleCredentialData(
            givenName: "John",
            familyName: "Doe",
            email: "apple@test.com"
        )

        // Act
        let newUserInfo = try await service.signInWithApple(data: data)

        // Assert - returns NewUserInfo for new users
        XCTAssertNotNil(newUserInfo)
        XCTAssertEqual(newUserInfo?.uid, "new-apple-user")
        XCTAssertEqual(newUserInfo?.email, "apple@test.com")
        XCTAssertEqual(newUserInfo?.displayName, "John Doe")
    }

    func test_signInWithApple_returnsNilForExistingUser() async throws {
        // Arrange
        mockAuthProvider.simulateNewUser = false
        _ = service.prepareAppleSignIn()
        let data = TestFixtures.makeAppleCredentialData()

        // Act
        let newUserInfo = try await service.signInWithApple(data: data)

        // Assert - returns nil for existing users
        XCTAssertNil(newUserInfo)
    }

    func test_signInWithApple_clearsNonceAfterSuccess() async throws {
        // Arrange
        _ = service.prepareAppleSignIn()
        let data = TestFixtures.makeAppleCredentialData()

        // Act - First sign-in should succeed
        try await service.signInWithApple(data: data)

        // Assert - Try to sign in again without preparing - should fail with missingNonce
        do {
            try await service.signInWithApple(data: data)
            XCTFail("Expected missingNonce after nonce was cleared")
        } catch AuthenticationError.missingNonce {
            // Expected - nonce was cleared after first successful sign-in
        } catch {
            XCTFail("Wrong error: \(error)")
        }
    }

    // MARK: - Sign Out Tests

    func test_signOut_callsProviderSignOut() throws {
        // Arrange
        mockAuthProvider.mockCurrentUser = TestFixtures.makeAuthUser(uid: "user-123")

        // Act
        try service.signOut()

        // Assert
        XCTAssertTrue(mockAuthProvider.signOutCalled)
    }

    func test_signOut_throwsSignOutFailed() {
        // Arrange
        mockAuthProvider.errorToThrow = NSError(domain: "Test", code: -1)

        // Act & Assert
        XCTAssertThrowsError(try service.signOut()) { error in
            XCTAssertEqual(error as? AuthenticationError, .signOutFailed)
        }
    }

    // MARK: - Delete Account Tests

    func test_deleteAccount_callsUserDelete() async throws {
        // Arrange
        let mockUser = TestFixtures.makeAuthUser(uid: "user-to-delete")
        mockAuthProvider.mockCurrentUser = mockUser

        // Act
        try await service.deleteAccount()

        // Assert
        XCTAssertTrue(mockUser.deleteWasCalled)
    }

    func test_deleteAccount_throwsUserNotFoundWhenSignedOut() async {
        // Arrange - No current user
        mockAuthProvider.mockCurrentUser = nil

        // Act & Assert
        do {
            try await service.deleteAccount()
            XCTFail("Expected userNotFound error")
        } catch AuthenticationError.userNotFound {
            // Expected
        } catch {
            XCTFail("Wrong error type: \(error)")
        }
    }

    func test_deleteAccount_propagatesDeleteError() async {
        // Arrange
        let mockUser = TestFixtures.makeAuthUser(uid: "user-123")
        let nsError = NSError(domain: "FIRAuthErrorDomain", code: 17020, userInfo: nil)
        mockUser.deleteError = nsError
        mockAuthProvider.mockCurrentUser = mockUser

        // Act & Assert
        do {
            try await service.deleteAccount()
            XCTFail("Expected error to be thrown")
        } catch AuthenticationError.networkError {
            // Expected - error was mapped
        } catch {
            XCTFail("Wrong error type: \(error)")
        }
    }

    // MARK: - Computed Property Tests

    func test_currentUserID_returnsUidWhenSignedIn() {
        // Arrange
        mockAuthProvider.simulateAuthStateChange(user: TestFixtures.makeAuthUser(uid: "uid-123"))

        // Assert
        XCTAssertEqual(service.currentUserID, "uid-123")
    }

    func test_currentUserID_returnsNilWhenSignedOut() {
        // Arrange
        mockAuthProvider.simulateAuthStateChange(user: nil)

        // Assert
        XCTAssertNil(service.currentUserID)
    }

    func test_isAuthenticated_trueWhenSignedIn() {
        // Arrange
        mockAuthProvider.simulateAuthStateChange(user: TestFixtures.makeAuthUser(uid: "any"))

        // Assert
        XCTAssertTrue(service.isAuthenticated)
    }

    func test_isAuthenticated_falseWhenSignedOut() {
        // Arrange
        mockAuthProvider.simulateAuthStateChange(user: nil)

        // Assert
        XCTAssertFalse(service.isAuthenticated)
    }
}

