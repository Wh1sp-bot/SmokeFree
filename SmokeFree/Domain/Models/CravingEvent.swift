import Foundation

/// Один епізод тяги, який користувач пережив (наприклад, через дихальну вправу).
struct CravingEvent: Codable, Equatable, Hashable, Identifiable {
    let id: UUID
    let startedAt: Date
    var duration: TimeInterval
    /// `true`, якщо вправу доведено до кінця.
    var wasCompleted: Bool
    var trigger: CravingTrigger
    /// Необов'язкова нотатка — `Optional`: значення може бути відсутнім.
    var note: String?

    init(
        id: UUID = UUID(),
        startedAt: Date,
        duration: TimeInterval,
        wasCompleted: Bool,
        trigger: CravingTrigger = .other,
        note: String? = nil
    ) {
        self.id = id
        self.startedAt = startedAt
        self.duration = duration
        self.wasCompleted = wasCompleted
        self.trigger = trigger
        self.note = note
    }
}
