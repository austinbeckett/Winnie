import SwiftUI

/// Full-screen view showing all contributions for a goal.
///
/// Displays contributions in a list with swipe actions for editing/deleting.
/// Only shows edit/delete actions for the current user's contributions.
///
/// ## Usage
/// ```swift
/// NavigationLink {
///     ContributionsHistoryView(viewModel: viewModel)
/// } label: {
///     Text("View All")
/// }
/// ```
struct ContributionsHistoryView: View {
    @Bindable var viewModel: GoalDetailViewModel

    @Environment(\.colorScheme) private var colorScheme

    @State private var contributionToEdit: Contribution?
    @State private var showEditSheet = false

    var body: some View {
        Group {
            if viewModel.contributions.isEmpty {
                emptyState
            } else {
                contributionsList
            }
        }
        .background(WinnieColors.background(for: colorScheme).ignoresSafeArea())
        .navigationTitle("Activity")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showEditSheet) {
            if let contribution = contributionToEdit {
                ContributionEntrySheet(mode: .edit(contribution)) { amount, date, notes in
                    Task {
                        var updated = contribution
                        updated.amount = amount
                        updated.date = date
                        updated.notes = notes
                        await viewModel.updateContribution(updated)
                    }
                }
            }
        }
    }

    // MARK: - Views

    private var emptyState: some View {
        VStack(spacing: WinnieSpacing.m) {
            Image(systemName: "chart.line.uptrend.xyaxis")
                .font(.system(size: 48))
                .foregroundColor(WinnieColors.tertiaryText(for: colorScheme))

            Text("No contributions yet")
                .font(WinnieTypography.headlineM())
                .foregroundColor(WinnieColors.primaryText(for: colorScheme))

            Text("Add your first contribution to start tracking progress.")
                .font(WinnieTypography.bodyM())
                .foregroundColor(WinnieColors.secondaryText(for: colorScheme))
                .multilineTextAlignment(.center)
        }
        .padding(WinnieSpacing.xl)
    }

    private var contributionsList: some View {
        List {
            ForEach(viewModel.contributions) { contribution in
                SwipeableContributionRow(
                    contribution: contribution,
                    displayName: viewModel.displayName(for: contribution),
                    isCurrentUser: viewModel.isCurrentUserContribution(contribution),
                    onEdit: {
                        contributionToEdit = contribution
                        showEditSheet = true
                    },
                    onDelete: {
                        Task {
                            await viewModel.deleteContribution(contribution)
                        }
                    }
                )
                .listRowBackground(WinnieColors.cardBackground(for: colorScheme))
                .listRowSeparator(.hidden)
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
    }
}

// MARK: - Previews

#Preview("With Contributions") {
    NavigationStack {
        ContributionsHistoryView(
            viewModel: .preview()
        )
    }
}

#Preview("Empty State") {
    NavigationStack {
        ContributionsHistoryView(
            viewModel: .preview(contributions: [])
        )
    }
}

#Preview("Dark Mode") {
    NavigationStack {
        ContributionsHistoryView(
            viewModel: .preview()
        )
    }
    .preferredColorScheme(.dark)
}
