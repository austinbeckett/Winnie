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

    // Animation state for progress ring entrance
    @State private var showRing = false

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
                    .accessibilityLabel("Edit goal")

                    Button {
                        showDeleteConfirmation = true
                    } label: {
                        Image(systemName: "trash")
                    }
                    .accessibilityLabel("Delete goal")
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
        let ringSize: CGFloat = 200
        let strokeWidth: CGFloat = 18
        let goalColor = viewModel.goal.displayColor

        return VStack(spacing: WinnieSpacing.m) {
            // Circular progress ring
            ZStack {
                // Background circle with subtle shadow
                Circle()
                    .stroke(
                        WinnieColors.progressBackground(for: colorScheme),
                        lineWidth: strokeWidth
                    )
                    .shadow(color: WinnieColors.shadow(for: colorScheme), radius: 8, x: 0, y: 4)

                // Progress arc
                Circle()
                    .trim(from: 0, to: viewModel.goal.progressPercentage)
                    .stroke(
                        goalColor,
                        style: StrokeStyle(lineWidth: strokeWidth, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))

                // Center content
                VStack(spacing: WinnieSpacing.xxs) {
                    Text(milestoneMessage)
                        .font(WinnieTypography.bodyS())
                        .fontWeight(.medium)
                        .foregroundColor(WinnieColors.primaryText(for: colorScheme))

                    Text(Formatting.currency(viewModel.goal.currentAmount))
                        .font(WinnieTypography.financialXL())
                        .minimumScaleFactor(0.5)
                        .lineLimit(1)
                        .foregroundColor(WinnieColors.primaryText(for: colorScheme))

                    Text(Formatting.currency(viewModel.goal.targetAmount) + " goal")
                        .font(WinnieTypography.bodyS())
                        .foregroundColor(WinnieColors.tertiaryText(for: colorScheme))
                }
                .padding(.horizontal, 20)
            }
            .frame(width: ringSize, height: ringSize)
            .scaleEffect(showRing ? 1 : 0.9)
            .opacity(showRing ? 1 : 0)
        }
        .padding(.vertical, WinnieSpacing.m)
        .onAppear {
            withAnimation(.easeOut(duration: 0.4)) {
                showRing = true
            }
        }
    }

    // MARK: - Contributions Section

    private var contributionsSection: some View {
        WinnieCard {
            VStack(alignment: .leading, spacing: WinnieSpacing.m) {
                Text("Contributions")
                    .font(WinnieTypography.headlineM())
                    .foregroundColor(WinnieColors.primaryText(for: colorScheme))

                VStack(spacing: WinnieSpacing.s) {
                    // Current user row
                    HStack(spacing: WinnieSpacing.s) {
                        UserProfileAvatar(isCurrentUser: true, size: .small)
                        Text(viewModel.currentUserName)
                            .font(WinnieTypography.bodyM())
                            .foregroundColor(WinnieColors.primaryText(for: colorScheme))
                        Spacer()
                        Text(Formatting.currency(viewModel.currentUserTotal))
                            .font(WinnieTypography.bodyM())
                            .fontWeight(.semibold)
                            .foregroundColor(WinnieColors.primaryText(for: colorScheme))
                    }

                    // Partner row
                    HStack(spacing: WinnieSpacing.s) {
                        UserProfileAvatar(isCurrentUser: false, size: .small)
                        Text(viewModel.partnerName)
                            .font(WinnieTypography.bodyM())
                            .foregroundColor(WinnieColors.primaryText(for: colorScheme))
                        Spacer()
                        Text(Formatting.currency(viewModel.partnerTotal))
                            .font(WinnieTypography.bodyM())
                            .fontWeight(.semibold)
                            .foregroundColor(WinnieColors.primaryText(for: colorScheme))
                    }
                }

                // Add Funds button
                addFundsButton
            }
        }
    }

    // MARK: - Add Funds Button

    private var addFundsButton: some View {
        WinnieButton("Log Contribution", style: .primary) {
            showAddContribution = true
        }
    }

    // MARK: - Details Card

    private var detailsCard: some View {
        WinnieCard {
            VStack(spacing: WinnieSpacing.l) {
                Text("Details")
                    .font(WinnieTypography.headlineM())
                    .foregroundColor(WinnieColors.primaryText(for: colorScheme))
                    .frame(maxWidth: .infinity, alignment: .leading)

                // MARK: Timeline Group
                VStack(alignment: .leading, spacing: WinnieSpacing.s) {
                    Text("Timeline")
                        .font(WinnieTypography.caption())
                        .foregroundColor(WinnieColors.tertiaryText(for: colorScheme))
                        .textCase(.uppercase)
                        .tracking(0.5)

                    detailRow(
                        icon: "calendar",
                        label: "Target Date",
                        value: viewModel.goal.desiredDate.map { Formatting.date($0) } ?? "Not set"
                    )

                    statusRow
                }

                Divider()

                // MARK: Growth Group
                VStack(alignment: .leading, spacing: WinnieSpacing.s) {
                    Text("Growth")
                        .font(WinnieTypography.caption())
                        .foregroundColor(WinnieColors.tertiaryText(for: colorScheme))
                        .textCase(.uppercase)
                        .tracking(0.5)

                    detailRow(
                        icon: "percent",
                        label: "Interest Rate (APY)",
                        value: Formatting.percentage(viewModel.goal.effectiveReturnRate)
                    )

                    detailRow(
                        icon: "dollarsign.arrow.circlepath",
                        label: "Monthly Contribution",
                        value: "$300"
                    )

                    detailRow(
                        icon: "building.columns",
                        label: "Account",
                        value: viewModel.goal.accountName ?? "Not set"
                    )
                }

                Divider()

                // MARK: Meta (smaller, less prominent)
                HStack(spacing: WinnieSpacing.xs) {
                    Image(systemName: "clock")
                        .font(.system(size: 12))
                        .foregroundColor(WinnieColors.tertiaryText(for: colorScheme))

                    Text("Created \(Formatting.date(viewModel.goal.createdAt))")
                        .font(WinnieTypography.caption())
                        .foregroundColor(WinnieColors.tertiaryText(for: colorScheme))

                    Spacer()
                }
            }
        }
    }

    private func detailRow(icon: String, label: String, value: String) -> some View {
        HStack(spacing: WinnieSpacing.s) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(viewModel.goal.displayColor)
                .frame(width: 20)

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
        HStack(spacing: WinnieSpacing.s) {
            Image(systemName: "flag")
                .font(.system(size: 16))
                .foregroundColor(viewModel.goal.displayColor)
                .frame(width: 20)

            Text("Status")
                .font(WinnieTypography.bodyM())
                .foregroundColor(WinnieColors.secondaryText(for: colorScheme))

            Spacer()

            // Status chip/badge
            HStack(spacing: WinnieSpacing.xs) {
                Circle()
                    .fill(statusColor)
                    .frame(width: 8, height: 8)

                Text(statusText)
                    .font(WinnieTypography.bodyS())
                    .fontWeight(.medium)
                    .foregroundColor(statusTextColor)
            }
            .padding(.horizontal, WinnieSpacing.s)
            .padding(.vertical, WinnieSpacing.xs)
            .background(statusBackgroundColor)
            .clipShape(Capsule())
            .accessibilityElement(children: .combine)
            .accessibilityLabel("Goal status: \(statusText)")
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
        case .onTrack: return WinnieColors.success(for: colorScheme)
        case .behind: return WinnieColors.warning(for: colorScheme)
        case .completed: return WinnieColors.amethystSmoke
        case .noTarget: return WinnieColors.tertiaryText(for: colorScheme)
        }
    }

    private var statusTextColor: Color {
        switch viewModel.onTrackStatus {
        case .onTrack: return WinnieColors.success(for: colorScheme)
        case .behind: return WinnieColors.warning(for: colorScheme)
        case .completed: return WinnieColors.amethystSmoke
        case .noTarget: return WinnieColors.secondaryText(for: colorScheme)
        }
    }

    private var statusBackgroundColor: Color {
        switch viewModel.onTrackStatus {
        case .onTrack: return WinnieColors.success(for: colorScheme).opacity(0.12)
        case .behind: return WinnieColors.warning(for: colorScheme).opacity(0.12)
        case .completed: return WinnieColors.amethystSmoke.opacity(0.15)
        case .noTarget: return WinnieColors.tertiaryText(for: colorScheme).opacity(0.1)
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

                Text("Tap \"Log Contribution\" to record your first contribution")
                    .font(WinnieTypography.caption())
                    .foregroundColor(WinnieColors.tertiaryText(for: colorScheme))
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, WinnieSpacing.m)
        }
    }

    // MARK: - Milestone Message

    private var milestoneMessage: String {
        switch viewModel.goal.progressPercentageInt {
        case 0:
            return "Every dollar counts!"
        case 1..<11:
            return "Great start!"
        case 11..<21:
            return "Building momentum!"
        case 21..<31:
            return "Keep it up!"
        case 31..<41:
            return "Making progress!"
        case 41..<50:
            return "Almost halfway!"
        case 50:
            return "Halfway there!"
        case 51..<61:
            return "Over halfway!"
        case 61..<71:
            return "Looking good!"
        case 71..<81:
            return "Strong progress!"
        case 81..<91:
            return "So close!"
        case 91..<100:
            return "Almost done!"
        default:
            return "Goal reached!"
        }
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
