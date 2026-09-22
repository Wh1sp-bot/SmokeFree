import Foundation
import Observation

/// ViewModel деталей одного етапу. Отримує лише `id` (а не весь `HealthMilestone`)
/// — так дані завжди читаються заново з `MilestoneTimeline`, а не «застигають»
/// на момент переходу.
@MainActor
@Observable
final class MilestoneDetailViewModel {
    let milestoneID: String
    private let repository: ProfileProviding
    private let calculator: ProgressCalculating
    private let timeline: MilestoneTimeline

    init(milestoneID: String, repository: ProfileProviding, calculator: ProgressCalculating, timeline: MilestoneTimeline) {
        self.milestoneID = milestoneID
        self.repository = repository
        self.calculator = calculator
        self.timeline = timeline
    }

    struct Snapshot {
        let milestone: HealthMilestone
        let isReached: Bool
        let fraction: Double
        let remaining: TimeInterval
    }

    func snapshot(at date: Date) -> Snapshot? {
        guard let milestone = timeline.milestone(withID: milestoneID),
              let profile = repository.profile else { return nil }
        let progress = calculator.progress(for: profile, at: date)
        return Snapshot(
            milestone: milestone,
            isReached: milestone.isReached(after: progress.elapsed),
            fraction: milestone.fraction(after: progress.elapsed),
            remaining: max(0, milestone.requiredInterval - progress.elapsed)
        )
    }
}
