import SwiftUI

// Compact step indicator to guide the user through the single-screen flow.
struct StepBar: View {
    let current: Int
    let step1: String
    let step2: String
    let step3: String

    var body: some View {
        HStack(spacing: 0) {
            StepNode(index: 1, current: current, title: step1)
            StepConnector(isActive: current > 1)
            StepNode(index: 2, current: current, title: step2)
            StepConnector(isActive: current > 2)
            StepNode(index: 3, current: current, title: step3)
        }
    }
}

private struct StepNode: View {
    let index: Int
    let current: Int
    let title: String

    var body: some View {
        VStack(spacing: 6) {
            ZStack {
                Circle()
                    .fill(isActive ? Color.accentColor.opacity(0.2) : Color.secondary.opacity(0.15))
                Text("\(index)")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(isActive ? .primary : .secondary)
            }
            .frame(width: 22, height: 22)

            Text(title)
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(isActive ? .primary : .secondary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 120)
        }
        .frame(maxWidth: .infinity)
    }

    private var isActive: Bool { index <= current }
}

private struct StepConnector: View {
    let isActive: Bool

    var body: some View {
        Rectangle()
            .fill(isActive ? Color.accentColor.opacity(0.35) : Color.secondary.opacity(0.2))
            .frame(height: 2)
            .padding(.horizontal, 6)
    }
}
