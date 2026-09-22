import Foundation

/// Усе, що потрібно головному екрану для відображення на момент часу.
struct HomeSnapshot: Equatable {
    let progress: QuitProgress
    let currency: Currency
    let nextMilestone: HealthMilestone?
    let fractionToNext: Double
    let reachedCount: Int
    let totalMilestones: Int
    let overcomeCravings: Int
}
