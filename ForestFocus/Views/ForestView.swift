import SwiftUI
import SwiftData

struct ForestView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \CompletedTree.completionTime, order: .reverse) private var trees: [CompletedTree]

    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var body: some View {
        NavigationStack {
            Group {
                if trees.isEmpty {
                    emptyState
                } else {
                    forestGrid
                }
            }
            .navigationTitle("Forest")
        }
    }

    private var emptyState: some View {
        VStack(spacing: 24) {
            Image(systemName: "tree.fill")
                .font(.system(size: 80))
                .foregroundColor(.green.opacity(0.3))

            Text("Plant your first tree!")
                .font(.title.bold())
                .foregroundColor(.primary)

            Text("Complete a focus session to grow your first tree and start building your forest.")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .accessibilityLabel("No trees planted yet")
        .accessibilityHint("Complete a focus session to grow your first tree")
    }

    private var forestGrid: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(Array(trees.enumerated()), id: \.element.id) { index, tree in
                    TreeCell(tree: tree, index: index)
                }
            }
            .padding()
        }
    }
}

struct TreeCell: View {
    let tree: CompletedTree
    let index: Int

    var body: some View {
        VStack {
            TreeAnimationView(stage: tree.visualStage)
                .frame(height: 80)

            Text(formattedDate)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding(8)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(8)
        .accessibilityLabel("Completed tree")
        .accessibilityValue("Planted on \(formattedDate)")
        .accessibilityIdentifier("tree-cell-\(index)")
    }

    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        return formatter.string(from: tree.startDay)
    }
}
