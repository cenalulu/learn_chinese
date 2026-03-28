import Foundation
import SwiftData

@Model
final class UserProfile {
    var streakCount: Int
    var streakLastDate: Date?
    var totalXP: Int
    var hasSeededData: Bool
    var dailyNewWordLimit: Int   // how many new cards to introduce per day

    init() {
        self.streakCount = 0
        self.streakLastDate = nil
        self.totalXP = 0
        self.hasSeededData = false
        self.dailyNewWordLimit = 10
    }

    /// Call once per session to update the streak.
    func recordActivity(on date: Date = Date()) {
        let calendar = Calendar.current
        if let last = streakLastDate {
            if calendar.isDateInToday(last) {
                return // already recorded today
            } else if calendar.isDateInYesterday(last) {
                streakCount += 1
            } else {
                streakCount = 1 // streak broken
            }
        } else {
            streakCount = 1
        }
        streakLastDate = date
    }
}
