import Foundation
import SwiftData

/// Tracks a user's SRS progress for a single Word.
@Model
final class UserWordRecord {
    @Attribute(.unique) var wordID: UUID

    // SM-2 fields
    var interval: Int       // days until next review (0 = review now)
    var repetitions: Int    // consecutive correct answers
    var easeFactor: Double  // 1.3–2.5, default 2.5

    var dueDate: Date
    var lastReviewDate: Date?

    // Stats
    var timesCorrect: Int
    var timesIncorrect: Int

    /// True once the card has been reviewed at least once (graduated from "new")
    var isLearned: Bool

    init(wordID: UUID) {
        self.wordID = wordID
        self.interval = 0
        self.repetitions = 0
        self.easeFactor = 2.5
        self.dueDate = Date()
        self.lastReviewDate = nil
        self.timesCorrect = 0
        self.timesIncorrect = 0
        self.isLearned = false
    }

    var isDueNow: Bool {
        dueDate <= Date()
    }

    var accuracyPercent: Int {
        let total = timesCorrect + timesIncorrect
        guard total > 0 else { return 0 }
        return Int(Double(timesCorrect) / Double(total) * 100)
    }
}
