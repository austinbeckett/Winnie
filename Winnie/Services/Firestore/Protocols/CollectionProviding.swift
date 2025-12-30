import Foundation

// MARK: - Collection Protocol

/// Represents a collection of documents in the database.
///
/// A collection is like a folder that contains documents. For example:
/// - `/users` contains all user documents
/// - `/couples/{coupleId}/goals` contains goal documents for a specific couple
///
/// ## Key Operations
/// - Get a specific document: `collection.document("abc123")`
/// - Query documents: `collection.whereField(...).order(by:...)`
/// - Listen for changes: `collection.addSnapshotListener { ... }`
///
/// ## Swift Concept: Protocol Composition
/// This protocol defines "what" a collection can do, without specifying "how".
/// Both `FirestoreCollection` (real) and `MockCollection` (fake) implement this.
protocol CollectionProviding {

    // MARK: - Document Access

    /// Get a reference to a specific document by ID
    /// - Parameter documentID: The unique identifier for the document
    /// - Returns: A document reference (doesn't fetch data yet)
    func document(_ documentID: String) -> DocumentProviding

    // MARK: - Queries

    /// Fetch all documents in this collection
    /// - Returns: A snapshot containing all documents
    func getDocuments() async throws -> QuerySnapshotProviding

    /// Filter documents where a field equals a value
    /// - Parameters:
    ///   - field: The field name to filter on
    ///   - value: The value to match
    /// - Returns: A query that can be further refined or executed
    func whereField(_ field: String, isEqualTo value: Any) -> QueryProviding

    /// Order results by a field
    /// - Parameters:
    ///   - field: The field to sort by
    ///   - descending: If true, sort in descending order (default: false)
    /// - Returns: A query that can be further refined or executed
    func order(by field: String, descending: Bool) -> QueryProviding

    // MARK: - Real-time Listeners

    /// Listen for changes to documents in this collection
    /// - Parameter listener: Called whenever documents change
    /// - Returns: A registration that can be removed to stop listening
    func addSnapshotListener(
        _ listener: @escaping (QuerySnapshotProviding?, Error?) -> Void
    ) -> ListenerRegistrationProviding
}

// MARK: - Default Parameter Values

/// Extension to provide default parameter values (Swift protocols can't have defaults)
extension CollectionProviding {

    /// Order by field in ascending order (convenience method)
    func order(by field: String) -> QueryProviding {
        order(by: field, descending: false)
    }
}
