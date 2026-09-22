import Foundation
import Observation

/// Контракт журналу тяги для тих, хто його лише читає/доповнює.
protocol CravingLogging: AnyObject {
    var events: [CravingEvent] { get }
    func add(_ event: CravingEvent)
    /// Оновлює нотатку існуючого епізоду за його `id`. Якщо `id` не знайдено — нічого не робить.
    func updateNote(for id: UUID, note: String?)
    func removeAll()
}

/// Журнал епізодів тяги.
///
/// `class` — бо це спільний змінюваний об'єкт (семантика посилання). Тепер він
/// ще й зберігає дані через `DataStoring` та `@Observable` сповіщає інтерфейс.
@Observable
final class CravingJournal: CravingLogging {
    private(set) var events: [CravingEvent]

    @ObservationIgnored private let storage: DataStoring

    /// - Parameter events: початковий вміст. Якщо `nil` — завантажується зі сховища.
    init(events: [CravingEvent]? = nil, storage: DataStoring = InMemoryStorage()) {
        self.storage = storage
        if let events {
            self.events = events
        } else {
            self.events = Self.loadEvents(from: storage)
        }
    }

    func add(_ event: CravingEvent) {
        events.append(event)
        persist()
    }

    func updateNote(for id: UUID, note: String?) {
        guard let index = events.firstIndex(where: { $0.id == id }) else { return }
        events[index].note = note
        persist()
    }

    func removeAll() {
        events.removeAll()
        persist()
    }

    /// Скільки разів вправу доведено до кінця.
    var completedCount: Int {
        events.filter { $0.wasCompleted }.count
    }

    /// Фільтрація колекції за тригером.
    func events(triggeredBy trigger: CravingTrigger) -> [CravingEvent] {
        events.filter { $0.trigger == trigger }
    }

    /// Найчастіший тригер або `nil`, якщо журнал порожній.
    func mostCommonTrigger() -> CravingTrigger? {
        guard !events.isEmpty else { return nil }
        let counts = Dictionary(grouping: events, by: { $0.trigger }).mapValues { $0.count }
        // При однаковій кількості обираємо детерміновано — за алфавітом rawValue.
        return counts.max { lhs, rhs in
            lhs.value != rhs.value ? lhs.value < rhs.value : lhs.key.rawValue > rhs.key.rawValue
        }?.key
    }

    // MARK: - Зберігання

    private static func loadEvents(from storage: DataStoring) -> [CravingEvent] {
        do {
            return try storage.load([CravingEvent].self, forKey: StorageKey.cravings) ?? []
        } catch {
            Log.storage.error("Не вдалося прочитати журнал: \(error.localizedDescription)")
            return []
        }
    }

    private func persist() {
        do {
            try storage.save(events, forKey: StorageKey.cravings)
        } catch {
            Log.storage.error("Не вдалося зберегти журнал: \(error.localizedDescription)")
        }
    }
}
