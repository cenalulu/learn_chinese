import SwiftUI
import SwiftData

struct FlashcardSessionView: View {
    enum Mode { case review, learn }

    let mode: Mode

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query private var words: [Word]
    @Query private var records: [UserWordRecord]
    @Query private var profiles: [UserProfile]

    @State private var queue: [Word] = []
    @State private var currentIndex: Int = 0
    @State private var isFlipped = false
    @State private var sessionCorrect = 0
    @State private var sessionIncorrect = 0
    @State private var isSessionDone = false
    @State private var cardOffset: CGFloat = 0
    @State private var cardOpacity: Double = 1

    private var profile: UserProfile? { profiles.first }

    private var currentWord: Word? {
        guard currentIndex < queue.count else { return nil }
        return queue[currentIndex]
    }

    var body: some View {
        NavigationStack {
            Group {
                if isSessionDone {
                    summaryView
                } else if queue.isEmpty {
                    emptyView
                } else {
                    sessionView
                }
            }
            .navigationTitle(mode == .review ? "Review" : "Learn New Words")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("End Session") { dismiss() }
                }
            }
        }
        .onAppear(perform: buildQueue)
    }

    // MARK: - Session view

    private var sessionView: some View {
        VStack(spacing: 0) {
            progressBar
                .padding(.horizontal, 24)
                .padding(.top, 16)

            Spacer()

            if let word = currentWord {
                FlashcardCardView(
                    word: word,
                    isFlipped: isFlipped,
                    onAudio: { AudioService.shared.speak(word.hanzi) }
                )
                .padding(.horizontal, 32)
                .offset(x: cardOffset)
                .opacity(cardOpacity)
                .onTapGesture { flipCard() }
            }

            Spacer()

            if isFlipped {
                answerButtons
                    .padding(.horizontal, 32)
                    .padding(.bottom, 32)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            } else {
                Text("Tap card to reveal")
                    .font(.subheadline)
                    .foregroundStyle(.tertiary)
                    .padding(.bottom, 32)
            }
        }
        .background(Color(.systemGroupedBackground))
        .animation(.easeInOut(duration: 0.25), value: isFlipped)
    }

    // MARK: - Progress bar

    private var progressBar: some View {
        VStack(spacing: 6) {
            ProgressView(value: Double(currentIndex), total: Double(max(queue.count, 1)))
                .tint(.blue)
                .scaleEffect(x: 1, y: 1.5)
            HStack {
                Text("\(currentIndex) / \(queue.count)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
                Label("\(sessionCorrect)", systemImage: "checkmark")
                    .font(.caption)
                    .foregroundStyle(.green)
                    .padding(.horizontal, 6)
                Label("\(sessionIncorrect)", systemImage: "xmark")
                    .font(.caption)
                    .foregroundStyle(.red)
            }
        }
    }

    // MARK: - Answer buttons

    private var answerButtons: some View {
        HStack(spacing: 16) {
            Button {
                recordAnswer(.incorrect)
            } label: {
                Label("Still Learning", systemImage: "arrow.circlepath")
                    .font(.headline)
                    .frame(maxWidth: .infinity, minHeight: 60)
            }
            .buttonStyle(.bordered)
            .tint(.orange)

            Button {
                recordAnswer(.correct)
            } label: {
                Label("Know It", systemImage: "checkmark")
                    .font(.headline)
                    .frame(maxWidth: .infinity, minHeight: 60)
            }
            .buttonStyle(.borderedProminent)
            .tint(.green)
        }
    }

    // MARK: - Summary view

    private var summaryView: some View {
        VStack(spacing: 32) {
            Spacer()

            Image(systemName: "star.fill")
                .font(.system(size: 64))
                .foregroundStyle(.yellow)

            VStack(spacing: 8) {
                Text("Session Complete!")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                Text("You reviewed \(sessionCorrect + sessionIncorrect) cards")
                    .font(.title3)
                    .foregroundStyle(.secondary)
            }

            HStack(spacing: 40) {
                VStack(spacing: 4) {
                    Text("\(sessionCorrect)")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundStyle(.green)
                    Text("Correct")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                VStack(spacing: 4) {
                    Text("\(sessionIncorrect)")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundStyle(.orange)
                    Text("Still learning")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(24)
            .background(.background, in: RoundedRectangle(cornerRadius: 16))

            Spacer()

            Button("Done") { dismiss() }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .padding(.bottom, 32)
        }
        .padding(32)
        .background(Color(.systemGroupedBackground))
    }

    // MARK: - Empty view

    private var emptyView: some View {
        ContentUnavailableView(
            mode == .review ? "Nothing to Review" : "No New Words",
            systemImage: mode == .review ? "checkmark.circle.fill" : "tray.fill",
            description: Text(mode == .review
                ? "You're all caught up! Come back later."
                : "You've seen all available words.")
        )
    }

    // MARK: - Logic

    private func buildQueue() {
        let limit = profile?.dailyNewWordLimit ?? 10
        switch mode {
        case .review:
            queue = SRSService.dueWords(records: records, words: words)
        case .learn:
            queue = SRSService.newWords(records: records, words: words, limit: limit)
        }
        currentIndex = 0
        isFlipped = false
    }

    private func flipCard() {
        guard !isFlipped else { return }
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            isFlipped = true
        }
        if let word = currentWord {
            AudioService.shared.speak(word.hanzi)
        }
    }

    private func recordAnswer(_ result: SRSService.ReviewResult) {
        guard let word = currentWord else { return }

        // Get or create the SRS record
        let record: UserWordRecord
        if let existing = records.first(where: { $0.wordID == word.id }) {
            record = existing
        } else {
            let new = UserWordRecord(wordID: word.id)
            modelContext.insert(new)
            record = new
        }

        SRSService.processReview(record: record, result: result)

        switch result {
        case .correct: sessionCorrect += 1
        case .incorrect: sessionIncorrect += 1
        }

        profile?.recordActivity()
        profile?.totalXP += (result == .correct ? 5 : 1)

        try? modelContext.save()

        advanceCard()
    }

    private func advanceCard() {
        withAnimation(.easeInOut(duration: 0.2)) {
            cardOpacity = 0
            cardOffset = -40
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.22) {
            cardOffset = 40
            isFlipped = false
            currentIndex += 1

            if currentIndex >= queue.count {
                isSessionDone = true
            }

            withAnimation(.easeInOut(duration: 0.2)) {
                cardOpacity = 1
                cardOffset = 0
            }
        }
    }
}
