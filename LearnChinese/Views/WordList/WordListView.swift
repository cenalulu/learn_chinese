import SwiftUI
import SwiftData

struct WordListView: View {
    @Query(sort: \Word.sortOrder) private var words: [Word]
    @Query private var records: [UserWordRecord]

    @State private var searchText = ""
    @State private var selectedFilter: WordFilter = .all
    @State private var selectedWord: Word?

    enum WordFilter: String, CaseIterable {
        case all = "All"
        case learned = "Learned"
        case due = "Due"
        case new = "New"
    }

    private var recordMap: [UUID: UserWordRecord] {
        Dictionary(uniqueKeysWithValues: records.map { ($0.wordID, $0) })
    }

    private var filteredWords: [Word] {
        var result = words

        // Apply filter
        switch selectedFilter {
        case .all: break
        case .learned:
            result = result.filter { recordMap[$0.id]?.isLearned == true }
        case .due:
            result = result.filter { recordMap[$0.id]?.isDueNow == true }
        case .new:
            result = result.filter { recordMap[$0.id] == nil }
        }

        // Apply search
        if !searchText.isEmpty {
            let q = searchText.lowercased()
            result = result.filter {
                $0.hanzi.contains(q)
                || $0.pinyin.lowercased().contains(q)
                || $0.english.lowercased().contains(q)
            }
        }

        return result
    }

    var body: some View {
        NavigationSplitView {
            listContent
                .navigationTitle("Word List")
                .searchable(text: $searchText, prompt: "Search hanzi, pinyin, or English")
        } detail: {
            if let word = selectedWord {
                WordDetailView(word: word)
            } else {
                ContentUnavailableView(
                    "Select a Word",
                    systemImage: "character.book.closed.fill",
                    description: Text("Tap a word from the list to see its details.")
                )
            }
        }
    }

    // MARK: - List content

    private var listContent: some View {
        VStack(spacing: 0) {
            filterPicker
                .padding(.horizontal, 16)
                .padding(.vertical, 10)

            Divider()

            List(filteredWords, selection: $selectedWord) { word in
                WordRowView(word: word, record: recordMap[word.id])
                    .tag(word)
                    .listRowBackground(selectedWord?.id == word.id
                                       ? Color.accentColor.opacity(0.1)
                                       : Color(.secondarySystemGroupedBackground))
            }
            .listStyle(.insetGrouped)
            .overlay {
                if filteredWords.isEmpty {
                    ContentUnavailableView.search(text: searchText)
                }
            }
        }
    }

    private var filterPicker: some View {
        Picker("Filter", selection: $selectedFilter) {
            ForEach(WordFilter.allCases, id: \.self) { filter in
                Text(filter.rawValue).tag(filter)
            }
        }
        .pickerStyle(.segmented)
    }
}

// MARK: - Word row

struct WordRowView: View {
    let word: Word
    let record: UserWordRecord?

    private var statusColor: Color {
        guard let r = record else { return .purple }
        if r.isDueNow { return .blue }
        return .green
    }

    private var statusLabel: String {
        guard let r = record else { return "New" }
        if r.isDueNow { return "Due" }
        return "Learned"
    }

    var body: some View {
        HStack(spacing: 14) {
            // Hanzi
            Text(word.hanzi)
                .font(.system(size: 32, weight: .medium))
                .frame(width: 60, alignment: .center)

            // Pinyin + English
            VStack(alignment: .leading, spacing: 3) {
                Text(word.pinyin)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Text(word.english)
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundStyle(.primary)
                    .lineLimit(1)
            }

            Spacer()

            // Status badge
            Text(statusLabel)
                .font(.caption2)
                .fontWeight(.semibold)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(statusColor.opacity(0.15), in: Capsule())
                .foregroundStyle(statusColor)
        }
        .padding(.vertical, 6)
    }
}
