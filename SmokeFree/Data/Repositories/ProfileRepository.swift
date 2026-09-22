import Foundation
import Observation

/// Що потрібно споживачам від «джерела профілю». View Model залежить саме від
/// цього протоколу, а не від конкретного класу (DIP, ISP).
protocol ProfileProviding: AnyObject {
    var profile: QuitProfile? { get }
    func save(_ profile: QuitProfile) throws
    func reset()
}

/// Єдине джерело істини про профіль. `@Observable` — вбудована реалізація
/// патерну Observer: екрани, що читають `profile`, автоматично оновлюються.
@Observable
final class ProfileRepository: ProfileProviding {
    private(set) var profile: QuitProfile?

    @ObservationIgnored private let storage: DataStoring

    init(storage: DataStoring) {
        self.storage = storage
        do {
            self.profile = try storage.load(QuitProfile.self, forKey: StorageKey.profile)
        } catch {
            Log.storage.error("Не вдалося прочитати профіль: \(error.localizedDescription)")
            self.profile = nil
        }
    }

    /// Спершу зберігаємо, потім оновлюємо стан: при збої пам'ять і сховище не розходяться.
    func save(_ profile: QuitProfile) throws {
        try storage.save(profile, forKey: StorageKey.profile)
        self.profile = profile
    }

    func reset() {
        storage.remove(forKey: StorageKey.profile)
        profile = nil
    }
}
