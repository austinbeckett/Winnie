import Foundation
@testable import Winnie

// MARK: - Mock Firestore Service

/// In-memory mock implementation of `FirestoreProviding` for unit tests.
///
/// This mock allows you to:
/// 1. **Stub data**: Pre-populate the "database" with test data
/// 2. **Inject errors**: Make operations fail with specific errors
/// 3. **Verify calls**: Check what operations were performed
///
/// ## Example Usage
/// ```swift
/// func testFetchUser() async throws {
///     // Arrange
///     let mock = MockFirestoreService()
///     mock.stubDocument(path: "users/123", data: ["email": "test@example.com"])
///
///     let repository = UserRepository(db: mock)
///
///     // Act
///     let user = try await repository.fetchUser(id: "123")
///
///     // Assert
///     XCTAssertEqual(user.email, "test@example.com")
/// }
/// ```
final class MockFirestoreService: FirestoreProviding {

    // MARK: - Stubbed Data

    /// In-memory document storage: path -> data
    /// Example: ["users/abc123": ["email": "test@example.com", "displayName": "Test"]]
    var documents: [String: [String: Any]] = [:]

    /// Error to throw on the next operation (nil = success)
    var errorToThrow: Error?

    // MARK: - Call Recording

    /// Records all setData calls: (path, data, merge)
    var setDataCalls: [(path: String, data: [String: Any], merge: Bool)] = []

    /// Records all updateData calls: (path, fields)
    var updateDataCalls: [(path: String, fields: [String: Any])] = []

    /// Records all delete calls: path
    var deleteCalls: [String] = []

    /// Records all getDocument calls: path
    var getDocumentCalls: [String] = []

    /// Records all batch commits
    var batchCommitCount: Int = 0

    /// Records all transaction runs
    var transactionRunCount: Int = 0

    // MARK: - Listener Simulation

    /// Listeners registered for document paths
    var documentListeners: [String: (DocumentSnapshotProviding?, Error?) -> Void] = [:]

    /// Listeners registered for collection paths
    var collectionListeners: [String: (QuerySnapshotProviding?, Error?) -> Void] = [:]

    // MARK: - FirestoreProviding

    func collection(_ collectionPath: String) -> CollectionProviding {
        MockCollection(service: self, path: collectionPath)
    }

    func batch() -> WriteBatchProviding {
        MockWriteBatch(service: self)
    }

    func runTransaction<T>(_ updateBlock: @escaping (TransactionProviding) throws -> T?) async throws -> T? {
        transactionRunCount += 1

        if let error = errorToThrow {
            throw error
        }

        let transaction = MockTransaction(service: self)
        return try updateBlock(transaction)
    }

    // MARK: - Test Helpers: Stubbing

    /// Add a document to the mock database
    /// - Parameters:
    ///   - path: Full document path (e.g., "users/abc123")
    ///   - data: The document data
    func stubDocument(path: String, data: [String: Any]) {
        documents[path] = data
    }

    /// Remove a document from the mock database
    func removeDocument(path: String) {
        documents.removeValue(forKey: path)
    }

    /// Clear all stubbed documents
    func clearDocuments() {
        documents.removeAll()
    }

    // MARK: - Test Helpers: Verification

    /// Check if setData was called for a specific path
    func didSetData(at path: String) -> Bool {
        setDataCalls.contains { $0.path == path }
    }

    /// Get the data that was written to a path
    func dataWritten(to path: String) -> [String: Any]? {
        setDataCalls.first { $0.path == path }?.data
    }

    /// Check if updateData was called for a specific path
    func didUpdateData(at path: String) -> Bool {
        updateDataCalls.contains { $0.path == path }
    }

    /// Get the fields that were updated at a path
    func fieldsUpdated(at path: String) -> [String: Any]? {
        updateDataCalls.first { $0.path == path }?.fields
    }

    /// Check if delete was called for a specific path
    func didDelete(at path: String) -> Bool {
        deleteCalls.contains(path)
    }

    /// Reset all recorded calls
    func resetRecording() {
        setDataCalls.removeAll()
        updateDataCalls.removeAll()
        deleteCalls.removeAll()
        getDocumentCalls.removeAll()
        batchCommitCount = 0
        transactionRunCount = 0
    }

    // MARK: - Test Helpers: Listener Simulation

    /// Simulate a document update (triggers any registered listeners)
    func simulateDocumentChange(path: String, data: [String: Any]?) {
        documents[path] = data ?? [:]
        if let listener = documentListeners[path] {
            let snapshot = MockDocumentSnapshot(
                documentID: path.components(separatedBy: "/").last ?? path,
                data: data,
                exists: data != nil
            )
            listener(snapshot, nil)
        }
    }

    /// Simulate an error on a listener
    func simulateListenerError(path: String, error: Error) {
        if let listener = documentListeners[path] {
            listener(nil, error)
        }
    }
}


// MARK: - Mock Collection

final class MockCollection: CollectionProviding {

    private let service: MockFirestoreService
    private let path: String

    init(service: MockFirestoreService, path: String) {
        self.service = service
        self.path = path
    }

    func document(_ documentID: String) -> DocumentProviding {
        MockDocument(service: service, path: "\(path)/\(documentID)")
    }

    func getDocuments() async throws -> QuerySnapshotProviding {
        if let error = service.errorToThrow {
            throw error
        }

        // Find all documents in this collection
        let prefix = path + "/"
        let matchingDocs = service.documents.filter { key, _ in
            key.hasPrefix(prefix) && !key.dropFirst(prefix.count).contains("/")
        }

        let snapshots = matchingDocs.map { key, data in
            MockDocumentSnapshot(
                documentID: key.components(separatedBy: "/").last ?? key,
                data: data,
                exists: true
            )
        }

        return MockQuerySnapshot(documents: snapshots)
    }

    func whereField(_ field: String, isEqualTo value: Any) -> QueryProviding {
        MockQuery(service: service, basePath: path, filters: [(field, value)], ordering: [])
    }

    func order(by field: String, descending: Bool) -> QueryProviding {
        MockQuery(service: service, basePath: path, filters: [], ordering: [(field, descending)])
    }

    func addSnapshotListener(
        _ listener: @escaping (QuerySnapshotProviding?, Error?) -> Void
    ) -> ListenerRegistrationProviding {
        service.collectionListeners[path] = listener

        // Immediately call with current data
        Task {
            do {
                let snapshot = try await getDocuments()
                listener(snapshot, nil)
            } catch {
                listener(nil, error)
            }
        }

        return MockListenerRegistration { [weak service] in
            service?.collectionListeners.removeValue(forKey: self.path)
        }
    }
}


// MARK: - Mock Document

final class MockDocument: DocumentProviding {

    private let service: MockFirestoreService
    let path: String

    init(service: MockFirestoreService, path: String) {
        self.service = service
        self.path = path
    }

    var documentID: String {
        path.components(separatedBy: "/").last ?? path
    }

    func getDocument() async throws -> DocumentSnapshotProviding {
        service.getDocumentCalls.append(path)

        if let error = service.errorToThrow {
            throw error
        }

        let data = service.documents[path]
        return MockDocumentSnapshot(
            documentID: documentID,
            data: data,
            exists: data != nil
        )
    }

    func setData(_ documentData: [String: Any], merge: Bool) async throws {
        if let error = service.errorToThrow {
            throw error
        }

        service.setDataCalls.append((path: path, data: documentData, merge: merge))

        if merge, let existing = service.documents[path] {
            var merged = existing
            for (key, value) in documentData {
                merged[key] = value
            }
            service.documents[path] = merged
        } else {
            service.documents[path] = documentData
        }
    }

    func updateData(_ fields: [String: Any]) async throws {
        if let error = service.errorToThrow {
            throw error
        }

        service.updateDataCalls.append((path: path, fields: fields))

        if var existing = service.documents[path] {
            for (key, value) in fields {
                existing[key] = value
            }
            service.documents[path] = existing
        } else {
            throw FirestoreError.documentNotFound
        }
    }

    func delete() async throws {
        if let error = service.errorToThrow {
            throw error
        }

        service.deleteCalls.append(path)
        service.documents.removeValue(forKey: path)
    }

    func collection(_ collectionPath: String) -> CollectionProviding {
        MockCollection(service: service, path: "\(path)/\(collectionPath)")
    }

    func addSnapshotListener(
        _ listener: @escaping (DocumentSnapshotProviding?, Error?) -> Void
    ) -> ListenerRegistrationProviding {
        service.documentListeners[path] = listener

        // Immediately call with current data
        let data = service.documents[path]
        let snapshot = MockDocumentSnapshot(
            documentID: documentID,
            data: data,
            exists: data != nil
        )
        listener(snapshot, nil)

        return MockListenerRegistration { [weak service] in
            service?.documentListeners.removeValue(forKey: self.path)
        }
    }
}


// MARK: - Mock Query

final class MockQuery: QueryProviding {

    private let service: MockFirestoreService
    private let basePath: String
    private let filters: [(field: String, value: Any)]
    private let ordering: [(field: String, descending: Bool)]
    private var limitCount: Int?

    init(
        service: MockFirestoreService,
        basePath: String,
        filters: [(field: String, value: Any)],
        ordering: [(field: String, descending: Bool)]
    ) {
        self.service = service
        self.basePath = basePath
        self.filters = filters
        self.ordering = ordering
    }

    func whereField(_ field: String, isEqualTo value: Any) -> QueryProviding {
        MockQuery(
            service: service,
            basePath: basePath,
            filters: filters + [(field, value)],
            ordering: ordering
        )
    }

    func order(by field: String, descending: Bool) -> QueryProviding {
        MockQuery(
            service: service,
            basePath: basePath,
            filters: filters,
            ordering: ordering + [(field, descending)]
        )
    }

    func limit(to limit: Int) -> QueryProviding {
        let query = MockQuery(
            service: service,
            basePath: basePath,
            filters: filters,
            ordering: ordering
        )
        query.limitCount = limit
        return query
    }

    func getDocuments() async throws -> QuerySnapshotProviding {
        if let error = service.errorToThrow {
            throw error
        }

        // Find all documents in the collection
        let prefix = basePath + "/"
        var matchingDocs = service.documents.filter { key, _ in
            key.hasPrefix(prefix) && !key.dropFirst(prefix.count).contains("/")
        }

        // Apply filters
        for (field, expectedValue) in filters {
            matchingDocs = matchingDocs.filter { _, data in
                guard let actualValue = data[field] else { return false }
                return "\(actualValue)" == "\(expectedValue)"
            }
        }

        // Convert to snapshots
        var snapshots = matchingDocs.map { key, data in
            MockDocumentSnapshot(
                documentID: key.components(separatedBy: "/").last ?? key,
                data: data,
                exists: true
            )
        }

        // Apply ordering (simplified: only handles first ordering)
        if let (field, descending) = ordering.first {
            snapshots.sort { a, b in
                let aVal = a.data()?[field]
                let bVal = b.data()?[field]

                // Handle common types
                if let aInt = aVal as? Int, let bInt = bVal as? Int {
                    return descending ? aInt > bInt : aInt < bInt
                }
                if let aStr = aVal as? String, let bStr = bVal as? String {
                    return descending ? aStr > bStr : aStr < bStr
                }
                return false
            }
        }

        // Apply limit
        if let limit = limitCount {
            snapshots = Array(snapshots.prefix(limit))
        }

        return MockQuerySnapshot(documents: snapshots)
    }

    func addSnapshotListener(
        _ listener: @escaping (QuerySnapshotProviding?, Error?) -> Void
    ) -> ListenerRegistrationProviding {
        let queryKey = "\(basePath)_query_\(UUID().uuidString)"
        service.collectionListeners[queryKey] = listener

        // Immediately call with current data
        Task {
            do {
                let snapshot = try await getDocuments()
                listener(snapshot, nil)
            } catch {
                listener(nil, error)
            }
        }

        return MockListenerRegistration { [weak service] in
            service?.collectionListeners.removeValue(forKey: queryKey)
        }
    }
}


// MARK: - Mock Write Batch

final class MockWriteBatch: WriteBatchProviding {

    private let service: MockFirestoreService
    private var operations: [() async throws -> Void] = []

    init(service: MockFirestoreService) {
        self.service = service
    }

    func setData(_ data: [String: Any], forDocument document: DocumentProviding, merge: Bool) {
        guard let mockDoc = document as? MockDocument else { return }
        operations.append {
            try await mockDoc.setData(data, merge: merge)
        }
    }

    func updateData(_ fields: [String: Any], forDocument document: DocumentProviding) {
        guard let mockDoc = document as? MockDocument else { return }
        operations.append {
            try await mockDoc.updateData(fields)
        }
    }

    func deleteDocument(_ document: DocumentProviding) {
        guard let mockDoc = document as? MockDocument else { return }
        operations.append {
            try await mockDoc.delete()
        }
    }

    func commit() async throws {
        if let error = service.errorToThrow {
            throw error
        }

        service.batchCommitCount += 1

        for operation in operations {
            try await operation()
        }
    }
}


// MARK: - Mock Transaction

final class MockTransaction: TransactionProviding {

    private let service: MockFirestoreService
    private var pendingWrites: [() -> Void] = []

    init(service: MockFirestoreService) {
        self.service = service
    }

    func getDocument(_ document: DocumentProviding) throws -> DocumentSnapshotProviding {
        guard let mockDoc = document as? MockDocument else {
            throw FirestoreError.unknown(NSError(domain: "Mock", code: -1))
        }

        service.getDocumentCalls.append(mockDoc.path)

        let data = service.documents[mockDoc.path]
        return MockDocumentSnapshot(
            documentID: mockDoc.documentID,
            data: data,
            exists: data != nil
        )
    }

    func setData(_ data: [String: Any], forDocument document: DocumentProviding, merge: Bool) {
        guard let mockDoc = document as? MockDocument else { return }
        let path = mockDoc.path

        service.setDataCalls.append((path: path, data: data, merge: merge))

        if merge, let existing = service.documents[path] {
            var merged = existing
            for (key, value) in data {
                merged[key] = value
            }
            service.documents[path] = merged
        } else {
            service.documents[path] = data
        }
    }

    func updateData(_ fields: [String: Any], forDocument document: DocumentProviding) {
        guard let mockDoc = document as? MockDocument else { return }
        let path = mockDoc.path

        service.updateDataCalls.append((path: path, fields: fields))

        if var existing = service.documents[path] {
            for (key, value) in fields {
                existing[key] = value
            }
            service.documents[path] = existing
        }
    }

    func deleteDocument(_ document: DocumentProviding) {
        guard let mockDoc = document as? MockDocument else { return }
        service.deleteCalls.append(mockDoc.path)
        service.documents.removeValue(forKey: mockDoc.path)
    }
}


// MARK: - Mock Document Snapshot

final class MockDocumentSnapshot: DocumentSnapshotProviding {

    let documentID: String
    private let _data: [String: Any]?
    let exists: Bool

    init(documentID: String, data: [String: Any]?, exists: Bool) {
        self.documentID = documentID
        self._data = data
        self.exists = exists
    }

    func data() -> [String: Any]? {
        _data
    }

    func data<T: Decodable>(as type: T.Type) throws -> T {
        guard let data = _data else {
            throw FirestoreError.documentNotFound
        }

        // Convert dictionary to JSON, then decode with date handling
        let jsonData = try JSONSerialization.data(withJSONObject: data)

        let decoder = JSONDecoder()
        // Handle ISO8601 date strings (used in test fixtures)
        decoder.dateDecodingStrategy = .iso8601

        return try decoder.decode(type, from: jsonData)
    }
}


// MARK: - Mock Query Snapshot

final class MockQuerySnapshot: QuerySnapshotProviding {

    let documents: [DocumentSnapshotProviding]

    init(documents: [DocumentSnapshotProviding]) {
        self.documents = documents
    }

    var isEmpty: Bool {
        documents.isEmpty
    }

    var count: Int {
        documents.count
    }
}


// MARK: - Mock Listener Registration

final class MockListenerRegistration: ListenerRegistrationProviding {

    private let onRemove: () -> Void
    private(set) var wasRemoved = false

    init(onRemove: @escaping () -> Void) {
        self.onRemove = onRemove
    }

    func remove() {
        wasRemoved = true
        onRemove()
    }
}
