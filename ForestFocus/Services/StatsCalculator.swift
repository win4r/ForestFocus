import Foundation
import SwiftData

struct FocusTime: Equatable {
    let hours: Int
    let minutes: Int

    init(totalMinutes: Int) {
        self.hours = totalMinutes / 60
        self.minutes = totalMinutes % 60
    }

    var displayString: String {
        if hours == 0 {
            return "\(minutes) minutes"
        } else if minutes == 0 {
            return "\(hours) hours"
        } else {
            return "\(hours) hours \(minutes) minutes"
        }
    }
}

@MainActor
class StatsCalculator {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func totalTreesPlanted() async throws -> Int {
        let descriptor = FetchDescriptor<CompletedTree>()
        return try modelContext.fetchCount(descriptor)
    }

    func totalFocusTime() async throws -> FocusTime {
        let count = try await totalTreesPlanted()
        let totalMinutes = count * 25
        return FocusTime(totalMinutes: totalMinutes)
    }

    func todaysTreeCount(for date: Date = Date()) async throws -> Int {
        let startDay = date.startOfDay()
        let descriptor = FetchDescriptor<CompletedTree>(
            predicate: #Predicate { $0.startDay == startDay }
        )
        return try modelContext.fetchCount(descriptor)
    }

    func currentStreak() async throws -> Int {
        let descriptor = FetchDescriptor<StreakData>()
        guard let streakData = try modelContext.fetch(descriptor).first else {
            // Initialize if not exists
            let newStreak = StreakData()
            modelContext.insert(newStreak)
            try modelContext.save()
            return 0
        }

        return streakData.currentStreak
    }

    func updateStreak(for sessionStartDay: Date) async throws {
        let descriptor = FetchDescriptor<StreakData>()
        let streakData: StreakData

        if let existing = try modelContext.fetch(descriptor).first {
            streakData = existing
        } else {
            let newStreak = StreakData()
            modelContext.insert(newStreak)
            streakData = newStreak
        }

        streakData.updateStreak(for: sessionStartDay)
        try modelContext.save()
    }

    func logTimeJump(_ timeJump: TimeInterval) async throws {
        let event = AntiTamperEvent(
            timestamp: Date(),
            timeJumpMagnitude: timeJump
        )
        modelContext.insert(event)
        try modelContext.save()
    }
}
