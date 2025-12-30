import Foundation

// MARK: - Document Protocol

/// Represents a single document in the database.
///
/// A document is like a file that contains fields (key-value pairs). For example:
/// - `/users/abc123` might contain `{ "email": "...", "displayName": "..." }`
/// - `/couples/xyz/goals/goal1` might contain `{ "type": "house", "targetAmount": 50000 }`
///
/// ## Key Operations
/// - Read: `document.getDocument()` - fetches the current data
/// - Write: `document.setData(...)` - creates or overwrites
/// - Update: `document.updateData(...)` - modifies specific fields
/// - Delete: `document.delete()` - removes the document
/// - Listen: `document.addSnapshotListener { ... }` - real-time updates
///
/// ## Swift Concept: Async/Await
/// Most operations are `async throws` because they involve network I/O.
/// You call them with `try await`:
/// ```swift
/// let snapshot = try await document.getDocument()
/// ```
protocol DocumentProviding {

    // MARK: - Properties

    /// The unique identifier for this document within its collection
    var documentID: String { get }

    // MARK: - Read Operations

    /// Fetch the current data for this document
    /// - Returns: A snapshot containing the document's data (or indicating it doesn't exist)
    func getDocument() async throws -> DocumentSnapshotProviding

    // MARK: - Write Operations

    /// Create or overwrite this document with the given data
    /// - Parameter documentData: The fields to write
    func setData(_ documentData: [String: Any]) async throws

    /// Create or update this document, optionally merging with existing data
    /// - Parameters:
    ///   - documentData: The fields to write
    ///   - merge: If true, only updates specified fields; if false, overwrites entire document
    func setData(_ documentData: [String: Any], merge: Bool) async throws

    /// Update specific fields in this document
    /// - Parameter fields: The fields to update (document must exist)
    /// - Throws: Error if document doesn't exist
    func updateData(_ fields: [String: Any]) async throws

    /// Delete this document
    func delete() async throws

    // MARK: - Subcollections

    /// Access a subcollection within this document
    /// - Parameter collectionPath: The name of the subcollection
    /// - Returns: A collection reference
    ///
    /// Example: `document.collection("goals")` for `/couples/xyz/goals`
    func collection(_ collectionPath: String) -> CollectionProviding

    // MARK: - Real-time Listeners

    /// Listen for changes to this document
    /// - Parameter listener: Called whenever the document changes
    /// - Returns: A registration that can be removed to stop listening
    func addSnapshotListener(
        _ listener: @escaping (DocumentSnapshotProviding?, Error?) -> Void
    ) -> ListenerRegistrationProviding
}

// MARK: - Default Parameter Values

extension DocumentProviding {

    /// Set data without merging (overwrites entire document)
    func setData(_ documentData: [String: Any]) async throws {
        try await setData(documentData, merge: false)
    }
}
