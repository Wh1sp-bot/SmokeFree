import XCTest
@testable import SmokeFree

final class StorageTests: XCTestCase {
    private func makeUserDefaults() throws -> (UserDefaults, String) {
        let suite = "SmokeFreeTests.\(UUID().uuidString)"
        return (try XCTUnwrap(UserDefaults(suiteName: suite)), suite)
    }

    func testUserDefaultsAdapterRoundTrip() throws {
        let (defaults, suite) = try makeUserDefaults()
        defer { defaults.removePersistentDomain(forName: suite) }
        let storage = UserDefaultsStorage(defaults: defaults)
        let profile = Fixtures.profile()

        try storage.save(profile, forKey: "k")
        XCTAssertEqual(try storage.load(QuitProfile.self, forKey: "k"), profile)

        storage.remove(forKey: "k")
        XCTAssertNil(try storage.load(QuitProfile.self, forKey: "k"))
    }

    func testUserDefaultsAdapterThrowsOnCorruptedData() throws {
        let (defaults, suite) = try makeUserDefaults()
        defer { defaults.removePersistentDomain(forName: suite) }
        defaults.set(Data("не json".utf8), forKey: "k")
        let storage = UserDefaultsStorage(defaults: defaults)
        XCTAssertThrowsError(try storage.load(QuitProfile.self, forKey: "k"))
    }

    func testInMemoryStorageIsInterchangeable() throws {
        let storage: DataStoring = InMemoryStorage()
        try storage.save([1, 2, 3], forKey: "numbers")
        XCTAssertEqual(try storage.load([Int].self, forKey: "numbers"), [1, 2, 3])
    }

    func testProfileRepositoryPersistsAcrossInstances() throws {
        let storage = InMemoryStorage()
        let first = ProfileRepository(storage: storage)
        XCTAssertNil(first.profile)

        let profile = Fixtures.profile()
        try first.save(profile)

        let second = ProfileRepository(storage: storage)
        XCTAssertEqual(second.profile, profile)

        second.reset()
        XCTAssertNil(ProfileRepository(storage: storage).profile)
    }

    func testRepositoryKeepsStateWhenSavingFails() {
        let repository = ProfileRepository(storage: FailingStorage())
        XCTAssertThrowsError(try repository.save(Fixtures.profile()))
        XCTAssertNil(repository.profile, "Після невдалого збереження стан у пам'яті не змінюється")
    }

    func testJournalPersistsEvents() {
        let storage = InMemoryStorage()
        let journal = CravingJournal(storage: storage)
        journal.add(CravingEvent(startedAt: Fixtures.now, duration: 180, wasCompleted: true, trigger: .coffee))
        XCTAssertEqual(CravingJournal(storage: storage).events.count, 1)

        journal.removeAll()
        XCTAssertTrue(CravingJournal(storage: storage).events.isEmpty)
    }
}
