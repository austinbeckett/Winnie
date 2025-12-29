import Foundation

/// Individual user account information
struct User: Codable, Identifiable, Equatable {

    /// Unique user identifier (Firebase Auth UID)
    let id: String

    /// User's display name
    var displayName: String?

    /// User's email address
    var email: String?

    /// Partner's user ID (nil if not connected)
    var partnerID: String?

    /// Couple container ID (nil if not in couple)
    var coupleID: String?

    /// Account creation date
    let createdAt: Date

    /// Last login timestamp
    var lastLoginAt: Date?

    /// Whether onboarding flow is complete
    var hasCompletedOnboarding: Bool

    // MARK: - Computed Properties

    /// Whether user is connected to a partner
    var hasPartner: Bool {
        partnerID != nil && coupleID != nil
    }

    /// First name extracted from display name
    var firstName: String? {
        displayName?.components(separatedBy: " ").first
    }

    /// Greeting name (first name or "there" as fallback)
    var greetingName: String {
        firstName ?? "there"
    }

    // MARK: - Initializer

    init(
        id: String,
        displayName: String? = nil,
        email: String? = nil,
        partnerID: String? = nil,
        coupleID: String? = nil,
        createdAt: Date = Date(),
        lastLoginAt: Date? = nil,
        hasCompletedOnboarding: Bool = false
    ) {
        self.id = id
        self.displayName = displayName
        self.email = email
        self.partnerID = partnerID
        self.coupleID = coupleID
        self.createdAt = createdAt
        self.lastLoginAt = lastLoginAt
        self.hasCompletedOnboarding = hasCompletedOnboarding
    }
}

// MARK: - Sample Data

extension User {

    /// Sample user for previews
    static let sample = User(
        id: "user123",
        displayName: "Alex Johnson",
        email: "alex@example.com",
        partnerID: "user456",
        coupleID: "couple789",
        hasCompletedOnboarding: true
    )

    /// Sample partner for previews
    static let samplePartner = User(
        id: "user456",
        displayName: "Jordan Johnson",
        email: "jordan@example.com",
        partnerID: "user123",
        coupleID: "couple789",
        hasCompletedOnboarding: true
    )

    /// New user (not onboarded)
    static let newUser = User(
        id: "newUser",
        hasCompletedOnboarding: false
    )
}
