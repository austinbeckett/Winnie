import SwiftUI

/// Main screen displaying all goals for a couple.
///
/// Shows a list of goal cards with navigation to detail and create views.
/// Handles loading, empty, and error states.
struct GoalsListView: View {
    @State private var viewModel: GoalsViewModel
    @State private var showCreateGoal = false

    @Environment(\.colorScheme) private var colorScheme

    /// Initialize with a couple ID.
    init(coupleID: String) {
        _viewModel = State(initialValue: GoalsViewModel(coupleID: coupleID))
    }

    /// Initialize with an injected ViewModel (for previews/testing).
    init(viewModel: GoalsViewModel) {
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
                GoalFormView(goal: nil) { newGoal in
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
            configureNavigationBarAppearance()
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
                    NavigationLink(destination: GoalDetailView(goal: goal, viewModel: viewModel)) {
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
                .foregroundColor(WinnieColors.amethystSmoke)
        }
    }

    // MARK: - Navigation Bar Appearance

    private func configureNavigationBarAppearance() {
        // Create appearance for large title (scrolled to top)
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()

        // Create serif fonts using font descriptor
        let largeTitleFont: UIFont = {
            let descriptor = UIFont.systemFont(ofSize: 34, weight: .bold).fontDescriptor.withDesign(.serif)
            return descriptor.map { UIFont(descriptor: $0, size: 34) } ?? UIFont.systemFont(ofSize: 34, weight: .bold)
        }()

        let inlineTitleFont: UIFont = {
            let descriptor = UIFont.systemFont(ofSize: 17, weight: .semibold).fontDescriptor.withDesign(.serif)
            return descriptor.map { UIFont(descriptor: $0, size: 17) } ?? UIFont.systemFont(ofSize: 17, weight: .semibold)
        }()

        // Large title font (serif)
        appearance.largeTitleTextAttributes = [
            .font: largeTitleFont,
            .foregroundColor: UIColor(WinnieColors.primaryText(for: colorScheme))
        ]

        // Inline title font (when scrolled)
        appearance.titleTextAttributes = [
            .font: inlineTitleFont,
            .foregroundColor: UIColor(WinnieColors.primaryText(for: colorScheme))
        ]

        // Apply to navigation bar
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
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
