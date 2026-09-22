import Foundation

/// Реалізація `DataStoring` у пам'яті: для тестів, Preview та демонстраційного режиму.
/// Замінює справжнє сховище без жодних змін у коді, що ним користується.
final class InMemoryStorage: DataStoring {
    private var storage: [String: Data] = [:]
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    func load<T: Decodable>(_ type: T.Type, forKey key: String) throws -> T? {
        guard let data = storage[key] else { return nil }
        return try decoder.decode(T.self, from: data)
    }

    func save<T: Encodable>(_ value: T, forKey key: String) throws {
        storage[key] = try encoder.encode(value)
    }

    func remove(forKey key: String) {
        storage[key] = nil
    }
}
