import SwiftUI

struct CountdownTimerView: View {
    let remainingSeconds: Int

    var body: some View {
        Text(formattedTime)
            .font(.system(size: 72, weight: .bold, design: .monospaced))
            .foregroundColor(.primary)
            .accessibilityLabel("Time remaining")
            .accessibilityValue("\(minutes) minutes, \(seconds) seconds remaining")
            .accessibilityIdentifier("countdown-timer")
    }

    private var formattedTime: String {
        String(format: "%02d:%02d", minutes, seconds)
    }

    private var minutes: Int {
        remainingSeconds / 60
    }

    private var seconds: Int {
        remainingSeconds % 60
    }
}
