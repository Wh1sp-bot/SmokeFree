import Foundation

enum BreathingPhaseKind: Equatable {
    case inhale
    case holdFull
    case exhale
    case holdEmpty

    var title: String {
        switch self {
        case .inhale: return "Вдих"
        case .holdFull: return "Затримка"
        case .exhale: return "Видих"
        case .holdEmpty: return "Пауза"
        }
    }

    /// Цільовий масштаб кола наприкінці фази (для анімації): повне після вдиху, мале після видиху.
    var endScale: Double {
        switch self {
        case .inhale, .holdFull: return 1.0
        case .exhale, .holdEmpty: return 0.55
        }
    }
}

struct BreathingPhase: Equatable {
    let kind: BreathingPhaseKind
    let duration: TimeInterval
}

/// **Патерн Strategy (поведінковий).**
/// Різні техніки дихання — взаємозамінні алгоритми з однаковим інтерфейсом.
/// `BreathingViewModel` працює з протоколом і не знає, яка саме техніка обрана.
/// Нова техніка = новий тип; існуючий код не змінюється (Open/Closed).
protocol BreathingPattern {
    var id: String { get }
    var title: String { get }
    var summary: String { get }
    var phases: [BreathingPhase] { get }
}

extension BreathingPattern {
    var cycleDuration: TimeInterval {
        phases.reduce(0) { $0 + $1.duration }
    }
}

/// «Квадратне» дихання 4-4-4-4.
struct BoxBreathing: BreathingPattern {
    let id = "box"
    let title = "Квадратне 4-4-4-4"
    let summary = "Рівні вдих, затримка, видих і пауза — швидко заспокоює."
    let phases = [
        BreathingPhase(kind: .inhale, duration: 4),
        BreathingPhase(kind: .holdFull, duration: 4),
        BreathingPhase(kind: .exhale, duration: 4),
        BreathingPhase(kind: .holdEmpty, duration: 4)
    ]
}

/// Техніка 4-7-8.
struct FourSevenEightBreathing: BreathingPattern {
    let id = "478"
    let title = "4-7-8"
    let summary = "Довга затримка та повільний видих знімають напругу."
    let phases = [
        BreathingPhase(kind: .inhale, duration: 4),
        BreathingPhase(kind: .holdFull, duration: 7),
        BreathingPhase(kind: .exhale, duration: 8)
    ]
}

/// Спокійне дихання 4-6: видих довший за вдих.
struct CalmBreathing: BreathingPattern {
    let id = "calm"
    let title = "Спокійне 4-6"
    let summary = "Простий ритм без затримок — для початківців."
    let phases = [
        BreathingPhase(kind: .inhale, duration: 4),
        BreathingPhase(kind: .exhale, duration: 6)
    ]
}

enum BreathingPatterns {
    static let all: [any BreathingPattern] = [CalmBreathing(), BoxBreathing(), FourSevenEightBreathing()]
}
