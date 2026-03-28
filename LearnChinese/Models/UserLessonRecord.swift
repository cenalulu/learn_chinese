import Foundation
import SwiftData

@Model
final class UserLessonRecord {
    @Attribute(.unique) var lessonID: String
    var isCompleted: Bool
    var score: Int          // 0–100 (percentage correct)
    var completedAt: Date?
    var timesAttempted: Int
    var bestScore: Int

    init(lessonID: String) {
        self.lessonID = lessonID
        self.isCompleted = false
        self.score = 0
        self.completedAt = nil
        self.timesAttempted = 0
        self.bestScore = 0
    }

    func recordAttempt(score: Int) {
        timesAttempted += 1
        self.score = score
        bestScore = max(bestScore, score)
        if score >= 70 {
            isCompleted = true
            completedAt = Date()
        }
    }

    var scoreLabel: String {
        switch bestScore {
        case 90...100: return "⭐️⭐️⭐️"
        case 70..<90:  return "⭐️⭐️"
        case 1..<70:   return "⭐️"
        default:       return ""
        }
    }
}
