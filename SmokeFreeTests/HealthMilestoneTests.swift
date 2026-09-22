import XCTest
@testable import SmokeFree

final class HealthMilestoneTests: XCTestCase {
    func testCatalogIsSortedAndIdsAreUnique() {
        let intervals = HealthMilestone.catalog.map(\.requiredInterval)
        XCTAssertEqual(intervals, intervals.sorted())
        let ids = HealthMilestone.catalog.map(\.id)
        XCTAssertEqual(Set(ids).count, ids.count)
    }

    func testIsReachedBoundary() throws {
        let milestone = try XCTUnwrap(HealthMilestone.catalog.first)
        XCTAssertFalse(milestone.isReached(after: milestone.requiredInterval - 1))
        XCTAssertTrue(milestone.isReached(after: milestone.requiredInterval))
    }

    func testFractionIsClamped() throws {
        let milestone = try XCTUnwrap(HealthMilestone.catalog.first)
        XCTAssertEqual(milestone.fraction(after: -5), 0)
        XCTAssertEqual(milestone.fraction(after: milestone.requiredInterval / 2), 0.5, accuracy: 0.0001)
        XCTAssertEqual(milestone.fraction(after: milestone.requiredInterval * 10), 1)
    }
}
