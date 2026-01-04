import SwiftUI

/// A segmented progress bar for the onboarding wizard flow.
///
/// Displays progress as a thin horizontal bar with filled segments
/// representing completed steps. Animates smoothly between steps.
struct OnboardingProgressBar: View {

    /// Current step index (1-based for display purposes)
    let currentStep: Int

    /// Total number of steps in the flow
    let totalSteps: Int

    @Environment(\.colorScheme) private var colorScheme

    /// Bar height in points
    private let barHeight: CGFloat = 4

    /// Corner radius for the bar
    private let cornerRadius: CGFloat = 2

    /// Progress as a fraction (0.0 to 1.0)
    private var progress: CGFloat {
        guard totalSteps > 0 else { return 0 }
        return CGFloat(currentStep) / CGFloat(totalSteps)
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Background track
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(WinnieColors.progressBackground(for: colorScheme))
                    .frame(height: barHeight)

                // Filled progress
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(WinnieColors.accent)
                    .frame(width: geometry.size.width * progress, height: barHeight)
                    .animation(.easeInOut(duration: 0.3), value: currentStep)
            }
        }
        .frame(height: barHeight)
    }
}

// MARK: - Previews

#Preview("Progress Bar - Step 1 of 8") {
    VStack(spacing: 20) {
        OnboardingProgressBar(currentStep: 1, totalSteps: 8)
        OnboardingProgressBar(currentStep: 4, totalSteps: 8)
        OnboardingProgressBar(currentStep: 8, totalSteps: 8)
    }
    .padding()
}

#Preview("Progress Bar - Dark Mode") {
    VStack(spacing: 20) {
        OnboardingProgressBar(currentStep: 1, totalSteps: 8)
        OnboardingProgressBar(currentStep: 4, totalSteps: 8)
        OnboardingProgressBar(currentStep: 8, totalSteps: 8)
    }
    .padding()
    .background(WinnieColors.ink)
    .preferredColorScheme(.dark)
}

#Preview("Interactive Progress") {
    struct InteractivePreview: View {
        @State private var step = 1
        
        var body: some View {
            VStack(spacing: 40) {
                OnboardingProgressBar(currentStep: step, totalSteps: 8)
                    .padding(.horizontal)
                
                Text("Step \(step) of 8")
                    .font(.headline)
                
                HStack(spacing: 20) {
                    Button("Previous") {
                        if step > 1 { step -= 1 }
                    }
                    .disabled(step <= 1)
                    
                    Button("Next") {
                        if step < 8 { step += 1 }
                    }
                    .disabled(step >= 8)
                }
            }
            .padding()
        }
    }
    
    return InteractivePreview()
}
