//
//  ContributeSheet.swift
//  Winnie
//
//  Created by Claude on 2026-01-11.
//

import SwiftUI

/// A sheet wrapper that loads goals and presents QuickContributionView.
///
/// This view handles data fetching so QuickContributionView can be presented
/// from anywhere in the app (like the tab bar) without needing pre-loaded data.
struct ContributeSheet: View {
    let coupleID: String
    let currentUserID: String

    @State private var goals: [Goal] = []
    @State private var allocations: Allocation = Allocation()
    @State private var isLoading = true
    @State private var errorMessage: String?
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        NavigationStack {
            Group {
                if isLoading {
                    loadingView
                } else if let error = errorMessage {
                    errorView(error)
                } else {
                    QuickContributionView(
                        goals: goals,
                        allocations: allocations,
                        currentUserID: currentUserID,
                        coupleID: coupleID
                    )
                }
            }
        }
        .task {
            await loadData()
        }
    }

    // MARK: - Loading View

    private var loadingView: some View {
        VStack(spacing: WinnieSpacing.m) {
            ProgressView()
                .scaleEffect(1.2)

            Text("Loading your goals...")
                .font(WinnieTypography.bodyM())
                .foregroundColor(WinnieColors.secondaryText(for: colorScheme))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(WinnieColors.background(for: colorScheme))
        .navigationTitle("Log Contributions")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    dismiss()
                }
            }
        }
    }

    // MARK: - Error View

    private func errorView(_ message: String) -> some View {
        VStack(spacing: WinnieSpacing.m) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 48))
                .foregroundColor(WinnieColors.goldenOrange)

            Text("Couldn't load goals")
                .font(WinnieTypography.headlineM())
                .contextPrimaryText()

            Text(message)
                .font(WinnieTypography.bodyS())
                .contextSecondaryText()
                .multilineTextAlignment(.center)

            Button("Try Again") {
                Task {
                    await loadData()
                }
            }
            .buttonStyle(.borderedProminent)
            .tint(WinnieColors.lavenderVeil)
        }
        .padding(WinnieSpacing.l)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(WinnieColors.background(for: colorScheme))
        .navigationTitle("Log Contributions")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    dismiss()
                }
            }
        }
    }

    // MARK: - Data Loading

    private func loadData() async {
        isLoading = true
        errorMessage = nil

        let goalRepository = GoalRepository()
        let scenarioRepository = ScenarioRepository()

        do {
            // Fetch all goals for this couple
            goals = try await goalRepository.fetchAllGoals(coupleID: coupleID)

            // Fetch active scenario for allocations
            if let activeScenario = try await scenarioRepository.fetchActiveScenario(coupleID: coupleID) {
                allocations = activeScenario.allocations
            }

            isLoading = false
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
        }
    }
}

#Preview {
    ContributeSheet(
        coupleID: "preview-couple",
        currentUserID: "preview-user"
    )
}
