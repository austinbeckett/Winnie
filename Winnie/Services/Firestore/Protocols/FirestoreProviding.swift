import Foundation

// MARK: - Main Database Protocol

/// The main entry point for all database operations.
///
/// This protocol abstracts the Firestore SDK, allowing us to:
/// - Use `FirestoreService` in production (wraps real Firestore)
/// - Use `MockFirestoreService` in tests (in-memory fake)
///
/// ## Why This Exists
/// Without this protocol, repositories would call `Firestore.firestore()` directly,
/// making them impossible to unit test without hitting real Firebase servers.
///
/// ## Usage
/// ```swift
/// class UserRepository {
///     private let db: FirestoreProviding
///
///     init(db: FirestoreProviding = FirestoreService()) {
///         self.db = db
///     }
/// }
/// ```
protocol FirestoreProviding {

    /// Access a top-level collection by path (e.g., "users", "couples")
    func collection(_ collectionPath: String) -> CollectionProviding

    /// Create a batch write operation for atomic multi-document updates
    func batch() -> WriteBatchProviding

    /// Run a transaction for atomic read-then-write operations
    /// - Parameter updateBlock: A closure that receives a transaction object
    /// - Returns: The value returned by the update block
    /// - Throws: Any error from the transaction or the update block
    func runTransaction<T>(_ updateBlock: @escaping (TransactionProviding) throws -> T?) async throws -> T?
}
