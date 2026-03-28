import SwiftUI

/// Tap tiles from the bank to build the correct sentence.
struct SentenceTilesView: View {
    let tiles: [String]         // correct order
    let shuffled: [String]      // starting order shown in bank
    let translation: String
    let onAnswer: (Bool) -> Void

    @State private var bank: [TileItem]       // tiles still available to tap
    @State private var answer: [TileItem]     // tiles placed by the user
    @State private var feedbackState: FeedbackState = .idle

    enum FeedbackState { case idle, correct, wrong }

    struct TileItem: Identifiable {
        let id = UUID()
        let text: String
    }

    init(tiles: [String], shuffled: [String], translation: String, onAnswer: @escaping (Bool) -> Void) {
        self.tiles = tiles
        self.shuffled = shuffled
        self.translation = translation
        self.onAnswer = onAnswer
        _bank = State(initialValue: shuffled.map { TileItem(text: $0) })
        _answer = State(initialValue: [])
    }

    var body: some View {
        VStack(spacing: 28) {
            // Prompt
            VStack(spacing: 4) {
                Text("Build the sentence")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .textCase(.uppercase)
                    .tracking(0.8)
                Text(translation)
                    .font(.title3)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.center)
            }

            // Answer tray
            answerTray

            Divider()
                .padding(.horizontal, 24)

            // Tile bank
            tileBank

            // Submit button
            if !answer.isEmpty {
                Button(action: submit) {
                    Text("Check")
                        .font(.headline)
                        .frame(maxWidth: 240, minHeight: 52)
                }
                .buttonStyle(.borderedProminent)
                .tint(feedbackColor)
                .disabled(feedbackState != .idle)
                .transition(.move(edge: .bottom).combined(with: .opacity))
                .animation(.spring(), value: answer.isEmpty)
            }
        }
        .padding(.horizontal, 32)
    }

    // MARK: - Answer tray

    private var answerTray: some View {
        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: 14)
                .fill(feedbackBackground)
                .frame(maxWidth: .infinity, minHeight: 64)

            if answer.isEmpty {
                Text("Tap words below to build the sentence")
                    .font(.subheadline)
                    .foregroundStyle(.tertiary)
                    .padding(.horizontal, 16)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(answer) { tile in
                            TileView(text: tile.text, style: .placed(feedbackState: feedbackState)) {
                                returnToBank(tile)
                            }
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                }
            }
        }
        .frame(maxWidth: 600)
        .animation(.spring(response: 0.3), value: answer.map { $0.id })
    }

    // MARK: - Tile bank

    private var tileBank: some View {
        FlowLayout(spacing: 10) {
            ForEach(bank) { tile in
                TileView(text: tile.text, style: .bank) {
                    placeInAnswer(tile)
                }
            }
        }
        .frame(maxWidth: 600)
        .animation(.spring(response: 0.3), value: bank.map { $0.id })
    }

    // MARK: - Logic

    private func placeInAnswer(_ tile: TileItem) {
        guard feedbackState == .idle else { return }
        bank.removeAll { $0.id == tile.id }
        answer.append(tile)
    }

    private func returnToBank(_ tile: TileItem) {
        guard feedbackState == .idle else { return }
        answer.removeAll { $0.id == tile.id }
        bank.append(tile)
    }

    private func submit() {
        let isCorrect = answer.map { $0.text } == tiles
        feedbackState = isCorrect ? .correct : .wrong
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
            onAnswer(isCorrect)
        }
    }

    private var feedbackColor: Color {
        switch feedbackState {
        case .idle:    return .accentColor
        case .correct: return .green
        case .wrong:   return .red
        }
    }

    private var feedbackBackground: Color {
        switch feedbackState {
        case .idle:    return Color(.secondarySystemBackground)
        case .correct: return .green.opacity(0.12)
        case .wrong:   return .red.opacity(0.12)
        }
    }
}

// MARK: - Tile view

enum TileStyle {
    case bank
    case placed(feedbackState: SentenceTilesView.FeedbackState)
}

struct TileView: View {
    let text: String
    let style: TileStyle
    let onTap: () -> Void

    private var background: Color {
        switch style {
        case .bank: return Color(.tertiarySystemBackground)
        case .placed(let state):
            switch state {
            case .idle:    return .accentColor.opacity(0.12)
            case .correct: return .green.opacity(0.15)
            case .wrong:   return .red.opacity(0.15)
            }
        }
    }

    var body: some View {
        Button(action: onTap) {
            Text(text)
                .font(.system(size: 22, weight: .medium))
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(background, in: RoundedRectangle(cornerRadius: 10))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .strokeBorder(Color.primary.opacity(0.08), lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - FlowLayout (wrapping HStack)

struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let maxWidth = proposal.width ?? .infinity
        var x: CGFloat = 0
        var y: CGFloat = 0
        var rowHeight: CGFloat = 0
        var totalHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > maxWidth, x > 0 {
                x = 0
                y += rowHeight + spacing
                totalHeight = y
                rowHeight = 0
            }
            x += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }
        totalHeight += rowHeight
        return CGSize(width: maxWidth, height: totalHeight)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let maxWidth = bounds.width
        var x = bounds.minX
        var y = bounds.minY
        var rowHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > bounds.maxX, x > bounds.minX {
                x = bounds.minX
                y += rowHeight + spacing
                rowHeight = 0
            }
            subview.place(at: CGPoint(x: x, y: y), proposal: ProposedViewSize(size))
            x += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }
    }
}
