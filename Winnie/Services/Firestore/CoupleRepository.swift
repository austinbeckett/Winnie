import Foundation
import FirebaseFirestore

/// Repository for Couple document operations in Firestore
/// Collection: /couples/{coupleId}
/// Subcollection: /couples/{coupleId}/financialProfile/profile
final class CoupleRepository {

    private let db = Firestore.firestore()
    private let collectionPath = "couples"

    /// Document ID for the single financial profile document
    private let profileDocID = "profile"

    // MARK: - Create

    /// Create a new couple for a user (starts with 1 member)
    /// Creates both the couple document and an empty financial profile atomically
    /// - Parameter userID: The user ID of the creator
    /// - Returns: The created Couple domain model
    func createCouple(for userID: String) async throws -> Couple {
        let coupleID = UUID().uuidString
        let coupleDTO = CoupleDTO(id: coupleID, creatorUserID: userID)
        let profileDTO = FinancialProfileDTO()

        // Use batch write for atomicity
        let batch = db.batch()

        // Create couple document
        let coupleRef = db.collection(collectionPath).document(coupleID)
        batch.setData(coupleDTO.dictionary, forDocument: coupleRef)

        // Create empty financial profile
        let profileRef = coupleRef.collection("financialProfile").document(profileDocID)
        batch.setData(profileDTO.dictionary, forDocument: profileRef)

        try await batch.commit()

        return coupleDTO.toCouple(financialProfile: profileDTO.toFinancialProfile())
    }

    // MARK: - Read

    /// Fetch a couple with its financial profile
    func fetchCouple(id: String) async throws -> Couple {
        // Fetch couple document
        let coupleDoc = try await db.collection(collectionPath)
            .document(id)
            .getDocument()

        guard coupleDoc.exists else {
            throw FirestoreError.documentNotFound
        }

        guard let coupleDTO = try? coupleDoc.data(as: CoupleDTO.self) else {
            throw FirestoreError.decodingFailed
        }

        // Fetch financial profile
        let profile = try await fetchFinancialProfile(coupleID: id)

        return coupleDTO.toCouple(financialProfile: profile)
    }

    /// Check if a couple exists
    func coupleExists(id: String) async throws -> Bool {
        let document = try await db.collection(collectionPath)
            .document(id)
            .getDocument()
        return document.exists
    }

    /// Fetch only the financial profile for a couple
    func fetchFinancialProfile(coupleID: String) async throws -> FinancialProfile {
        let document = try await db.collection(collectionPath)
            .document(coupleID)
            .collection("financialProfile")
            .document(profileDocID)
            .getDocument()

        if document.exists, let dto = try? document.data(as: FinancialProfileDTO.self) {
            return dto.toFinancialProfile()
        }

        // Return empty profile if document doesn't exist
        return FinancialProfile()
    }

    // MARK: - Update

    /// Update the financial profile for a couple
    func updateFinancialProfile(_ profile: FinancialProfile, coupleID: String) async throws {
        let dto = FinancialProfileDTO(from: profile)
        try await db.collection(collectionPath)
            .document(coupleID)
            .collection("financialProfile")
            .document(profileDocID)
            .setData(dto.dictionary, merge: true)
    }

    /// Update the entire couple document
    func updateCouple(_ couple: Couple) async throws {
        let dto = CoupleDTO(from: couple)
        try await db.collection(collectionPath)
            .document(couple.id)
            .setData(dto.dictionary, merge: true)
    }

    /// Update invite code on couple
    /// - Parameters:
    ///   - coupleID: The couple ID
    ///   - code: The new invite code (nil to clear)
    ///   - expiresAt: Expiration date (nil to clear)
    func updateInviteCode(
        coupleID: String,
        code: String?,
        expiresAt: Date?
    ) async throws {
        var data: [String: Any] = [
            "lastSyncedAt": Timestamp(date: Date())
        ]

        if let code {
            data["inviteCode"] = code
        } else {
            data["inviteCode"] = FieldValue.delete()
        }

        if let expiresAt {
            data["inviteCodeExpiresAt"] = Timestamp(date: expiresAt)
        } else {
            data["inviteCodeExpiresAt"] = FieldValue.delete()
        }

        try await db.collection(collectionPath)
            .document(coupleID)
            .updateData(data)
    }

    /// Add a partner to the couple using a transaction for safety
    /// Ensures atomicity: checks member count, then adds partner
    func addPartner(userID: String, to coupleID: String) async throws {
        let coupleRef = db.collection(collectionPath).document(coupleID)

        _ = try await db.runTransaction { transaction, errorPointer in
            // Read current couple data
            let coupleDoc: DocumentSnapshot
            do {
                coupleDoc = try transaction.getDocument(coupleRef)
            } catch let error {
                errorPointer?.pointee = error as NSError
                return nil
            }

            guard let data = coupleDoc.data(),
                  var memberIDs = data["memberIDs"] as? [String] else {
                errorPointer?.pointee = FirestoreError.decodingFailed as NSError
                return nil
            }

            // Check if couple already has 2 members
            guard memberIDs.count < 2 else {
                errorPointer?.pointee = FirestoreError.coupleAlreadyComplete as NSError
                return nil
            }

            // Check if user is already a member
            guard !memberIDs.contains(userID) else {
                // Already a member, no-op
                return nil
            }

            // Add the partner
            memberIDs.append(userID)

            // Update the document: add partner and clear invite code
            transaction.updateData([
                "memberIDs": memberIDs,
                "inviteCode": FieldValue.delete(),
                "inviteCodeExpiresAt": FieldValue.delete(),
                "lastSyncedAt": Timestamp(date: Date())
            ], forDocument: coupleRef)

            return nil
        }
    }

    /// Remove a partner from the couple (for account deletion scenarios)
    func removePartner(userID: String, from coupleID: String) async throws {
        let coupleRef = db.collection(collectionPath).document(coupleID)

        _ = try await db.runTransaction { transaction, errorPointer in
            let coupleDoc: DocumentSnapshot
            do {
                coupleDoc = try transaction.getDocument(coupleRef)
            } catch let error {
                errorPointer?.pointee = error as NSError
                return nil
            }

            guard let data = coupleDoc.data(),
                  var memberIDs = data["memberIDs"] as? [String] else {
                errorPointer?.pointee = FirestoreError.decodingFailed as NSError
                return nil
            }

            memberIDs.removeAll { $0 == userID }

            transaction.updateData([
                "memberIDs": memberIDs,
                "lastSyncedAt": Timestamp(date: Date())
            ], forDocument: coupleRef)

            return nil
        }
    }

    // MARK: - Delete

    /// Delete a couple and its financial profile subcollection
    /// Note: Goals and Scenarios subcollections should be deleted separately
    /// For production, consider using Cloud Functions for recursive deletion
    func deleteCouple(id: String) async throws {
        let batch = db.batch()

        // Delete financial profile document
        let profileRef = db.collection(collectionPath)
            .document(id)
            .collection("financialProfile")
            .document(profileDocID)
        batch.deleteDocument(profileRef)

        // Delete couple document
        let coupleRef = db.collection(collectionPath).document(id)
        batch.deleteDocument(coupleRef)

        try await batch.commit()
    }

    // MARK: - Real-time Listeners

    /// Listen to couple changes
    /// Note: Financial profile changes require a separate listener
    func listenToCouple(
        id: String,
        onChange: @escaping (Couple?) -> Void
    ) -> ListenerRegistration {
        return db.collection(collectionPath)
            .document(id)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self, let snapshot, snapshot.exists else {
                    onChange(nil)
                    return
                }

                guard let dto = try? snapshot.data(as: CoupleDTO.self) else {
                    onChange(nil)
                    return
                }

                // Fetch profile asynchronously
                Task {
                    let profile = (try? await self.fetchFinancialProfile(coupleID: id)) ?? FinancialProfile()
                    onChange(dto.toCouple(financialProfile: profile))
                }
            }
    }

    /// Listen to financial profile changes
    func listenToFinancialProfile(
        coupleID: String,
        onChange: @escaping (FinancialProfile) -> Void
    ) -> ListenerRegistration {
        return db.collection(collectionPath)
            .document(coupleID)
            .collection("financialProfile")
            .document(profileDocID)
            .addSnapshotListener { snapshot, error in
                guard let snapshot, snapshot.exists else {
                    onChange(FinancialProfile())
                    return
                }

                if let dto = try? snapshot.data(as: FinancialProfileDTO.self) {
                    onChange(dto.toFinancialProfile())
                } else {
                    onChange(FinancialProfile())
                }
            }
    }
}
