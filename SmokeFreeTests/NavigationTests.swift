import XCTest
@testable import SmokeFree

@MainActor
final class AppRouterTests: XCTestCase {
    func testPushAndPop() {
        let router = AppRouter()
        XCTAssertTrue(router.path.isEmpty)
        router.push(.history)
        router.push(.milestoneDetail(id: "m1y"))
        XCTAssertEqual(router.path.count, 2)
        router.pop()
        XCTAssertEqual(router.path.count, 1)
        router.popToRoot()
        XCTAssertTrue(router.path.isEmpty)
    }

    func testPopOnEmptyPathIsNoOp() {
        let router = AppRouter()
        router.pop()
        XCTAssertTrue(router.path.isEmpty)
    }

    func testSheetPresentationAndDismissal() {
        let router = AppRouter()
        XCTAssertNil(router.presentedSheet)
        router.presentEditProfile()
        XCTAssertEqual(router.presentedSheet, .editProfile)
        router.dismissSheet()
        XCTAssertNil(router.presentedSheet)

        let event = CravingEvent(startedAt: Fixtures.now, duration: 60, wasCompleted: true)
        router.presentNote(for: event)
        XCTAssertEqual(router.presentedSheet, .addCravingNote(event))
    }

    /// Перехід зі сповіщення: перемикає вкладку, скидає стек і відкриває деталі.
    func testShowMilestoneDetailFromAnotherTab() {
        let router = AppRouter()
        router.selectedTab = .sos
        router.push(.history)
        router.showMilestoneDetail(id: "m24h")
        XCTAssertEqual(router.selectedTab, .progress)
        XCTAssertEqual(router.path.count, 1)
    }
}

@MainActor
final class HistoryViewModelTests: XCTestCase {
    func testEventsAreSortedNewestFirst() {
        let journal = MockJournal()
        journal.add(CravingEvent(startedAt: Fixtures.now, duration: 60, wasCompleted: true))
        journal.add(CravingEvent(startedAt: Fixtures.now.addingTimeInterval(3600), duration: 60, wasCompleted: false))
        let vm = HistoryViewModel(journal: journal)
        XCTAssertEqual(vm.events.first?.startedAt, Fixtures.now.addingTimeInterval(3600))
    }

    func testUpdateNoteUpdatesUnderlyingEvent() {
        let journal = MockJournal()
        let event = CravingEvent(startedAt: Fixtures.now, duration: 60, wasCompleted: true)
        journal.add(event)
        let vm = HistoryViewModel(journal: journal)
        vm.updateNote(for: event, note: "Після обіду")
        XCTAssertEqual(journal.events.first?.note, "Після обіду")
    }

    func testUpdateNoteWithUnknownIDIsNoOp() {
        let journal = MockJournal()
        let vm = HistoryViewModel(journal: journal)
        let ghost = CravingEvent(startedAt: Fixtures.now, duration: 10, wasCompleted: true)
        vm.updateNote(for: ghost, note: "x")
        XCTAssertTrue(journal.events.isEmpty)
    }
}

@MainActor
final class MilestoneDetailViewModelTests: XCTestCase {
    func testSnapshotForReachedMilestone() {
        let repository = MockProfileRepository(profile: Fixtures.profile())
        let vm = MilestoneDetailViewModel(
            milestoneID: "m20min", repository: repository,
            calculator: ProgressCalculator(), timeline: MilestoneTimeline()
        )
        let snapshot = vm.snapshot(at: Fixtures.now.addingTimeInterval(TimeSpan.hour))
        XCTAssertEqual(snapshot?.isReached, true)
        XCTAssertEqual(snapshot?.fraction, 1)
    }

    func testSnapshotIsNilForUnknownMilestone() {
        let repository = MockProfileRepository(profile: Fixtures.profile())
        let vm = MilestoneDetailViewModel(
            milestoneID: "unknown", repository: repository,
            calculator: ProgressCalculator(), timeline: MilestoneTimeline()
        )
        XCTAssertNil(vm.snapshot(at: Fixtures.now))
    }

    func testSnapshotIsNilWithoutProfile() {
        let vm = MilestoneDetailViewModel(
            milestoneID: "m20min", repository: MockProfileRepository(),
            calculator: ProgressCalculator(), timeline: MilestoneTimeline()
        )
        XCTAssertNil(vm.snapshot(at: Fixtures.now))
    }
}
