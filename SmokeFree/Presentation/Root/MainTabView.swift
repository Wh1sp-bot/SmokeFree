import SwiftUI

/// Основний контейнер: вкладки «Прогрес» (власний навігаційний стек через
/// `AppRouter`) та «SOS». `AppRouter` створюється тут і передається вниз —
/// єдиний router на весь застосунок, спільний для обох вкладок.
struct MainTabView: View {
    let container: AppContainer
    @State private var router = AppRouter()
    @State private var breathing: BreathingViewModel

    init(container: AppContainer) {
        self.container = container
        _breathing = State(initialValue: container.makeBreathingViewModel())
    }

    var body: some View {
        TabView(selection: Binding(get: { router.selectedTab }, set: { router.selectedTab = $0 })) {
            ProgressTabView(container: container, router: router)
                .tabItem { Label("Прогрес", systemImage: "leaf.fill") }
                .tag(MainTab.progress)

            SOSView(viewModel: breathing)
                .tabItem { Label("SOS", systemImage: "lifepreserver.fill") }
                .tag(MainTab.sos)
        }
    }
}
