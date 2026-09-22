import XCTest
@testable import SmokeFree

final class MilestoneTimelineTests: XCTestCase {
    private let timeline = MilestoneTimeline()

    func testNothingReachedAtStart() {
        XCTAssertTrue(timeline.reached(after: 0).isEmpty)
        XCTAssertEqual(timeline.next(after: 0)?.id, "m20min")
    }

    func testReachedAfterOneDay() {
        let ids = timeline.reached(after: TimeSpan.day).map(\.id)
        XCTAssertEqual(ids, ["m20min", "m24h"])
        XCTAssertEqual(timeline.next(after: TimeSpan.day)?.id, "m48h")
    }

    func testNextIsNilWhenEverythingReached() {
        XCTAssertNil(timeline.next(after: 11 * TimeSpan.year))
        XCTAssertEqual(timeline.fractionToNext(after: 11 * TimeSpan.year), 1)
    }

    func testNewlyReachedWindow() {
        let ids = timeline.newlyReached(from: TimeSpan.hour, to: 25 * TimeSpan.hour).map(\.id)
        XCTAssertEqual(ids, ["m24h"])
        XCTAssertTrue(timeline.newlyReached(from: 25 * TimeSpan.hour, to: 26 * TimeSpan.hour).isEmpty)
    }

    func testFractionToNextIsRelativeToPreviousMilestone() {
        // Між 24 год і 48 год: середина = 36 год → 0.5
        XCTAssertEqual(timeline.fractionToNext(after: 36 * TimeSpan.hour), 0.5, accuracy: 0.0001)
    }

    func testLookupByID() {
        XCTAssertNotNil(timeline.milestone(withID: "m1y"))
        XCTAssertNil(timeline.milestone(withID: "unknown"))
    }
}
