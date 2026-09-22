import XCTest
@testable import SmokeFree

final class ProgressCalculatorTests: XCTestCase {
    private let quitDate = Date(timeIntervalSince1970: 1_700_000_000)
    private let calculator = ProgressCalculator()

    private func makeProfile() throws -> QuitProfile {
        // 15 цигарок/день, пачка 20 шт. за 95 → 71.25 за день
        try QuitProfile(quitDate: quitDate, cigarettesPerDay: 15, cigarettesPerPack: 20, packPrice: 95, currency: .uah)
    }

    func testZeroProgressAtQuitMoment() throws {
        let progress = calculator.progress(for: try makeProfile(), at: quitDate)
        XCTAssertEqual(progress.elapsed, 0)
        XCTAssertEqual(progress.cigarettesAvoided, 0)
        XCTAssertEqual(progress.moneySaved, 0, accuracy: 0.0001)
    }

    func testFutureQuitDateIsClampedToZero() throws {
        let progress = calculator.progress(for: try makeProfile(), at: quitDate.addingTimeInterval(-1000))
        XCTAssertEqual(progress.elapsed, 0)
        XCTAssertEqual(progress.moneySaved, 0, accuracy: 0.0001)
    }

    func testTwoDays() throws {
        let progress = calculator.progress(for: try makeProfile(), at: quitDate.addingTimeInterval(2 * TimeSpan.day))
        XCTAssertEqual(progress.cigarettesAvoided, 30)
        XCTAssertEqual(progress.moneySaved, 142.5, accuracy: 0.0001)
        XCTAssertEqual(progress.days, 2)
        XCTAssertEqual(progress.hours, 0)
    }

    func testCigarettesAvoidedIsRoundedDown() throws {
        // 12 годин = 0.5 доби → 7.5 цигарки → 7
        let progress = calculator.progress(for: try makeProfile(), at: quitDate.addingTimeInterval(12 * TimeSpan.hour))
        XCTAssertEqual(progress.cigarettesAvoided, 7)
    }

    func testTimeBreakdown() throws {
        let elapsed = 3 * TimeSpan.day + 5 * TimeSpan.hour + 20 * TimeSpan.minute + 7
        let progress = calculator.progress(for: try makeProfile(), at: quitDate.addingTimeInterval(elapsed))
        XCTAssertEqual([progress.days, progress.hours, progress.minutes, progress.seconds], [3, 5, 20, 7])
    }
}
