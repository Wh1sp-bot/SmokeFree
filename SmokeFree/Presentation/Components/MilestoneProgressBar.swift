import SwiftUI

/// Смуга прогресу. При появі плавно «заповнюється» до значення (анімація стану).
struct MilestoneProgressBar: View {
    let fraction: Double
    @State private var displayed: Double = 0
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .leading) {
                Capsule().fill(Color.secondary.opacity(0.2))
                Capsule()
                    .fill(Color.accentColor)
                    .frame(width: max(0, proxy.size.width * displayed))
            }
        }
        .frame(height: 8)
        .onAppear { update(animated: true) }
        .onChange(of: fraction) { update(animated: true) }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Прогрес")
        .accessibilityValue("\(Int(fraction * 100)) відсотків")
    }

    private func update(animated: Bool) {
        let target = min(1, max(0, fraction))
        if animated && !reduceMotion {
            withAnimation(.easeOut(duration: 0.8)) { displayed = target }
        } else {
            displayed = target
        }
    }
}
