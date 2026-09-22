import XCTest
@testable import SmokeFree

final class QuitProfileBuilderTests: XCTestCase {
    func testBuildsValidProfile() throws {
        let profile = try QuitProfileBuilder()
            .withQuitDate(Fixtures.now)
            .withCigarettesPerDay(12)
            .withCigarettesPerPack(20)
            .withPackPrice(100)
            .withCurrency(.eur)
            .build()
        XCTAssertEqual(profile.cigarettesPerDay, 12)
        XCTAssertEqual(profile.currency, .eur)
        XCTAssertEqual(profile.quitDate, Fixtures.now)
    }

    func testMissingPriceIsRejected() {
        XCTAssertThrowsError(try QuitProfileBuilder().build()) {
            XCTAssertEqual($0 as? ProfileValidationError, .invalidPackPrice)
        }
    }

    func testInvalidValueSurfacesFromProductValidation() {
        XCTAssertThrowsError(try QuitProfileBuilder().withPackPrice(50).withCigarettesPerDay(0).build())
    }

    func testEditingKeepsIdentity() throws {
        let original = Fixtures.profile()
        let edited = try QuitProfileBuilder(editing: original).withCigarettesPerDay(5).build()
        XCTAssertEqual(edited.id, original.id)
        XCTAssertEqual(edited.cigarettesPerDay, 5)
        XCTAssertEqual(edited.packPrice, original.packPrice)
    }

    func testBuilderIsImmutableBetweenSteps() throws {
        let base = QuitProfileBuilder().withPackPrice(10)
        let a = try base.withCigarettesPerDay(5).build()
        let b = try base.withCigarettesPerDay(7).build()
        XCTAssertEqual(a.cigarettesPerDay, 5)
        XCTAssertEqual(b.cigarettesPerDay, 7)
    }
}
