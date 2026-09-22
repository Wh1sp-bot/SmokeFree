import Foundation
import Observation

/// View Model екрана «SOS / Подолання тяги»: 3-хвилинна дихальна вправа із вібрацією.
///
/// Залежності передаються ззовні (DI) і є абстракціями: техніка дихання
/// (`BreathingPattern` — Strategy), вібрація (`HapticsProviding`), журнал
/// (`CravingLogging`), годинник (`clock`). Завдяки цьому вправу можна
/// перевірити в тесті без реального часу та вібромотора.
@MainActor
@Observable
final class BreathingViewModel {
    enum Status: Equatable {
        case idle
        case running
        case finished
    }

    static let sessionDuration: TimeInterval = 3 * TimeSpan.minute
    /// Коротші перервані сеанси не потрапляють у журнал.
    static let minimumLoggedDuration: TimeInterval = 30

    private(set) var status: Status = .idle
    private(set) var state: BreathingState
    private(set) var selectedPatternID: String
    var selectedTrigger: CravingTrigger = .other

    let patterns: [any BreathingPattern]

    private let haptics: HapticsProviding
    private let journal: CravingLogging
    private let clock: () -> Date
    @ObservationIgnored private var startDate: Date?
    @ObservationIgnored private var timerTask: Task<Void, Never>?

    init(
        patterns: [any BreathingPattern] = BreathingPatterns.all,
        haptics: HapticsProviding,
        journal: CravingLogging,
        clock: @escaping () -> Date = { Date() }
    ) {
        precondition(!patterns.isEmpty, "Потрібна хоча б одна техніка дихання")
        self.patterns = patterns
        self.haptics = haptics
        self.journal = journal
        self.clock = clock
        let first = patterns[0]
        self.selectedPatternID = first.id
        self.state = BreathingSchedule(pattern: first, totalDuration: Self.sessionDuration).state(at: 0)
    }

    // MARK: - Похідні значення

    var pattern: any BreathingPattern {
        patterns.first { $0.id == selectedPatternID } ?? patterns[0]
    }

    private var schedule: BreathingSchedule {
        BreathingSchedule(pattern: pattern, totalDuration: Self.sessionDuration)
    }

    // MARK: - Дії

    func select(patternID: String) {
        guard status != .running, patterns.contains(where: { $0.id == patternID }) else { return }
        selectedPatternID = patternID
        status = .idle
        state = schedule.state(at: 0)
    }

    func start() {
        guard status != .running else { return }
        haptics.prepare()
        startDate = clock()
        status = .running
        state = schedule.state(at: 0)
        haptics.play(cue(for: state.phase))

        timerTask?.cancel()
        timerTask = Task { [weak self] in
            while !Task.isCancelled {
                try? await Task.sleep(for: .milliseconds(100))
                guard let self, !Task.isCancelled else { return }
                self.tick(now: self.clock())
                if self.status != .running { return }
            }
        }
    }

    /// Оновлює стан за поточним часом. Окремий метод, щоб тест міг «крутити» час вручну.
    func tick(now: Date) {
        guard status == .running, let startDate else { return }
        let previous = state
        let next = schedule.state(at: now.timeIntervalSince(startDate))
        state = next

        if next.isFinished {
            finish()
        } else if next.phaseCounter != previous.phaseCounter {
            haptics.play(cue(for: next.phase))
        }
    }

    /// Зупиняє вправу (кнопка «Зупинити» або закриття екрана).
    func stop() {
        timerTask?.cancel()
        timerTask = nil
        haptics.stop()
        guard status == .running else { return }

        let elapsed = state.elapsed
        if elapsed >= Self.minimumLoggedDuration, let startDate {
            log(startedAt: startDate, duration: elapsed, completed: false)
        }
        status = .idle
        state = schedule.state(at: 0)
        startDate = nil
    }

    // MARK: - Внутрішнє

    private func finish() {
        timerTask?.cancel()
        timerTask = nil
        status = .finished
        haptics.play(.completed)
        if let startDate {
            log(startedAt: startDate, duration: Self.sessionDuration, completed: true)
        }
        startDate = nil
    }

    private func log(startedAt: Date, duration: TimeInterval, completed: Bool) {
        journal.add(CravingEvent(
            startedAt: startedAt, duration: duration,
            wasCompleted: completed, trigger: selectedTrigger
        ))
    }

    private func cue(for phase: BreathingPhase) -> HapticCue {
        switch phase.kind {
        case .inhale: return .inhale(duration: phase.duration)
        case .exhale: return .exhale(duration: phase.duration)
        case .holdFull, .holdEmpty: return .hold
        }
    }
}
