import Foundation
import FirebaseFirestore

/// Data Transfer Object for FinancialProfile documents in Firestore
/// Stored at: /couples/{coupleId}/financialProfile/profile
struct FinancialProfileDTO: Codable {

    /// Combined monthly take-home income (stored as Double for Firestore)
    var monthlyIncome: Double

    /// Monthly fixed expenses (rent, loans, utilities) - "Needs"
    var monthlyNeeds: Double

    /// Monthly discretionary spending (entertainment, dining) - "Wants"
    var monthlyWants: Double

    /// Current liquid savings balance
    var currentSavings: Double

    /// Current retirement account balance (optional)
    var retirementBalance: Double?

    /// Direct savings pool entry (used when user skips income/expense breakdown)
    var directSavingsPool: Double?

    /// Timestamp of last update
    var lastUpdated: Date

    // MARK: - Coding Keys

    enum CodingKeys: String, CodingKey {
        case monthlyIncome
        case monthlyNeeds
        case monthlyWants
        case currentSavings
        case retirementBalance
        case directSavingsPool
        case lastUpdated
    }

    // MARK: - Initializers

    /// Create from domain model
    /// Converts Decimal values to Double for Firestore storage
    init(from profile: FinancialProfile) {
        self.monthlyIncome = NSDecimalNumber(decimal: profile.monthlyIncome).doubleValue
        self.monthlyNeeds = NSDecimalNumber(decimal: profile.monthlyNeeds).doubleValue
        self.monthlyWants = NSDecimalNumber(decimal: profile.monthlyWants).doubleValue
        self.currentSavings = NSDecimalNumber(decimal: profile.currentSavings).doubleValue
        self.retirementBalance = profile.retirementBalance.map {
            NSDecimalNumber(decimal: $0).doubleValue
        }
        self.directSavingsPool = profile.directSavingsPool.map {
            NSDecimalNumber(decimal: $0).doubleValue
        }
        self.lastUpdated = profile.lastUpdated
    }

    /// Create empty profile for new couples
    init() {
        self.monthlyIncome = 0
        self.monthlyNeeds = 0
        self.monthlyWants = 0
        self.currentSavings = 0
        self.retirementBalance = nil
        self.directSavingsPool = nil
        self.lastUpdated = Date()
    }

    // MARK: - Conversion to Domain Model

    /// Convert back to domain model
    /// Converts Double values back to Decimal for precise calculations
    func toFinancialProfile() -> FinancialProfile {
        FinancialProfile(
            monthlyIncome: Decimal(monthlyIncome),
            monthlyNeeds: Decimal(monthlyNeeds),
            monthlyWants: Decimal(monthlyWants),
            currentSavings: Decimal(currentSavings),
            retirementBalance: retirementBalance.map { Decimal($0) },
            directSavingsPool: directSavingsPool.map { Decimal($0) },
            lastUpdated: lastUpdated
        )
    }

    // MARK: - Firestore Dictionary

    /// Convert to dictionary for Firestore write operations
    /// Uses Timestamp for dates (Firestore's native date type)
    var dictionary: [String: Any] {
        var dict: [String: Any] = [
            "monthlyIncome": monthlyIncome,
            "monthlyNeeds": monthlyNeeds,
            "monthlyWants": monthlyWants,
            "currentSavings": currentSavings,
            "lastUpdated": Timestamp(date: lastUpdated)
        ]

        if let retirementBalance {
            dict["retirementBalance"] = retirementBalance
        }

        if let directSavingsPool {
            dict["directSavingsPool"] = directSavingsPool
        }

        return dict
    }
}
