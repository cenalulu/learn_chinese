import SwiftUI
import SwiftData

struct WordDetailView: View {
    let word: Word

    @Environment(\.modelContext) private var modelContext
    @Query private var records: [UserWordRecord]

    private var record: UserWordRecord? {
        records.first { $0.wordID == word.id }
    }

    private var safeToneColor: Color {
        switch word.primaryTone {
        case 1: return .blue
        case 2: return .green
        case 3: return .orange
        case 4: return .red
        default: return .gray
        }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 28) {
                characterCard
                detailsCard
                if !word.exampleSentenceZh.isEmpty {
                    exampleCard
                }
                srsCard
            }
            .padding(24)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle(word.hanzi)
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Character card

    private var characterCard: some View {
        VStack(spacing: 16) {
            Text(word.hanzi)
                .font(.system(size: 120, weight: .medium))
                .foregroundStyle(safeToneColor)

            Text(word.pinyin)
                .font(.system(size: 28, weight: .regular, design: .rounded))
                .foregroundStyle(.secondary)

            Text(word.english)
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundStyle(.primary)

            HStack(spacing: 12) {
                Button {
                    AudioService.shared.speak(word.hanzi)
                } label: {
                    Label("Normal", systemImage: "speaker.wave.2.fill")
                }
                .buttonStyle(.bordered)
                .tint(safeToneColor)

                Button {
                    AudioService.shared.speakSlowly(word.hanzi)
                } label: {
                    Label("Slow", systemImage: "tortoise.fill")
                }
                .buttonStyle(.bordered)
                .tint(.secondary)
            }
        }
        .padding(28)
        .frame(maxWidth: .infinity)
        .background(.background, in: RoundedRectangle(cornerRadius: 20))
    }

    // MARK: - Details card

    private var detailsCard: some View {
        VStack(alignment: .leading, spacing: 0) {
            sectionHeader("Details")
            detailRow(label: "HSK Level", value: "HSK \(word.hskLevel)")
            Divider().padding(.leading, 16)
            detailRow(label: "Pinyin", value: word.pinyin)
            if !word.topicTags.isEmpty {
                Divider().padding(.leading, 16)
                detailRow(label: "Topics", value: word.topicTags.joined(separator: ", "))
            }
        }
        .background(.background, in: RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Example card

    private var exampleCard: some View {
        VStack(alignment: .leading, spacing: 0) {
            sectionHeader("Example Sentence")
            VStack(alignment: .leading, spacing: 10) {
                Text(word.exampleSentenceZh)
                    .font(.system(size: 22, weight: .regular))
                    .foregroundStyle(.primary)

                Text(word.exampleSentenceEn)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Button {
                    AudioService.shared.speak(word.exampleSentenceZh)
                } label: {
                    Label("Hear sentence", systemImage: "speaker.wave.2")
                        .font(.caption)
                }
                .buttonStyle(.bordered)
                .tint(safeToneColor)
                .padding(.top, 4)
            }
            .padding(16)
        }
        .background(.background, in: RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - SRS status card

    private var srsCard: some View {
        VStack(alignment: .leading, spacing: 0) {
            sectionHeader("Study Progress")
            VStack(alignment: .leading, spacing: 12) {
                if let r = record {
                    srsRow(label: "Status", value: r.isLearned ? "In rotation" : "New")
                    srsRow(label: "Correct", value: "\(r.timesCorrect)")
                    srsRow(label: "Incorrect", value: "\(r.timesIncorrect)")
                    srsRow(label: "Accuracy", value: "\(r.accuracyPercent)%")
                    srsRow(label: "Next review",
                           value: r.interval == 0 ? "Soon" : "In \(r.interval) day\(r.interval == 1 ? "" : "s")")
                } else {
                    Text("Not studied yet")
                        .foregroundStyle(.secondary)
                        .padding(16)

                    Button("Add to review queue") { addToQueue() }
                        .buttonStyle(.borderedProminent)
                        .padding([.horizontal, .bottom], 16)
                }
            }
        }
        .background(.background, in: RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Helpers

    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(.caption)
            .fontWeight(.semibold)
            .foregroundStyle(.secondary)
            .textCase(.uppercase)
            .tracking(0.8)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
    }

    private func detailRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }

    private func srsRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 4)
    }

    private func addToQueue() {
        let r = UserWordRecord(wordID: word.id)
        modelContext.insert(r)
        try? modelContext.save()
    }
}
