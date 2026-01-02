import SwiftUI

/// A circular avatar displaying an illustrated profile image.
///
/// Shows a cartoon-style avatar image. Currently uses placeholder avatars
/// (male for current user, female for partner). Avatar customization will be
/// added during onboarding in a future update.
///
/// ## Usage
/// ```swift
/// UserProfileAvatar(isCurrentUser: true, size: .medium)
/// UserProfileAvatar(isCurrentUser: false, size: .small)
/// ```
struct UserProfileAvatar: View {
    let isCurrentUser: Bool
    let size: AvatarSize

    /// Create an avatar with an illustrated profile image.
    /// - Parameters:
    ///   - isCurrentUser: Whether this represents the current user (affects which avatar is shown)
    ///   - size: The avatar size (default: .medium)
    init(isCurrentUser: Bool, size: AvatarSize = .medium) {
        self.isCurrentUser = isCurrentUser
        self.size = size
    }

    var body: some View {
        Image(avatarImageName)
            .resizable()
            .scaledToFit()
            .frame(width: size.diameter, height: size.diameter)
            .clipShape(Circle())
    }

    // MARK: - Avatar Selection

    /// Returns the asset name for the appropriate avatar image.
    /// Currently: male avatar for current user, female avatar for partner.
    /// This will be replaced with user-customized avatars after onboarding is built.
    private var avatarImageName: String {
        isCurrentUser ? "MaleAvatarCircle" : "FemaleAvatarCircle"
    }
}

// MARK: - Previews

#Preview("Sizes") {
    HStack(spacing: WinnieSpacing.m) {
        UserProfileAvatar(isCurrentUser: true, size: .small)
        UserProfileAvatar(isCurrentUser: true, size: .medium)
        UserProfileAvatar(isCurrentUser: true, size: .large)
    }
    .padding()
}

#Preview("Current User vs Partner") {
    HStack(spacing: WinnieSpacing.m) {
        VStack {
            UserProfileAvatar(isCurrentUser: true)
            Text("Austin")
                .font(.caption)
        }
        VStack {
            UserProfileAvatar(isCurrentUser: false)
            Text("Paige")
                .font(.caption)
        }
    }
    .padding()
}

#Preview("In Contribution Badge") {
    HStack(spacing: WinnieSpacing.xs) {
        UserProfileAvatar(isCurrentUser: true, size: .small)
        Text("Austin: $150")
            .font(WinnieTypography.bodyM())
    }
    .padding()
}
