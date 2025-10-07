import SwiftUI

struct TreeAnimationView: View {
    let stage: Int // 1-5

    var body: some View {
        Image(systemName: "tree.fill")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .foregroundColor(colorForStage(stage))
            .scaleEffect(scaleForStage(stage))
            .opacity(opacityForStage(stage))
            .animation(.easeInOut(duration: 1.0), value: stage)
            .accessibilityLabel("Growing tree")
            .accessibilityValue("Stage \(stage) of 5")
            .accessibilityIdentifier("tree-animation")
    }

    private func scaleForStage(_ s: Int) -> CGFloat {
        // Stage 1 = 0.36, Stage 5 = 1.0
        return 0.2 + (CGFloat(s) * 0.16)
    }

    private func opacityForStage(_ s: Int) -> Double {
        // Stage 1 = 0.44, Stage 5 = 1.0
        return 0.3 + (Double(s) * 0.14)
    }

    private func colorForStage(_ s: Int) -> Color {
        switch s {
        case 1:
            return .green.opacity(0.4)
        case 2:
            return .green.opacity(0.6)
        case 3:
            return .green.opacity(0.8)
        case 4:
            return .green
        default:
            return .green
        }
    }
}
