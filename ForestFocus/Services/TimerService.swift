import Foundation
import Combine
import SwiftData

@MainActor
class TimerService: ObservableObject {
    private let modelContext: ModelContext
    private var timerCancellable: AnyCancellable?
    private var sessionStartMonotonic: TimeInterval?
    private var currentSession: FocusSession?
    private var sessionDuration: Int = 1500 // Default 25 minutes, can be customized

    @Published var remainingTime: Int = 1500 // Default 25 minutes
    @Published var treeStage: Int = 1
    @Published var sessionState: SessionState = .idle

    var hasActiveSession: Bool {
        sessionState == .active || sessionState == .paused
    }

    var elapsedSeconds: Int {
        return sessionDuration - remainingTime
    }

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func startSession(durationMinutes: Int = 25) async throws {
        guard sessionState == .idle else {
            throw TimerError.sessionAlreadyActive
        }

        let now = Date()
        let startDay = now.startOfDay()
        let monotonicRef = MonotonicClock.now()
        let durationSecs = durationMinutes * 60

        let session = FocusSession(
            startTime: now,
            startDay: startDay,
            durationSeconds: durationSecs,
            monotonicReference: monotonicRef
        )

        modelContext.insert(session)
        try modelContext.save()

        currentSession = session
        sessionStartMonotonic = monotonicRef
        sessionDuration = durationSecs
        sessionState = .active
        remainingTime = durationSecs
        treeStage = 1

        startTimer()
    }

    func pauseSession() async throws {
        guard sessionState == .active else {
            throw TimerError.noActiveSession
        }

        stopTimer()

        let descriptor = FetchDescriptor<FocusSession>(
            predicate: #Predicate { $0.statusRawValue == "active" }
        )
        guard let session = try modelContext.fetch(descriptor).first else {
            throw TimerError.sessionNotFound
        }

        session.status = .paused
        session.elapsedSeconds = elapsedSeconds
        try modelContext.save()

        sessionState = .paused
    }

    func resumeSession() async throws {
        guard sessionState == .paused else {
            throw TimerError.sessionNotPaused
        }

        let descriptor = FetchDescriptor<FocusSession>(
            predicate: #Predicate { $0.statusRawValue == "paused" }
        )
        guard let session = try modelContext.fetch(descriptor).first else {
            throw TimerError.sessionNotFound
        }

        session.status = .active
        sessionDuration = session.durationSeconds
        sessionStartMonotonic = MonotonicClock.now() - TimeInterval(session.elapsedSeconds)
        try modelContext.save()

        sessionState = .active
        startTimer()
    }

    func cancelSession() async throws {
        guard hasActiveSession else {
            throw TimerError.noActiveSession
        }

        stopTimer()

        let descriptor = FetchDescriptor<FocusSession>(
            predicate: #Predicate { $0.statusRawValue == "active" || $0.statusRawValue == "paused" }
        )
        guard let session = try modelContext.fetch(descriptor).first else {
            throw TimerError.sessionNotFound
        }

        session.status = .abandoned
        session.endTime = Date()
        session.elapsedSeconds = elapsedSeconds
        try modelContext.save()

        sessionState = .idle
        sessionDuration = 1500
        remainingTime = 1500
        treeStage = 1
    }

    func recalculateFromBackground() async throws {
        let descriptor = FetchDescriptor<FocusSession>(
            predicate: #Predicate { $0.statusRawValue == "active" }
        )
        guard let session = try modelContext.fetch(descriptor).first else {
            return
        }

        let now = MonotonicClock.now()
        let elapsed = Int(now - session.monotonicReference)
        sessionDuration = session.durationSeconds

        remainingTime = max(0, sessionDuration - elapsed)
        treeStage = calculateTreeStage(elapsed: elapsed, duration: sessionDuration)
        session.elapsedSeconds = elapsed

        if remainingTime == 0 {
            try await completeSession()
        } else {
            try modelContext.save()
        }
    }

    func calculateTreeStage(elapsed: Int, duration: Int) -> Int {
        // Calculate stage proportionally based on duration
        // Always divide into 5 equal stages
        let stageInterval = duration / 5

        switch elapsed {
        case 0..<stageInterval:
            return 1
        case stageInterval..<(stageInterval * 2):
            return 2
        case (stageInterval * 2)..<(stageInterval * 3):
            return 3
        case (stageInterval * 3)..<(stageInterval * 4):
            return 4
        default:
            return 5
        }
    }

    private func startTimer() {
        timerCancellable = Timer.publish(every: 1.0, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                Task { @MainActor [weak self] in
                    await self?.updateCountdown()
                }
            }
    }

    private func stopTimer() {
        timerCancellable?.cancel()
        timerCancellable = nil
    }

    private func updateCountdown() async {
        guard let startMonotonic = sessionStartMonotonic else { return }

        let elapsed = Int(MonotonicClock.now() - startMonotonic)
        remainingTime = max(0, sessionDuration - elapsed)
        treeStage = calculateTreeStage(elapsed: elapsed, duration: sessionDuration)

        // Update session in database
        let descriptor = FetchDescriptor<FocusSession>(
            predicate: #Predicate { $0.statusRawValue == "active" }
        )
        if let session = try? modelContext.fetch(descriptor).first {
            session.elapsedSeconds = elapsed
            session.treeStage = treeStage
            try? modelContext.save()
        }

        if remainingTime == 0 {
            try? await completeSession()
        }
    }

    func completeSession() async throws {
        stopTimer()

        let descriptor = FetchDescriptor<FocusSession>(
            predicate: #Predicate { $0.statusRawValue == "active" }
        )
        guard let session = try modelContext.fetch(descriptor).first else {
            return
        }

        session.status = .completed
        session.endTime = Date()
        session.elapsedSeconds = session.durationSeconds
        session.treeStage = 5
        try modelContext.save()

        // Create completed tree
        let forestService = ForestService(modelContext: modelContext)
        _ = try await forestService.addTree(from: session)

        // Update streak
        let statsCalculator = StatsCalculator(modelContext: modelContext)
        try await statsCalculator.updateStreak(for: session.startDay)

        sessionState = .completed
        treeStage = 5
    }

    func resetToIdle() {
        sessionState = .idle
        sessionDuration = 1500
        remainingTime = 1500
        treeStage = 1
    }
}

enum SessionState: String, Codable {
    case idle
    case active
    case paused
    case completed
    case abandoned
}

enum TimerError: Error {
    case sessionAlreadyActive
    case noActiveSession
    case sessionNotPaused
    case sessionNotFound
}
