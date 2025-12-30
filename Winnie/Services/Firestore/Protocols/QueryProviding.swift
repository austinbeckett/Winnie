import Foundation

// MARK: - Query Protocol

/// Represents a query that can be built up and executed.
///
/// Queries let you filter and order documents. They're chainable:
/// ```swift
/// collection
///     .whereField("isActive", isEqualTo: true)
///     .order(by: "priority")
///     .limit(to: 10)
///     .getDocuments()
/// ```
///
/// ## Swift Concept: Method Chaining
/// Each method returns `QueryProviding`, so you can chain calls.
/// This is the "Builder" pattern - you build up a query step by step.
///
/// ## Important: Queries Are Immutable
/// Each method returns a NEW query. The original is unchanged:
/// ```swift
/// let baseQuery = collection.whereField("isActive", isEqualTo: true)
/// let orderedQuery = baseQuery.order(by: "priority")  // baseQuery unchanged
/// ```
protocol QueryProviding {

    // MARK: - Filtering

    /// Filter documents where a field equals a value
    /// - Parameters:
    ///   - field: The field name to filter on
    ///   - value: The value to match
    /// - Returns: A new query with the filter applied
    func whereField(_ field: String, isEqualTo value: Any) -> QueryProviding

    /// Filter documents where a field is less than a value
    /// - Parameters:
    ///   - field: The field name to filter on
    ///   - value: The value to compare against
    /// - Returns: A new query with the filter applied
    func whereField(_ field: String, isLessThan value: Any) -> QueryProviding

    // MARK: - Ordering

    /// Order results by a field
    /// - Parameters:
    ///   - field: The field to sort by
    ///   - descending: If true, sort in descending order
    /// - Returns: A new query with the ordering applied
    func order(by field: String, descending: Bool) -> QueryProviding

    // MARK: - Limiting

    /// Limit the number of results
    /// - Parameter limit: Maximum number of documents to return
    /// - Returns: A new query with the limit applied
    func limit(to limit: Int) -> QueryProviding

    // MARK: - Execution

    /// Execute the query and fetch matching documents
    /// - Returns: A snapshot containing the matching documents
    func getDocuments() async throws -> QuerySnapshotProviding

    // MARK: - Real-time Listeners

    /// Listen for changes to documents matching this query
    /// - Parameter listener: Called whenever matching documents change
    /// - Returns: A registration that can be removed to stop listening
    func addSnapshotListener(
        _ listener: @escaping (QuerySnapshotProviding?, Error?) -> Void
    ) -> ListenerRegistrationProviding
}

// MARK: - Default Parameter Values

extension QueryProviding {

    /// Order by field in ascending order (convenience method)
    func order(by field: String) -> QueryProviding {
        order(by: field, descending: false)
    }
}
