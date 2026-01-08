import Foundation

/// Central state container for the app's user and couple data.
///
/// AppState is responsible for:
/// - Loading the current user from Firestore after authentication
/// - Creating a new user document if one doesn't exist
/// - Loading partner data if the user is connected to a partner
///
/// ## Usage
/// ```swift
/// @State private var appState = AppState()
///
/// // After auth state changes to signedIn
/// await appState.loadUser(uid: uid)
///
/// // Access user data
/// if let user = appState.currentUser {
///     Text("Hello, \(user.greetingName)")
/// }
/// ```
@Observable
@MainActor
class AppState {

    // MARK: - User Data

    /// The currently signed-in user
    var currentUser: User?

    /// The current user's partner (if connected)
    var partner: User?

    /// The couple container (if user is in a couple)
    var couple: Couple?

    // MARK: - Loading State

    /// Whether user data is currently being loaded
    var isLoading = false

    /// Error message if loading failed
    var errorMessage: String?

    // MARK: - Initialization

    init() {
        // No dependencies initialized here to avoid Firebase initialization order issues.
        // UserRepository is created when needed in methods below.
    }

    // MARK: - User Loading

    /// Load the current user's data from Firestore.
    ///
    /// This method:
    /// 1. Checks if a user document exists
    /// 2. Creates one if it doesn't (new user), using provided initial data if available
    /// 3. Loads partner data if the user is connected
    ///
    /// - Parameters:
    ///   - uid: The Firebase Auth user ID
    ///   - initialData: Optional data from Apple Sign-In for new users (displayName, email)
    func loadUser(uid: String, initialData: NewUserInfo? = nil) async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        // Create repository here (after FirebaseApp.configure() has been called)
        let userRepository = UserRepository()

        do {
            // Check if user document exists
            let exists = try await userRepository.userExists(id: uid)

            if exists {
                // Load existing user
                currentUser = try await userRepository.fetchUser(id: uid)

                // Load partner if connected
                if let partnerID = currentUser?.partnerID {
                    do {
                        partner = try await userRepository.fetchUser(id: partnerID)
                    } catch {
                        // Partner might not exist yet, that's okay
                        partner = nil
                    }
                }
            } else {
                // Create new user document, using Apple Sign-In data if available
                let displayName = initialData?.displayName
                let email = initialData?.email
                try await userRepository.createUser(id: uid, displayName: displayName, email: email)
                currentUser = User(id: uid, displayName: displayName, email: email)
            }
        } catch {
            errorMessage = "Failed to load user: \(error.localizedDescription)"
            #if DEBUG
            print("AppState: Error loading user - \(type(of: error))")
            #endif
        }
    }

    /// Update the current user's display name.
    ///
    /// Called after onboarding name input.
    /// - Parameter name: The display name to set
    func updateDisplayName(_ name: String) async {
        guard let uid = currentUser?.id else { return }

        let userRepository = UserRepository()

        do {
            try await userRepository.updateDisplayName(uid: uid, displayName: name)
            // Update local state
            currentUser?.displayName = name
        } catch {
            errorMessage = "Failed to save name: \(error.localizedDescription)"
            #if DEBUG
            print("AppState: Error updating display name - \(type(of: error))")
            #endif
        }
    }

    // MARK: - Onboarding

    /// Save onboarding data to Firestore.
    ///
    /// Called when user completes the onboarding wizard.
    /// Creates a couple if needed, saves the financial profile and first goal,
    /// then marks onboarding complete.
    ///
    /// - Parameters:
    ///   - profile: The user's financial profile from onboarding
    ///   - goal: The user's first goal from onboarding
    func saveOnboardingData(profile: FinancialProfile, goal: Goal?) async {
        guard let uid = currentUser?.id else {
            #if DEBUG
            print("AppState: saveOnboardingData failed - no current user ID")
            #endif
            return
        }

        #if DEBUG
        print("AppState: Saving onboarding data for user \(uid)")
        print("AppState: Profile - income: \(profile.monthlyIncome), needs: \(profile.monthlyNeeds), wants: \(profile.monthlyWants), savingsPool: \(profile.savingsPool)")
        #endif

        let userRepository = UserRepository()
        let coupleRepository = CoupleRepository()
        let goalRepository = GoalRepository()

        do {
            // Determine or create the couple ID
            var coupleID = currentUser?.coupleID

            if coupleID == nil {
                #if DEBUG
                print("AppState: Creating new couple for user")
                #endif
                // Create a new couple for this user
                let newCouple = try await coupleRepository.createCouple(for: uid)
                coupleID = newCouple.id

                // Update user's coupleID reference (no partner yet during onboarding)
                try await userRepository.updateCoupleAssociation(uid: uid, coupleID: newCouple.id, partnerID: nil)
                currentUser?.coupleID = newCouple.id
                couple = newCouple
                #if DEBUG
                print("AppState: Created couple with ID: \(newCouple.id)")
                #endif
            } else {
                #if DEBUG
                print("AppState: Using existing coupleID: \(coupleID!)")
                #endif
            }

            guard let coupleID else {
                #if DEBUG
                print("AppState: Failed - coupleID is nil after creation attempt")
                #endif
                return
            }

            // Save financial profile to the couple
            #if DEBUG
            print("AppState: Saving financial profile to couple \(coupleID)")
            #endif
            try await coupleRepository.updateFinancialProfile(profile, coupleID: coupleID)

            // Save first goal if provided
            if let goal {
                #if DEBUG
                print("AppState: Saving goal '\(goal.name)' to couple \(coupleID)")
                #endif
                try await goalRepository.createGoal(goal, coupleID: coupleID)
            }

            // Mark onboarding as complete
            try await userRepository.completeOnboarding(uid: uid)
            currentUser?.hasCompletedOnboarding = true

            #if DEBUG
            print("AppState: ✅ Onboarding data saved successfully!")
            #endif
        } catch {
            errorMessage = "Failed to save onboarding data: \(error.localizedDescription)"
            #if DEBUG
            print("AppState: ❌ Error saving onboarding data - \(error)")
            #endif
        }
    }

    /// Reset onboarding status for testing.
    ///
    /// Called from developer settings to re-test the onboarding flow.
    /// Does not delete user data, just resets the onboarding flag.
    func resetOnboarding() async {
        guard let uid = currentUser?.id else { return }

        let userRepository = UserRepository()

        do {
            try await userRepository.resetOnboarding(uid: uid)
            currentUser?.hasCompletedOnboarding = false

            #if DEBUG
            print("AppState: Onboarding reset successfully")
            #endif
        } catch {
            errorMessage = "Failed to reset onboarding: \(error.localizedDescription)"
            #if DEBUG
            print("AppState: Error resetting onboarding - \(type(of: error))")
            #endif
        }
    }

    /// Clear all user data (for sign out)
    func clearUserData() {
        currentUser = nil
        partner = nil
        couple = nil
        errorMessage = nil
    }
}
