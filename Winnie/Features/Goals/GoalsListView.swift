import SwiftUI

/// Main screen displaying all goals for a couple.
///
/// Shows a list of goal cards with navigation to detail and create views.
/// Handles loading, empty, and error states.
struct GoalsListView: View {
    @State private var viewModel: GoalsViewModel
    @State private var showCreateGoal = false

    @Environment(\.colorScheme) private var colorScheme

    /// Current user for contribution tracking
    private let currentUser: User

    /// Partner user (if connected)
    private let partner: User?

    /// Couple ID for data queries
    private let coupleID: String

    /// Initialize with a couple ID.
    /// Creates a minimal User from the coupleID for development/testing.
    init(coupleID: String) {
        self.coupleID = coupleID
        // Create minimal user from coupleID for development
        // TODO: Accept actual User once auth flow provides it
        self.currentUser = User(id: coupleID, displayName: "You")
        self.partner = nil
        _viewModel = State(initialValue: GoalsViewModel(coupleID: coupleID))
    }

    /// Initialize with user context for full contribution tracking.
    init(coupleID: String, currentUser: User, partner: User?) {
        self.coupleID = coupleID
        self.currentUser = currentUser
        self.partner = partner
        _viewModel = State(initialValue: GoalsViewModel(coupleID: coupleID))
    }

    /// Initialize with an injected ViewModel (for previews/testing).
    init(viewModel: GoalsViewModel, currentUser: User = .sample, partner: User? = .samplePartner) {
        self.coupleID = "preview"
        self.currentUser = currentUser
        self.partner = partner
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                WinnieColors.background(for: colorScheme)
                    .ignoresSafeArea()

                // Content
                content
            }
            .navigationTitle("Goals")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    addButton
                }
            }
            .sheet(isPresented: $showCreateGoal) {
                GoalCreationView { newGoal in
                    // Handle async save in a Task - form uses sync callback
                    Task {
                        await viewModel.createGoal(newGoal)
                    }
                }
            }
            .alert("Error", isPresented: $viewModel.showError) {
                Button("OK") {
                    viewModel.errorMessage = nil
                }
            } message: {
                if let message = viewModel.errorMessage {
                    Text(message)
                }
            }
        }
        .onAppear {
            viewModel.startListening()
        }
        .onDisappear {
            viewModel.cleanup()
        }
    }

    // MARK: - Content

    @ViewBuilder
    private var content: some View {
        if viewModel.isLoading && viewModel.goals.isEmpty {
            loadingView
        } else if viewModel.goals.isEmpty {
            emptyStateView
        } else {
            goalsList
        }
    }

    // MARK: - Goals List

    private var goalsList: some View {
        ScrollView {
            LazyVStack(spacing: WinnieSpacing.m) {
                ForEach(viewModel.goals) { goal in
                    NavigationLink {
                        GoalDetailView(
                            goal: goal,
                            currentUser: currentUser,
                            partner: partner,
                            coupleID: coupleID,
                            goalsViewModel: viewModel
                        )
                    } label: {
                        GoalCard(goal: goal)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, WinnieSpacing.screenMarginMobile)
            .padding(.top, WinnieSpacing.m)
            .padding(.bottom, WinnieSpacing.xxl)
        }
    }

    // MARK: - Empty State

    private var emptyStateView: some View {
        VStack(spacing: WinnieSpacing.l) {
            Spacer()

            Image(systemName: "target")
                .font(.system(size: 64))
                .foregroundColor(WinnieColors.amethystSmoke)

            VStack(spacing: WinnieSpacing.s) {
                Text("No Goals Yet")
                    .font(WinnieTypography.headlineL())
                    .foregroundColor(WinnieColors.primaryText(for: colorScheme))

                Text("Create your first financial goal\nand start tracking your progress.")
                    .font(WinnieTypography.bodyM())
                    .foregroundColor(WinnieColors.secondaryText(for: colorScheme))
                    .multilineTextAlignment(.center)
            }

            WinnieButton("Create First Goal", style: .primary) {
                showCreateGoal = true
            }
            .frame(maxWidth: 240)

            Spacer()
        }
        .padding(.horizontal, WinnieSpacing.screenMarginMobile)
    }

    // MARK: - Loading View

    private var loadingView: some View {
        VStack(spacing: WinnieSpacing.m) {
            ProgressView()
                .scaleEffect(1.5)
            Text("Loading goals...")
                .font(WinnieTypography.bodyM())
                .foregroundColor(WinnieColors.secondaryText(for: colorScheme))
        }
    }

    // MARK: - Add Button

    private var addButton: some View {
        Button {
            showCreateGoal = true
        } label: {
            Image(systemName: "plus")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.primary)
        }
    }

}

// MARK: - Preview

#Preview("With Goals") {
    // Create a mock ViewModel with sample data
    let viewModel = GoalsViewModel(coupleID: "preview")

    GoalsListView(viewModel: viewModel)
        .onAppear {
            // Manually set sample goals for preview
            viewModel.goals = Goal.samples
        }
}

#Preview("Empty State") {
    let viewModel = GoalsViewModel(coupleID: "preview")

    GoalsListView(viewModel: viewModel)
}

#Preview("Dark Mode") {
    let viewModel = GoalsViewModel(coupleID: "preview")

    GoalsListView(viewModel: viewModel)
        .onAppear {
            viewModel.goals = Goal.samples
        }
        .preferredColorScheme(.dark)
}
