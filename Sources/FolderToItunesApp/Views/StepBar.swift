import SwiftUI

// Compact step indicator to guide the user through the single-screen flow.
struct StepBar: View {
    let current: Int
    let step1: String
    let step2: String
    let step3: String

    var body: some View {
        HStack(spacing: 10) {
            StepPill(index: 1, current: current, title: step1)
            StepPill(index: 2, current: current, title: step2)
            StepPill(index: 3, current: current, title: step3)
        }
    }
}

private struct StepPill: View {
    let index: Int
    let current: Int
    let title: String

    var body: some View {
        HStack(spacing: 6) {
            Text("\(index)")
                .font(.system(size: 11, weight: .semibold))
                .frame(width: 18, height: 18)
                .background(isActive ? Color.accentColor.opacity(0.2) : Color.secondary.opacity(0.15))
                .clipShape(Circle())
            Text(title)
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(isActive ? .primary : .secondary)
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 10)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(isActive ? Color.accentColor.opacity(0.08) : Color.secondary.opacity(0.08))
        )
    }

    private var isActive: Bool { index <= current }
}
