import XCTest
@testable import SmokeFree

@MainActor
final class HomeViewModelTests: XCTestCase {
    func testSnapshotIsNilWithoutProfile() {
        let vm = HomeViewModel(repository: MockProfileRepository(), journal: MockJournal(),
                               calculator: ProgressCalculator(), timeline: MilestoneTimeline())
        XCTAssertNil(vm.snapshot(at: Fixtures.now))
    }

    /// Бізнес-логіку перевіряємо окремо від UI та справжнього сховища:
    /// підставляємо фіксований калькулятор і mock-репозиторій.
    func testSnapshotUsesInjectedDependencies() {
        let fixed = QuitProgress(elapsed: 25 * TimeSpan.hour, cigarettesAvoided: 42, moneySaved: 123.45)
        let journal = MockJournal()
        journal.add(CravingEvent(startedAt: Fixtures.now, duration: 180, wasCompleted: true))
        journal.add(CravingEvent(startedAt: Fixtures.now, duration: 20, wasCompleted: false))

        let vm = HomeViewModel(
            repository: MockProfileRepository(profile: Fixtures.profile(currency: .usd)),
            journal: journal, calculator: FixedCalculator(result: fixed), timeline: MilestoneTimeline())

        let snapshot = vm.snapshot(at: Fixtures.now)
        XCTAssertEqual(snapshot?.progress, fixed)
        XCTAssertEqual(snapshot?.currency, .usd)
        XCTAssertEqual(snapshot?.reachedCount, 2)           // 20 хв і 24 год
        XCTAssertEqual(snapshot?.nextMilestone?.id, "m48h")
        XCTAssertEqual(snapshot?.overcomeCravings, 1)
    }
}

@MainActor
final class ProfileFormViewModelTests: XCTestCase {
    func testCreateSavesProfile() {
        let repository = MockProfileRepository()
        let vm = ProfileFormViewModel(mode: .create, repository: repository, now: Fixtures.now)
        vm.packPriceText = "95,5"
        XCTAssertTrue(vm.save())
        XCTAssertEqual(repository.saved.first?.packPrice, 95.5)
        XCTAssertNil(vm.errorMessage)
    }

    func testEmptyPriceShowsError() {
        let repository = MockProfileRepository()
        let vm = ProfileFormViewModel(mode: .create, repository: repository, now: Fixtures.now)
        XCTAssertFalse(vm.save())
        XCTAssertNotNil(vm.errorMessage)
        XCTAssertTrue(repository.saved.isEmpty)
    }

    func testEditKeepsIdAndPrefillsFields() {
        let original = Fixtures.profile(perDay: 20, price: 100)
        let repository = MockProfileRepository(profile: original)
        let vm = ProfileFormViewModel(mode: .edit(original), repository: repository)
        XCTAssertEqual(vm.cigarettesPerDay, 20)
        XCTAssertEqual(vm.packPriceText, "100")
        vm.cigarettesPerDay = 8
        XCTAssertTrue(vm.save())
        XCTAssertEqual(repository.saved.first?.id, original.id)
        XCTAssertEqual(repository.saved.first?.cigarettesPerDay, 8)
    }

    func testStorageFailureIsReportedNotCrashing() {
        let repository = MockProfileRepository()
        repository.shouldFail = true
        let vm = ProfileFormViewModel(mode: .create, repository: repository)
        vm.packPriceText = "50"
        XCTAssertFalse(vm.save())
        XCTAssertNotNil(vm.errorMessage)
    }

    func testParsePrice() {
        XCTAssertEqual(ProfileFormViewModel.parsePrice("12.5"), 12.5)
        XCTAssertEqual(ProfileFormViewModel.parsePrice(" 12,5 "), 12.5)
        XCTAssertNil(ProfileFormViewModel.parsePrice(""))
        XCTAssertNil(ProfileFormViewModel.parsePrice("abc"))
    }
}
