import Foundation
import SwiftData

/// Implements a simplified SM-2 spaced repetition algorithm.
struct SRSService {

    // MARK: - Review result

    enum ReviewResult {
        case correct   // "Know it"
        case incorrect // "Still learning"
    }

    // MARK: - Update record after a review

    static func processReview(
        record: UserWordRecord,
        result: ReviewResult,
        now: Date = Date()
    ) {
        record.lastReviewDate = now
        record.isLearned = true

        switch result {
        case .correct:
            record.timesCorrect += 1
            let newInterval = nextInterval(record: record)
            record.repetitions += 1
            record.easeFactor = min(2.5, record.easeFactor + 0.1)
            record.interval = newInterval
            record.dueDate = Calendar.current.date(byAdding: .day, value: newInterval, to: now) ?? now

        case .incorrect:
            record.timesIncorrect += 1
            record.repetitions = 0
            record.easeFactor = max(1.3, record.easeFactor - 0.2)
            record.interval = 0
            // Show again in the same session (1 min buffer so it re-appears later)
            record.dueDate = now.addingTimeInterval(60)
        }
    }

    // MARK: - Private helpers

    private static func nextInterval(record: UserWordRecord) -> Int {
        switch record.repetitions {
        case 0: return 1   // first correct: review tomorrow
        case 1: return 3   // second correct: review in 3 days
        default:
            let next = Double(record.interval) * record.easeFactor
            return max(record.interval + 1, Int(next.rounded()))
        }
    }

    // MARK: - Queue building

    /// Words due for review (have an existing record).
    static func dueWords(records: [UserWordRecord], words: [Word]) -> [Word] {
        let dueIDs = Set(records.filter { $0.isDueNow }.map { $0.wordID })
        return words
            .filter { dueIDs.contains($0.id) }
            .sorted { $0.sortOrder < $1.sortOrder }
    }

    /// Words with no record yet (never studied).
    static func newWords(records: [UserWordRecord], words: [Word], limit: Int) -> [Word] {
        let learnedIDs = Set(records.map { $0.wordID })
        return words
            .filter { !learnedIDs.contains($0.id) }
            .sorted { $0.sortOrder < $1.sortOrder }
            .prefix(limit)
            .map { $0 }
    }

    /// Count of words learned (have a record and isLearned == true).
    static func learnedCount(records: [UserWordRecord]) -> Int {
        records.filter { $0.isLearned }.count
    }
}
