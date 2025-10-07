import Foundation

extension Date {
    /// Returns the start of day (midnight) for this date
    /// Uses current calendar (respects user's locale and timezone)
    /// - Returns: Date normalized to 00:00:00
    func startOfDay() -> Date {
        return Calendar.current.startOfDay(for: self)
    }

    /// Checks if this date is the same calendar day as another date
    /// - Parameter otherDate: The date to compare with
    /// - Returns: True if both dates are on the same calendar day
    func isSameDay(as otherDate: Date) -> Bool {
        let calendar = Calendar.current
        return calendar.isDate(self, inSameDayAs: otherDate)
    }

    /// Returns the number of days between this date and another date
    /// - Parameter otherDate: The date to compare with
    /// - Returns: Number of full calendar days between dates
    func daysBetween(_ otherDate: Date) -> Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: self.startOfDay(), to: otherDate.startOfDay())
        return abs(components.day ?? 0)
    }

    /// Checks if this date is consecutive to another date (exactly 1 day apart)
    /// - Parameter otherDate: The date to compare with
    /// - Returns: True if dates are exactly 1 day apart
    func isConsecutiveDay(after otherDate: Date) -> Bool {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: otherDate.startOfDay(), to: self.startOfDay())
        return components.day == 1
    }
}
