import SwiftUI
import SwiftData

struct LessonRunnerView: View {
    let lesson: LessonContent
    let unitColor: Color
    let allWords: [Word]

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query private var lessonRecords: [UserLessonRecord]
    @Query private var profiles: [UserProfile]

    @State private var exercises: [Exercise] = []
    @State private var currentIndex = 0
    @State private var correct = 0
    @State private var incorrect = 0
    @State private var feedbackMessage: String?
    @State private var feedbackIsCorrect = false
    @State private var showingFeedback = false
    @State private var isDone = false

    private var currentExercise: Exercise? {
        guard currentIndex < exercises.count else { return nil }
        return exercises[currentIndex]
    }

    var body: some View {
        NavigationStack {
            Group {
                if isDone {
                    LessonSummaryView(
                        lessonTitle: lesson.title,
                        correct: correct,
                        total: correct + incorrect,
                        unitColor: unitColor,
                        onDone: { dismiss() }
                    )
                } else if exercises.isEmpty {
                    ProgressView("Preparing exercises…")
                } else {
                    lessonBody
                }
            }
            .navigationTitle(lesson.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Quit") { dismiss() }
                }
            }
        }
        .onAppear { buildExercises() }
    }

    // MARK: - Main lesson body

    private var lessonBody: some View {
        VStack(spacing: 0) {
            // Progress bar
            progressHeader
                .padding(.horizontal, 24)
                .padding(.top, 16)
                .padding(.bottom, 24)

            // Exercise content
            ScrollView {
                VStack {
                    if let exercise = currentExercise {
                        exerciseView(for: exercise)
                            .transition(.asymmetric(
                                insertion: .move(edge: .trailing).combined(with: .opacity),
                                removal: .move(edge: .leading).combined(with: .opacity)
                            ))
                            .id(exercise.id)
                    }
                }
                .padding(.vertical, 8)
            }

            // Feedback banner
            if showingFeedback {
                feedbackBanner
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .background(Color(.systemGroupedBackground))
        .animation(.easeInOut(duration: 0.25), value: showingFeedback)
    }

    // MARK: - Progress header

    private var progressHeader: some View {
        VStack(spacing: 6) {
            ProgressView(value: Double(currentIndex), total: Double(max(exercises.count, 1)))
                .tint(unitColor)
                .scaleEffect(x: 1, y: 1.5)
            HStack {
                Text("\(currentIndex)/\(exercises.count)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
                Label("\(correct)", systemImage: "checkmark")
                    .font(.caption).foregroundStyle(.green)
                    .padding(.horizontal, 4)
                Label("\(incorrect)", systemImage: "xmark")
                    .font(.caption).foregroundStyle(.red)
            }
        }
    }

    // MARK: - Feedback banner

    private var feedbackBanner: some View {
        HStack(spacing: 12) {
            Image(systemName: feedbackIsCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                .font(.title2)
                .foregroundStyle(feedbackIsCorrect ? .green : .red)
            Text(feedbackMessage ?? "")
                .font(.headline)
                .foregroundStyle(feedbackIsCorrect ? .green : .red)
            Spacer()
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 16)
        .background(
            (feedbackIsCorrect ? Color.green : Color.red).opacity(0.1)
        )
    }

    // MARK: - Exercise routing

    @ViewBuilder
    private func exerciseView(for exercise: Exercise) -> some View {
        switch exercise.kind {
        case .hanziToEnglish(let word, let options):
            HanziToEnglishView(word: word, options: options) { isCorrect in
                handleAnswer(isCorrect, correctLabel: word.english)
            }

        case .englishToHanzi(let word, let options):
            EnglishToHanziView(word: word, options: options) { isCorrect in
                handleAnswer(isCorrect, correctLabel: word.hanzi)
            }

        case .sentenceTiles(let tiles, let shuffled, let translation):
            SentenceTilesView(tiles: tiles, shuffled: shuffled, translation: translation) { isCorrect in
                handleAnswer(isCorrect, correctLabel: tiles.joined())
            }
        }
    }

    // MARK: - Logic

    private func buildExercises() {
        exercises = ExerciseGenerator.exercises(for: lesson, allWords: allWords)
    }

    private func handleAnswer(_ isCorrect: Bool, correctLabel: String) {
        if isCorrect {
            correct += 1
            feedbackMessage = "Correct! 🎉"
        } else {
            incorrect += 1
            feedbackMessage = "Answer: \(correctLabel)"
        }
        feedbackIsCorrect = isCorrect

        withAnimation { showingFeedback = true }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            withAnimation { showingFeedback = false }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                advance()
            }
        }
    }

    private func advance() {
        if currentIndex + 1 >= exercises.count {
            finishLesson()
        } else {
            withAnimation { currentIndex += 1 }
        }
    }

    private func finishLesson() {
        let total = correct + incorrect
        let score = total > 0 ? Int(Double(correct) / Double(total) * 100) : 0

        // Persist lesson record
        let record: UserLessonRecord
        if let existing = lessonRecords.first(where: { $0.lessonID == lesson.id }) {
            record = existing
        } else {
            let new = UserLessonRecord(lessonID: lesson.id)
            modelContext.insert(new)
            record = new
        }
        record.recordAttempt(score: score)

        // Award XP
        profiles.first?.totalXP += correct * 10
        profiles.first?.recordActivity()

        try? modelContext.save()
        withAnimation { isDone = true }
    }
}
