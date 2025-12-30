//
//  ContentView.swift
//  Winnie
//
//  Created by Austin Beckett on 2025-12-29.
//

import SwiftUI

/// Main content view shown after authentication.
///
/// Currently shows the Goals list. Will eventually be expanded to include
/// a tab bar with Dashboard, Goals, Scenarios, and Settings.
struct ContentView: View {
    @EnvironmentObject var authService: AuthenticationService

    var body: some View {
        Group {
            if let userID = currentUserID {
                // TODO: Replace userID with actual coupleID once partner system is built
                // For now, we use the user's UID as a temporary "coupleID" for testing
                // This allows each user to have their own goals during development
                GoalsListView(coupleID: userID)
                    .overlay(alignment: .bottom) {
                        // Temporary sign out button for testing
                        signOutButton
                    }
            } else {
                // Fallback if somehow signed in without a user ID
                VStack {
                    Text("Loading...")
                    ProgressView()
                }
            }
        }
    }

    // MARK: - User ID

    private var currentUserID: String? {
        switch authService.authState {
        case .signedIn(let uid):
            return uid
        default:
            return nil
        }
    }

    // MARK: - Temporary Sign Out Button

    private var signOutButton: some View {
        Button {
            try? authService.signOut()
        } label: {
            Text("Sign Out")
                .font(WinnieTypography.bodyS())
                .foregroundColor(.white)
                .padding(.horizontal, WinnieSpacing.m)
                .padding(.vertical, WinnieSpacing.xs)
                .background(Color.red.opacity(0.8))
                .clipShape(Capsule())
        }
        .padding(.bottom, WinnieSpacing.l)
    }
}

#Preview {
    ContentView()
        .environmentObject(AuthenticationService())
}
