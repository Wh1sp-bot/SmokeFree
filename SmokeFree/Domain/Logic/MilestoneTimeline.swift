import Foundation

/// Уся логіка «етапів відновлення» в одному місці: які досягнуто, який наступний,
/// що досягнуто за проміжок. Екрани й View Model цього не дублюють.
struct MilestoneTimeline {
    /// Відсортовані за зростанням порога.
    let milestones: [HealthMilestone]

    init(milestones: [HealthMilestone] = HealthMilestone.catalog) {
        self.milestones = milestones.sorted { $0.requiredInterval < $1.requiredInterval }
    }

    func reached(after elapsed: TimeInterval) -> [HealthMilestone] {
        milestones.filter { $0.isReached(after: elapsed) }
    }

    func next(after elapsed: TimeInterval) -> HealthMilestone? {
        milestones.first { !$0.isReached(after: elapsed) }
    }

    func milestone(withID id: String) -> HealthMilestone? {
        milestones.first { $0.id == id }
    }

    /// Етапи, досягнуті в проміжку `(previous, current]` — для сповіщень.
    func newlyReached(from previous: TimeInterval, to current: TimeInterval) -> [HealthMilestone] {
        milestones.filter { $0.requiredInterval > previous && $0.requiredInterval <= current }
    }

    /// Прогрес від попереднього етапу до наступного (0…1); 1, якщо всі досягнуто.
    func fractionToNext(after elapsed: TimeInterval) -> Double {
        guard let next = next(after: elapsed) else { return 1 }
        let previous = reached(after: elapsed).last?.requiredInterval ?? 0
        let span = next.requiredInterval - previous
        guard span > 0 else { return 1 }
        return min(1, max(0, (elapsed - previous) / span))
    }
}
