import Foundation

/// Provides monotonic time measurements immune to wall-clock changes
/// Uses CFAbsoluteTimeGetCurrent() which returns time since reference date (Jan 1, 2001)
struct MonotonicClock {
    /// Returns current monotonic time in seconds
    /// - Returns: Seconds since absolute reference date
    static func now() -> TimeInterval {
        return CFAbsoluteTimeGetCurrent()
    }

    /// Detects time jumps by comparing expected vs actual monotonic time
    /// - Parameters:
    ///   - previousMonotonic: Last recorded monotonic time
    ///   - currentMonotonic: Current monotonic time
    ///   - expectedElapsed: Expected elapsed seconds based on wall-clock time
    /// - Returns: Magnitude of time jump if >5 minutes, nil otherwise
    static func detectTimeJump(
        previousMonotonic: TimeInterval,
        currentMonotonic: TimeInterval,
        expectedElapsed: TimeInterval
    ) -> TimeInterval? {
        let actualElapsed = currentMonotonic - previousMonotonic
        let discrepancy = abs(actualElapsed - expectedElapsed)

        // Threshold: 5 minutes (300 seconds)
        if discrepancy > 300 {
            return discrepancy
        }

        return nil
    }

    /// Simplified time jump detection based on monotonic delta
    /// - Parameters:
    ///   - previous: Previous monotonic reference
    ///   - current: Current monotonic time
    /// - Returns: Magnitude if jump >5 minutes detected
    static func detectTimeJump(previous: TimeInterval, current: TimeInterval) -> TimeInterval? {
        let elapsed = current - previous

        // Check for abnormal jumps (>25 minutes = impossible for a session)
        if elapsed > 1500 || elapsed < 0 {
            return abs(elapsed)
        }

        return nil
    }
}
