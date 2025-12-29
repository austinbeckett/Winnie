import SwiftUI

/// Goal category types with associated colors, icons, and default return rates
enum GoalType: String, Codable, CaseIterable, Identifiable {
    case house
    case retirement
    case vacation
    case emergencyFund
    case babyFamily
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
        case .custom: return "Custom Goal"
        }
    }

    /// Associated color from Winnie design system
    var color: Color {
        switch self {
        case .house: return WinnieColors.goalHouse
        case .retirement: return WinnieColors.goalRetirement
        case .vacation: return WinnieColors.goalVacation
        case .emergencyFund: return WinnieColors.goalEmergency
        case .babyFamily: return WinnieColors.goalRetirement
        case .custom: return WinnieColors.amethystSmoke
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
        case .custom: return "star.fill"
        }
    }

    // MARK: - Financial Properties

    /// Default annual return rate for this goal type
    /// - House/Emergency: 4.5% (HYSA rates)
    /// - Retirement: 7% (historical stock market real returns)
    /// - Vacation: 4% (conservative short-term)
    /// - Baby/Custom: 5% (blended approach)
    var defaultAnnualReturnRate: Decimal {
        switch self {
        case .house: return Decimal(string: "0.045")!
        case .retirement: return Decimal(string: "0.07")!
        case .vacation: return Decimal(string: "0.04")!
        case .emergencyFund: return Decimal(string: "0.045")!
        case .babyFamily: return Decimal(string: "0.05")!
        case .custom: return Decimal(string: "0.05")!
        }
    }

    /// Whether this goal type is typically long-term (5+ years)
    var isLongTermGoal: Bool {
        switch self {
        case .retirement, .babyFamily: return true
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
        case .vacation:
            return "Savings Account"
        case .babyFamily:
            return "529 Plan / Savings"
        case .custom:
            return "Varies by timeline"
        }
    }
}
