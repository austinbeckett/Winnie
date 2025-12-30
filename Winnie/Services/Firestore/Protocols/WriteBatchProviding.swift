import Foundation

// MARK: - Write Batch Protocol

/// Represents an atomic batch of write operations.
///
/// A batch groups multiple writes into a single atomic operation:
/// - Either ALL writes succeed, or NONE of them do
/// - No partial updates - prevents inconsistent data
///
/// ## When to Use Batches
/// Use when you need to update multiple documents together:
/// - Creating a couple AND their financial profile
/// - Deleting a couple AND their financial profile
/// - Reordering goals (updating priority on multiple documents)
///
/// ## Example Usage
/// ```swift
/// let batch = db.batch()
/// batch.setData(coupleData, forDocument: coupleRef)
/// batch.setData(profileData, forDocument: profileRef)
/// try await batch.commit()  // Both writes happen atomically
/// ```
///
/// ## Swift Concept: Atomicity
/// "Atomic" means the operation is indivisible. Think of it like a bank transfer:
/// you don't want money to leave one account without arriving in another.
protocol WriteBatchProviding {

    // MARK: - Write Operations

    /// Add a "set data" operation to the batch
    /// - Parameters:
    ///   - data: The document data to write
    ///   - document: The document to write to
    ///   - merge: If true, merge with existing data; if false, overwrite
    func setData(_ data: [String: Any], forDocument document: DocumentProviding, merge: Bool)

    /// Add an "update" operation to the batch
    /// - Parameters:
    ///   - fields: The fields to update
    ///   - document: The document to update (must exist)
    func updateData(_ fields: [String: Any], forDocument document: DocumentProviding)

    /// Add a "delete" operation to the batch
    /// - Parameter document: The document to delete
    func deleteDocument(_ document: DocumentProviding)

    // MARK: - Commit

    /// Execute all operations in the batch atomically
    /// - Throws: Error if any operation fails (all operations are rolled back)
    func commit() async throws
}

// MARK: - Default Parameter Values

extension WriteBatchProviding {

    /// Set data without merging (overwrites entire document)
    func setData(_ data: [String: Any], forDocument document: DocumentProviding) {
        setData(data, forDocument: document, merge: false)
    }
}
