import SwiftUI

/// Корінь інтерфейсу: якщо профілю ще немає — показуємо форму створення,
/// інакше — основний екран. `profileRepository` — `@Observable`, тому вибір
/// оновлюється автоматично після збереження.
struct RootView: View {
    let container: AppContainer

    var body: some View {
        if container.profileRepository.profile == nil {
            ProfileFormView(viewModel: container.makeProfileFormViewModel(mode: .create))
        } else {
            MainTabView(container: container)
        }
    }
}
