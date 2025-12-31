import Foundation

/// Goal category types with icons, default return rates, and financial assumptions
enum GoalType: String, Codable, CaseIterable, Identifiable, Sendable {
    case house
    case retirement
    case vacation
    case emergencyFund
    case babyFamily
    case debt
    case car
    case education
    case hobby
    case fitness
    case gift
    case homeImprovement
    case investment
    case charity
    case custom

    var id: String { rawValue }

    // MARK: - Display Properties

    /// User-facing display name
    var displayName: String {
        switch self {
        case .house: return "House"
        case .retirement: return "Retirement"
        case .vacation: return "Vacation"
        case .emergencyFund: return "Emergency Fund"
        case .babyFamily: return "Baby & Family"
        case .debt: return "Debt Payoff"
        case .car: return "Vehicle"
        case .education: return "Education"
        case .hobby: return "Hobby & Recreation"
        case .fitness: return "Health & Fitness"
        case .gift: return "Gift & Celebration"
        case .homeImprovement: return "Home Improvement"
        case .investment: return "Investment"
        case .charity: return "Charitable Giving"
        case .custom: return "Custom Goal"
        }
    }

    /// SF Symbol icon name
    var iconName: String {
        switch self {
        case .house: return "house.fill"
        case .retirement: return "chart.line.uptrend.xyaxis"
        case .vacation: return "airplane"
        case .emergencyFund: return "shield.fill"
        case .babyFamily: return "figure.2.and.child.holdinghands"
        case .debt: return "creditcard.fill"
        case .car: return "car.fill"
        case .education: return "graduationcap.fill"
        case .hobby: return "gamecontroller.fill"
        case .fitness: return "dumbbell.fill"
        case .gift: return "gift.fill"
        case .homeImprovement: return "hammer.fill"
        case .investment: return "chart.bar.fill"
        case .charity: return "heart.circle.fill"
        case .custom: return "star.fill"
        }
    }

    // MARK: - Financial Properties

    /// Default annual return rate for this goal type
    /// - House/Emergency: 4.5% (HYSA rates)
    /// - Retirement/Investment: 7% (historical stock market real returns)
    /// - Vacation/Hobby/Fitness/Gift: 4% (conservative short-term)
    /// - Education/Baby: 5% (blended approach)
    /// - Debt: 0% (paying down debt, not earning)
    /// - Charity: 3.5% (donor-advised fund conservative)
    var defaultAnnualReturnRate: Decimal {
        switch self {
        case .house: return Decimal(string: "0.045")!
        case .retirement: return Decimal(string: "0.07")!
        case .vacation: return Decimal(string: "0.04")!
        case .emergencyFund: return Decimal(string: "0.045")!
        case .babyFamily: return Decimal(string: "0.05")!
        case .debt: return Decimal(string: "0.0")!
        case .car: return Decimal(string: "0.04")!
        case .education: return Decimal(string: "0.05")!
        case .hobby: return Decimal(string: "0.04")!
        case .fitness: return Decimal(string: "0.04")!
        case .gift: return Decimal(string: "0.035")!
        case .homeImprovement: return Decimal(string: "0.04")!
        case .investment: return Decimal(string: "0.07")!
        case .charity: return Decimal(string: "0.035")!
        case .custom: return Decimal(string: "0.05")!
        }
    }

    /// Whether this goal type is typically long-term (5+ years)
    var isLongTermGoal: Bool {
        switch self {
        case .retirement, .babyFamily, .education, .investment: return true
        default: return false
        }
    }

    /// Suggested savings vehicle description
    var suggestedVehicle: String {
        switch self {
        case .house, .emergencyFund:
            return "High-Yield Savings Account"
        case .retirement:
            return "401(k) / IRA"
        case .vacation, .hobby, .fitness, .gift:
            return "Savings Account"
        case .babyFamily, .education:
            return "529 Plan / Savings"
        case .debt:
            return "Extra Payments"
        case .car:
            return "Savings Account"
        case .homeImprovement:
            return "HELOC / Savings"
        case .investment:
            return "Brokerage Account"
        case .charity:
            return "Donor-Advised Fund"
        case .custom:
            return "Varies by timeline"
        }
    }
}
