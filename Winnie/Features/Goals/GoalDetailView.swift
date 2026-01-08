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
    @State private var showPlanEditor = false

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
        .background(WinnieColors.background(for: colorScheme).ignoresSafeArea(edges: .all))
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
        .sheet(isPresented: $viewModel.showAddToPlanSheet) {
            // TODO: Replace with actual AddGoalToPlanSheet when available
            NavigationStack {
                VStack(spacing: WinnieSpacing.l) {
                    Text("Add to Plan")
                        .font(WinnieTypography.headlineL())
                    Text("This feature will allow you to add \"\(viewModel.goal.name)\" to your current plan.")
                        .font(WinnieTypography.bodyM())
                        .multilineTextAlignment(.center)
                    Spacer()
                }
                .padding()
                .navigationTitle("Add to Plan")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") {
                            viewModel.showAddToPlanSheet = false
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $showPlanEditor) {
            if let scenario = viewModel.activeScenario {
                ScenarioEditorView(
                    coupleID: viewModel.coupleID,
                    userID: viewModel.currentUser.id,
                    scenario: scenario,
                    onDismiss: { showPlanEditor = false }
                )
            }
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
                    .foregroundColor(WinnieColors.cardText)

                VStack(spacing: WinnieSpacing.s) {
                    // Current user row
                    HStack(spacing: WinnieSpacing.s) {
                        UserProfileAvatar(isCurrentUser: true, size: .small)
                        Text(viewModel.currentUserName)
                            .font(WinnieTypography.bodyM())
                            .foregroundColor(WinnieColors.cardText)
                        Spacer()
                        Text(Formatting.currency(viewModel.currentUserTotal))
                            .font(WinnieTypography.bodyM())
                            .fontWeight(.semibold)
                            .foregroundColor(WinnieColors.cardText)
                    }

                    // Partner row
                    HStack(spacing: WinnieSpacing.s) {
                        UserProfileAvatar(isCurrentUser: false, size: .small)
                        Text(viewModel.partnerName)
                            .font(WinnieTypography.bodyM())
                            .foregroundColor(WinnieColors.cardText)
                        Spacer()
                        Text(Formatting.currency(viewModel.partnerTotal))
                            .font(WinnieTypography.bodyM())
                            .fontWeight(.semibold)
                            .foregroundColor(WinnieColors.cardText)
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
                    .foregroundColor(WinnieColors.cardText)
                    .frame(maxWidth: .infinity, alignment: .leading)

                // MARK: Timeline Group
                VStack(alignment: .leading, spacing: WinnieSpacing.s) {
                    Text("Timeline")
                        .font(WinnieTypography.caption())
                        .contextTertiaryText()
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
                        .contextTertiaryText()
                        .textCase(.uppercase)
                        .tracking(0.5)

                    detailRow(
                        icon: "percent",
                        label: "Interest Rate (APY)",
                        value: Formatting.percentage(viewModel.goal.effectiveReturnRate)
                    )

                    // Enhanced allocation section with plan context
                    allocationSection

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
                        .contextTertiaryText()

                    Text("Created \(Formatting.date(viewModel.goal.createdAt))")
                        .font(WinnieTypography.caption())
                        .contextTertiaryText()

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
                .foregroundColor(WinnieColors.cardText.opacity(WinnieColors.Opacity.secondary))

            Spacer()

            Text(value)
                .font(WinnieTypography.bodyM())
                .foregroundColor(WinnieColors.cardText)
        }
    }

    private var statusRow: some View {
        VStack(alignment: .leading, spacing: WinnieSpacing.s) {
            HStack(spacing: WinnieSpacing.s) {
                Image(systemName: viewModel.trackingStatus.iconName)
                    .font(.system(size: 16))
                    .foregroundColor(viewModel.goal.displayColor)
                    .frame(width: 20)

                Text("Status")
                    .font(WinnieTypography.bodyM())
                    .foregroundColor(WinnieColors.cardText.opacity(WinnieColors.Opacity.secondary))

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

            // Additional status details based on tracking status
            statusDetailsSection
        }
    }

    /// Additional details shown below the status badge for actionable states.
    @ViewBuilder
    private var statusDetailsSection: some View {
        switch viewModel.trackingStatus {
        case .completed:
            EmptyView()

        case .noTargetDate(let projectedDate):
            if let date = projectedDate {
                Text("Projected completion: \(Formatting.monthYear(date))")
                    .font(WinnieTypography.caption())
                    .foregroundColor(WinnieColors.cardText.opacity(WinnieColors.Opacity.secondary))
                    .padding(.leading, 28) // Align with text after icon
            }

        case .notInPlan:
            VStack(alignment: .leading, spacing: WinnieSpacing.xs) {
                Text("Add this goal to a plan to track progress")
                    .font(WinnieTypography.caption())
                    .foregroundColor(WinnieColors.cardText.opacity(WinnieColors.Opacity.secondary))

                Button {
                    viewModel.showAddToPlanSheet = true
                } label: {
                    Text("Add to Current Plan")
                        .font(WinnieTypography.bodyS())
                        .fontWeight(.medium)
                }
                .buttonStyle(.borderedProminent)
                .tint(WinnieColors.amethystSmoke)
            }
            .padding(.leading, 28)

        case .onTrack(let details):
            Text("Projected: \(Formatting.monthYear(details.projectedDate)) (\(abs(details.monthsDifference)) months early)")
                .font(WinnieTypography.caption())
                .foregroundColor(WinnieColors.cardText.opacity(WinnieColors.Opacity.secondary))
                .padding(.leading, 28)

        case .behind(let details, let requiredContribution):
            VStack(alignment: .leading, spacing: WinnieSpacing.s) {
                Text("Current plan projects \(abs(details.monthsDifference)) months late")
                    .font(WinnieTypography.caption())
                    .foregroundColor(WinnieColors.cardText.opacity(WinnieColors.Opacity.secondary))

                // Primary recommendation: increase savings
                if requiredContribution > details.currentContribution {
                    Text("Save \(Formatting.currency(requiredContribution))/month to hit your target")
                        .font(WinnieTypography.bodyS())
                        .fontWeight(.medium)
                        .foregroundColor(WinnieColors.cardText)
                }

                // Secondary option: adjust target date
                Button {
                    Task {
                        await viewModel.adjustTargetDateToProjection()
                    }
                } label: {
                    Text("Adjust target to \(Formatting.monthYear(details.projectedDate))")
                        .font(WinnieTypography.bodyS())
                }
                .buttonStyle(.bordered)
            }
            .padding(.leading, 28)
        }
    }

    private var statusText: String {
        viewModel.trackingStatus.label
    }

    /// Display text for monthly allocation from plan.
    private var monthlyAllocationText: String {
        guard let projection = viewModel.projection else {
            return "Not in plan"
        }
        if projection.monthlyContribution > 0 {
            return Formatting.currency(projection.monthlyContribution) + "/month"
        }
        return "Not in plan"
    }

    // MARK: - Enhanced Allocation Section

    /// Enhanced allocation section showing plan context and target vs projected comparison.
    private var allocationSection: some View {
        VStack(alignment: .leading, spacing: WinnieSpacing.s) {
            // Header row with icon and label
            HStack(spacing: WinnieSpacing.s) {
                Image(systemName: "dollarsign.arrow.circlepath")
                    .font(.system(size: 16))
                    .foregroundColor(viewModel.goal.displayColor)
                    .frame(width: 20)

                Text("Monthly Allocation")
                    .font(WinnieTypography.bodyM())
                    .foregroundColor(WinnieColors.cardText.opacity(WinnieColors.Opacity.secondary))

                Spacer()
            }

            // Allocation amount with plan context
            if let projection = viewModel.projection, projection.monthlyContribution > 0 {
                VStack(alignment: .leading, spacing: WinnieSpacing.xs) {
                    // Amount and plan name
                    HStack {
                        Text(Formatting.currency(projection.monthlyContribution) + "/mo")
                            .font(WinnieTypography.bodyM())
                            .fontWeight(.semibold)
                            .foregroundColor(WinnieColors.cardText)

                        if let planName = viewModel.activePlanName {
                            Text("from \"\(planName)\"")
                                .font(WinnieTypography.caption())
                                .foregroundColor(WinnieColors.cardText.opacity(WinnieColors.Opacity.tertiary))
                        }
                    }

                    // Target vs Projected date comparison (if goal has target date)
                    if let targetDate = viewModel.goal.desiredDate,
                       let projectedDate = projection.completionDate {
                        HStack(spacing: WinnieSpacing.xs) {
                            Text("Target: \(Formatting.monthYear(targetDate))")
                                .font(WinnieTypography.caption())
                                .foregroundColor(WinnieColors.cardText.opacity(WinnieColors.Opacity.secondary))

                            Image(systemName: "arrow.right")
                                .font(.system(size: 10))
                                .foregroundColor(WinnieColors.cardText.opacity(WinnieColors.Opacity.tertiary))

                            Text("Projected: \(Formatting.monthYear(projectedDate))")
                                .font(WinnieTypography.caption())
                                .foregroundColor(WinnieColors.cardText.opacity(WinnieColors.Opacity.secondary))
                        }
                    }

                    // Edit in Plan button
                    if viewModel.activeScenario != nil {
                        Button {
                            showPlanEditor = true
                        } label: {
                            HStack(spacing: WinnieSpacing.xxs) {
                                Text("Edit in Plan")
                                Image(systemName: "arrow.right")
                                    .font(.system(size: 10))
                            }
                            .font(WinnieTypography.bodyS())
                            .fontWeight(.medium)
                        }
                        .buttonStyle(.plain)
                        .foregroundColor(WinnieColors.lavenderVeil)
                        .padding(.top, WinnieSpacing.xxs)
                    }
                }
                .padding(.leading, 28) // Align with text after icon
            } else {
                // Not in plan state
                Text("Not in plan")
                    .font(WinnieTypography.bodyM())
                    .foregroundColor(WinnieColors.cardText)
                    .padding(.leading, 28)
            }
        }
    }

    private var statusColor: Color {
        switch viewModel.trackingStatus {
        case .onTrack: return WinnieColors.success(for: colorScheme)
        case .behind: return WinnieColors.warning(for: colorScheme)
        case .completed: return WinnieColors.amethystSmoke
        case .noTargetDate, .notInPlan: return WinnieColors.tertiaryText(for: colorScheme)
        }
    }

    private var statusTextColor: Color {
        switch viewModel.trackingStatus {
        case .onTrack: return WinnieColors.success(for: colorScheme)
        case .behind: return WinnieColors.warning(for: colorScheme)
        case .completed: return WinnieColors.amethystSmoke
        case .noTargetDate, .notInPlan: return WinnieColors.secondaryText(for: colorScheme)
        }
    }

    private var statusBackgroundColor: Color {
        switch viewModel.trackingStatus {
        case .onTrack: return WinnieColors.success(for: colorScheme).opacity(0.12)
        case .behind: return WinnieColors.warning(for: colorScheme).opacity(0.12)
        case .completed: return WinnieColors.amethystSmoke.opacity(0.15)
        case .noTargetDate, .notInPlan: return WinnieColors.tertiaryText(for: colorScheme).opacity(0.1)
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
                    .contextTertiaryText()

                Text("No contributions yet")
                    .font(WinnieTypography.bodyM())
                    .contextSecondaryText()

                Text("Tap \"Log Contribution\" to record your first contribution")
                    .font(WinnieTypography.caption())
                    .contextTertiaryText()
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
