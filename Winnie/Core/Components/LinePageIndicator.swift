//
//  LinePageIndicator.swift
//  Winnie
//
//  Created by Claude on 2026-01-09.
//

import SwiftUI

/// A modern page indicator using horizontal lines (capsules) instead of dots.
///
/// Provides a more elegant, contemporary feel compared to standard UIPageControl dots.
/// Uses lavender for the current page and dimmed version for inactive pages.
///
/// Usage:
/// ```swift
/// LinePageIndicator(
///     pageCount: 3,
///     currentPage: $currentPage
/// )
/// ```
struct LinePageIndicator: View {
    /// Total number of pages
    let pageCount: Int

    /// Currently selected page (0-indexed)
    @Binding var currentPage: Int

    /// Color for the active page indicator
    var activeColor: Color = WinnieColors.lavenderVeil

    /// Opacity for inactive indicators
    var inactiveOpacity: Double = 0.3

    /// Width of each line indicator
    var lineWidth: CGFloat = 20

    /// Height of each line indicator
    var lineHeight: CGFloat = 4

    /// Spacing between indicators
    var spacing: CGFloat = WinnieSpacing.xs

    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        if pageCount > 1 {
            HStack(spacing: spacing) {
                ForEach(0..<pageCount, id: \.self) { index in
                    Capsule()
                        .fill(index == currentPage ? activeColor : inactiveColor)
                        .frame(width: lineWidth, height: lineHeight)
                        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: currentPage)
                }
            }
            .padding(.vertical, WinnieSpacing.xs)
        }
    }

    private var inactiveColor: Color {
        // Use context-aware inactive color
        WinnieColors.primaryText(for: colorScheme).opacity(inactiveOpacity)
    }
}

// MARK: - Previews

#Preview("Line Page Indicator") {
    struct PreviewWrapper: View {
        @State private var currentPage = 0

        var body: some View {
            VStack(spacing: WinnieSpacing.xl) {
                Text("Page \(currentPage + 1) of 3")
                    .font(WinnieTypography.bodyM())

                LinePageIndicator(pageCount: 3, currentPage: $currentPage)

                HStack(spacing: WinnieSpacing.m) {
                    Button("Previous") {
                        if currentPage > 0 { currentPage -= 1 }
                    }
                    Button("Next") {
                        if currentPage < 2 { currentPage += 1 }
                    }
                }
            }
            .padding()
        }
    }

    return PreviewWrapper()
}

#Preview("Single Page (Hidden)") {
    VStack {
        Text("Single page - indicator should be hidden")
            .font(WinnieTypography.bodyS())

        LinePageIndicator(pageCount: 1, currentPage: .constant(0))
    }
    .padding()
}

#Preview("Multiple Pages") {
    VStack(spacing: WinnieSpacing.l) {
        LinePageIndicator(pageCount: 2, currentPage: .constant(0))
        LinePageIndicator(pageCount: 3, currentPage: .constant(1))
        LinePageIndicator(pageCount: 4, currentPage: .constant(2))
        LinePageIndicator(pageCount: 5, currentPage: .constant(4))
    }
    .padding()
}

#Preview("Dark Mode") {
    VStack(spacing: WinnieSpacing.l) {
        LinePageIndicator(pageCount: 3, currentPage: .constant(0))
        LinePageIndicator(pageCount: 3, currentPage: .constant(1))
        LinePageIndicator(pageCount: 3, currentPage: .constant(2))
    }
    .padding()
    .background(WinnieColors.onyx)
    .preferredColorScheme(.dark)
}
