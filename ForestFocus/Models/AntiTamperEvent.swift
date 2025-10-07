import Foundation
import SwiftData

@Model
final class AntiTamperEvent {
    @Attribute(.unique) var id: UUID
    var timestamp: Date // When jump detected
    var timeJumpMagnitude: TimeInterval // Seconds of wall-clock change

    init(timestamp: Date, timeJumpMagnitude: TimeInterval) {
        self.id = UUID()
        self.timestamp = timestamp
        self.timeJumpMagnitude = timeJumpMagnitude
    }
}
