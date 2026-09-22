import Foundation

/// **Патерн Adapter (структурний).**
/// `UserDefaults` уміє зберігати лише «сирі» значення (`Data`, `String`, …), а
/// застосунку потрібен типізований інтерфейс `DataStoring`. Адаптер перекладає
/// один інтерфейс в інший: `Codable`-значення ⇄ JSON `Data`.
final class UserDefaultsStorage: DataStoring {
    private let defaults: UserDefaults
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func load<T: Decodable>(_ type: T.Type, forKey key: String) throws -> T? {
        guard let data = defaults.data(forKey: key) else { return nil }
        return try decoder.decode(T.self, from: data)
    }

    func save<T: Encodable>(_ value: T, forKey key: String) throws {
        defaults.set(try encoder.encode(value), forKey: key)
    }

    func remove(forKey key: String) {
        defaults.removeObject(forKey: key)
    }
}
