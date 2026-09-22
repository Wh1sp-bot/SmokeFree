import Foundation

/// Миттєвий стан вправи.
struct BreathingState: Equatable {
    let phase: BreathingPhase
    /// Монотонний номер фази від початку сеансу — зручний тригер для анімації та вібрації.
    let phaseCounter: Int
    /// Частка поточної фази, що минула (0…1).
    let phaseProgress: Double
    let cycle: Int
    let elapsed: TimeInterval
    let remaining: TimeInterval
    let isFinished: Bool
}

/// Чиста функція «час → стан». Без таймерів і побічних ефектів, тому
/// тестується без UI та без очікування.
struct BreathingSchedule {
    let pattern: any BreathingPattern
    let totalDuration: TimeInterval

    func state(at elapsed: TimeInterval) -> BreathingState {
        let phases = pattern.phases
        let clamped = min(max(0, elapsed), totalDuration)
        let cycleLength = pattern.cycleDuration

        guard let first = phases.first, cycleLength > 0 else {
            return BreathingState(
                phase: BreathingPhase(kind: .holdEmpty, duration: 1), phaseCounter: 0, phaseProgress: 1,
                cycle: 1, elapsed: clamped, remaining: totalDuration - clamped, isFinished: true
            )
        }

        let completedCycles = Int(clamped / cycleLength)
        var offset = clamped - Double(completedCycles) * cycleLength
        var index = 0
        while index < phases.count - 1 && offset >= phases[index].duration {
            offset -= phases[index].duration
            index += 1
        }

        let phase = phases.indices.contains(index) ? phases[index] : first
        let progress = phase.duration > 0 ? min(1, offset / phase.duration) : 1

        return BreathingState(
            phase: phase,
            phaseCounter: completedCycles * phases.count + index,
            phaseProgress: progress,
            cycle: completedCycles + 1,
            elapsed: clamped,
            remaining: totalDuration - clamped,
            isFinished: clamped >= totalDuration
        )
    }
}
