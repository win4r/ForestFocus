import Foundation
import SwiftData

@MainActor
class ForestService {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func fetchAllTrees() async throws -> [CompletedTree] {
        let descriptor = FetchDescriptor<CompletedTree>(
            sortBy: [SortDescriptor(\.completionTime, order: .reverse)]
        )
        return try modelContext.fetch(descriptor)
    }

    func fetchTrees(for date: Date) async throws -> [CompletedTree] {
        let startDay = date.startOfDay()
        let descriptor = FetchDescriptor<CompletedTree>(
            predicate: #Predicate { $0.startDay == startDay }
        )
        return try modelContext.fetch(descriptor)
    }

    var totalTreeCount: Int {
        get async throws {
            let descriptor = FetchDescriptor<CompletedTree>()
            return try modelContext.fetchCount(descriptor)
        }
    }

    func addTree(from session: FocusSession) async throws -> CompletedTree {
        guard session.status == .completed else {
            throw ForestError.sessionNotCompleted
        }

        let tree = CompletedTree(from: session)
        modelContext.insert(tree)
        try modelContext.save()

        return tree
    }

    var totalFocusMinutes: Int {
        get async throws {
            let count = try await totalTreeCount
            return count * 25 // Each tree = 25 minutes
        }
    }

    func todaysTrees() async throws -> [CompletedTree] {
        let today = Date().startOfDay()
        return try await fetchTrees(for: today)
    }
}

enum ForestError: Error {
    case sessionNotCompleted
}
