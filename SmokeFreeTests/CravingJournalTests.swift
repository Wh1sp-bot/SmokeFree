import XCTest
@testable import SmokeFree

final class CravingJournalTests: XCTestCase {
    private let now = Date(timeIntervalSince1970: 1_700_000_000)

    private func event(_ trigger: CravingTrigger, completed: Bool = true) -> CravingEvent {
        CravingEvent(startedAt: now, duration: 180, wasCompleted: completed, trigger: trigger)
    }

    func testAddAndCounts() {
        let journal = CravingJournal()
        journal.add(event(.coffee))
        journal.add(event(.stress, completed: false))
        XCTAssertEqual(journal.events.count, 2)
        XCTAssertEqual(journal.completedCount, 1)
    }

    func testFilterByTrigger() {
        let journal = CravingJournal(events: [event(.coffee), event(.stress), event(.coffee)])
        XCTAssertEqual(journal.events(triggeredBy: .coffee).count, 2)
        XCTAssertTrue(journal.events(triggeredBy: .alcohol).isEmpty)
    }

    func testMostCommonTriggerIsNilForEmptyJournal() {
        XCTAssertNil(CravingJournal().mostCommonTrigger())
    }

    func testMostCommonTrigger() {
        let journal = CravingJournal(events: [event(.coffee), event(.stress), event(.stress)])
        XCTAssertEqual(journal.mostCommonTrigger(), .stress)
    }

    /// class має семантику посилання: дві змінні вказують на один об'єкт.
    func testClassHasReferenceSemantics() {
        let journal = CravingJournal()
        let alias = journal
        alias.add(event(.other))
        XCTAssertEqual(journal.events.count, 1)
        XCTAssertTrue(journal === alias)
    }
}
