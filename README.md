# ForestFocus

ForestFocus is a SwiftUI focus timer that turns completed pomodoro sessions into a growing digital forest. It combines a 25-minute countdown experience with background-safe timekeeping, motivational streak tracking, and accessibility-friendly visuals that reward your deep work with virtual trees.

## Features
- **Focus timer with tree growth** – Start, pause, resume, and cancel 25-minute focus sessions while watching a tree advance through five visual stages as time passes.【F:ForestFocus/ForestFocus/Services/TimerService.swift†L12-L123】【F:ForestFocus/ForestFocus/Views/TimerView.swift†L16-L121】
- **Persistent forest gallery** – Completed sessions automatically plant trees that are stored with SwiftData and displayed in a responsive grid for long-term motivation.【F:ForestFocus/ForestFocus/Services/TimerService.swift†L124-L179】【F:ForestFocus/ForestFocus/Views/ForestView.swift†L5-L74】
- **Insightful stats dashboard** – Track total trees, cumulative focus time, today’s progress, and multi-day streaks with compact stat cards fed by SwiftData queries.【F:ForestFocus/ForestFocus/Views/StatsView.swift†L5-L70】【F:ForestFocus/ForestFocus/Services/StatsCalculator.swift†L23-L83】
- **Background and notification support** – Sessions survive app lifecycle changes by recalculating elapsed time with a monotonic clock and re-scheduling local notifications when needed.【F:ForestFocus/ForestFocus/Services/TimerService.swift†L80-L163】【F:ForestFocus/ForestFocus/Services/NotificationService.swift†L5-L49】【F:ForestFocus/ForestFocus/Services/SessionManager.swift†L14-L43】
- **Anti-tamper logging and streak protection** – Time-jump detection and streak updates guard against manual clock changes while recording suspicious events for review.【F:ForestFocus/ForestFocus/Utils/MonotonicClock.swift†L1-L44】【F:ForestFocus/ForestFocus/Services/StatsCalculator.swift†L85-L104】【F:ForestFocus/ForestFocus/Models/StreakData.swift†L5-L46】
- **Accessibility-minded design** – Button labels, hints, and VoiceOver-friendly empty states help the app remain usable for a wide audience.【F:ForestFocus/ForestFocus/Views/TimerView.swift†L85-L168】【F:ForestFocus/ForestFocus/Views/ForestView.swift†L23-L68】

## Requirements
- Xcode 15 or later (for Swift 5.9, SwiftUI, SwiftData, and the new `Testing` framework)
- iOS 17 or later deployment target (SwiftData is iOS 17+)

## Getting Started
1. Clone the repository and open `ForestFocus.xcodeproj` in Xcode.
2. Select the **ForestFocus** scheme and choose an iOS 17+ simulator or device.
3. Build and run (`Cmd + R`). On first launch the app will request notification permission for session-complete alerts.【F:ForestFocus/ForestFocus/ForestFocusApp.swift†L11-L33】
4. Start a focus session from the **Timer** tab to grow trees, visit the **Forest** tab to view your collection, and explore the **Stats** tab for progress insights.【F:ForestFocus/ForestFocus/ForestFocusApp.swift†L33-L48】

## Project Structure
```
ForestFocus/
├─ ForestFocus/            # Application source
│  ├─ Models/              # SwiftData model definitions (sessions, trees, streaks, events)
│  ├─ Services/            # Timer, forest, stats, notification, and session-management logic
│  ├─ Utils/               # Monotonic clock helper and date extensions
│  ├─ Views/               # SwiftUI screens and reusable components
│  └─ Assets.xcassets/     # App icon and UI assets
├─ ForestFocusTests/       # Placeholder for unit and UI tests using the Testing package
├─ ForestFocusUITests/     # (Empty) target ready for UI automation
└─ ForestFocus.xcodeproj   # Xcode project configuration
```

### Key Modules
- **Models** – `FocusSession`, `CompletedTree`, `StreakData`, and `AntiTamperEvent` persist session state, history, and tamper logs with SwiftData.【F:ForestFocus/ForestFocus/Models/FocusSession.swift†L5-L36】【F:ForestFocus/ForestFocus/Models/CompletedTree.swift†L5-L33】【F:ForestFocus/ForestFocus/Models/StreakData.swift†L5-L46】【F:ForestFocus/ForestFocus/Models/AntiTamperEvent.swift†L5-L15】
- **TimerService** – Orchestrates session lifecycle, countdown updates, and tree stage transitions while writing progress to the database.【F:ForestFocus/ForestFocus/Services/TimerService.swift†L6-L179】
- **ForestService & StatsCalculator** – Provide high-level queries for completed trees, aggregate metrics, streak updates, and tamper logging.【F:ForestFocus/ForestFocus/Services/ForestService.swift†L5-L62】【F:ForestFocus/ForestFocus/Services/StatsCalculator.swift†L23-L104】
- **SessionManager** – Responds to scene changes to keep timers accurate when the app moves between foreground and background.【F:ForestFocus/ForestFocus/Services/SessionManager.swift†L6-L43】
- **NotificationService** – Wraps `UNUserNotificationCenter` to schedule or cancel session-complete alerts.【F:ForestFocus/ForestFocus/Services/NotificationService.swift†L5-L49】

## Data & Persistence
- SwiftData stores session, tree, streak, and anti-tamper entities in an app-managed container configured at launch.【F:ForestFocus/ForestFocus/ForestFocusApp.swift†L13-L32】
- Session metadata captures both wall-clock timestamps and a monotonic reference to rebuild state safely after backgrounding.【F:ForestFocus/ForestFocus/Models/FocusSession.swift†L5-L36】【F:ForestFocus/ForestFocus/Utils/MonotonicClock.swift†L1-L35】
- Completed trees inherit their data directly from finished sessions to guarantee consistency between timers and the forest view.【F:ForestFocus/ForestFocus/Models/CompletedTree.swift†L5-L33】

## Notifications & Background Behavior
- When a session starts the app schedules a one-off local notification 25 minutes in the future so users are alerted even if they leave the app.【F:ForestFocus/ForestFocus/Views/TimerView.swift†L92-L105】【F:ForestFocus/ForestFocus/Services/NotificationService.swift†L18-L41】
- Pausing or cancelling clears pending notifications, while resuming re-schedules them with the remaining time.【F:ForestFocus/ForestFocus/Views/TimerView.swift†L106-L148】【F:ForestFocus/ForestFocus/Services/NotificationService.swift†L43-L49】
- Scene transitions trigger recalculation of elapsed time using the monotonic clock to avoid drift from manual clock edits or background execution pauses.【F:ForestFocus/ForestFocus/Services/SessionManager.swift†L14-L43】【F:ForestFocus/ForestFocus/Services/TimerService.swift†L80-L163】

## Testing
ForestFocus ships with Swift's new `Testing` target scaffolded and ready for unit or UI tests. Add async `@Test` cases under `ForestFocusTests` to verify timer logic, stats aggregation, or anti-tamper guards as the app evolves.【F:ForestFocus/ForestFocusTests/ForestFocusTests.swift†L1-L15】

## Roadmap Ideas
- Customize focus durations and break timers
- Surface anti-tamper event history in the UI
- Add widgets or Live Activities for at-a-glance progress
- Expand the forest with seasonal or streak-based tree variations

---
Happy focusing! 🌲
