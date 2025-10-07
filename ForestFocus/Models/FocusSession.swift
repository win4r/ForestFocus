import Foundation
import SwiftData

@Model
final class FocusSession {
    @Attribute(.unique) var id: UUID
    var startTime: Date
    var startDay: Date // Normalized to 00:00:00 of start date (for stats grouping)
    var endTime: Date? // nil if active/paused
    var elapsedSeconds: Int // Accumulated time (handles pause/resume)
    var statusRawValue: String // Store as String for SwiftData compatibility
    var treeStage: Int // 1-5 (visual growth stage)
    var monotonicReference: TimeInterval // CFAbsoluteTimeGetCurrent() at session start

    var status: SessionStatus {
        get { SessionStatus(rawValue: statusRawValue) ?? .abandoned }
        set { statusRawValue = newValue.rawValue }
    }

    init(startTime: Date, startDay: Date, monotonicReference: TimeInterval) {
        self.id = UUID()
        self.startTime = startTime
        self.startDay = startDay
        self.endTime = nil
        self.elapsedSeconds = 0
        self.statusRawValue = SessionStatus.active.rawValue
        self.treeStage = 1
        self.monotonicReference = monotonicReference
    }
}

enum SessionStatus: String, Codable {
    case active      // Timer running
    case paused      // User paused or system interruption
    case completed   // Full 25 minutes elapsed
    case abandoned   // User cancelled or force-quit
}
