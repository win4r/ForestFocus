# ForestFocus

A beautiful iOS productivity app that helps you stay focused by growing virtual trees. Built with SwiftUI and SwiftData, ForestFocus gamifies the Pomodoro Technique to make focus sessions more engaging and rewarding.

## Overview

ForestFocus combines proven productivity techniques with delightful animations to help you build better focus habits. Each 25-minute focus session grows a virtual tree in your personal forest. Stay focused, grow your forest, and track your productivity over time.

## Features

### 🌱 Focus Timer
- **25-minute focus sessions** based on the Pomodoro Technique
- **Visual tree growth** - watch your tree grow through 5 stages as you focus
- **Pause & Resume** - life happens, pause when needed and pick up where you left off
- **Session controls** - start, pause, resume, or cancel sessions with intuitive controls

### 🌳 Personal Forest
- **Collect completed trees** - every successful focus session adds a tree to your forest
- **Visual progress tracking** - see your productivity forest grow over time
- **Persistent storage** - your forest is saved using SwiftData

### 📊 Statistics & Insights
- **Daily, weekly, and monthly stats** - track your focus time and trends
- **Streak tracking** - maintain your focus habit with daily streaks
- **Productivity metrics** - see completion rates and total focus time
- **Visual analytics** - beautiful charts and cards display your progress

### 🔔 Notifications
- **Session completion alerts** - get notified when your focus session is complete
- **Background support** - timer continues running even when app is minimized
- **Smart scheduling** - notifications adapt to your session state (pause/resume)

### 🛡️ Anti-Tamper Protection
- **Monotonic clock** - prevents time manipulation
- **Tamper event logging** - tracks suspicious activity
- **Fair play enforcement** - ensures authentic productivity tracking

## Technical Stack

- **SwiftUI** - Modern declarative UI framework
- **SwiftData** - Apple's latest data persistence framework
- **Combine** - Reactive programming for timer updates
- **UserNotifications** - Background notifications and alerts
- **Xcode 15+** - Built for iOS 17+

## Project Structure

```
ForestFocus/
├── ForestFocus/
│   ├── Models/
│   │   ├── FocusSession.swift      # Focus session data model
│   │   ├── CompletedTree.swift     # Completed tree records
│   │   ├── StreakData.swift        # Daily streak tracking
│   │   └── AntiTamperEvent.swift   # Tamper detection logs
│   ├── Views/
│   │   ├── TimerView.swift         # Main timer interface
│   │   ├── ForestView.swift        # Forest visualization
│   │   ├── StatsView.swift         # Statistics dashboard
│   │   └── Components/
│   │       ├── CountdownTimerView.swift
│   │       ├── TreeAnimationView.swift
│   │       └── StatCardView.swift
│   ├── Services/
│   │   ├── TimerService.swift      # Timer logic and state management
│   │   ├── SessionManager.swift    # Session lifecycle management
│   │   ├── ForestService.swift     # Forest data operations
│   │   ├── StatsCalculator.swift   # Statistics computation
│   │   └── NotificationService.swift
│   ├── Utils/
│   │   ├── DateExtensions.swift
│   │   └── MonotonicClock.swift    # Anti-tamper timing
│   └── ForestFocusApp.swift        # App entry point
├── ForestFocusTests/               # Unit tests
└── ForestFocusUITests/             # UI tests
```

## Getting Started

### Prerequisites

- **macOS Ventura** or later
- **Xcode 15.0** or later
- **iOS 17.0+** target device or simulator

### Installation

1. Clone the repository:
```bash
git clone https://github.com/win4r/ForestFocus.git
cd ForestFocus
```

2. Open the project in Xcode:
```bash
open ForestFocus.xcodeproj
```

3. Select your target device or simulator

4. Build and run the project (⌘ + R)

### First Launch

On first launch, the app will request notification permissions. Grant these to receive alerts when your focus sessions complete.

## Usage

1. **Start a Focus Session**
   - Tap "Start Focus" on the Timer tab
   - Watch your tree begin to grow
   - Stay in the app or minimize - the timer continues

2. **Complete Your Session**
   - Work for 25 minutes to fully grow your tree
   - Receive a notification when complete
   - Your tree is added to your forest

3. **View Your Progress**
   - Check the Forest tab to see all your completed trees
   - Visit the Stats tab for detailed productivity insights
   - Track your streaks and maintain your focus habit

4. **Pause When Needed**
   - Life happens - use the pause button when needed
   - Resume when you're ready to continue
   - Your progress is saved

## Data Models

### FocusSession
Tracks active and historical focus sessions with:
- Start/end times and duration
- Session status (active, paused, completed, abandoned)
- Tree growth stage (1-5)
- Monotonic clock reference for tamper detection

### CompletedTree
Records successfully completed 25-minute sessions for forest visualization

### StreakData
Maintains daily focus streaks and completion statistics

### AntiTamperEvent
Logs suspicious system time changes to ensure data integrity

## Architecture

ForestFocus follows a clean MVVM-inspired architecture:

- **Models**: SwiftData models for persistence
- **Views**: SwiftUI views with reactive bindings
- **Services**: Business logic and state management
- **Utils**: Shared utilities and extensions

The app uses Combine publishers for reactive timer updates and state synchronization.

## Testing

Run the test suite:

```bash
# Run unit tests
⌘ + U in Xcode

# Or via command line
xcodebuild test -scheme ForestFocus -destination 'platform=iOS Simulator,name=iPhone 15'
```

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## License

This project is available for personal and educational use.

## Author

Created by Charles Qin

## Acknowledgments

- Inspired by the Pomodoro Technique by Francesco Cirillo
- Tree growth concept inspired by Forest app
- Built with Apple's modern SwiftUI and SwiftData frameworks

---

**Start growing your focus forest today!** 🌳
