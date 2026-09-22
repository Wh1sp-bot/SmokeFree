import Foundation

/// Абстракція типізованого сховища. Решта застосунку не знає, ЩО за нею
/// (UserDefaults, файл, пам'ять) — це і є Dependency Inversion.
protocol DataStoring {
    func load<T: Decodable>(_ type: T.Type, forKey key: String) throws -> T?
    func save<T: Encodable>(_ value: T, forKey key: String) throws
    func remove(forKey key: String)
}

/// Ключі сховища в одному місці (без дублювання рядків по коду).
enum StorageKey {
    static let profile = "smokefree.profile"
    static let cravings = "smokefree.cravings"
}
