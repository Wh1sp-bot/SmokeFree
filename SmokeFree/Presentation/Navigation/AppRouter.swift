import Foundation
import SwiftUI
import Observation

/// **Coordinator/Router**, обґрунтований для SwiftUI: окремий `@Observable`-об'єкт
/// із маршрутами (`NavigationPath`) і станом модальних вікон (`AppSheet?`), не
/// прив'язаний до жодного конкретного `View`. Екрани не знають одне про одного й
/// не викликають `NavigationLink(destination:)` напряму — вони просять роутер
/// перейти (`push`, `presentEditProfile`) або повернутися (`pop`, `dismissSheet`).
/// Це відокремлює навігаційну логіку від Presentation-шару.
@MainActor
@Observable
final class AppRouter {
    var path = NavigationPath()
    var presentedSheet: AppSheet?
    /// Яку вкладку показано; переходи можуть перемикати вкладку програмно.
    var selectedTab: MainTab = .progress

    // MARK: - Стекова навігація

    func push(_ route: ProgressRoute) {
        path.append(route)
    }

    func pop() {
        guard !path.isEmpty else { return }
        path.removeLast()
    }

    func popToRoot() {
        path = NavigationPath()
    }

    // MARK: - Модальні екрани

    func presentEditProfile() {
        presentedSheet = .editProfile
    }

    func presentNote(for event: CravingEvent) {
        presentedSheet = .addCravingNote(event)
    }

    func dismissSheet() {
        presentedSheet = nil
    }

    // MARK: - Міжвкладкові переходи

    /// Наприклад, зі сповіщення про досягнутий етап одразу відкрити його деталі.
    func showMilestoneDetail(id: String) {
        selectedTab = .progress
        popToRoot()
        push(.milestoneDetail(id: id))
    }
}

enum MainTab: Hashable {
    case progress
    case sos
}
