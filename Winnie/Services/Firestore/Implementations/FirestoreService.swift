import Foundation
import FirebaseFirestore

// MARK: - Firestore Service (Production Implementation)

/// Production implementation of `FirestoreProviding` that wraps the real Firestore SDK.
///
/// This class is the "adapter" between our protocol-based architecture and Firebase.
/// It delegates all operations to the real Firestore SDK while conforming to our protocols.
///
/// ## Why This Exists
/// By wrapping Firestore in this class, our repositories depend on `FirestoreProviding`
/// (the protocol) rather than `Firestore` (the concrete class). This allows us to
/// swap in a mock implementation during tests.
///
/// ## Usage
/// In production, repositories use this automatically:
/// ```swift
/// class UserRepository {
///     private let db: FirestoreProviding
///
///     init(db: FirestoreProviding = FirestoreService.shared) {
///         self.db = db
///     }
/// }
/// ```
final class FirestoreService: FirestoreProviding {

    // MARK: - Shared Instance

    /// Shared instance using the default Firestore database
    static let shared = FirestoreService()

    // MARK: - Properties

    private let firestore: Firestore

    // MARK: - Initialization

    /// Create a FirestoreService with the default Firestore instance
    init() {
        self.firestore = Firestore.firestore()
    }

    /// Create a FirestoreService with a specific Firestore instance (for testing)
    init(firestore: Firestore) {
        self.firestore = firestore
    }

    // MARK: - FirestoreProviding

    func collection(_ collectionPath: String) -> CollectionProviding {
        FirestoreCollectionWrapper(reference: firestore.collection(collectionPath))
    }

    func batch() -> WriteBatchProviding {
        FirestoreWriteBatchWrapper(batch: firestore.batch())
    }

    func runTransaction<T>(_ updateBlock: @escaping (TransactionProviding) throws -> T?) async throws -> T? {
        let result = try await firestore.runTransaction { transaction, errorPointer in
            do {
                let wrapper = FirestoreTransactionWrapper(transaction: transaction)
                return try updateBlock(wrapper)
            } catch {
                errorPointer?.pointee = error as NSError
                return nil
            }
        }
        return result as? T
    }
}


// MARK: - Collection Wrapper

/// Wraps `CollectionReference` to conform to `CollectionProviding`
final class FirestoreCollectionWrapper: CollectionProviding {

    private let reference: CollectionReference

    init(reference: CollectionReference) {
        self.reference = reference
    }

    func document(_ documentID: String) -> DocumentProviding {
        FirestoreDocumentWrapper(reference: reference.document(documentID))
    }

    func getDocuments() async throws -> QuerySnapshotProviding {
        let snapshot = try await reference.getDocuments()
        return FirestoreQuerySnapshotWrapper(snapshot: snapshot)
    }

    func whereField(_ field: String, isEqualTo value: Any) -> QueryProviding {
        FirestoreQueryWrapper(query: reference.whereField(field, isEqualTo: value))
    }

    func order(by field: String, descending: Bool) -> QueryProviding {
        FirestoreQueryWrapper(query: reference.order(by: field, descending: descending))
    }

    func addSnapshotListener(
        _ listener: @escaping (QuerySnapshotProviding?, Error?) -> Void
    ) -> ListenerRegistrationProviding {
        let registration = reference.addSnapshotListener { snapshot, error in
            if let snapshot {
                listener(FirestoreQuerySnapshotWrapper(snapshot: snapshot), error)
            } else {
                listener(nil, error)
            }
        }
        return FirestoreListenerRegistrationWrapper(registration: registration)
    }
}


// MARK: - Document Wrapper

/// Wraps `DocumentReference` to conform to `DocumentProviding`
final class FirestoreDocumentWrapper: DocumentProviding {

    private let reference: DocumentReference

    init(reference: DocumentReference) {
        self.reference = reference
    }

    var documentID: String {
        reference.documentID
    }

    func getDocument() async throws -> DocumentSnapshotProviding {
        let snapshot = try await reference.getDocument()
        return FirestoreDocumentSnapshotWrapper(snapshot: snapshot)
    }

    func setData(_ documentData: [String: Any], merge: Bool) async throws {
        try await reference.setData(documentData, merge: merge)
    }

    func updateData(_ fields: [String: Any]) async throws {
        try await reference.updateData(fields)
    }

    func delete() async throws {
        try await reference.delete()
    }

    func collection(_ collectionPath: String) -> CollectionProviding {
        FirestoreCollectionWrapper(reference: reference.collection(collectionPath))
    }

    func addSnapshotListener(
        _ listener: @escaping (DocumentSnapshotProviding?, Error?) -> Void
    ) -> ListenerRegistrationProviding {
        let registration = reference.addSnapshotListener { snapshot, error in
            if let snapshot {
                listener(FirestoreDocumentSnapshotWrapper(snapshot: snapshot), error)
            } else {
                listener(nil, error)
            }
        }
        return FirestoreListenerRegistrationWrapper(registration: registration)
    }
}


// MARK: - Query Wrapper

/// Wraps `Query` to conform to `QueryProviding`
final class FirestoreQueryWrapper: QueryProviding {

    private let query: Query

    init(query: Query) {
        self.query = query
    }

    func whereField(_ field: String, isEqualTo value: Any) -> QueryProviding {
        FirestoreQueryWrapper(query: query.whereField(field, isEqualTo: value))
    }

    func order(by field: String, descending: Bool) -> QueryProviding {
        FirestoreQueryWrapper(query: query.order(by: field, descending: descending))
    }

    func limit(to limit: Int) -> QueryProviding {
        FirestoreQueryWrapper(query: query.limit(to: limit))
    }

    func getDocuments() async throws -> QuerySnapshotProviding {
        let snapshot = try await query.getDocuments()
        return FirestoreQuerySnapshotWrapper(snapshot: snapshot)
    }

    func addSnapshotListener(
        _ listener: @escaping (QuerySnapshotProviding?, Error?) -> Void
    ) -> ListenerRegistrationProviding {
        let registration = query.addSnapshotListener { snapshot, error in
            if let snapshot {
                listener(FirestoreQuerySnapshotWrapper(snapshot: snapshot), error)
            } else {
                listener(nil, error)
            }
        }
        return FirestoreListenerRegistrationWrapper(registration: registration)
    }
}


// MARK: - Write Batch Wrapper

/// Wraps `WriteBatch` to conform to `WriteBatchProviding`
final class FirestoreWriteBatchWrapper: WriteBatchProviding {

    private let batch: WriteBatch

    init(batch: WriteBatch) {
        self.batch = batch
    }

    func setData(_ data: [String: Any], forDocument document: DocumentProviding, merge: Bool) {
        guard let wrapper = document as? FirestoreDocumentWrapper else {
            fatalError("Document must be a FirestoreDocumentWrapper in production")
        }
        // Access the underlying reference via a helper
        let ref = wrapper.underlyingReference
        batch.setData(data, forDocument: ref, merge: merge)
    }

    func updateData(_ fields: [String: Any], forDocument document: DocumentProviding) {
        guard let wrapper = document as? FirestoreDocumentWrapper else {
            fatalError("Document must be a FirestoreDocumentWrapper in production")
        }
        let ref = wrapper.underlyingReference
        batch.updateData(fields, forDocument: ref)
    }

    func deleteDocument(_ document: DocumentProviding) {
        guard let wrapper = document as? FirestoreDocumentWrapper else {
            fatalError("Document must be a FirestoreDocumentWrapper in production")
        }
        let ref = wrapper.underlyingReference
        batch.deleteDocument(ref)
    }

    func commit() async throws {
        try await batch.commit()
    }
}


// MARK: - Transaction Wrapper

/// Wraps `Transaction` to conform to `TransactionProviding`
final class FirestoreTransactionWrapper: TransactionProviding {

    private let transaction: Transaction

    init(transaction: Transaction) {
        self.transaction = transaction
    }

    func getDocument(_ document: DocumentProviding) throws -> DocumentSnapshotProviding {
        guard let wrapper = document as? FirestoreDocumentWrapper else {
            fatalError("Document must be a FirestoreDocumentWrapper in production")
        }
        let ref = wrapper.underlyingReference
        let snapshot = try transaction.getDocument(ref)
        return FirestoreDocumentSnapshotWrapper(snapshot: snapshot)
    }

    func setData(_ data: [String: Any], forDocument document: DocumentProviding, merge: Bool) {
        guard let wrapper = document as? FirestoreDocumentWrapper else {
            fatalError("Document must be a FirestoreDocumentWrapper in production")
        }
        let ref = wrapper.underlyingReference
        transaction.setData(data, forDocument: ref, merge: merge)
    }

    func updateData(_ fields: [String: Any], forDocument document: DocumentProviding) {
        guard let wrapper = document as? FirestoreDocumentWrapper else {
            fatalError("Document must be a FirestoreDocumentWrapper in production")
        }
        let ref = wrapper.underlyingReference
        transaction.updateData(fields, forDocument: ref)
    }

    func deleteDocument(_ document: DocumentProviding) {
        guard let wrapper = document as? FirestoreDocumentWrapper else {
            fatalError("Document must be a FirestoreDocumentWrapper in production")
        }
        let ref = wrapper.underlyingReference
        transaction.deleteDocument(ref)
    }
}


// MARK: - Document Snapshot Wrapper

/// Wraps `DocumentSnapshot` to conform to `DocumentSnapshotProviding`
final class FirestoreDocumentSnapshotWrapper: DocumentSnapshotProviding {

    private let snapshot: DocumentSnapshot

    init(snapshot: DocumentSnapshot) {
        self.snapshot = snapshot
    }

    var exists: Bool {
        snapshot.exists
    }

    var documentID: String {
        snapshot.documentID
    }

    func data() -> [String: Any]? {
        snapshot.data()
    }

    func data<T: Decodable>(as type: T.Type) throws -> T {
        try snapshot.data(as: type)
    }
}


// MARK: - Query Snapshot Wrapper

/// Wraps `QuerySnapshot` to conform to `QuerySnapshotProviding`
final class FirestoreQuerySnapshotWrapper: QuerySnapshotProviding {

    private let snapshot: QuerySnapshot

    init(snapshot: QuerySnapshot) {
        self.snapshot = snapshot
    }

    var documents: [DocumentSnapshotProviding] {
        snapshot.documents.map { FirestoreDocumentSnapshotWrapper(snapshot: $0) }
    }

    var isEmpty: Bool {
        snapshot.isEmpty
    }

    var count: Int {
        snapshot.count
    }
}


// MARK: - Listener Registration Wrapper

/// Wraps `ListenerRegistration` to conform to `ListenerRegistrationProviding`
final class FirestoreListenerRegistrationWrapper: ListenerRegistrationProviding {

    private let registration: ListenerRegistration

    init(registration: ListenerRegistration) {
        self.registration = registration
    }

    func remove() {
        registration.remove()
    }
}


// MARK: - Helper Extension

/// Provides access to the underlying DocumentReference for batch/transaction operations
extension FirestoreDocumentWrapper {

    /// Access the underlying Firestore DocumentReference
    /// This is needed for batch and transaction operations that require the concrete type
    var underlyingReference: DocumentReference {
        reference
    }
}
