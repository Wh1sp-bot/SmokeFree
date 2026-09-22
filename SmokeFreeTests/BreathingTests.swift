import XCTest
@testable import SmokeFree

final class BreathingScheduleTests: XCTestCase {
    func testBoxPhasesOverTime() {
        let schedule = BreathingSchedule(pattern: BoxBreathing(), totalDuration: 180)
        XCTAssertEqual(schedule.state(at: 0).phase.kind, .inhale)
        XCTAssertEqual(schedule.state(at: 3.9).phase.kind, .inhale)
        XCTAssertEqual(schedule.state(at: 4).phase.kind, .holdFull)
        XCTAssertEqual(schedule.state(at: 8).phase.kind, .exhale)
        XCTAssertEqual(schedule.state(at: 12).phase.kind, .holdEmpty)
        // Другий цикл
        let second = schedule.state(at: 16)
        XCTAssertEqual(second.phase.kind, .inhale)
        XCTAssertEqual(second.cycle, 2)
        XCTAssertEqual(second.phaseCounter, 4)
    }

    func testFinishesAtTotalDuration() {
        let schedule = BreathingSchedule(pattern: BoxBreathing(), totalDuration: 180)
        XCTAssertFalse(schedule.state(at: 179.9).isFinished)
        XCTAssertTrue(schedule.state(at: 180).isFinished)
        XCTAssertEqual(schedule.state(at: 500).remaining, 0)
    }

    func testPhaseProgress() {
        let schedule = BreathingSchedule(pattern: BoxBreathing(), totalDuration: 180)
        XCTAssertEqual(schedule.state(at: 2).phaseProgress, 0.5, accuracy: 0.0001)
    }

    /// Strategy: різні техніки — різні розклади за того самого коду розрахунку.
    func testStrategiesAreInterchangeable() {
        let calm = BreathingSchedule(pattern: CalmBreathing(), totalDuration: 180)
        let four78 = BreathingSchedule(pattern: FourSevenEightBreathing(), totalDuration: 180)
        XCTAssertEqual(calm.state(at: 4).phase.kind, .exhale)
        XCTAssertEqual(four78.state(at: 4).phase.kind, .holdFull)
        XCTAssertEqual(CalmBreathing().cycleDuration, 10)
        XCTAssertEqual(FourSevenEightBreathing().cycleDuration, 19)
    }
}

@MainActor
final class BreathingViewModelTests: XCTestCase {
    private var haptics: SpyHaptics!
    private var journal: MockJournal!
    private var now: Date!
    private var viewModel: BreathingViewModel!

    override func setUp() {
        super.setUp()
        haptics = SpyHaptics()
        journal = MockJournal()
        now = Fixtures.now
        viewModel = BreathingViewModel(
            patterns: [BoxBreathing()], haptics: haptics, journal: journal, clock: { [unowned self] in self.now }
        )
    }

    func testStartPlaysFirstCueAndRuns() {
        viewModel.start()
        viewModel.stop() // зупиняємо фоновий таймер
        XCTAssertEqual(haptics.prepareCount, 1)
        XCTAssertEqual(haptics.cues.first, .inhale(duration: 4))
    }

    func testPhaseChangeTriggersHaptics() {
        viewModel.start()
        viewModel.tick(now: Fixtures.now.addingTimeInterval(4.5)) // → затримка
        viewModel.tick(now: Fixtures.now.addingTimeInterval(8.5)) // → видих
        viewModel.stop()
        XCTAssertEqual(haptics.cues, [.inhale(duration: 4), .hold, .exhale(duration: 4)])
    }

    func testCompletionLogsEventAndPlaysSuccess() {
        viewModel.selectedTrigger = .coffee
        viewModel.start()
        viewModel.tick(now: Fixtures.now.addingTimeInterval(BreathingViewModel.sessionDuration))
        XCTAssertEqual(viewModel.status, .finished)
        XCTAssertEqual(haptics.cues.last, .completed)
        XCTAssertEqual(journal.events.count, 1)
        XCTAssertEqual(journal.events.first?.wasCompleted, true)
        XCTAssertEqual(journal.events.first?.trigger, .coffee)
    }

    func testEarlyStopBelowThresholdIsNotLogged() {
        viewModel.start()
        viewModel.tick(now: Fixtures.now.addingTimeInterval(10))
        viewModel.stop()
        XCTAssertTrue(journal.events.isEmpty)
        XCTAssertEqual(viewModel.status, .idle)
    }

    func testEarlyStopAfterThresholdIsLoggedAsIncomplete() {
        viewModel.start()
        viewModel.tick(now: Fixtures.now.addingTimeInterval(45))
        viewModel.stop()
        XCTAssertEqual(journal.events.count, 1)
        XCTAssertEqual(journal.events.first?.wasCompleted, false)
    }

    func testPatternCannotChangeWhileRunning() {
        let vm = BreathingViewModel(patterns: [BoxBreathing(), CalmBreathing()], haptics: haptics, journal: journal)
        vm.start()
        vm.select(patternID: "calm")
        XCTAssertEqual(vm.selectedPatternID, "box")
        vm.stop()
        vm.select(patternID: "calm")
        XCTAssertEqual(vm.selectedPatternID, "calm")
    }
}
