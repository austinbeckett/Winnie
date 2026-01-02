import Foundation

/// Shared formatting utilities for currency, dates, and percentages.
///
/// These utilities ensure consistent formatting across the app while
/// maintaining proper Decimal precision for financial calculations.
///
/// ## Usage
/// ```swift
/// let formatted = Formatting.currency(amount)  // "$1,234"
/// let percent = Formatting.percentage(0.75)    // "75%"
/// let date = Formatting.date(someDate)         // "Jan 15, 2026"
/// ```
enum Formatting {

    // MARK: - Currency

    /// Formats a Decimal amount as currency (e.g., "$1,234").
    ///
    /// - Parameters:
    ///   - amount: The amount to format
    ///   - showCents: Whether to show cents (default: false for whole dollars)
    /// - Returns: Formatted currency string
    static func currency(_ amount: Decimal, showCents: Bool = false) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = "$"
        formatter.maximumFractionDigits = showCents ? 2 : 0
        formatter.minimumFractionDigits = showCents ? 2 : 0

        let number = NSDecimalNumber(decimal: amount)
        return formatter.string(from: number) ?? "$0"
    }

    // MARK: - Percentages

    /// Formats a decimal value as a percentage (e.g., 0.075 → "7.5%").
    ///
    /// - Parameters:
    ///   - decimal: The decimal value (0.0 to 1.0)
    ///   - decimalPlaces: Number of decimal places (default: 1)
    /// - Returns: Formatted percentage string
    static func percentage(_ decimal: Decimal, decimalPlaces: Int = 1) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .percent
        formatter.maximumFractionDigits = decimalPlaces
        formatter.minimumFractionDigits = decimalPlaces

        let number = NSDecimalNumber(decimal: decimal)
        return formatter.string(from: number) ?? "0%"
    }

    // MARK: - Dates

    /// Formats a date in medium style (e.g., "Jan 15, 2026").
    ///
    /// - Parameter date: The date to format
    /// - Returns: Formatted date string
    static func date(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }

    /// Formats a date as relative time (e.g., "2 days ago", "in 3 months").
    ///
    /// - Parameter date: The date to format
    /// - Returns: Relative time string
    static func relativeDate(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}
