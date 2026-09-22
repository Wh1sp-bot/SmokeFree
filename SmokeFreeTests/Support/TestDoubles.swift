import Foundation
@testable import SmokeFree

/// Тестові двійники: демонструють, що залежності підміняються без змін у коді, що їх використовує.

final class MockProfileRepository: ProfileProviding {
    var profile: QuitProfile?
    var saved: [QuitProfile] = []
    var shouldFail = false

    init(profile: QuitProfile? = nil) { self.profile = profile }

    func save(_ profile: QuitProfile) throws {
        if shouldFail { throw NSError(domain: "test", code: 1) }
        saved.append(profile)
        self.profile = profile
    }

    func reset() { profile = nil }
}

final class MockJournal: CravingLogging {
    private(set) var events: [CravingEvent] = []
    func add(_ event: CravingEvent) { events.append(event) }
    func updateNote(for id: UUID, note: String?) {
        guard let index = events.firstIndex(where: { $0.id == id }) else { return }
        events[index].note = note
    }
    func removeAll() { events.removeAll() }
}

final class SpyHaptics: HapticsProviding {
    private(set) var cues: [HapticCue] = []
    private(set) var prepareCount = 0
    private(set) var stopCount = 0

    func prepare() { prepareCount += 1 }
    func play(_ cue: HapticCue) { cues.append(cue) }
    func stop() { stopCount += 1 }
}

struct FixedCalculator: ProgressCalculating {
    let result: QuitProgress
    func progress(for profile: QuitProfile, at date: Date) -> QuitProgress { result }
}

struct FailingStorage: DataStoring {
    struct Failure: Error {}
    func load<T: Decodable>(_ type: T.Type, forKey key: String) throws -> T? { throw Failure() }
    func save<T: Encodable>(_ value: T, forKey key: String) throws { throw Failure() }
    func remove(forKey key: String) {}
}

enum Fixtures {
    static let now = Date(timeIntervalSince1970: 1_700_000_000)

    static func profile(
        quitDate: Date = now, perDay: Int = 15, perPack: Int = 20, price: Double = 95, currency: Currency = .uah
    ) -> QuitProfile {
        // Фікстури створюються з валідних констант; збій тут означає помилку в тесті.
        try! QuitProfile(quitDate: quitDate, cigarettesPerDay: perDay, cigarettesPerPack: perPack, packPrice: price, currency: currency)
    }
}
