import Foundation
import SwiftData

/// Tracks a user's SRS progress for a single Word.
@Model
final class UserWordRecord {
    @Attribute(.unique) var wordID: UUID

    // MARK: - Reading SRS (SM-2)
    var interval: Int       // days until next review (0 = review now)
    var repetitions: Int    // consecutive correct answers
    var easeFactor: Double  // 1.3–2.5, default 2.5
    var dueDate: Date
    var lastReviewDate: Date?
    var timesCorrect: Int
    var timesIncorrect: Int
    /// True once the card has been reviewed at least once.
    var isLearned: Bool

    // MARK: - Writing SRS (Phase 3, separate SM-2 track)
    var writingInterval: Int
    var writingRepetitions: Int
    var writingEaseFactor: Double
    var writingDueDate: Date
    var writingTimesCorrect: Int
    var writingTimesIncorrect: Int
    /// True once the user has successfully written the character from memory at least once.
    var isWritingLearned: Bool

    init(wordID: UUID) {
        self.wordID = wordID
        // Reading SRS
        self.interval = 0
        self.repetitions = 0
        self.easeFactor = 2.5
        self.dueDate = Date()
        self.lastReviewDate = nil
        self.timesCorrect = 0
        self.timesIncorrect = 0
        self.isLearned = false
        // Writing SRS
        self.writingInterval = 0
        self.writingRepetitions = 0
        self.writingEaseFactor = 2.5
        self.writingDueDate = Date()
        self.writingTimesCorrect = 0
        self.writingTimesIncorrect = 0
        self.isWritingLearned = false
    }

    // MARK: - Computed helpers

    var isDueNow: Bool { dueDate <= Date() }
    var isWritingDueNow: Bool { writingDueDate <= Date() }

    var accuracyPercent: Int {
        let total = timesCorrect + timesIncorrect
        guard total > 0 else { return 0 }
        return Int(Double(timesCorrect) / Double(total) * 100)
    }

    var writingAccuracyPercent: Int {
        let total = writingTimesCorrect + writingTimesIncorrect
        guard total > 0 else { return 0 }
        return Int(Double(writingTimesCorrect) / Double(total) * 100)
    }
}
