import Foundation

/// Тактильні сигнали, які потрібні дихальній вправі (без прив'язки до CoreHaptics).
enum HapticCue: Equatable {
    case inhale(duration: TimeInterval)
    case hold
    case exhale(duration: TimeInterval)
    case completed
}

protocol HapticsProviding {
    func prepare()
    func play(_ cue: HapticCue)
    func stop()
}

/// Порожня реалізація — для симулятора, тестів і демо-режиму.
struct NoOpHaptics: HapticsProviding {
    func prepare() {}
    func play(_ cue: HapticCue) {}
    func stop() {}
}
