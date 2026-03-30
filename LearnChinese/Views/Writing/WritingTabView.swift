import SwiftUI
import SwiftData

struct WritingTabView: View {
    @Query(sort: \Word.sortOrder) private var words: [Word]
    @Query private var records: [UserWordRecord]

    @State private var selectedWord: Word?
    @State private var filter: WritingFilter = .due

    enum WritingFilter: String, CaseIterable {
        case due = "Due"
        case all = "All Learned"
        case mastered = "Mastered"
    }

    private var recordMap: [UUID: UserWordRecord] {
        Dictionary(uniqueKeysWithValues: records.map { ($0.wordID, $0) })
    }

    /// Only show words the user has learned in the reading SRS.
    private var learnedWords: [Word] {
        words.filter { recordMap[$0.id]?.isLearned == true }
    }

    private var filteredWords: [Word] {
        switch filter {
        case .due:
            return learnedWords.filter {
                let r = recordMap[$0.id]
                return r?.isWritingDueNow == true || r?.isWritingLearned == false
            }
        case .all:
            return learnedWords
        case .mastered:
            return learnedWords.filter { recordMap[$0.id]?.isWritingLearned == true }
        }
    }

    private var dueCount: Int {
        learnedWords.filter {
            let r = recordMap[$0.id]
            return r?.isWritingDueNow == true || r?.isWritingLearned == false
        }.count
    }

    var body: some View {
        NavigationSplitView {
            listContent
                .navigationTitle("Writing")
        } detail: {
            if let word = selectedWord {
                WritingSessionView(word: word)
            } else {
                emptyDetail
            }
        }
    }

    // MARK: - List

    private var listContent: some View {
        VStack(spacing: 0) {
            // Filter
            Picker("Filter", selection: $filter) {
                ForEach(WritingFilter.allCases, id: \.self) { f in
                    Text(f.rawValue).tag(f)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)

            Divider()

            if filteredWords.isEmpty {
                emptyListState
            } else {
                List(filteredWords, selection: $selectedWord) { word in
                    WritingWordRow(word: word, record: recordMap[word.id])
                        .tag(word)
                }
                .listStyle(.insetGrouped)
            }
        }
    }

    // MARK: - Empty states

    private var emptyDetail: some View {
        VStack(spacing: 16) {
            Image(systemName: "pencil.tip.crop.circle")
                .font(.system(size: 64))
                .foregroundStyle(.secondary)
            Text("Select a character to practice writing")
                .font(.title3)
                .foregroundStyle(.secondary)
            Text("Characters unlock for writing once you've learned them in flashcard review.")
                .font(.subheadline)
                .foregroundStyle(.tertiary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 340)
        }
        .padding()
    }

    private var emptyListState: some View {
        ContentUnavailableView(
            filter == .due ? "Nothing Due" : "No Characters",
            systemImage: filter == .due ? "checkmark.circle.fill" : "tray.fill",
            description: Text(filter == .due
                ? "All writing is up to date! Come back later."
                : "Learn words in the Flashcards tab first.")
        )
    }
}

// MARK: - Writing word row

struct WritingWordRow: View {
    let word: Word
    let record: UserWordRecord?

    private var writingStatus: (label: String, color: Color) {
        guard let r = record, r.isWritingLearned else { return ("New", .purple) }
        if r.isWritingDueNow { return ("Due", .blue) }
        return ("Mastered", .green)
    }

    private var strokeCount: Int? {
        StrokeDataLoader.shared.strokeCount(for: word.hanzi)
    }

    var body: some View {
        HStack(spacing: 14) {
            Text(word.hanzi)
                .font(.system(size: 40, weight: .medium))
                .frame(width: 56, alignment: .center)

            VStack(alignment: .leading, spacing: 3) {
                Text(word.pinyin)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Text(word.english)
                    .font(.body)
                    .fontWeight(.medium)
                    .lineLimit(1)
                if let sc = strokeCount {
                    Text("\(sc) stroke\(sc == 1 ? "" : "s")")
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }
            }

            Spacer()

            // Writing accuracy badge
            VStack(spacing: 2) {
                Text(writingStatus.label)
                    .font(.caption2)
                    .fontWeight(.semibold)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(writingStatus.color.opacity(0.15), in: Capsule())
                    .foregroundStyle(writingStatus.color)

                if let r = record, r.isWritingLearned, r.writingTimesCorrect + r.writingTimesIncorrect > 0 {
                    Text("\(r.writingAccuracyPercent)%")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(.vertical, 6)
    }
}
