import SwiftUI
import SwiftData

struct StatsView: View {
    @Environment(\.modelContext) private var modelContext

    @State private var totalTrees: Int = 0
    @State private var focusTime: FocusTime = FocusTime(totalMinutes: 0)
    @State private var todayTrees: Int = 0
    @State private var currentStreak: Int = 0

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Grid of stat cards
                    VStack(spacing: 16) {
                        HStack(spacing: 16) {
                            StatCardView(
                                title: "Total Trees",
                                value: "\(totalTrees)"
                            )
                            StatCardView(
                                title: "Focus Time",
                                value: focusTimeValue
                            )
                        }

                        HStack(spacing: 16) {
                            StatCardView(
                                title: "Today",
                                value: "\(todayTrees)"
                            )
                            StatCardView(
                                title: "Streak",
                                value: "\(currentStreak) days"
                            )
                        }
                    }
                    .padding()

                    Spacer()
                }
            }
            .navigationTitle("Stats")
            .onAppear {
                Task {
                    await refreshStats()
                }
            }
        }
    }

    private var focusTimeValue: String {
        if focusTime.hours == 0 {
            return "\(focusTime.minutes)m"
        } else if focusTime.minutes == 0 {
            return "\(focusTime.hours)h"
        } else {
            return "\(focusTime.hours)h \(focusTime.minutes)m"
        }
    }

    private func refreshStats() async {
        let calculator = StatsCalculator(modelContext: modelContext)

        do {
            totalTrees = try await calculator.totalTreesPlanted()
            focusTime = try await calculator.totalFocusTime()
            todayTrees = try await calculator.todaysTreeCount()
            currentStreak = try await calculator.currentStreak()
        } catch {
            print("Failed to refresh stats: \(error)")
        }
    }
}
