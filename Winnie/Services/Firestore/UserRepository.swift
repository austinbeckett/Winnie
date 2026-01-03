import Foundation
import FirebaseFirestore

/// Repository for User document operations in Firestore
///
/// This repository uses the `FirestoreProviding` protocol for database access,
/// enabling dependency injection for testing.
///
/// ## Production Usage
/// ```swift
/// let repository = UserRepository()  // Uses real Firestore
/// ```
///
/// ## Test Usage
/// ```swift
/// let mock = MockFirestoreService()
/// let repository = UserRepository(db: mock)
/// ```
final class UserRepository {

    // MARK: - Dependencies

    private let db: FirestoreProviding
    private let collectionPath = "users"

    // MARK: - Initialization

    /// Create a repository with the default Firestore service (production)
    init() {
        self.db = FirestoreService.shared
    }

    /// Create a repository with an injected database (for testing)
    /// - Parameter db: Any implementation of FirestoreProviding
    init(db: FirestoreProviding) {
        self.db = db
    }

    // MARK: - Create

    /// Create a new user document
    func createUser(_ user: User) async throws {
        let dto = UserDTO(from: user)
        try await db.collection(collectionPath)
            .document(user.id)
            .setData(dto.dictionary)
    }

    /// Create a new user document from sign-up data
    func createUser(id: String, displayName: String?, email: String?) async throws {
        let dto = UserDTO(id: id, displayName: displayName, email: email)
        try await db.collection(collectionPath)
            .document(id)
            .setData(dto.dictionary)
    }

    // MARK: - Read

    /// Fetch a user by ID
    func fetchUser(id: String) async throws -> User {
        let document = try await db.collection(collectionPath)
            .document(id)
            .getDocument()

        guard document.exists else {
            throw FirestoreError.documentNotFound
        }

        guard let dto = try? document.data(as: UserDTO.self) else {
            throw FirestoreError.decodingFailed
        }

        return dto.toUser()
    }

    /// Check if user document exists
    func userExists(id: String) async throws -> Bool {
        let document = try await db.collection(collectionPath)
            .document(id)
            .getDocument()
        return document.exists
    }

    // MARK: - Update

    /// Update user's last login timestamp
    func updateLastLogin(uid: String) async throws {
        try await db.collection(collectionPath)
            .document(uid)
            .updateData([
                "lastLoginAt": Timestamp(date: Date()),
                "lastSyncedAt": Timestamp(date: Date())
            ])
    }

    /// Update user's display name
    func updateDisplayName(uid: String, displayName: String) async throws {
        try await db.collection(collectionPath)
            .document(uid)
            .updateData([
                "displayName": displayName,
                "lastSyncedAt": Timestamp(date: Date())
            ])
    }

    /// Mark onboarding as complete
    func completeOnboarding(uid: String) async throws {
        try await db.collection(collectionPath)
            .document(uid)
            .updateData([
                "hasCompletedOnboarding": true,
                "lastSyncedAt": Timestamp(date: Date())
            ])
    }

    /// Reset onboarding for testing (developer use only)
    func resetOnboarding(uid: String) async throws {
        try await db.collection(collectionPath)
            .document(uid)
            .updateData([
                "hasCompletedOnboarding": false,
                "lastSyncedAt": Timestamp(date: Date())
            ])
    }

    /// Update user's couple association
    func updateCoupleAssociation(uid: String, coupleID: String, partnerID: String?) async throws {
        var data: [String: Any] = [
            "coupleID": coupleID,
            "lastSyncedAt": Timestamp(date: Date())
        ]

        if let partnerID {
            data["partnerID"] = partnerID
        }

        try await db.collection(collectionPath)
            .document(uid)
            .updateData(data)
    }

    /// Update general user fields
    func updateUser(_ user: User) async throws {
        let dto = UserDTO(from: user)
        try await db.collection(collectionPath)
            .document(user.id)
            .setData(dto.dictionary, merge: true)
    }

    // MARK: - Delete

    /// Delete a user document
    func deleteUser(id: String) async throws {
        try await db.collection(collectionPath)
            .document(id)
            .delete()
    }

    // MARK: - Real-time Listeners

    /// Listen to changes on a user document
    /// - Parameters:
    ///   - id: The user ID to listen to
    ///   - onChange: Called when the user document changes
    /// - Returns: A registration that should be removed when done listening
    func listenToUser(id: String, onChange: @escaping (User?) -> Void) -> ListenerRegistrationProviding {
        return db.collection(collectionPath)
            .document(id)
            .addSnapshotListener { snapshot, error in
                if let error {
                    #if DEBUG
                    print("UserRepository.listenToUser error: \(type(of: error))")
                    #endif
                }

                guard let snapshot, snapshot.exists else {
                    onChange(nil)
                    return
                }

                let dto = try? snapshot.data(as: UserDTO.self)
                onChange(dto?.toUser())
            }
    }
}
