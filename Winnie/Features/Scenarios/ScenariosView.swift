//
//  ScenariosView.swift
//  Winnie
//
//  Created by Austin Beckett on 2026-01-02.
//

import SwiftUI

/// Main view for the Scenarios/Planning tab.
///
/// Displays the scenario list view where users can:
/// - View all saved scenarios
/// - Create new "what-if" scenarios
/// - Edit allocations and see timeline projections
/// - Compare different financial paths
struct ScenariosView: View {
    let coupleID: String
    let userID: String

    var body: some View {
        ScenarioListView(coupleID: coupleID, userID: userID)
    }
}

// MARK: - Previews

#Preview("Light Mode") {
    NavigationStack {
        ScenariosView(coupleID: "preview", userID: "user1")
    }
}

#Preview("Dark Mode") {
    NavigationStack {
        ScenariosView(coupleID: "preview", userID: "user1")
    }
    .preferredColorScheme(.dark)
}
