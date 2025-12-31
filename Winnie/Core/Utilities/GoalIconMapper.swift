import Foundation

/// Maps goal name keywords to SF Symbols and infers GoalType for storage.
///
/// **How It Works:**
/// - Scans the goal name for keywords (case-insensitive)
/// - Returns the first matching SF Symbol, or a default star icon
/// - Also infers which GoalType category best fits for data storage
///
/// **Usage:**
/// ```swift
/// let icon = GoalIconMapper.icon(for: "Down Payment")  // Returns "house.fill"
/// let type = GoalIconMapper.inferGoalType(from: "Down Payment")  // Returns .house
/// ```
struct GoalIconMapper {

    // MARK: - Keyword to Icon Mapping

    /// Dictionary mapping keywords (lowercased) to SF Symbol names.
    /// Order matters for multi-word keywords - check longer phrases first.
    private static let keywordToIcon: [(keyword: String, icon: String)] = [
        // House/Home (check multi-word first)
        ("down payment", "house.fill"),
        ("mortgage", "house.fill"),
        ("house", "house.fill"),
        ("home", "house.fill"),
        ("property", "house.fill"),
        ("apartment", "building.2.fill"),
        ("condo", "building.2.fill"),
        ("rent", "key.fill"),

        // Transportation
        ("car", "car.fill"),
        ("vehicle", "car.fill"),
        ("truck", "truck.box.fill"),
        ("motorcycle", "bicycle"),
        ("bike", "bicycle"),
        ("boat", "sailboat.fill"),

        // Travel/Vacation
        ("vacation", "airplane"),
        ("travel", "airplane"),
        ("trip", "airplane"),
        ("flight", "airplane"),
        ("cruise", "ferry.fill"),
        ("beach", "beach.umbrella.fill"),
        ("hawaii", "sun.max.fill"),

        // Education
        ("college", "graduationcap.fill"),
        ("university", "graduationcap.fill"),
        ("education", "book.fill"),
        ("school", "book.fill"),
        ("tuition", "graduationcap.fill"),
        ("student", "graduationcap.fill"),
        ("degree", "graduationcap.fill"),

        // Family (check multi-word first)
        ("baby fund", "figure.2.and.child.holdinghands"),
        ("baby", "figure.2.and.child.holdinghands"),
        ("child", "figure.2.and.child.holdinghands"),
        ("kid", "figure.2.and.child.holdinghands"),
        ("family", "figure.2.and.child.holdinghands"),
        ("wedding", "heart.fill"),
        ("marriage", "heart.fill"),
        ("engagement", "heart.circle.fill"),
        ("honeymoon", "heart.fill"),

        // Emergency/Safety (check multi-word first)
        ("rainy day", "cloud.rain.fill"),
        ("safety net", "shield.fill"),
        ("emergency", "shield.fill"),
        ("buffer", "shield.fill"),
        ("savings", "banknote.fill"),

        // Retirement
        ("retirement", "chart.line.uptrend.xyaxis"),
        ("401k", "chart.line.uptrend.xyaxis"),
        ("ira", "chart.line.uptrend.xyaxis"),
        ("pension", "chart.line.uptrend.xyaxis"),

        // Electronics/Tech
        ("computer", "laptopcomputer"),
        ("laptop", "laptopcomputer"),
        ("phone", "iphone"),
        ("iphone", "iphone"),
        ("mac", "desktopcomputer"),
        ("tablet", "ipad"),
        ("ipad", "ipad"),

        // Medical
        ("medical", "cross.case.fill"),
        ("health", "heart.text.square.fill"),
        ("surgery", "cross.case.fill"),
        ("dental", "face.smiling"),
        ("doctor", "stethoscope"),

        // Business/Investment
        ("business", "briefcase.fill"),
        ("startup", "lightbulb.fill"),
        ("investment", "chart.bar.fill"),
        ("stocks", "chart.xyaxis.line"),

        // Home Improvement
        ("renovation", "hammer.fill"),
        ("remodel", "hammer.fill"),
        ("furniture", "sofa.fill"),
        ("appliance", "refrigerator.fill"),

        // Lifestyle
        ("gift", "gift.fill"),
        ("christmas", "gift.fill"),
        ("birthday", "birthday.cake.fill"),
        ("party", "party.popper.fill"),
        ("pet", "pawprint.fill"),
        ("dog", "pawprint.fill"),
        ("cat", "pawprint.fill"),

        // Misc
        ("dream", "sparkles"),
        ("goal", "target"),
        ("future", "sparkles")
    ]

    /// Default icon when no keywords match.
    static let defaultIcon = "star.fill"

    // MARK: - Public Methods

    /// Find the best matching SF Symbol for a goal name.
    ///
    /// - Parameter goalName: The user-entered goal name
    /// - Returns: An SF Symbol name that represents the goal
    static func icon(for goalName: String) -> String {
        let lowercased = goalName.lowercased()

        // Check each keyword - first match wins
        for (keyword, icon) in keywordToIcon {
            if lowercased.contains(keyword) {
                return icon
            }
        }

        return defaultIcon
    }

    /// Infer the GoalType category from a goal name for data storage.
    ///
    /// This ensures goals are properly categorized even with custom names,
    /// which affects default return rates and suggested savings vehicles.
    ///
    /// - Parameter goalName: The user-entered goal name
    /// - Returns: The most appropriate GoalType, defaulting to `.custom`
    static func inferGoalType(from goalName: String) -> GoalType {
        let lowercased = goalName.lowercased()

        // House-related
        let houseKeywords = ["house", "home", "down payment", "mortgage", "property", "apartment", "condo", "rent"]
        if houseKeywords.contains(where: { lowercased.contains($0) }) {
            return .house
        }

        // Retirement-related
        let retirementKeywords = ["retirement", "401k", "ira", "pension"]
        if retirementKeywords.contains(where: { lowercased.contains($0) }) {
            return .retirement
        }

        // Vacation-related
        let vacationKeywords = ["vacation", "travel", "trip", "cruise", "beach", "flight", "hawaii", "honeymoon"]
        if vacationKeywords.contains(where: { lowercased.contains($0) }) {
            return .vacation
        }

        // Emergency-related
        let emergencyKeywords = ["emergency", "rainy day", "safety net", "buffer"]
        if emergencyKeywords.contains(where: { lowercased.contains($0) }) {
            return .emergencyFund
        }

        // Family-related
        let familyKeywords = ["baby", "child", "kid", "family", "wedding", "marriage", "engagement"]
        if familyKeywords.contains(where: { lowercased.contains($0) }) {
            return .babyFamily
        }

        // Default to custom for everything else
        return .custom
    }
}
