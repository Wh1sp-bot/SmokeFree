import XCTest
@testable import SmokeFree

final class QuitProfileTests: XCTestCase {
    private let date = Date(timeIntervalSince1970: 1_700_000_000)

    private func makeProfile(perDay: Int = 15, perPack: Int = 20, price: Double = 95) throws -> QuitProfile {
        try QuitProfile(quitDate: date, cigarettesPerDay: perDay, cigarettesPerPack: perPack, packPrice: price, currency: .uah)
    }

    func testValidProfileIsCreated() throws {
        let profile = try makeProfile()
        XCTAssertEqual(profile.cigarettesPerDay, 15)
        XCTAssertEqual(profile.currency, .uah)
    }

    func testPricePerCigaretteAndDailySavings() throws {
        let profile = try makeProfile(perDay: 15, perPack: 20, price: 95)
        XCTAssertEqual(profile.pricePerCigarette, 4.75, accuracy: 0.0001)
        XCTAssertEqual(profile.dailySavings, 71.25, accuracy: 0.0001)
    }

    func testInvalidCigarettesPerDayThrows() {
        XCTAssertThrowsError(try makeProfile(perDay: 0)) {
            XCTAssertEqual($0 as? ProfileValidationError, .invalidCigarettesPerDay(0))
        }
        XCTAssertThrowsError(try makeProfile(perDay: 201))
    }

    func testInvalidCigarettesPerPackThrows() {
        XCTAssertThrowsError(try makeProfile(perPack: 0)) {
            XCTAssertEqual($0 as? ProfileValidationError, .invalidCigarettesPerPack(0))
        }
    }

    func testInvalidPriceThrows() {
        XCTAssertThrowsError(try makeProfile(price: 0))
        XCTAssertThrowsError(try makeProfile(price: -5))
        XCTAssertThrowsError(try makeProfile(price: .nan))
        XCTAssertThrowsError(try makeProfile(price: .infinity))
    }

    /// struct має семантику значення: копія не впливає на оригінал.
    func testStructHasValueSemantics() throws {
        let original = try makeProfile()
        var copy = original
        copy.cigarettesPerDay = 5
        XCTAssertEqual(original.cigarettesPerDay, 15)
        XCTAssertEqual(copy.cigarettesPerDay, 5)
    }

    func testCodableRoundTrip() throws {
        let profile = try makeProfile()
        let data = try JSONEncoder().encode(profile)
        let decoded = try JSONDecoder().decode(QuitProfile.self, from: data)
        XCTAssertEqual(decoded, profile)
    }
}
