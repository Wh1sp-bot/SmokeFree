import Foundation
import Observation

/// ViewModel списку епізодів тяги, від найновішого до найстарішого.
@MainActor
@Observable
final class HistoryViewModel {
    private let journal: CravingLogging

    init(journal: CravingLogging) {
        self.journal = journal
    }

    var events: [CravingEvent] {
        journal.events.sorted { $0.startedAt > $1.startedAt }
    }

    func updateNote(for event: CravingEvent, note: String?) {
        journal.updateNote(for: event.id, note: note)
    }
}
