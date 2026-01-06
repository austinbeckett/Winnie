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
///     displayName: "Austin",
///     isCurrentUser: true,
///     onEdit: { ... },
///     onDelete: { ... }
/// )
/// ```
struct ContributionRow: View {
    let contribution: Contribution
    let displayName: String
    let isCurrentUser: Bool
    let onEdit: (() -> Void)?
    let onDelete: (() -> Void)?

    @Environment(\.colorScheme) private var colorScheme

    init(
        contribution: Contribution,
        displayName: String,
        isCurrentUser: Bool,
        onEdit: (() -> Void)? = nil,
        onDelete: (() -> Void)? = nil
    ) {
        self.contribution = contribution
        self.displayName = displayName
        self.isCurrentUser = isCurrentUser
        self.onEdit = onEdit
        self.onDelete = onDelete
    }

    var body: some View {
        HStack(spacing: WinnieSpacing.s) {
            // Avatar
            UserProfileAvatar(
                isCurrentUser: isCurrentUser,
                size: .small
            )

            // Description
            VStack(alignment: .leading, spacing: 2) {
                Text(descriptionText)
                    .font(WinnieTypography.bodyM())
                    .foregroundColor(WinnieColors.cardText)

                Text(relativeDate)
                    .font(WinnieTypography.caption())
                    .foregroundColor(WinnieColors.cardText.opacity(0.5))
            }

            Spacer()
        }
        .padding(.vertical, WinnieSpacing.xs)
        .contentShape(Rectangle())
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(descriptionText), \(relativeDate)")
    }

    // MARK: - Computed Properties

    private var descriptionText: String {
        let formattedAmount = Formatting.currency(contribution.amount)
        return "\(displayName) added \(formattedAmount)"
    }

    private var relativeDate: String {
        Formatting.relativeDate(contribution.date)
    }
}

// MARK: - Swipeable Version

/// ContributionRow with swipe actions enabled.
/// Use this in a List for built-in swipe gesture support.
struct SwipeableContributionRow: View {
    let contribution: Contribution
    let displayName: String
    let isCurrentUser: Bool
    let onEdit: () -> Void
    let onDelete: () -> Void

    @State private var showDeleteConfirmation = false

    var body: some View {
        ContributionRow(
            contribution: contribution,
            displayName: displayName,
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
            displayName: "Austin",
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
            displayName: "Paige",
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
            displayName: "Austin",
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
            displayName: "Paige",
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
        displayName: "Austin",
        isCurrentUser: true
    )
    .padding()
    .background(WinnieColors.carbonBlack)
    .preferredColorScheme(.dark)
}
