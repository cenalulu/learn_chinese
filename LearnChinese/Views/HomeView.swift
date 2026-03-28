import SwiftUI
import SwiftData

struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var words: [Word]
    @Query private var records: [UserWordRecord]
    @Query private var profiles: [UserProfile]

    @State private var showingReviewSession = false
    @State private var showingLearnSession = false
    @State private var sessionMode: FlashcardSession.Mode = .review

    private var profile: UserProfile? { profiles.first }

    private var dueCount: Int {
        records.filter { $0.isDueNow }.count
    }

    private var learnedCount: Int {
        SRSService.learnedCount(records: records)
    }

    private var newAvailableCount: Int {
        SRSService.newWords(
            records: records,
            words: words,
            limit: profile?.dailyNewWordLimit ?? 10
        ).count
    }

    private var progressFraction: Double {
        guard !words.isEmpty else { return 0 }
        return Double(learnedCount) / Double(words.count)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 28) {
                headerSection
                statsRow
                reviewCard
                learnNewCard
                progressSection
            }
            .padding(24)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Learn Chinese")
        .navigationBarTitleDisplayMode(.large)
        .fullScreenCover(isPresented: $showingReviewSession) {
            FlashcardSessionView(mode: .review)
        }
        .fullScreenCover(isPresented: $showingLearnSession) {
            FlashcardSessionView(mode: .learn)
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 4) {
                Text("HSK 1")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.secondary)
                    .textCase(.uppercase)
                    .tracking(1)
                Text("Daily Review")
                    .font(.title2)
                    .fontWeight(.bold)
            }
            Spacer()
            streakBadge
        }
    }

    private var streakBadge: some View {
        VStack(spacing: 2) {
            Text("🔥")
                .font(.title2)
            Text("\(profile?.streakCount ?? 0)")
                .font(.title3)
                .fontWeight(.bold)
            Text("day streak")
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(width: 70)
        .padding(12)
        .background(.orange.opacity(0.1), in: RoundedRectangle(cornerRadius: 14))
    }

    // MARK: - Stats row

    private var statsRow: some View {
        HStack(spacing: 12) {
            statTile(value: learnedCount, label: "Learned", color: .green)
            statTile(value: dueCount, label: "Due now", color: .blue)
            statTile(value: words.count - learnedCount, label: "New", color: .purple)
        }
    }

    private func statTile(value: Int, label: String, color: Color) -> some View {
        VStack(spacing: 4) {
            Text("\(value)")
                .font(.title)
                .fontWeight(.bold)
                .foregroundStyle(color)
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(.background, in: RoundedRectangle(cornerRadius: 14))
    }

    // MARK: - Review card

    private var reviewCard: some View {
        Button {
            showingReviewSession = true
        } label: {
            HStack(spacing: 16) {
                Image(systemName: "rectangle.stack.fill")
                    .font(.title2)
                    .foregroundStyle(.white)
                    .frame(width: 52, height: 52)
                    .background(.blue, in: RoundedRectangle(cornerRadius: 12))

                VStack(alignment: .leading, spacing: 3) {
                    Text("Review Due Cards")
                        .font(.headline)
                        .foregroundStyle(.primary)
                    Text(dueCount == 0
                         ? "All caught up! Come back later."
                         : "\(dueCount) card\(dueCount == 1 ? "" : "s") waiting")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                if dueCount > 0 {
                    Image(systemName: "chevron.right")
                        .foregroundStyle(.secondary)
                }
            }
            .padding(18)
            .background(.background, in: RoundedRectangle(cornerRadius: 16))
        }
        .disabled(dueCount == 0)
    }

    // MARK: - Learn new card

    private var learnNewCard: some View {
        Button {
            showingLearnSession = true
        } label: {
            HStack(spacing: 16) {
                Image(systemName: "plus.circle.fill")
                    .font(.title2)
                    .foregroundStyle(.white)
                    .frame(width: 52, height: 52)
                    .background(.purple, in: RoundedRectangle(cornerRadius: 12))

                VStack(alignment: .leading, spacing: 3) {
                    Text("Learn New Words")
                        .font(.headline)
                        .foregroundStyle(.primary)
                    Text(newAvailableCount == 0
                         ? "No new words available"
                         : "\(newAvailableCount) new word\(newAvailableCount == 1 ? "" : "s") available")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                if newAvailableCount > 0 {
                    Image(systemName: "chevron.right")
                        .foregroundStyle(.secondary)
                }
            }
            .padding(18)
            .background(.background, in: RoundedRectangle(cornerRadius: 16))
        }
        .disabled(newAvailableCount == 0)
    }

    // MARK: - Progress section

    private var progressSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("HSK 1 Progress")
                .font(.headline)

            ProgressView(value: progressFraction)
                .tint(.green)
                .scaleEffect(x: 1, y: 2)

            HStack {
                Text("\(learnedCount) / \(words.count) words learned")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Spacer()
                Text("\(Int(progressFraction * 100))%")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.green)
            }
        }
        .padding(18)
        .background(.background, in: RoundedRectangle(cornerRadius: 16))
    }
}
