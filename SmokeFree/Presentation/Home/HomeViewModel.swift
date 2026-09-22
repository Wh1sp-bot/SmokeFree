import Foundation
import Observation

/// View Model головного екрана: перетворює стан застосунку на дані для показу.
///
/// Залежить лише від абстракцій (`ProfileProviding`, `CravingLogging`,
/// `ProgressCalculating`), тому перевіряється в тестах без UI та справжнього сховища.
@MainActor
@Observable
final class HomeViewModel {
    private let repository: ProfileProviding
    private let journal: CravingLogging
    private let calculator: ProgressCalculating
    private let timeline: MilestoneTimeline

    init(
        repository: ProfileProviding,
        journal: CravingLogging,
        calculator: ProgressCalculating,
        timeline: MilestoneTimeline
    ) {
        self.repository = repository
        self.journal = journal
        self.calculator = calculator
        self.timeline = timeline
    }

    /// Чиста функція від часу: View передає «поточний момент» (з `TimelineView`),
    /// тому таймер у View Model не потрібен.
    func snapshot(at date: Date) -> HomeSnapshot? {
        guard let profile = repository.profile else { return nil }
        let progress = calculator.progress(for: profile, at: date)
        return HomeSnapshot(
            progress: progress,
            currency: profile.currency,
            nextMilestone: timeline.next(after: progress.elapsed),
            fractionToNext: timeline.fractionToNext(after: progress.elapsed),
            reachedCount: timeline.reached(after: progress.elapsed).count,
            totalMilestones: timeline.milestones.count,
            overcomeCravings: journal.events.filter { $0.wasCompleted }.count
        )
    }
}
