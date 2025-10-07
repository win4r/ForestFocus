import SwiftUI
import SwiftData
import Combine

struct TimerView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.scenePhase) private var scenePhase

    @State private var timerService: TimerService?
    @State private var sessionManager: SessionManager?
    @State private var remainingTime: Int = 1500
    @State private var treeStage: Int = 1
    @State private var sessionState: SessionState = .idle
    @State private var cancellables = Set<AnyCancellable>()

    var body: some View {
        VStack(spacing: 40) {
            Spacer()

            // Tree Animation
            TreeAnimationView(stage: treeStage)
                .frame(height: 200)

            // Countdown Timer
            CountdownTimerView(remainingSeconds: remainingTime)

            Spacer()

            // Controls
            VStack(spacing: 16) {
                switch sessionState {
                case .idle:
                    startButton
                case .active:
                    HStack(spacing: 16) {
                        pauseButton
                        cancelButton
                    }
                case .paused:
                    HStack(spacing: 16) {
                        resumeButton
                        cancelButton
                    }
                case .completed:
                    completionOverlay
                case .abandoned:
                    Text("Session cancelled")
                        .font(.headline)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 40)
        }
        .onAppear {
            // Initialize services with actual modelContext
            if timerService == nil {
                let actualTimerService = TimerService(modelContext: modelContext)
                let actualSessionManager = SessionManager(
                    modelContext: modelContext,
                    timerService: actualTimerService
                )

                timerService = actualTimerService
                sessionManager = actualSessionManager

                // Subscribe to timer updates
                actualTimerService.$remainingTime
                    .sink { [self] time in
                        remainingTime = time
                    }
                    .store(in: &cancellables)

                actualTimerService.$treeStage
                    .sink { [self] stage in
                        treeStage = stage
                    }
                    .store(in: &cancellables)

                actualTimerService.$sessionState
                    .sink { [self] state in
                        sessionState = state
                    }
                    .store(in: &cancellables)

                Task {
                    try? await actualSessionManager.markAbandonedSessionsOnRelaunch()
                }
            }
        }
        .onChange(of: scenePhase) { oldPhase, newPhase in
            Task {
                await sessionManager?.handleSceneChange(oldPhase: oldPhase, newPhase: newPhase)
            }
        }
    }

    // MARK: - UI Components

    private var startButton: some View {
        Button {
            Task {
                try? await timerService?.startSession()
                NotificationService.shared.scheduleSessionComplete(in: 1500)
            }
        } label: {
            Text("Start Focus")
                .font(.title2.bold())
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.green)
                .cornerRadius(12)
        }
        .accessibilityLabel("Start focus session")
        .accessibilityHint("Begins a 25-minute timer and plants a tree")
    }

    private var pauseButton: some View {
        Button {
            Task {
                try? await timerService?.pauseSession()
                NotificationService.shared.cancelPendingNotifications()
            }
        } label: {
            Text("Pause")
                .font(.title3.bold())
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.orange)
                .cornerRadius(12)
        }
        .accessibilityLabel("Pause session")
    }

    private var resumeButton: some View {
        Button {
            Task {
                try? await timerService?.resumeSession()
                if let remaining = timerService?.remainingTime {
                    NotificationService.shared.rescheduleNotification(for: remaining)
                }
            }
        } label: {
            Text("Resume")
                .font(.title3.bold())
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.green)
                .cornerRadius(12)
        }
        .accessibilityLabel("Resume session")
    }

    private var cancelButton: some View {
        Button {
            Task {
                try? await timerService?.cancelSession()
                NotificationService.shared.cancelPendingNotifications()
            }
        } label: {
            Text("Cancel")
                .font(.title3.bold())
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.red)
                .cornerRadius(12)
        }
        .accessibilityLabel("Cancel session")
        .accessibilityHint("Abandons current session and kills the tree")
    }

    private var completionOverlay: some View {
        VStack(spacing: 16) {
            Text("Focus Complete! 🎉")
                .font(.largeTitle.bold())
                .foregroundColor(.green)

            Text("Your tree is fully grown!")
                .font(.headline)
                .foregroundColor(.secondary)

            Button("Start New Session") {
                timerService?.resetToIdle()
                sessionState = .idle
                remainingTime = 1500
                treeStage = 1
            }
            .buttonStyle(.borderedProminent)
        }
    }
}
