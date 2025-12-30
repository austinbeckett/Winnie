import Foundation
import FirebaseFirestore

/// Repository for invite code operations in Firestore
/// Collection: /inviteCodes/{code}
final class InviteCodeRepository {

    private let db = Firestore.firestore()
    private let collectionPath = "inviteCodes"

    // MARK: - Create

    /// Generate and store a new invite code
    /// - Parameters:
    ///   - coupleID: The couple this code belongs to
    ///   - createdBy: User ID who created the invite
    ///   - expirationDays: Days until code expires (default: 7)
    /// - Returns: The generated code string
    func createInviteCode(
        coupleID: String,
        createdBy: String,
        expirationDays: Int = 7
    ) async throws -> String {
        let code = generateCode()

        guard let expiresAt = Calendar.current.date(
            byAdding: .day,
            value: expirationDays,
            to: Date()
        ) else {
            throw FirestoreError.invalidData("Could not calculate expiration date")
        }

        let dto = InviteCodeDTO(
            code: code,
            coupleID: coupleID,
            createdBy: createdBy,
            expiresAt: expiresAt
        )

        // Use the code as the document ID for quick lookups
        try await db.collection(collectionPath)
            .document(code)
            .setData(dto.dictionary)

        return code
    }

    // MARK: - Read

    /// Fetch an invite code document
    /// - Parameter code: The invite code to look up
    /// - Returns: The invite code DTO
    func fetchInviteCode(_ code: String) async throws -> InviteCodeDTO {
        let document = try await db.collection(collectionPath)
            .document(code.uppercased())
            .getDocument()

        guard document.exists else {
            throw FirestoreError.documentNotFound
        }

        guard let dto = try? document.data(as: InviteCodeDTO.self) else {
            throw FirestoreError.decodingFailed
        }

        return dto
    }

    /// Validate an invite code and return the couple ID if valid
    /// - Parameter code: The invite code to validate
    /// - Returns: The couple ID associated with the valid code
    /// - Throws: Appropriate error if code is invalid, expired, or already used
    func validateInviteCode(_ code: String) async throws -> String {
        let dto = try await fetchInviteCode(code)

        guard !dto.isUsed else {
            throw FirestoreError.inviteCodeAlreadyUsed
        }

        guard dto.expiresAt > Date() else {
            throw FirestoreError.inviteCodeExpired
        }

        return dto.coupleID
    }

    /// Check if an invite code exists
    func inviteCodeExists(_ code: String) async throws -> Bool {
        let document = try await db.collection(collectionPath)
            .document(code.uppercased())
            .getDocument()
        return document.exists
    }

    // MARK: - Update

    /// Mark an invite code as used
    /// - Parameters:
    ///   - code: The invite code
    ///   - userID: The user ID who used the code
    func markCodeAsUsed(code: String, by userID: String) async throws {
        try await db.collection(collectionPath)
            .document(code.uppercased())
            .updateData([
                "isUsed": true,
                "usedBy": userID,
                "usedAt": Timestamp(date: Date())
            ])
    }

    // MARK: - Delete

    /// Delete an invite code
    func deleteInviteCode(_ code: String) async throws {
        try await db.collection(collectionPath)
            .document(code.uppercased())
            .delete()
    }

    /// Delete all expired codes
    /// Call periodically for cleanup, or implement as a Cloud Function
    func deleteExpiredCodes() async throws {
        let snapshot = try await db.collection(collectionPath)
            .whereField("expiresAt", isLessThan: Timestamp(date: Date()))
            .getDocuments()

        guard !snapshot.documents.isEmpty else { return }

        let batch = db.batch()
        for document in snapshot.documents {
            batch.deleteDocument(document.reference)
        }
        try await batch.commit()
    }

    /// Delete all unused codes for a specific couple
    /// Useful when a partner successfully joins
    func deleteUnusedCodesForCouple(_ coupleID: String) async throws {
        let snapshot = try await db.collection(collectionPath)
            .whereField("coupleID", isEqualTo: coupleID)
            .whereField("isUsed", isEqualTo: false)
            .getDocuments()

        guard !snapshot.documents.isEmpty else { return }

        let batch = db.batch()
        for document in snapshot.documents {
            batch.deleteDocument(document.reference)
        }
        try await batch.commit()
    }

    // MARK: - Private Helpers

    /// Generate a random 6-character alphanumeric code
    /// Excludes ambiguous characters: I, O, 0, 1
    private func generateCode() -> String {
        let characters = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789"
        return String((0..<6).map { _ in characters.randomElement()! })
    }
}
