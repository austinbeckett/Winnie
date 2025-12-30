import Foundation
import FirebaseFirestore

/// Repository for User document operations in Firestore
/// Uses shared FirestoreError from FirestoreError.swift
final class UserRepository {

    private let db = Firestore.firestore()
    private let collectionPath = "users"

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
    func listenToUser(id: String, onChange: @escaping (User?) -> Void) -> ListenerRegistration {
        return db.collection(collectionPath)
            .document(id)
            .addSnapshotListener { snapshot, error in
                guard let snapshot, snapshot.exists else {
                    onChange(nil)
                    return
                }

                let dto = try? snapshot.data(as: UserDTO.self)
                onChange(dto?.toUser())
            }
    }
}
