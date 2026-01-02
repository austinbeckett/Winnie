import Foundation

/// Protocol for ViewModels with async operations and error handling.
///
/// Provides a default implementation of `handleError(_:context:)` that:
/// - Logs errors in debug builds
/// - Converts `FirestoreError` to user-friendly messages
/// - Sets the `showError` flag to trigger UI alerts
///
/// ## Usage
/// ```swift
/// @Observable
/// @MainActor
/// final class MyViewModel: ErrorHandlingViewModel {
///     var isLoading = false
///     var errorMessage: String?
///     var showError = false
///
///     func doSomething() async {
///         isLoading = true
///         do {
///             try await someOperation()
///         } catch {
///             handleError(error, context: "doing something")
///         }
///         isLoading = false
///     }
/// }
/// ```
@MainActor
protocol ErrorHandlingViewModel: AnyObject {
    var isLoading: Bool { get set }
    var errorMessage: String? { get set }
    var showError: Bool { get set }
}

extension ErrorHandlingViewModel {

    /// Handle an error by logging it and setting user-facing error state.
    /// - Parameters:
    ///   - error: The error that occurred
    ///   - context: A description of what was happening (e.g., "loading contributions")
    func handleError(_ error: Error, context: String) {
        #if DEBUG
        print("\(type(of: self)) error \(context): \(error.localizedDescription)")
        #endif

        if let firestoreError = error as? FirestoreError {
            errorMessage = firestoreError.userMessage
        } else {
            errorMessage = "Something went wrong while \(context). Please try again."
        }

        showError = true
    }
}
