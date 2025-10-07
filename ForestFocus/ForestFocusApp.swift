//
//  ForestFocusApp.swift
//  ForestFocus
//
//  Created by charles qin on 10/6/25.
//

import SwiftUI
import SwiftData

@main
struct ForestFocusApp: App {
    let modelContainer: ModelContainer

    init() {
        do {
            // Configure SwiftData ModelContainer for all models
            modelContainer = try ModelContainer(
                for: FocusSession.self,
                     CompletedTree.self,
                     StreakData.self,
                     AntiTamperEvent.self
            )
        } catch {
            fatalError("Failed to initialize ModelContainer: \(error.localizedDescription)")
        }

        // Request notification permissions on first launch
        Task {
            _ = await NotificationService.shared.requestAuthorization()
        }
    }

    var body: some Scene {
        WindowGroup {
            TabView {
                TimerView()
                    .tabItem {
                        Label("Timer", systemImage: "timer")
                    }

                ForestView()
                    .tabItem {
                        Label("Forest", systemImage: "tree.fill")
                    }

                StatsView()
                    .tabItem {
                        Label("Stats", systemImage: "chart.bar.fill")
                    }
            }
            .modelContainer(modelContainer)
        }
    }
}
