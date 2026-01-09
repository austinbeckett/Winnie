import Foundation
import SwiftUI

/// A single financial goal with target amount and progress tracking
struct Goal: Codable, Identifiable, Equatable, Hashable, Sendable {

    /// Unique identifier (UUID locally, Firestore doc ID when synced)
    let id: String

    /// Goal category type
    var type: GoalType

    /// User-defined name (e.g., "Beach House in Malibu")
    var name: String

    /// Target amount to reach
    var targetAmount: Decimal

    /// Current progress toward goal
    var currentAmount: Decimal

    /// Optional desired completion date (user's wish)
    var desiredDate: Date?

    /// Custom annual return rate override (nil uses type default)
    var customReturnRate: Decimal?

    /// Priority order (lower number = higher priority)
    var priority: Int

    /// Creation timestamp
    let createdAt: Date

    /// Whether goal is currently active
    var isActive: Bool

    /// Optional notes or description
    var notes: String?

    /// Custom color hex code (e.g., "#FFA099"). If nil, uses default Coral (Sweet Salmon).
    var colorHex: String?

    /// Custom SF Symbol icon name (e.g., "heart.fill"). If nil, uses type default.
    var iconName: String?

    /// User-specified account name (e.g., "Chase Savings", "Ally HYSA")
    var accountName: String?

    // MARK: - Computed Properties

    /// The SF Symbol icon to display for this goal.
    /// Uses custom iconName if set, otherwise falls back to type default.
    var displayIcon: String {
        iconName ?? type.iconName
    }

    /// The color to display for this goal
    /// Uses custom colorHex if set, otherwise defaults to Coral (Sweet Salmon)
    var displayColor: Color {
        if let hex = colorHex {
            return Color(hex: hex)
        }
        return WinnieColors.sweetSalmon
    }

    /// Effective return rate (custom override or type default)
    var effectiveReturnRate: Decimal {
        customReturnRate ?? type.defaultAnnualReturnRate
    }

    /// Amount still needed to reach the goal
    var remainingAmount: Decimal {
        max(targetAmount - currentAmount, 0)
    }

    /// Progress as a percentage (0.0 to 1.0)
    var progressPercentage: Double {
        guard targetAmount > 0 else { return 0 }
        let progress = NSDecimalNumber(decimal: currentAmount / targetAmount)
        return min(progress.doubleValue, 1.0)
    }

    /// Progress as an integer percentage (0 to 100)
    var progressPercentageInt: Int {
        Int(progressPercentage * 100)
    }

    /// Whether the goal has been completed
    var isCompleted: Bool {
        currentAmount >= targetAmount
    }

    /// Whether the goal has any saved amount
    var hasProgress: Bool {
        currentAmount > 0
    }

    // MARK: - Initializer

    init(
        id: String = UUID().uuidString,
        type: GoalType,
        name: String,
        targetAmount: Decimal,
        currentAmount: Decimal = 0,
        desiredDate: Date? = nil,
        customReturnRate: Decimal? = nil,
        priority: Int = 0,
        createdAt: Date = Date(),
        isActive: Bool = true,
        notes: String? = nil,
        colorHex: String? = nil,
        iconName: String? = nil,
        accountName: String? = nil
    ) {
        self.id = id
        self.type = type
        self.name = name
        self.targetAmount = targetAmount
        self.currentAmount = currentAmount
        self.desiredDate = desiredDate
        self.customReturnRate = customReturnRate
        self.priority = priority
        self.createdAt = createdAt
        self.isActive = isActive
        self.notes = notes
        self.colorHex = colorHex
        self.iconName = iconName
        self.accountName = accountName
    }
}

// MARK: - Sample Data

extension Goal {

    /// Sample house goal for previews (2 years out)
    static let sampleHouse = Goal(
        type: .house,
        name: "Down Payment",
        targetAmount: Decimal(60000),
        currentAmount: Decimal(15000),
        desiredDate: Calendar.current.date(byAdding: .year, value: 2, to: Date()),
        priority: 1,
        colorHex: GoalPresetColor.sage.rawValue,
        iconName: "house.fill"
    )

    /// Sample retirement goal for previews (no date - long-term goal, appears at bottom)
    static let sampleRetirement = Goal(
        type: .retirement,
        name: "Retirement Fund",
        targetAmount: Decimal(1000000),
        currentAmount: Decimal(50000),
        desiredDate: nil,
        priority: 2,
        colorHex: GoalPresetColor.coral.rawValue,
        iconName: "chart.line.uptrend.xyaxis"
    )

    /// Sample vacation goal for previews (6 months out - closest deadline)
    static let sampleVacation = Goal(
        type: .vacation,
        name: "Hawaii Trip",
        targetAmount: Decimal(8000),
        currentAmount: Decimal(2500),
        desiredDate: Calendar.current.date(byAdding: .month, value: 6, to: Date()),
        priority: 3,
        colorHex: GoalPresetColor.sand.rawValue,
        iconName: "airplane"
    )

    /// Sample emergency fund for previews (no date - ongoing goal, appears at bottom)
    static let sampleEmergency = Goal(
        type: .emergencyFund,
        name: "Emergency Fund",
        targetAmount: Decimal(20000),
        currentAmount: Decimal(12000),
        desiredDate: nil,
        priority: 4,
        colorHex: GoalPresetColor.clay.rawValue,
        iconName: "shield.fill"
    )

    /// Collection of sample goals
    static let samples: [Goal] = [
        .sampleHouse,
        .sampleRetirement,
        .sampleVacation,
        .sampleEmergency
    ]
}

// MARK: - Sorting

extension Array where Element == Goal {

    /// Returns goals sorted by desired date (ascending - closest date first).
    ///
    /// Goals without a desired date are placed at the bottom, sorted by creation date.
    /// This provides a sensible default order: urgent goals first, then undated goals
    /// in the order they were created.
    ///
    /// ## Sorting Logic
    /// 1. Goals with `desiredDate` → sorted ascending (closest deadline first)
    /// 2. Goals without `desiredDate` → sorted by `createdAt` ascending (oldest first)
    /// 3. All dated goals appear before undated goals
    var sortedByTargetDate: [Goal] {
        self.sorted { goal1, goal2 in
            switch (goal1.desiredDate, goal2.desiredDate) {
            case let (date1?, date2?):
                // Both have dates: sort by date ascending
                return date1 < date2
            case (_?, nil):
                // First has date, second doesn't: first comes before second
                return true
            case (nil, _?):
                // First has no date, second does: second comes before first
                return false
            case (nil, nil):
                // Neither has date: maintain stable order by creation date
                return goal1.createdAt < goal2.createdAt
            }
        }
    }
}
