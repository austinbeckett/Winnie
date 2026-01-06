import SwiftUI

/// A message in the iMessage-style conversation.
struct ChatMessage: Identifiable {
    let id = UUID()
    let text: String
    let isFromMe: Bool  // true = right/purple (sent), false = left/gray (received)
}

/// An iMessage-style conversation view with animated message appearance.
///
/// Displays a floating Messages-app-style conversation with:
/// - A header showing contact name and avatar
/// - Alternating message bubbles (left/right alignment)
/// - Typing indicator before received messages
/// - Auto-play animation that becomes scrollable after completion
struct iMessageConversationView: View {

    let messages: [ChatMessage]
    let contactName: String
    let contactEmoji: String

    @Environment(\.colorScheme) private var colorScheme

    // Animation state
    @State private var visibleMessageCount = 0
    @State private var showTypingIndicator = false
    @State private var animationComplete = false

    // Timing constants
    private let messageDelay: Double = 1.2
    private let typingDuration: Double = 0.8

    var body: some View {
        VStack(spacing: 0) {
            // Header
            conversationHeader

            Divider()
                .background(WinnieColors.border(for: colorScheme))

            // Messages area
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: WinnieSpacing.s) {
                        ForEach(Array(messages.prefix(visibleMessageCount).enumerated()), id: \.element.id) { index, message in
                            MessageBubble(
                                message: message,
                                colorScheme: colorScheme
                            )
                            .id(index)
                            .transition(.asymmetric(
                                insertion: .opacity.combined(with: .move(edge: .bottom)),
                                removal: .opacity
                            ))
                        }

                        // Typing indicator
                        if showTypingIndicator {
                            TypingIndicator(colorScheme: colorScheme)
                                .transition(.opacity)
                                .id("typing")
                        }

                        // Bottom spacer for scroll padding
                        Color.clear
                            .frame(height: 3)
                            .id("bottomSpacer")
                    }
                    .padding(.horizontal, WinnieSpacing.m)
                    .padding(.vertical, WinnieSpacing.s)
                }
                .scrollDisabled(!animationComplete)
                .onChange(of: visibleMessageCount) { _, _ in
                    withAnimation(.easeOut(duration: 0.3)) {
                        proxy.scrollTo("bottomSpacer", anchor: .bottom)
                    }
                }
                .onChange(of: showTypingIndicator) { _, isShowing in
                    if isShowing {
                        withAnimation(.easeOut(duration: 0.3)) {
                            proxy.scrollTo("bottomSpacer", anchor: .bottom)
                        }
                    }
                }
            }
        }
        .background(WinnieColors.background(for: colorScheme))
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(WinnieColors.border(for: colorScheme), lineWidth: 1)
        )
        .shadow(color: WinnieColors.cardShadow(for: colorScheme), radius: 10, x: 0, y: 4)
        .onAppear {
            startAnimation()
        }
    }

    // MARK: - Header

    private var conversationHeader: some View {
        HStack(spacing: WinnieSpacing.s) {
            // Back chevron
            Image(systemName: "chevron.left")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(WinnieColors.accent)

            Spacer()

            // Contact info
            VStack(spacing: 2) {
                // Avatar placeholder
                ZStack {
                    Circle()
                        .fill(WinnieColors.cardBackground(for: colorScheme))
                        .frame(width: 36, height: 36)

                    Text(contactEmoji)
                        .font(.system(size: 18))
                }

                Text(contactName)
                    .font(WinnieTypography.bodyS())
                    .foregroundColor(WinnieColors.primaryText(for: colorScheme))
            }

            Spacer()

            // Placeholder for symmetry (video call icon area)
            Image(systemName: "video")
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(WinnieColors.accent)
                .opacity(0.5)
        }
        .padding(.horizontal, WinnieSpacing.m)
        .padding(.vertical, WinnieSpacing.s)
    }

    // MARK: - Animation

    // MARK: - Animation

    private func startAnimation() {
        guard !animationComplete else { return }

        var accumulatedDelay: Double = 0.5
        let readingDelay: Double = 2.0 // Time to read a received message before replying

        for (index, message) in messages.enumerated() {
            // Determine delay for this message
            if index > 0 {
                let previousMessage = messages[index - 1]
                
                // If switching from Received -> Sent, add extra reading time
                if !previousMessage.isFromMe && message.isFromMe {
                    accumulatedDelay += readingDelay
                } else {
                    accumulatedDelay += messageDelay
                }
            }

            // Capture wait time for this specific message
            let waitTime = accumulatedDelay

            // Show typing indicator before received messages
            if !message.isFromMe {
                DispatchQueue.main.asyncAfter(deadline: .now() + waitTime) {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        showTypingIndicator = true
                    }
                }
                
                // Typing duration adds to the delay for the message appearance itself
                let appearanceTime = waitTime + typingDuration
                
                DispatchQueue.main.asyncAfter(deadline: .now() + appearanceTime) {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        showTypingIndicator = false
                    }
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                        visibleMessageCount = index + 1
                    }
                }
                
                // Advance accumulated delay by typing duration for the NEXT message calculation
                // so the next message doesn't start until this one finishes appearing
                accumulatedDelay += typingDuration
                
            } else {
                // Sent messages appear without typing indicator
                DispatchQueue.main.asyncAfter(deadline: .now() + waitTime) {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                        visibleMessageCount = index + 1
                    }
                }
            }
        }

        // Mark animation complete
        DispatchQueue.main.asyncAfter(deadline: .now() + accumulatedDelay + 1.0) {
            animationComplete = true
        }
    }
}

// MARK: - Message Bubble

private struct MessageBubble: View {
    let message: ChatMessage
    let colorScheme: ColorScheme

    var body: some View {
        HStack {
            if message.isFromMe {
                Spacer(minLength: 60)
            }

            Text(message.text)
                .font(WinnieTypography.bodyM())
                .foregroundColor(bubbleTextColor)
                .padding(.horizontal, WinnieSpacing.m)
                .padding(.vertical, WinnieSpacing.s)
                .background(bubbleBackground)
                .clipShape(BubbleShape(isFromMe: message.isFromMe))

            if !message.isFromMe {
                Spacer(minLength: 60)
            }
        }
    }

    private var bubbleBackground: Color {
        message.isFromMe
            ? WinnieColors.sweetSalmon  // Sent messages: warm coral
            : WinnieColors.pineTeal     // Received messages: deep teal
    }

    private var bubbleTextColor: Color {
        message.isFromMe
            ? WinnieColors.carbonBlack  // Dark text on light coral
            : WinnieColors.ivory        // Light text on dark teal
    }
}

// MARK: - Bubble Shape

// MARK: - Bubble Shape

private struct BubbleShape: Shape {
    let isFromMe: Bool

    func path(in rect: CGRect) -> Path {
        let width = rect.width
        let height = rect.height

        // Authentic iOS metrics
        let tailWidth: CGFloat = 6
        let radius: CGFloat = 18

        var path = Path()

        if isFromMe {
            // Right-aligned bubble (Sent)
            let bodyWidth = width - tailWidth

            // Start top-left
            path.move(to: CGPoint(x: radius, y: 0))

            // Box top
            path.addLine(to: CGPoint(x: bodyWidth - radius, y: 0))
            path.addQuadCurve(
                to: CGPoint(x: bodyWidth, y: radius),
                control: CGPoint(x: bodyWidth, y: 0)
            )

            // Right side down to near tail start
            // The tail starts curving from (bodyWidth, height - 20) roughly
            path.addLine(to: CGPoint(x: bodyWidth, y: height - 20))

            // Tail curve
            // 1. Curve down and out to the tip
            // This curve creates the smooth "S" transition
            path.addCurve(
                to: CGPoint(x: width, y: height),
                control1: CGPoint(x: bodyWidth, y: height - 8),
                control2: CGPoint(x: width - 5, y: height)
            )
            // 2. Curve back in to the bottom edge
            // This is the sharp return
            path.addCurve(
                to: CGPoint(x: bodyWidth - 12, y: height),
                control1: CGPoint(x: width - 2, y: height),
                control2: CGPoint(x: bodyWidth - 2, y: height)
            )

            // Box bottom
            path.addLine(to: CGPoint(x: radius, y: height))
            path.addQuadCurve(
                to: CGPoint(x: 0, y: height - radius),
                control: CGPoint(x: 0, y: height)
            )

            // Left side
            path.addLine(to: CGPoint(x: 0, y: radius))
            path.addQuadCurve(
                to: CGPoint(x: radius, y: 0),
                control: CGPoint(x: 0, y: 0)
            )

        } else {
            // Left-aligned bubble (Received)
            
            // Start at top-left of BODY (skipping tail for now)
            path.move(to: CGPoint(x: tailWidth + radius, y: 0))

            // Top line to right corner
            path.addLine(to: CGPoint(x: width - radius, y: 0))
            path.addQuadCurve(
                to: CGPoint(x: width, y: radius),
                control: CGPoint(x: width, y: 0)
            )

            // Right side
            path.addLine(to: CGPoint(x: width, y: height - radius))
            path.addQuadCurve(
                to: CGPoint(x: width - radius, y: height),
                control: CGPoint(x: width, y: height)
            )

            // Bottom line to near tail
            path.addLine(to: CGPoint(x: tailWidth + 12, y: height))

            // Tail curve
            // 1. Curve out to the tip (bottom-left)
            // Sharp turn out
            path.addCurve(
                to: CGPoint(x: 0, y: height),
                control1: CGPoint(x: tailWidth + 2, y: height),
                control2: CGPoint(x: 2, y: height)
            )
            // 2. Curve up and in to the left side
            // Smooth transition back to vertical
            path.addCurve(
                to: CGPoint(x: tailWidth, y: height - 20),
                control1: CGPoint(x: 5, y: height),
                control2: CGPoint(x: tailWidth, y: height - 8)
            )

            // Left side up
            path.addLine(to: CGPoint(x: tailWidth, y: radius))
            path.addQuadCurve(
                to: CGPoint(x: tailWidth + radius, y: 0),
                control: CGPoint(x: tailWidth, y: 0)
            )
        }

        path.closeSubpath()
        return path
    }
}

// MARK: - Typing Indicator

private struct TypingIndicator: View {
    let colorScheme: ColorScheme

    @State private var animatingDot = 0

    var body: some View {
        HStack {
            HStack(spacing: 4) {
                ForEach(0..<3, id: \.self) { index in
                    Circle()
                        .fill(WinnieColors.ivory.opacity(0.6))
                        .frame(width: 8, height: 8)
                        .scaleEffect(animatingDot == index ? 1.2 : 0.8)
                        .animation(
                            .easeInOut(duration: 0.4)
                                .repeatForever(autoreverses: true)
                                .delay(Double(index) * 0.15),
                            value: animatingDot
                        )
                }
            }
            .padding(.horizontal, WinnieSpacing.m)
            .padding(.vertical, WinnieSpacing.s)
            .background(WinnieColors.pineTeal)
            .clipShape(BubbleShape(isFromMe: false))

            Spacer(minLength: 60)
        }
        .onAppear {
            animatingDot = 1
        }
    }
}

// MARK: - Previews

#Preview("Conversation Animation") {
    let messages: [ChatMessage] = [
        ChatMessage(text: "I think we should go all-in on saving for our house.", isFromMe: true),
        ChatMessage(text: "But what about traveling? We said we'd go to Italy before we turn 30.", isFromMe: false),
        ChatMessage(text: "I know, but maybe we can push that back a year or two?", isFromMe: true),
        ChatMessage(text: "And what about the wedding? We haven't even started saving for that yet.", isFromMe: false),
        ChatMessage(text: "Ugh, you're right. And if we have kids soon after...", isFromMe: true),
        ChatMessage(text: "Are we even saving enough for retirement with all of this?", isFromMe: false),
        ChatMessage(text: "I honestly have no idea...", isFromMe: true)
    ]

    iMessageConversationView(
        messages: messages,
        contactName: "Partner 💕",
        contactEmoji: "💜"
    )
    .frame(height: 450)
    .padding()
}

#Preview("Dark Mode") {
    let messages: [ChatMessage] = [
        ChatMessage(text: "I think we should go all-in on saving for our house.", isFromMe: true),
        ChatMessage(text: "But what about traveling?", isFromMe: false),
        ChatMessage(text: "I know, but maybe we can push that back?", isFromMe: true)
    ]

    iMessageConversationView(
        messages: messages,
        contactName: "Partner 💕",
        contactEmoji: "💜"
    )
    .frame(height: 350)
    .padding()
    .preferredColorScheme(.dark)
}
