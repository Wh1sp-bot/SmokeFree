import SwiftUI

/// Великий лічильник «дні / години / хвилини / секунди без нікотину».
struct TimeCounterCard: View {
    let progress: QuitProgress

    var body: some View {
        VStack(spacing: 10) {
            Text("Без нікотину")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                unit(progress.days, "дн")
                unit(progress.hours, "год")
                unit(progress.minutes, "хв")
                unit(progress.seconds, "с")
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .cardBackground()
        // Секунди не озвучуємо, щоб VoiceOver не «говорив» щосекунди.
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Без нікотину: \(progress.days) днів, \(progress.hours) годин, \(progress.minutes) хвилин")
    }

    private func unit(_ value: Int, _ label: String) -> some View {
        VStack(spacing: 2) {
            Text("\(value)")
                .font(.system(size: 34, weight: .bold, design: .rounded))
                .monospacedDigit()
                .minimumScaleFactor(0.5)
                .lineLimit(1)
                .contentTransition(.numericText())
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}
