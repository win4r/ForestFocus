import Foundation
import SwiftData

@Model
final class CompletedTree {
    @Attribute(.unique) var id: UUID
    var startTime: Date
    var completionTime: Date
    var startDay: Date // Normalized to 00:00:00 (for stats)
    var visualStage: Int // Always 5 (fully grown)

    init(startTime: Date, completionTime: Date, startDay: Date, visualStage: Int) {
        self.id = UUID()
        self.startTime = startTime
        self.completionTime = completionTime
        self.startDay = startDay
        self.visualStage = visualStage
    }

    convenience init(from session: FocusSession) {
        guard session.status == .completed, let endTime = session.endTime else {
            fatalError("Cannot create CompletedTree from non-completed session")
        }

        self.init(
            startTime: session.startTime,
            completionTime: endTime,
            startDay: session.startDay,
            visualStage: 5
        )
    }
}
