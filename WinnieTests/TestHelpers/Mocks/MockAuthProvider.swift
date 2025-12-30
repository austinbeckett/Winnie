import Foundation
@testable import Winnie

/// In-memory mock implementation of `AuthProviding` for unit tests.
///
/// This mock allows you to:
/// 1. **Control state**: Set `mockCurrentUser` to simulate signed-in/out states
/// 2. **Inject errors**: Set `errorToThrow` to make operations fail
/// 3. **Verify calls**: Check what operations were performed
/// 4. **Simulate state changes**: Call `simulateAuthStateChange` to trigger listeners
///
/// ## Example Usage
/// ```swift
/// func testSignIn() async throws {
///     // Arrange
///     let mock = MockAuthProvider()
///     let service = AuthenticationService(authProvider: mock)
///
///     // Act
///     try await service.signIn(email: "test@test.com", password: "password")
///
///     // Assert
///     XCTAssertEqual(mock.signInCalls.count, 1)
///     XCTAssertEqual(mock.signInCalls.first?.email, "test@test.com")
/// }
/// ```
final class MockAuthProvider: AuthProviding {

    // MARK: - Controllable State

    /// The current "signed in" user (nil = signed out).
    /// Set this before creating the service to start in a signed-in state.
    var mockCurrentUser: MockAuthUser?

    /// Error to throw on the next operation.
    /// Set this to simulate Firebase errors.
    var errorToThrow: Error?

    /// Control whether sign-in results indicate a "new user" (first sign-in).
    /// Used for Apple Sign-In new user detection.
    var simulateNewUser: Bool = false

    // MARK: - Call Recording

    /// Recorded `createUser` calls: (email, password)
    var createUserCalls: [(email: String, password: String)] = []

    /// Recorded `signIn` with email/password calls: (email, password)
    var signInCalls: [(email: String, password: String)] = []

    /// Recorded `signIn` with credential calls
    var signInWithCredentialCalls: [AuthCredentialProviding] = []

    /// Recorded `sendPasswordReset` calls: email addresses
    var sendPasswordResetCalls: [String] = []

    /// Whether `signOut` was called
    var signOutCalled = false

    // MARK: - Listener Management

    private var stateListeners: [ObjectIdentifier: (AuthUserProviding?) -> Void] = [:]
    private var listenerHandles: [MockListenerHandle] = []

    // MARK: - AuthProviding Implementation

    var currentUser: AuthUserProviding? {
        mockCurrentUser
    }

    func addStateDidChangeListener(
        _ handler: @escaping (AuthUserProviding?) -> Void
    ) -> AuthStateListenerHandle {
        let handle = MockListenerHandle()
        let id = ObjectIdentifier(handle)
        stateListeners[id] = handler
        listenerHandles.append(handle)

        // Firebase immediately calls with current state - we do the same
        handler(mockCurrentUser)

        return handle
    }

    nonisolated func removeStateDidChangeListener(_ handle: AuthStateListenerHandle) {
        guard let mockHandle = handle as? MockListenerHandle else { return }
        // Note: In a real thread-safe implementation, we'd need synchronization here.
        // For tests running on MainActor, this is safe.
        mockHandle.wasRemoved = true
    }

    func createUser(withEmail email: String, password: String) async throws -> AuthResultProviding {
        createUserCalls.append((email, password))

        if let error = errorToThrow {
            throw error
        }

        // Simulate successful user creation
        let newUser = MockAuthUser(uid: UUID().uuidString, email: email)
        mockCurrentUser = newUser
        simulateAuthStateChange(user: newUser)

        // New user creation always returns isNewUser = true
        return MockAuthResult(user: newUser, isNewUser: true)
    }

    func signIn(withEmail email: String, password: String) async throws -> AuthResultProviding {
        signInCalls.append((email, password))

        if let error = errorToThrow {
            throw error
        }

        // Use existing mock user or create one
        let user = mockCurrentUser ?? MockAuthUser(uid: UUID().uuidString, email: email)
        mockCurrentUser = user
        simulateAuthStateChange(user: user)

        // Email sign-in is never a "new user"
        return MockAuthResult(user: user, isNewUser: false)
    }

    func signIn(with credential: AuthCredentialProviding) async throws -> AuthResultProviding {
        signInWithCredentialCalls.append(credential)

        if let error = errorToThrow {
            throw error
        }

        // Use existing mock user or create one
        let user = mockCurrentUser ?? MockAuthUser(uid: UUID().uuidString, email: nil)
        mockCurrentUser = user
        simulateAuthStateChange(user: user)

        // Use simulateNewUser flag to control new user detection
        return MockAuthResult(user: user, isNewUser: simulateNewUser)
    }

    func sendPasswordReset(withEmail email: String) async throws {
        sendPasswordResetCalls.append(email)

        if let error = errorToThrow {
            throw error
        }
    }

    func signOut() throws {
        signOutCalled = true

        if let error = errorToThrow {
            throw error
        }

        mockCurrentUser = nil
        simulateAuthStateChange(user: nil)
    }

    // MARK: - Test Helpers

    /// Simulate an auth state change (triggers all registered listeners).
    ///
    /// Call this to test how `AuthenticationService` responds to state changes.
    /// - Parameter user: The new user (or nil for signed out)
    func simulateAuthStateChange(user: MockAuthUser?) {
        mockCurrentUser = user
        for listener in stateListeners.values {
            listener(user)
        }
    }

    /// Reset all recorded calls.
    ///
    /// Call this in `setUp()` or between test cases to clear state.
    func resetRecording() {
        createUserCalls.removeAll()
        signInCalls.removeAll()
        signInWithCredentialCalls.removeAll()
        sendPasswordResetCalls.removeAll()
        signOutCalled = false
    }
}
