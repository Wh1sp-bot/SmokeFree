import Foundation

/// Усі можливі пункти призначення в межах вкладки «Прогрес» — стекова навігація.
/// `Hashable` потрібен для `NavigationStack(path:)`.
enum ProgressRoute: Hashable {
    case milestoneDetail(id: String)
    case history
}

/// Модальні екрани (aka "sheet") — відкриваються поверх поточного, а не в стеку.
enum AppSheet: Identifiable, Hashable {
    case editProfile
    case addCravingNote(CravingEvent)

    var id: String {
        switch self {
        case .editProfile: return "editProfile"
        case .addCravingNote(let event): return "note-\(event.id)"
        }
    }
}
