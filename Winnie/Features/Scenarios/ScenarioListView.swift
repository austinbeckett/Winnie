//
//  ScenarioListView.swift
//  Winnie
//
//  Created by Claude Code on 2026-01-08.
//

import SwiftUI

/// ViewModel for the Scenario List view.
@Observable
@MainActor
final class ScenarioListViewModel: ErrorHandlingViewModel {

    // MARK: - Published State

    var scenarios: [Scenario] = []
    var goals: [Goal] = []
    var financialProfile: FinancialProfile?
    var isLoading: Bool = false
    var errorMessage: String?
    var showError: Bool = false

    // MARK: - Computed

    /// Active scenario (if any)
    var activeScenario: Scenario? {
        scenarios.first { $0.isActive }
    }

    /// Non-active scenarios grouped by status
    var draftScenarios: [Scenario] {
        scenarios.filter { !$0.isActive && $0.decisionStatus == .draft }
    }

    var underReviewScenarios: [Scenario] {
        scenarios.filter { !$0.isActive && $0.decisionStatus == .underReview }
    }

    var archivedScenarios: [Scenario] {
        scenarios.filter { $0.decisionStatus == .archived }
    }

    /// Calculate projections for a scenario
    func projections(for scenario: Scenario) -> [String: GoalProjection] {
        guard let profile = financialProfile else { return [:] }

        let engine = FinancialEngine()
        let input = EngineInput(
            profile: profile,
            goals: goals,
            allocations: scenario.allocations
        )

        let output = engine.calculate(input: input)
        return output.projections
    }

    // MARK: - Dependencies

    private let coupleID: String
    private let scenarioRepository: ScenarioRepository
    private let goalRepository: GoalRepository
    private let coupleRepository: CoupleRepository
    private var listenerRegistration: ListenerRegistrationProviding?

    // MARK: - Initialization

    init(
        coupleID: String,
        scenarioRepository: ScenarioRepository? = nil,
        goalRepository: GoalRepository? = nil,
        coupleRepository: CoupleRepository? = nil
    ) {
        self.coupleID = coupleID
        self.scenarioRepository = scenarioRepository ?? ScenarioRepository()
        self.goalRepository = goalRepository ?? GoalRepository()
        self.coupleRepository = coupleRepository ?? CoupleRepository()
    }

    // MARK: - Data Loading

    func loadData() async {
        isLoading = true

        do {
            // Load goals and profile
            async let goalsTask = goalRepository.fetchAllGoals(coupleID: coupleID)
            async let profileTask = coupleRepository.fetchFinancialProfile(coupleID: coupleID)

            let (loadedGoals, loadedProfile) = try await (goalsTask, profileTask)
            goals = loadedGoals.filter { $0.isActive }
            financialProfile = loadedProfile

        } catch {
            handleError(error, context: "loading data")
        }

        isLoading = false
    }

    func startListening() {
        guard listenerRegistration == nil else { return }

        listenerRegistration = scenarioRepository.listenToScenarios(coupleID: coupleID) { [weak self] scenarios in
            self?.scenarios = scenarios
        }
    }

    func stopListening() {
        listenerRegistration?.remove()
        listenerRegistration = nil
    }

    // MARK: - Actions

    func setAsActive(scenario: Scenario) async {
        do {
            try await scenarioRepository.setActiveScenario(scenarioID: scenario.id, coupleID: coupleID)
        } catch {
            handleError(error, context: "setting active scenario")
        }
    }

    func deleteScenario(_ scenario: Scenario) async {
        do {
            try await scenarioRepository.deleteScenario(id: scenario.id, coupleID: coupleID)
        } catch {
            handleError(error, context: "deleting scenario")
        }
    }

    func archiveScenario(_ scenario: Scenario) async {
        do {
            try await scenarioRepository.updateScenarioStatus(
                scenarioID: scenario.id,
                status: .archived,
                coupleID: coupleID
            )
        } catch {
            handleError(error, context: "archiving scenario")
        }
    }
}

// MARK: - ScenarioListView

/// View displaying all scenarios with management options.
struct ScenarioListView: View {
    let coupleID: String
    let userID: String

    @State private var viewModel: ScenarioListViewModel
    @State private var showCreateSheet = false
    @State private var scenarioToEdit: Scenario?
    @State private var scenarioToView: Scenario?

    @Environment(\.colorScheme) private var colorScheme

    init(coupleID: String, userID: String) {
        self.coupleID = coupleID
        self.userID = userID
        self._viewModel = State(initialValue: ScenarioListViewModel(coupleID: coupleID))
    }

    var body: some View {
        ZStack {
            WinnieColors.background(for: colorScheme)
                .ignoresSafeArea()

            if viewModel.isLoading && viewModel.scenarios.isEmpty {
                ProgressView()
                    .scaleEffect(1.2)
            } else if viewModel.scenarios.isEmpty {
                emptyState
            } else {
                scenarioList
            }
        }
        .navigationTitle("Planning")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    showCreateSheet = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showCreateSheet) {
            ScenarioEditorView(
                coupleID: coupleID,
                userID: userID,
                onDismiss: { showCreateSheet = false }
            )
        }
        .sheet(item: $scenarioToEdit) { scenario in
            ScenarioEditorView(
                coupleID: coupleID,
                userID: userID,
                scenario: scenario,
                onDismiss: { scenarioToEdit = nil },
                onSave: {
                    // Refresh list after edit
                    Task { await viewModel.loadData() }
                }
            )
        }
        .navigationDestination(item: $scenarioToView) { scenario in
            ScenarioDetailView(
                scenario: scenario,
                coupleID: coupleID,
                userID: userID,
                onScenarioUpdated: {
                    // Refresh list when scenario is updated from detail view
                    Task { await viewModel.loadData() }
                }
            )
        }
        .alert("Error", isPresented: $viewModel.showError) {
            Button("OK") { viewModel.showError = false }
        } message: {
            Text(viewModel.errorMessage ?? "An error occurred")
        }
        .task {
            await viewModel.loadData()
            viewModel.startListening()
        }
        .onDisappear {
            viewModel.stopListening()
        }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: WinnieSpacing.l) {
            Spacer()

            Image(systemName: "chart.pie")
                .font(.system(size: 64))
                .foregroundColor(WinnieColors.tertiaryText(for: colorScheme))

            VStack(spacing: WinnieSpacing.s) {
                Text("No Plans Yet")
                    .font(WinnieTypography.headlineL())
                    .foregroundColor(WinnieColors.primaryText(for: colorScheme))

                Text("Create your first financial plan to see how different allocations affect your goal timelines.")
                    .font(WinnieTypography.bodyM())
                    .foregroundColor(WinnieColors.secondaryText(for: colorScheme))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, WinnieSpacing.xl)
            }

            WinnieButton("Create First Plan", style: .primary) {
                showCreateSheet = true
            }
            .padding(.horizontal, WinnieSpacing.xxl)

            Spacer()
        }
    }

    // MARK: - Scenario List

    private var scenarioList: some View {
        ScrollView {
            LazyVStack(spacing: WinnieSpacing.l) {
                // Active plan section
                if let active = viewModel.activeScenario {
                    VStack(alignment: .leading, spacing: WinnieSpacing.m) {
                        sectionHeader("Active Plan")

                        ScenarioCard(
                            scenario: active,
                            goals: viewModel.goals,
                            projections: viewModel.projections(for: active),
                            onTap: { scenarioToView = active }
                        )
                        .contextMenu {
                            Button {
                                scenarioToView = active
                            } label: {
                                Label("View Details", systemImage: "eye")
                            }

                            Button {
                                scenarioToEdit = active
                            } label: {
                                Label("Edit", systemImage: "pencil")
                            }
                        }
                    }
                }

                // Under review section
                if !viewModel.underReviewScenarios.isEmpty {
                    VStack(alignment: .leading, spacing: WinnieSpacing.m) {
                        sectionHeader("Under Review")

                        ForEach(viewModel.underReviewScenarios) { scenario in
                            scenarioRow(scenario)
                        }
                    }
                }

                // Drafts section
                if !viewModel.draftScenarios.isEmpty {
                    VStack(alignment: .leading, spacing: WinnieSpacing.m) {
                        sectionHeader("Drafts")

                        ForEach(viewModel.draftScenarios) { scenario in
                            scenarioRow(scenario)
                        }
                    }
                }

                // Archived section (collapsed by default)
                if !viewModel.archivedScenarios.isEmpty {
                    DisclosureGroup {
                        ForEach(viewModel.archivedScenarios) { scenario in
                            scenarioRow(scenario)
                        }
                    } label: {
                        sectionHeader("Archived (\(viewModel.archivedScenarios.count))")
                    }
                    .tint(WinnieColors.secondaryText(for: colorScheme))
                }
            }
            .padding(WinnieSpacing.l)
        }
    }

    // MARK: - Helpers

    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(WinnieTypography.labelM())
            .foregroundColor(WinnieColors.secondaryText(for: colorScheme))
    }

    private func scenarioRow(_ scenario: Scenario) -> some View {
        ScenarioCard(
            scenario: scenario,
            goals: viewModel.goals,
            projections: viewModel.projections(for: scenario),
            onTap: { scenarioToView = scenario }
        )
        .contextMenu {
            Button {
                scenarioToView = scenario
            } label: {
                Label("View Details", systemImage: "eye")
            }

            Button {
                scenarioToEdit = scenario
            } label: {
                Label("Edit", systemImage: "pencil")
            }

            if !scenario.isActive {
                Button {
                    Task { await viewModel.setAsActive(scenario: scenario) }
                } label: {
                    Label("Set as Active Plan", systemImage: "star")
                }
            }

            if scenario.decisionStatus != .archived {
                Button {
                    Task { await viewModel.archiveScenario(scenario) }
                } label: {
                    Label("Archive", systemImage: "archivebox")
                }
            }

            Divider()

            Button(role: .destructive) {
                Task { await viewModel.deleteScenario(scenario) }
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            Button(role: .destructive) {
                Task { await viewModel.deleteScenario(scenario) }
            } label: {
                Label("Delete", systemImage: "trash")
            }

            if scenario.decisionStatus != .archived {
                Button {
                    Task { await viewModel.archiveScenario(scenario) }
                } label: {
                    Label("Archive", systemImage: "archivebox")
                }
                .tint(WinnieColors.goldenOrange)
            }
        }
        .swipeActions(edge: .leading, allowsFullSwipe: true) {
            if !scenario.isActive {
                Button {
                    Task { await viewModel.setAsActive(scenario: scenario) }
                } label: {
                    Label("Activate", systemImage: "star")
                }
                .tint(WinnieColors.lavenderVeil)
            }
        }
    }
}

// MARK: - Previews

#Preview("Empty State") {
    NavigationStack {
        ScenarioListView(coupleID: "preview", userID: "user1")
    }
}

#Preview("Dark Mode") {
    NavigationStack {
        ScenarioListView(coupleID: "preview", userID: "user1")
    }
    .preferredColorScheme(.dark)
}
