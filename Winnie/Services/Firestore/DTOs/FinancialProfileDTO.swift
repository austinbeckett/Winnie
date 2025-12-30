import Foundation
import FirebaseFirestore

/// Data Transfer Object for FinancialProfile documents in Firestore
/// Stored at: /couples/{coupleId}/financialProfile/profile
struct FinancialProfileDTO: Codable {

    /// Combined monthly take-home income (stored as Double for Firestore)
    var monthlyIncome: Double

    /// Total monthly fixed expenses
    var monthlyExpenses: Double

    /// Current liquid savings balance
    var currentSavings: Double

    /// Current retirement account balance (optional)
    var retirementBalance: Double?

    /// Timestamp of last update
    var lastUpdated: Date

    // MARK: - Coding Keys

    enum CodingKeys: String, CodingKey {
        case monthlyIncome
        case monthlyExpenses
        case currentSavings
        case retirementBalance
        case lastUpdated
    }

    // MARK: - Initializers

    /// Create from domain model
    /// Converts Decimal values to Double for Firestore storage
    init(from profile: FinancialProfile) {
        self.monthlyIncome = NSDecimalNumber(decimal: profile.monthlyIncome).doubleValue
        self.monthlyExpenses = NSDecimalNumber(decimal: profile.monthlyExpenses).doubleValue
        self.currentSavings = NSDecimalNumber(decimal: profile.currentSavings).doubleValue
        self.retirementBalance = profile.retirementBalance.map {
            NSDecimalNumber(decimal: $0).doubleValue
        }
        self.lastUpdated = profile.lastUpdated
    }

    /// Create empty profile for new couples
    init() {
        self.monthlyIncome = 0
        self.monthlyExpenses = 0
        self.currentSavings = 0
        self.retirementBalance = nil
        self.lastUpdated = Date()
    }

    // MARK: - Conversion to Domain Model

    /// Convert back to domain model
    /// Converts Double values back to Decimal for precise calculations
    func toFinancialProfile() -> FinancialProfile {
        FinancialProfile(
            monthlyIncome: Decimal(monthlyIncome),
            monthlyExpenses: Decimal(monthlyExpenses),
            currentSavings: Decimal(currentSavings),
            retirementBalance: retirementBalance.map { Decimal($0) },
            lastUpdated: lastUpdated
        )
    }

    // MARK: - Firestore Dictionary

    /// Convert to dictionary for Firestore write operations
    /// Uses Timestamp for dates (Firestore's native date type)
    var dictionary: [String: Any] {
        var dict: [String: Any] = [
            "monthlyIncome": monthlyIncome,
            "monthlyExpenses": monthlyExpenses,
            "currentSavings": currentSavings,
            "lastUpdated": Timestamp(date: lastUpdated)
        ]

        if let retirementBalance {
            dict["retirementBalance"] = retirementBalance
        }

        return dict
    }
}
