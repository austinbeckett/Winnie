import Foundation
import SwiftUI

/// A single financial goal with target amount and progress tracking
struct Goal: Codable, Identifiable, Equatable, Sendable {

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

    /// Custom color hex code (e.g., "#A393BF"). If nil, uses default Amethyst Smoke.
    var colorHex: String?

    /// Custom SF Symbol icon name (e.g., "heart.fill"). If nil, uses type default.
    var iconName: String?

    // MARK: - Computed Properties

    /// The SF Symbol icon to display for this goal.
    /// Uses custom iconName if set, otherwise falls back to type default.
    var displayIcon: String {
        iconName ?? type.iconName
    }

    /// The color to display for this goal
    /// Uses custom colorHex if set, otherwise defaults to Amethyst Smoke
    var displayColor: Color {
        if let hex = colorHex {
            return Color(hex: hex)
        }
        return WinnieColors.amethystSmoke
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
        iconName: String? = nil
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
    }
}

// MARK: - Sample Data

extension Goal {

    /// Sample house goal for previews
    static let sampleHouse = Goal(
        type: .house,
        name: "Down Payment",
        targetAmount: Decimal(60000),
        currentAmount: Decimal(15000),
        priority: 1,
        colorHex: GoalPresetColor.sage.rawValue,
        iconName: "house.fill"
    )

    /// Sample retirement goal for previews
    static let sampleRetirement = Goal(
        type: .retirement,
        name: "Retirement Fund",
        targetAmount: Decimal(1000000),
        currentAmount: Decimal(50000),
        priority: 2,
        colorHex: GoalPresetColor.amethyst.rawValue,
        iconName: "chart.line.uptrend.xyaxis"
    )

    /// Sample vacation goal for previews
    static let sampleVacation = Goal(
        type: .vacation,
        name: "Hawaii Trip",
        targetAmount: Decimal(8000),
        currentAmount: Decimal(2500),
        priority: 3,
        colorHex: GoalPresetColor.sand.rawValue,
        iconName: "airplane"
    )

    /// Sample emergency fund for previews
    static let sampleEmergency = Goal(
        type: .emergencyFund,
        name: "Emergency Fund",
        targetAmount: Decimal(20000),
        currentAmount: Decimal(12000),
        priority: 4,
        colorHex: GoalPresetColor.terracotta.rawValue,
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
