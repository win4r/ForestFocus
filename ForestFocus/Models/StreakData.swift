import Foundation
import SwiftData

@Model
final class StreakData {
    @Attribute(.unique) var id: UUID
    var currentStreak: Int
    var lastSessionStartDay: Date // Normalized to 00:00:00

    init() {
        self.id = UUID()
        self.currentStreak = 0
        self.lastSessionStartDay = Date.distantPast
    }

    /// Updates streak based on completion day
    /// - Consecutive day: increment streak
    /// - Same day: no change
    /// - Gap >1 day: reset to 1
    /// - Clock rollback (completionDay < lastSessionStartDay): no update (anti-tamper)
    func updateStreak(for completionDay: Date) {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: completionDay)
        let lastDay = self.lastSessionStartDay

        // Reject clock rollback
        if today < lastDay {
            return
        }

        if today == lastDay {
            // Same day - no change
            return
        } else if let dayDiff = calendar.dateComponents([.day], from: lastDay, to: today).day,
                  dayDiff == 1 {
            // Consecutive day - increment
            self.currentStreak += 1
        } else {
            // Streak broken or first session - reset to 1
            self.currentStreak = 1
        }

        self.lastSessionStartDay = today
    }
}
