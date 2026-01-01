import SwiftUI

/// A row displaying a single contribution in the activity list.
///
/// Shows the user's avatar, description ("You added $150"), and relative date.
/// Supports swipe actions for editing and deleting (only for current user's contributions).
///
/// ## Usage
/// ```swift
/// ContributionRow(
///     contribution: contribution,
///     displayName: "You",
///     initials: "AJ",
///     isCurrentUser: true,
///     onEdit: { ... },
///     onDelete: { ... }
/// )
/// ```
struct ContributionRow: View {
    let contribution: Contribution
    let displayName: String
    let initials: String
    let isCurrentUser: Bool
    let onEdit: (() -> Void)?
    let onDelete: (() -> Void)?

    @Environment(\.colorScheme) private var colorScheme

    init(
        contribution: Contribution,
        displayName: String,
        initials: String,
        isCurrentUser: Bool,
        onEdit: (() -> Void)? = nil,
        onDelete: (() -> Void)? = nil
    ) {
        self.contribution = contribution
        self.displayName = displayName
        self.initials = initials
        self.isCurrentUser = isCurrentUser
        self.onEdit = onEdit
        self.onDelete = onDelete
    }

    var body: some View {
        HStack(spacing: WinnieSpacing.s) {
            // Avatar
            UserInitialsAvatar(
                initials: initials,
                size: .small,
                isCurrentUser: isCurrentUser
            )

            // Description
            VStack(alignment: .leading, spacing: 2) {
                Text(descriptionText)
                    .font(WinnieTypography.bodyM())
                    .foregroundColor(WinnieColors.primaryText(for: colorScheme))

                Text(relativeDate)
                    .font(WinnieTypography.caption())
                    .foregroundColor(WinnieColors.tertiaryText(for: colorScheme))
            }

            Spacer()
        }
        .padding(.vertical, WinnieSpacing.xs)
        .contentShape(Rectangle())
    }

    // MARK: - Computed Properties

    private var descriptionText: String {
        let formattedAmount = formatCurrency(contribution.amount)
        return "\(displayName) added \(formattedAmount)"
    }

    private var relativeDate: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: contribution.date, relativeTo: Date())
    }

    private func formatCurrency(_ amount: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = "$"
        formatter.maximumFractionDigits = 0
        let number = NSDecimalNumber(decimal: amount)
        return formatter.string(from: number) ?? "$0"
    }
}

// MARK: - Swipeable Version

/// ContributionRow with swipe actions enabled.
/// Use this in a List for built-in swipe gesture support.
struct SwipeableContributionRow: View {
    let contribution: Contribution
    let displayName: String
    let initials: String
    let isCurrentUser: Bool
    let onEdit: () -> Void
    let onDelete: () -> Void

    @State private var showDeleteConfirmation = false

    var body: some View {
        ContributionRow(
            contribution: contribution,
            displayName: displayName,
            initials: initials,
            isCurrentUser: isCurrentUser
        )
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            if isCurrentUser {
                Button(role: .destructive) {
                    showDeleteConfirmation = true
                } label: {
                    Label("Delete", systemImage: "trash")
                }

                Button {
                    onEdit()
                } label: {
                    Label("Edit", systemImage: "pencil")
                }
                .tint(WinnieColors.amethystSmoke)
            }
        }
        .alert("Delete Contribution", isPresented: $showDeleteConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                onDelete()
            }
        } message: {
            Text("Are you sure you want to delete this contribution? This action cannot be undone.")
        }
    }
}

// MARK: - Previews

#Preview("Current User") {
    VStack(spacing: 0) {
        ContributionRow(
            contribution: Contribution(
                goalId: "goal-1",
                userId: "user-1",
                amount: Decimal(150),
                date: Calendar.current.date(byAdding: .day, value: -1, to: Date())!
            ),
            displayName: "You",
            initials: "AJ",
            isCurrentUser: true
        )

        Divider()

        ContributionRow(
            contribution: Contribution(
                goalId: "goal-1",
                userId: "user-2",
                amount: Decimal(75),
                date: Calendar.current.date(byAdding: .day, value: -3, to: Date())!
            ),
            displayName: "Alex",
            initials: "AB",
            isCurrentUser: false
        )
    }
    .padding()
}

#Preview("In List with Swipe") {
    List {
        SwipeableContributionRow(
            contribution: Contribution(
                goalId: "goal-1",
                userId: "user-1",
                amount: Decimal(150),
                date: Date()
            ),
            displayName: "You",
            initials: "AJ",
            isCurrentUser: true,
            onEdit: { print("Edit tapped") },
            onDelete: { print("Delete tapped") }
        )

        SwipeableContributionRow(
            contribution: Contribution(
                goalId: "goal-1",
                userId: "user-2",
                amount: Decimal(75),
                date: Calendar.current.date(byAdding: .day, value: -2, to: Date())!
            ),
            displayName: "Alex",
            initials: "AB",
            isCurrentUser: false,
            onEdit: { },
            onDelete: { }
        )
    }
    .listStyle(.plain)
}

#Preview("Dark Mode") {
    ContributionRow(
        contribution: Contribution(
            goalId: "goal-1",
            userId: "user-1",
            amount: Decimal(50),
            date: Calendar.current.date(byAdding: .hour, value: -2, to: Date())!
        ),
        displayName: "You",
        initials: "AJ",
        isCurrentUser: true
    )
    .padding()
    .background(WinnieColors.ink)
    .preferredColorScheme(.dark)
}
