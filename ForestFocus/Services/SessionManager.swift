import Foundation
import SwiftData
import SwiftUI

@MainActor
class SessionManager {
    private let modelContext: ModelContext
    private let timerService: TimerService

    init(modelContext: ModelContext, timerService: TimerService) {
        self.modelContext = modelContext
        self.timerService = timerService
    }

    func handleSceneChange(oldPhase: ScenePhase, newPhase: ScenePhase) async {
        switch (oldPhase, newPhase) {
        case (.active, .background):
            // App going to background - timer will auto-pause
            break

        case (.background, .active), (.inactive, .active):
            // App returning to foreground - recalculate elapsed time
            try? await timerService.recalculateFromBackground()

        case (.active, .inactive):
            // System interruption (phone call, Siri, etc.) - auto-pause
            if timerService.hasActiveSession {
                try? await timerService.pauseSession()
            }

        default:
            break
        }
    }

    func markAbandonedSessionsOnRelaunch() async throws {
        let descriptor = FetchDescriptor<FocusSession>(
            predicate: #Predicate { $0.statusRawValue == "active" || $0.statusRawValue == "paused" }
        )

        let activeSessions = try modelContext.fetch(descriptor)

        for session in activeSessions {
            session.status = .abandoned
            session.endTime = Date()
        }

        if !activeSessions.isEmpty {
            try modelContext.save()
        }
    }
}
