import Foundation

// MARK: - Document Snapshot Protocol

/// Represents a snapshot of a single document's data at a point in time.
///
/// When you fetch or listen to a document, you get a snapshot. The snapshot
/// tells you:
/// - Does the document exist?
/// - What is its ID?
/// - What data does it contain?
///
/// ## Swift Concept: Value vs Reference Semantics
/// A snapshot is a "frozen" view of the data. Even if the document changes
/// in the database, your snapshot still contains the old data.
protocol DocumentSnapshotProviding {

    /// Whether this document exists in the database
    var exists: Bool { get }

    /// The document's unique identifier
    var documentID: String { get }

    /// Reference to the document this snapshot came from
    /// Used for batch operations where you need to update/delete documents from a query result
    var reference: DocumentProviding { get }

    /// Get the raw data as a dictionary (returns nil if document doesn't exist)
    func data() -> [String: Any]?

    /// Decode the document data into a Codable type
    /// - Parameter type: The type to decode into
    /// - Returns: The decoded object
    /// - Throws: DecodingError if decoding fails
    ///
    /// ## Usage
    /// ```swift
    /// let userDTO = try snapshot.data(as: UserDTO.self)
    /// ```
    func data<T: Decodable>(as type: T.Type) throws -> T
}


// MARK: - Query Snapshot Protocol

/// Represents the results of a query at a point in time.
///
/// A query snapshot contains:
/// - All documents matching the query
/// - Whether the result set is empty
///
/// ## Swift Concept: Collections
/// `documents` is an array of `DocumentSnapshotProviding`. You can iterate,
/// map, filter, etc. just like any Swift array.
protocol QuerySnapshotProviding {

    /// All documents in the query result
    var documents: [DocumentSnapshotProviding] { get }

    /// Whether the query returned zero documents
    var isEmpty: Bool { get }

    /// The number of documents in the result
    var count: Int { get }
}


// MARK: - Listener Registration Protocol

/// Represents an active real-time listener.
///
/// When you call `addSnapshotListener`, you get back a registration.
/// You MUST call `remove()` when you're done listening to:
/// - Stop receiving updates
/// - Free up resources
/// - Avoid memory leaks
///
/// ## SwiftUI Integration
/// In SwiftUI, you typically store the registration and remove it in `onDisappear`:
/// ```swift
/// @State private var listener: ListenerRegistrationProviding?
///
/// .onAppear {
///     listener = repository.listenToUser(id: userId) { user in ... }
/// }
/// .onDisappear {
///     listener?.remove()
/// }
/// ```
protocol ListenerRegistrationProviding {

    /// Stop listening for updates
    func remove()
}


// MARK: - Transaction Protocol

/// Represents a database transaction for atomic read-then-write operations.
///
/// Transactions are more powerful than batches because you can READ data
/// before deciding what to WRITE. This is essential for operations like:
/// - "Add partner to couple only if there's room" (read member count, then update)
/// - "Increment a counter" (read current value, then write new value)
///
/// ## How Transactions Work
/// 1. You read documents using `getDocument`
/// 2. You queue writes using `setData`, `updateData`, or `deleteDocument`
/// 3. Firestore executes everything atomically
/// 4. If any read data changed since you read it, Firestore RETRIES your transaction
///
/// ## Example
/// ```swift
/// try await db.runTransaction { transaction in
///     let doc = try transaction.getDocument(coupleRef)
///     guard let members = doc.data()?["memberIDs"] as? [String],
///           members.count < 2 else { return nil }
///
///     transaction.updateData(["memberIDs": members + [newUserID]], forDocument: coupleRef)
///     return nil
/// }
/// ```
protocol TransactionProviding {

    /// Read a document within the transaction
    /// - Parameter document: The document to read
    /// - Returns: A snapshot of the document's current data
    /// - Throws: Error if the read fails
    func getDocument(_ document: DocumentProviding) throws -> DocumentSnapshotProviding

    /// Queue a "set data" operation
    /// - Parameters:
    ///   - data: The document data to write
    ///   - document: The document to write to
    ///   - merge: If true, merge with existing data
    func setData(_ data: [String: Any], forDocument document: DocumentProviding, merge: Bool)

    /// Queue an "update" operation
    /// - Parameters:
    ///   - fields: The fields to update
    ///   - document: The document to update
    func updateData(_ fields: [String: Any], forDocument document: DocumentProviding)

    /// Queue a "delete" operation
    /// - Parameter document: The document to delete
    func deleteDocument(_ document: DocumentProviding)
}

// MARK: - Default Parameter Values

extension TransactionProviding {

    /// Set data without merging (overwrites entire document)
    func setData(_ data: [String: Any], forDocument document: DocumentProviding) {
        setData(data, forDocument: document, merge: false)
    }
}
