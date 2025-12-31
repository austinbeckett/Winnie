import Foundation

/// A predefined goal suggestion for quick selection during goal creation.
///
/// Suggestions help users quickly pick common financial goals without typing.
/// Each suggestion includes a name and an SF Symbol icon.
///
/// **Usage:**
/// ```swift
/// ForEach(GoalSuggestion.defaults) { suggestion in
///     Text(suggestion.name)
/// }
/// ```
struct GoalSuggestion: Identifiable {
    let id = UUID()
    let name: String
    let icon: String

    /// Default suggestions for common financial goals.
    ///
    /// These cover the most common savings goals couples typically set.
    /// The icons are pre-matched to ensure visual consistency.
    static let defaults: [GoalSuggestion] = [
        GoalSuggestion(name: "Down Payment", icon: "house.fill"),
        GoalSuggestion(name: "College Fund", icon: "graduationcap.fill"),
        GoalSuggestion(name: "Dream Vacation", icon: "airplane"),
        GoalSuggestion(name: "Rainy Day Fund", icon: "cloud.rain.fill"),
        GoalSuggestion(name: "New Car", icon: "car.fill"),
        GoalSuggestion(name: "Wedding", icon: "heart.fill"),
        GoalSuggestion(name: "Retirement", icon: "chart.line.uptrend.xyaxis"),
        GoalSuggestion(name: "Baby Fund", icon: "figure.2.and.child.holdinghands")
    ]
}
