//
//  WinnieSlider.swift
//  Winnie
//
//  Created by Claude Code on 2026-01-08.
//

import SwiftUI
import UIKit

/// A custom slider for financial allocation amounts following Winnie design system.
///
/// The slider features a thick-bordered thumb (Wispr Flow aesthetic), spring animations,
/// and haptic feedback at bounds. It works with Decimal values for financial precision.
///
/// Usage:
/// ```swift
/// // Basic usage with default $50 steps
/// @State private var amount: Decimal = 500
/// WinnieSlider(value: $amount, in: 0...2000)
///
/// // Custom step increment
/// WinnieSlider(value: $amount, in: 0...2000, step: 100)
///
/// // With custom fill color
/// WinnieSlider(value: $amount, in: 0...2000, fillColor: .teal)
///
/// // With editing callback (for debounced updates)
/// WinnieSlider(value: $amount, in: 0...2000) { isEditing in
///     if !isEditing { viewModel.recalculate() }
/// }
/// ```
struct WinnieSlider: View {
    @Binding var value: Decimal
    let range: ClosedRange<Decimal>
    let step: Decimal
    let fillColor: Color
    let onEditingChanged: ((Bool) -> Void)?

    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.cardContext) private var cardContext

    @State private var isDragging = false
    @State private var thumbScale: CGFloat = 1.0

    // Haptic feedback generator
    private let impactFeedback = UIImpactFeedbackGenerator(style: .light)

    // MARK: - Design Constants

    private let trackHeight: CGFloat = 8
    private let trackCornerRadius: CGFloat = 4
    private let thumbSize: CGFloat = 24
    private let thumbBorderWidth: CGFloat = 3

    /// Creates a slider for Decimal values.
    /// - Parameters:
    ///   - value: Binding to the current value
    ///   - range: The valid range of values (e.g., 0...2000)
    ///   - step: Increment amount (defaults to $50)
    ///   - fillColor: Color for the filled portion (defaults to Lavender Veil)
    ///   - onEditingChanged: Callback when dragging starts/stops (useful for debouncing)
    init(
        value: Binding<Decimal>,
        in range: ClosedRange<Decimal>,
        step: Decimal = 50,
        fillColor: Color = WinnieColors.lavenderVeil,
        onEditingChanged: ((Bool) -> Void)? = nil
    ) {
        self._value = value
        self.range = range
        self.step = step
        self.fillColor = fillColor
        self.onEditingChanged = onEditingChanged
    }

    var body: some View {
        GeometryReader { geometry in
            let trackWidth = geometry.size.width - thumbSize
            let progress = calculateProgress()
            let thumbOffset = trackWidth * progress

            ZStack(alignment: .leading) {
                // Background track
                RoundedRectangle(cornerRadius: trackCornerRadius)
                    .fill(trackColor)
                    .frame(height: trackHeight)

                // Filled track
                RoundedRectangle(cornerRadius: trackCornerRadius)
                    .fill(fillColor)
                    .frame(width: thumbOffset + thumbSize / 2, height: trackHeight)

                // Thumb
                Circle()
                    .fill(thumbBackgroundColor)
                    .overlay(
                        Circle()
                            .stroke(thumbBorderColor, lineWidth: thumbBorderWidth)
                    )
                    .frame(width: thumbSize, height: thumbSize)
                    .scaleEffect(thumbScale)
                    .offset(x: thumbOffset)
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { gesture in
                                handleDragChange(gesture: gesture, trackWidth: trackWidth)
                            }
                            .onEnded { _ in
                                handleDragEnd()
                            }
                    )
            }
            .frame(height: thumbSize)
        }
        .frame(height: thumbSize)
    }

    // MARK: - Calculations

    private func calculateProgress() -> CGFloat {
        let rangeSpan = range.upperBound - range.lowerBound
        guard rangeSpan > 0 else { return 0 }

        let clampedValue = min(max(value, range.lowerBound), range.upperBound)
        let progress = (clampedValue - range.lowerBound) / rangeSpan

        return CGFloat(truncating: progress as NSNumber)
    }

    // MARK: - Gesture Handling

    private func handleDragChange(gesture: DragGesture.Value, trackWidth: CGFloat) {
        // Start dragging state
        if !isDragging {
            isDragging = true
            onEditingChanged?(true)

            // Scale down thumb on press
            withAnimation(.spring(response: 0.2, dampingFraction: 0.6)) {
                thumbScale = 0.9
            }
        }

        // Calculate new value from position
        let position = gesture.location.x - thumbSize / 2
        let progress = max(0, min(1, position / trackWidth))

        let rangeSpan = range.upperBound - range.lowerBound
        var newValue = range.lowerBound + rangeSpan * Decimal(progress)

        // Snap to step increment
        if step > 0 {
            let stepsFromMinDecimal = (newValue - range.lowerBound) / step
            let stepsFromMin = Int(NSDecimalNumber(decimal: stepsFromMinDecimal).doubleValue.rounded())
            newValue = range.lowerBound + step * Decimal(stepsFromMin)
        }

        // Clamp to range
        newValue = min(max(newValue, range.lowerBound), range.upperBound)

        // Check if we hit bounds and provide haptic feedback
        if newValue != value {
            if newValue == range.lowerBound || newValue == range.upperBound {
                impactFeedback.impactOccurred()
            }
            value = newValue
        }
    }

    private func handleDragEnd() {
        isDragging = false
        onEditingChanged?(false)

        // Scale thumb back to normal
        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
            thumbScale = 1.0
        }
    }

    // MARK: - Colors

    private var trackColor: Color {
        if let style = cardContext {
            // Inside a card - adapt track color based on card style
            switch style {
            case .pineTeal, .carbon:
                return WinnieColors.ivory.opacity(0.2)
            case .ivory, .ivoryBordered:
                return colorScheme == .dark
                    ? WinnieColors.ivory.opacity(0.15)
                    : WinnieColors.carbonBlack.opacity(0.15)
            }
        } else {
            // On background
            return WinnieColors.trackBackground(for: colorScheme)
        }
    }

    private var thumbBackgroundColor: Color {
        // Thumb fill - uses fill color but lighter/opaque
        if let style = cardContext {
            switch style {
            case .pineTeal, .carbon:
                return WinnieColors.ivory
            case .ivory, .ivoryBordered:
                return colorScheme == .dark ? WinnieColors.carbonBlack : WinnieColors.ivory
            }
        } else {
            return colorScheme == .dark ? WinnieColors.carbonBlack : WinnieColors.ivory
        }
    }

    private var thumbBorderColor: Color {
        // Thick border - Wispr Flow aesthetic
        if let style = cardContext {
            switch style {
            case .pineTeal, .carbon:
                return WinnieColors.ivory
            case .ivory, .ivoryBordered:
                return colorScheme == .dark ? WinnieColors.ivory : WinnieColors.carbonBlack
            }
        } else {
            return colorScheme == .dark ? WinnieColors.ivory : WinnieColors.carbonBlack
        }
    }
}

// MARK: - Previews

#Preview("Basic Slider") {
    struct PreviewWrapper: View {
        @State private var value: Decimal = 500

        var body: some View {
            VStack(spacing: WinnieSpacing.l) {
                Text("Value: $\(NSDecimalNumber(decimal: value).intValue)")
                    .font(WinnieTypography.headlineM())

                WinnieSlider(value: $value, in: 0...2000)
                    .padding(.horizontal, WinnieSpacing.l)
            }
            .padding(WinnieSpacing.l)
            .background(WinnieColors.porcelain)
        }
    }

    return PreviewWrapper()
}

#Preview("With Custom Color") {
    struct PreviewWrapper: View {
        @State private var value: Decimal = 750

        var body: some View {
            VStack(spacing: WinnieSpacing.l) {
                Text("Value: $\(NSDecimalNumber(decimal: value).intValue)")
                    .font(WinnieTypography.headlineM())

                WinnieSlider(
                    value: $value,
                    in: 0...1500,
                    step: 25,
                    fillColor: GoalPresetColor.teal.color
                )
                .padding(.horizontal, WinnieSpacing.l)
            }
            .padding(WinnieSpacing.l)
            .background(WinnieColors.porcelain)
        }
    }

    return PreviewWrapper()
}

#Preview("On Ivory Bordered Card") {
    struct PreviewWrapper: View {
        @State private var value: Decimal = 1000

        var body: some View {
            WinnieCard(style: .ivoryBordered) {
                VStack(alignment: .leading, spacing: WinnieSpacing.m) {
                    HStack {
                        Text("Monthly Allocation")
                            .font(WinnieTypography.bodyM())
                        Spacer()
                        Text("$\(NSDecimalNumber(decimal: value).intValue)")
                            .font(WinnieTypography.headlineS())
                    }
                    .contextPrimaryText()

                    WinnieSlider(value: $value, in: 0...2000)
                }
            }
            .padding(WinnieSpacing.l)
            .background(WinnieColors.porcelain)
        }
    }

    return PreviewWrapper()
}

#Preview("Multiple Sliders") {
    struct PreviewWrapper: View {
        @State private var house: Decimal = 800
        @State private var retirement: Decimal = 500
        @State private var vacation: Decimal = 200

        var body: some View {
            VStack(spacing: WinnieSpacing.m) {
                SliderRow(label: "House", value: $house, color: GoalPresetColor.coral.color)
                SliderRow(label: "Retirement", value: $retirement, color: GoalPresetColor.teal.color)
                SliderRow(label: "Vacation", value: $vacation, color: GoalPresetColor.gold.color)

                Divider()

                HStack {
                    Text("Total:")
                        .font(WinnieTypography.bodyM())
                    Spacer()
                    Text("$\(NSDecimalNumber(decimal: house + retirement + vacation).intValue)/mo")
                        .font(WinnieTypography.headlineS())
                }
            }
            .padding(WinnieSpacing.l)
            .background(WinnieColors.porcelain)
        }
    }

    struct SliderRow: View {
        let label: String
        @Binding var value: Decimal
        let color: Color

        var body: some View {
            VStack(alignment: .leading, spacing: WinnieSpacing.xs) {
                HStack {
                    Text(label)
                        .font(WinnieTypography.bodyM())
                    Spacer()
                    Text("$\(NSDecimalNumber(decimal: value).intValue)/mo")
                        .font(WinnieTypography.bodyS())
                        .foregroundColor(WinnieColors.carbonBlack.opacity(0.6))
                }

                WinnieSlider(value: $value, in: 0...1500, fillColor: color)
            }
        }
    }

    return PreviewWrapper()
}

#Preview("Dark Mode") {
    struct PreviewWrapper: View {
        @State private var value: Decimal = 600

        var body: some View {
            VStack(spacing: WinnieSpacing.l) {
                Text("Value: $\(NSDecimalNumber(decimal: value).intValue)")
                    .font(WinnieTypography.headlineM())
                    .foregroundColor(WinnieColors.ivory)

                WinnieSlider(value: $value, in: 0...2000)
                    .padding(.horizontal, WinnieSpacing.l)
            }
            .padding(WinnieSpacing.l)
            .background(WinnieColors.onyx)
            .preferredColorScheme(.dark)
        }
    }

    return PreviewWrapper()
}

#Preview("Dark Mode on Card") {
    struct PreviewWrapper: View {
        @State private var value: Decimal = 800

        var body: some View {
            WinnieCard(style: .ivoryBordered) {
                VStack(alignment: .leading, spacing: WinnieSpacing.m) {
                    HStack {
                        Text("Monthly Allocation")
                            .font(WinnieTypography.bodyM())
                        Spacer()
                        Text("$\(NSDecimalNumber(decimal: value).intValue)")
                            .font(WinnieTypography.headlineS())
                    }
                    .contextPrimaryText()

                    WinnieSlider(value: $value, in: 0...2000)
                }
            }
            .padding(WinnieSpacing.l)
            .background(WinnieColors.onyx)
            .preferredColorScheme(.dark)
        }
    }

    return PreviewWrapper()
}
