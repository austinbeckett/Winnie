import SwiftUI

/// Avatar size options for UserInitialsAvatar
enum AvatarSize {
    case small   // 32pt - for compact lists
    case medium  // 44pt - standard size (touch target)
    case large   // 56pt - for featured display

    var diameter: CGFloat {
        switch self {
        case .small: return 32
        case .medium: return 44
        case .large: return 56
        }
    }

    var fontSize: CGFloat {
        switch self {
        case .small: return 12
        case .medium: return 16
        case .large: return 20
        }
    }
}

/// A circular avatar displaying a user's initials.
///
/// Shows the user's initials (first letter of first and last name) in a colored circle.
/// Automatically adapts colors for light and dark mode.
///
/// ## Usage
/// ```swift
/// UserInitialsAvatar(initials: "AJ", size: .medium)
/// UserInitialsAvatar(initials: "AB", size: .small, isCurrentUser: true)
/// ```
struct UserInitialsAvatar: View {
    let initials: String
    let size: AvatarSize
    let isCurrentUser: Bool

    @Environment(\.colorScheme) private var colorScheme

    /// Create an avatar with initials.
    /// - Parameters:
    ///   - initials: The initials to display (usually 1-2 characters)
    ///   - size: The avatar size (default: .medium)
    ///   - isCurrentUser: Whether this represents the current user (affects color)
    init(initials: String, size: AvatarSize = .medium, isCurrentUser: Bool = false) {
        self.initials = initials
        self.size = size
        self.isCurrentUser = isCurrentUser
    }

    var body: some View {
        Text(initials)
            .font(.system(size: size.fontSize, weight: .semibold))
            .foregroundColor(textColor)
            .frame(width: size.diameter, height: size.diameter)
            .background(backgroundColor)
            .clipShape(Circle())
    }

    // MARK: - Colors

    private var backgroundColor: Color {
        if isCurrentUser {
            return WinnieColors.amethystSmoke
        } else {
            // Partner gets a complementary color
            return colorScheme == .dark
                ? Color(hex: "#4A4A5A") // Storm-like in dark mode
                : Color(hex: "#E8E4E8") // Light gray in light mode
        }
    }

    private var textColor: Color {
        if isCurrentUser {
            return .white
        } else {
            return colorScheme == .dark
                ? WinnieColors.snow
                : WinnieColors.ink
        }
    }
}

// MARK: - Convenience Initializers

extension UserInitialsAvatar {

    /// Create an avatar from a display name.
    /// - Parameters:
    ///   - displayName: The user's full name (initials extracted automatically)
    ///   - size: The avatar size
    ///   - isCurrentUser: Whether this represents the current user
    init(displayName: String?, size: AvatarSize = .medium, isCurrentUser: Bool = false) {
        self.initials = Self.extractInitials(from: displayName)
        self.size = size
        self.isCurrentUser = isCurrentUser
    }

    /// Extract initials from a display name.
    private static func extractInitials(from name: String?) -> String {
        guard let name, !name.isEmpty else { return "?" }
        let components = name.components(separatedBy: " ").filter { !$0.isEmpty }
        if components.count >= 2 {
            let first = components[0].prefix(1)
            let last = components[1].prefix(1)
            return "\(first)\(last)".uppercased()
        }
        return String(name.prefix(2)).uppercased()
    }
}

// MARK: - Previews

#Preview("Sizes") {
    HStack(spacing: WinnieSpacing.m) {
        UserInitialsAvatar(initials: "AJ", size: .small, isCurrentUser: true)
        UserInitialsAvatar(initials: "AJ", size: .medium, isCurrentUser: true)
        UserInitialsAvatar(initials: "AJ", size: .large, isCurrentUser: true)
    }
    .padding()
}

#Preview("Current User vs Partner") {
    HStack(spacing: WinnieSpacing.m) {
        VStack {
            UserInitialsAvatar(initials: "AJ", isCurrentUser: true)
            Text("You")
                .font(.caption)
        }
        VStack {
            UserInitialsAvatar(initials: "JJ", isCurrentUser: false)
            Text("Partner")
                .font(.caption)
        }
    }
    .padding()
}

#Preview("From Name") {
    VStack(spacing: WinnieSpacing.m) {
        UserInitialsAvatar(displayName: "Alex Johnson", isCurrentUser: true)
        UserInitialsAvatar(displayName: "Jordan", isCurrentUser: false)
        UserInitialsAvatar(displayName: nil, isCurrentUser: false)
    }
    .padding()
}

#Preview("Dark Mode") {
    HStack(spacing: WinnieSpacing.m) {
        UserInitialsAvatar(initials: "AJ", isCurrentUser: true)
        UserInitialsAvatar(initials: "JJ", isCurrentUser: false)
    }
    .padding()
    .preferredColorScheme(.dark)
}
