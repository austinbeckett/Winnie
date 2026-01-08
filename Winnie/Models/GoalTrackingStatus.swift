import Foundation

/// Rich tracking status for goals based on plan projections.
///
/// Uses associated values to carry exactly the data needed for each state,
/// eliminating optional fields and invalid state combinations.
///
/// **States:**
/// - `completed`: Goal has reached its target amount
/// - `noTargetDate`: Goal has no desired date set (projection may still exist)
/// - `notInPlan`: Goal has a target date but no allocation in the active plan
/// - `onTrack`: Projected completion is on or before target date
/// - `behind`: Projected completion is after target date
enum GoalTrackingStatus: Equatable {
    case completed
    case noTargetDate(projectedDate: Date?)
    case notInPlan(targetDate: Date)
    case onTrack(TrackingDetails)
    case behind(TrackingDetails, requiredContribution: Decimal)

    /// Details about goal projection vs target when tracking against a plan.
    struct TrackingDetails: Equatable {
        /// When the plan projects the goal will be completed
        let projectedDate: Date
        /// User's desired completion date
        let targetDate: Date
        /// Difference in months (positive = early, negative = late)
        let monthsDifference: Int
        /// Current monthly allocation from the active plan
        let currentContribution: Decimal
    }

    /// Whether the status has actionable recommendations (behind status).
    var isActionable: Bool {
        if case .behind = self { return true }
        return false
    }

    /// Whether the goal is being tracked against a plan.
    var isTrackedByPlan: Bool {
        switch self {
        case .onTrack, .behind:
            return true
        case .completed, .noTargetDate, .notInPlan:
            return false
        }
    }

    /// Display-friendly status label.
    var label: String {
        switch self {
        case .completed:
            return "Complete"
        case .noTargetDate:
            return "No Target Date"
        case .notInPlan:
            return "Not in Plan"
        case .onTrack:
            return "On Track"
        case .behind:
            return "Behind"
        }
    }

    /// SF Symbol icon name for the status.
    var iconName: String {
        switch self {
        case .completed:
            return "checkmark.circle.fill"
        case .noTargetDate:
            return "calendar.badge.questionmark"
        case .notInPlan:
            return "doc.badge.plus"
        case .onTrack:
            return "checkmark.circle"
        case .behind:
            return "exclamationmark.triangle"
        }
    }
}
