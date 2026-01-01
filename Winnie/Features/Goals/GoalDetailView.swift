import SwiftUI

/// Detail view for a single goal showing contributions, progress, and activity.
///
/// Displays a circular progress ring, contribution breakdown by partner,
/// goal details, and recent activity history.
struct GoalDetailView: View {
    @State private var viewModel: GoalDetailViewModel
    let goalsViewModel: GoalsViewModel

    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dismiss) private var dismiss

    @State private var showEditSheet = false
    @State private var showDeleteConfirmation = false
    @State private var showAddContribution = false
    @State private var contributionToEdit: Contribution?

    init(goal: Goal, currentUser: User, partner: User?, coupleID: String, goalsViewModel: GoalsViewModel) {
        _viewModel = State(initialValue: GoalDetailViewModel(
            goal: goal,
            currentUser: currentUser,
            partner: partner,
            coupleID: coupleID,
            goalsViewModel: goalsViewModel
        ))
        self.goalsViewModel = goalsViewModel
    }

    /// Preview-only initializer
    init(viewModel: GoalDetailViewModel, goalsViewModel: GoalsViewModel) {
        _viewModel = State(initialValue: viewModel)
        self.goalsViewModel = goalsViewModel
    }

    var body: some View {
        ScrollView {
            VStack(spacing: WinnieSpacing.l) {
                // Progress ring header
                progressHeader

                // Contributions section
                contributionsSection

                // Add Funds button
                addFundsButton

                // Details card
                detailsCard

                // Recent Activity
                recentActivitySection

                Spacer(minLength: WinnieSpacing.xxl)
            }
            .padding(.horizontal, WinnieSpacing.screenMarginMobile)
            .padding(.top, WinnieSpacing.m)
        }
        .background(WinnieColors.background(for: colorScheme).ignoresSafeArea())
        .navigationTitle(viewModel.goal.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                HStack(spacing: WinnieSpacing.m) {
                    Button {
                        showEditSheet = true
                    } label: {
                        Image(systemName: "square.and.pencil")
                    }

                    Button {
                        showDeleteConfirmation = true
                    } label: {
                        Image(systemName: "trash")
                    }
                }
            }
        }
        .onAppear {
            viewModel.startListening()
        }
        .onDisappear {
            viewModel.stopListening()
        }
        .sheet(isPresented: $showEditSheet) {
            GoalEditView(existingGoal: viewModel.goal) { updatedGoal in
                Task {
                    await viewModel.updateGoal(updatedGoal)
                }
            }
        }
        .sheet(isPresented: $showAddContribution) {
            ContributionEntrySheet(mode: .add) { amount, date, notes in
                Task {
                    await viewModel.addContribution(amount: amount, date: date, notes: notes)
                }
            }
        }
        .sheet(item: $contributionToEdit) { contribution in
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
        .alert("Delete Goal", isPresented: $showDeleteConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                Task {
                    await goalsViewModel.deleteGoal(viewModel.goal)
                    dismiss()
                }
            }
        } message: {
            Text("Are you sure you want to delete \"\(viewModel.goal.name)\"? This action cannot be undone.")
        }
        .alert("Error", isPresented: $viewModel.showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(viewModel.errorMessage ?? "An error occurred")
        }
    }

    // MARK: - Progress Header

    private var progressHeader: some View {
        VStack(spacing: WinnieSpacing.m) {
            // Circular progress ring
            ZStack {
                // Background circle
                Circle()
                    .stroke(
                        WinnieColors.progressBackground(for: colorScheme),
                        lineWidth: 12
                    )

                // Progress arc
                Circle()
                    .trim(from: 0, to: CGFloat(viewModel.goal.progressPercentage))
                    .stroke(
                        viewModel.goal.displayColor,
                        style: StrokeStyle(lineWidth: 12, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                    .animation(.spring(response: 0.6, dampingFraction: 0.8), value: viewModel.goal.progressPercentage)

                // Center content
                VStack(spacing: WinnieSpacing.xxs) {
                    Text("\(viewModel.goal.progressPercentageInt)%")
                        .font(WinnieTypography.bodyS())
                        .foregroundColor(WinnieColors.secondaryText(for: colorScheme))

                    Text(formatCurrency(viewModel.goal.currentAmount))
                        .font(WinnieTypography.financialXL())
                        .foregroundColor(WinnieColors.primaryText(for: colorScheme))

                    Text(formatCurrency(viewModel.goal.targetAmount) + " goal")
                        .font(WinnieTypography.bodyS())
                        .foregroundColor(WinnieColors.tertiaryText(for: colorScheme))
                }
            }
            .frame(width: 180, height: 180)
        }
        .padding(.vertical, WinnieSpacing.m)
    }

    // MARK: - Contributions Section

    private var contributionsSection: some View {
        WinnieCard {
            VStack(alignment: .leading, spacing: WinnieSpacing.m) {
                Text("Contributions")
                    .font(WinnieTypography.headlineM())
                    .foregroundColor(WinnieColors.primaryText(for: colorScheme))

                HStack(spacing: WinnieSpacing.l) {
                    // Current user contribution
                    contributionBadge(
                        initials: viewModel.initials(for: viewModel.currentUserID),
                        name: "You",
                        amount: viewModel.currentUserTotal,
                        isCurrentUser: true
                    )

                    // Partner contribution (if exists)
                    if viewModel.partnerTotal > 0 || viewModel.currentUserTotal > 0 {
                        contributionBadge(
                            initials: viewModel.initials(for: viewModel.partner?.id ?? ""),
                            name: viewModel.partnerName,
                            amount: viewModel.partnerTotal,
                            isCurrentUser: false
                        )
                    }

                    Spacer()
                }
            }
        }
    }

    private func contributionBadge(
        initials: String,
        name: String,
        amount: Decimal,
        isCurrentUser: Bool
    ) -> some View {
        HStack(spacing: WinnieSpacing.xs) {
            UserInitialsAvatar(
                initials: initials,
                size: .small,
                isCurrentUser: isCurrentUser
            )

            Text("\(name): \(formatCurrency(amount))")
                .font(WinnieTypography.bodyM())
                .foregroundColor(WinnieColors.primaryText(for: colorScheme))
        }
    }

    // MARK: - Add Funds Button

    private var addFundsButton: some View {
        WinnieButton("Add Funds", style: .primary) {
            showAddContribution = true
        }
    }

    // MARK: - Details Card

    private var detailsCard: some View {
        WinnieCard {
            VStack(spacing: WinnieSpacing.m) {
                Text("Details")
                    .font(WinnieTypography.headlineM())
                    .foregroundColor(WinnieColors.primaryText(for: colorScheme))
                    .frame(maxWidth: .infinity, alignment: .leading)

                Divider()

                // Target Date
                detailRow(
                    label: "Target Date",
                    value: viewModel.goal.desiredDate.map { formatDate($0) } ?? "Not set"
                )

                // Status
                statusRow

                // Interest Rate (APY)
                detailRow(
                    label: "Interest Rate (APY)",
                    value: formatPercentage(viewModel.goal.effectiveReturnRate)
                )

                // Account
                detailRow(
                    label: "Account",
                    value: viewModel.goal.accountName ?? "Not set"
                )

                // Created date
                detailRow(
                    label: "Created",
                    value: formatDate(viewModel.goal.createdAt)
                )
            }
        }
    }

    private func detailRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(WinnieTypography.bodyM())
                .foregroundColor(WinnieColors.secondaryText(for: colorScheme))
            Spacer()
            Text(value)
                .font(WinnieTypography.bodyM())
                .foregroundColor(WinnieColors.primaryText(for: colorScheme))
        }
    }

    private var statusRow: some View {
        HStack {
            Text("Status")
                .font(WinnieTypography.bodyM())
                .foregroundColor(WinnieColors.secondaryText(for: colorScheme))
            Spacer()

            HStack(spacing: WinnieSpacing.xs) {
                Circle()
                    .fill(statusColor)
                    .frame(width: 8, height: 8)

                Text(statusText)
                    .font(WinnieTypography.bodyM())
                    .foregroundColor(WinnieColors.primaryText(for: colorScheme))
            }
        }
    }

    private var statusText: String {
        switch viewModel.onTrackStatus {
        case .onTrack: return "On Track"
        case .behind: return "Behind"
        case .completed: return "Complete"
        case .noTarget: return "No Target Date"
        }
    }

    private var statusColor: Color {
        switch viewModel.onTrackStatus {
        case .onTrack: return .green
        case .behind: return .orange
        case .completed: return WinnieColors.amethystSmoke
        case .noTarget: return WinnieColors.tertiaryText(for: colorScheme)
        }
    }

    // MARK: - Recent Activity Section

    private var recentActivitySection: some View {
        VStack(alignment: .leading, spacing: WinnieSpacing.m) {
            Text("Recent Activity")
                .font(WinnieTypography.headlineM())
                .foregroundColor(WinnieColors.primaryText(for: colorScheme))

            if viewModel.contributions.isEmpty {
                emptyActivityState
            } else {
                WinnieCard {
                    VStack(spacing: 0) {
                        ForEach(viewModel.recentContributions) { contribution in
                            ContributionRow(
                                contribution: contribution,
                                displayName: viewModel.displayName(for: contribution),
                                initials: viewModel.initials(for: contribution.userId),
                                isCurrentUser: viewModel.isCurrentUserContribution(contribution),
                                onEdit: {
                                    contributionToEdit = contribution
                                },
                                onDelete: {
                                    Task {
                                        await viewModel.deleteContribution(contribution)
                                    }
                                }
                            )
                            .onTapGesture {
                                if viewModel.isCurrentUserContribution(contribution) {
                                    contributionToEdit = contribution
                                }
                            }

                            if contribution.id != viewModel.recentContributions.last?.id {
                                Divider()
                            }
                        }
                    }
                }

                // View All button
                if viewModel.hasMoreContributions {
                    NavigationLink {
                        ContributionsHistoryView(viewModel: viewModel)
                    } label: {
                        Text("View All")
                            .font(WinnieTypography.bodyM())
                            .foregroundColor(WinnieColors.amethystSmoke)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, WinnieSpacing.s)
                    }
                }
            }
        }
    }

    private var emptyActivityState: some View {
        WinnieCard {
            VStack(spacing: WinnieSpacing.s) {
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .font(.system(size: 32))
                    .foregroundColor(WinnieColors.tertiaryText(for: colorScheme))

                Text("No contributions yet")
                    .font(WinnieTypography.bodyM())
                    .foregroundColor(WinnieColors.secondaryText(for: colorScheme))

                Text("Tap \"Add Funds\" to record your first contribution")
                    .font(WinnieTypography.caption())
                    .foregroundColor(WinnieColors.tertiaryText(for: colorScheme))
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, WinnieSpacing.m)
        }
    }

    // MARK: - Formatting Helpers

    private func formatCurrency(_ amount: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = "$"
        formatter.maximumFractionDigits = 0
        let number = NSDecimalNumber(decimal: amount)
        return formatter.string(from: number) ?? "$0"
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }

    private func formatPercentage(_ decimal: Decimal) -> String {
        let percentage = NSDecimalNumber(decimal: decimal * 100).doubleValue
        return String(format: "%.1f%%", percentage)
    }

    // MARK: - Partner Helper

    private var partner: User? {
        // This would come from the ViewModel in a real implementation
        nil
    }
}

// MARK: - Preview

#Preview("With Contributions") {
    NavigationStack {
        GoalDetailView(
            viewModel: .preview(),
            goalsViewModel: GoalsViewModel(coupleID: "preview")
        )
    }
}

#Preview("Empty State") {
    NavigationStack {
        GoalDetailView(
            viewModel: .preview(contributions: []),
            goalsViewModel: GoalsViewModel(coupleID: "preview")
        )
    }
}

#Preview("Dark Mode") {
    NavigationStack {
        GoalDetailView(
            viewModel: .preview(),
            goalsViewModel: GoalsViewModel(coupleID: "preview")
        )
    }
    .preferredColorScheme(.dark)
}
