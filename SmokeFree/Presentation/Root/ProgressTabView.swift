import SwiftUI

/// Стекова навігація вкладки «Прогрес»: керується `AppRouter.path`, а не
/// локальним станом View. Тут же підключаються модальні вікна (`.sheet`),
/// спільні для всіх екранів вкладки.
struct ProgressTabView: View {
    let container: AppContainer
    let router: AppRouter

    var body: some View {
        NavigationStack(path: Binding(get: { router.path }, set: { router.path = $0 })) {
            HomeView(
                viewModel: container.makeHomeViewModel(),
                motivationViewModel: container.makeMotivationViewModel(),
                router: router
            )
                .navigationDestination(for: ProgressRoute.self) { route in
                    destination(for: route)
                }
        }
        .sheet(item: Binding(get: { router.presentedSheet }, set: { router.presentedSheet = $0 })) { sheet in
            sheetContent(sheet)
        }
    }

    @ViewBuilder
    private func destination(for route: ProgressRoute) -> some View {
        switch route {
        case .milestoneDetail(let id):
            MilestoneDetailView(viewModel: container.makeMilestoneDetailViewModel(milestoneID: id))
        case .history:
            HistoryView(viewModel: container.makeHistoryViewModel(), router: router)
        }
    }

    @ViewBuilder
    private func sheetContent(_ sheet: AppSheet) -> some View {
        switch sheet {
        case .editProfile:
            if let profile = container.profileRepository.profile {
                ProfileFormView(viewModel: container.makeProfileFormViewModel(mode: .edit(profile)))
            }
        case .addCravingNote(let event):
            NoteEditorView(
                event: event,
                onSave: { note in
                    container.cravingJournal.updateNote(for: event.id, note: note)
                    router.dismissSheet()
                },
                onDismiss: { router.dismissSheet() }
            )
        }
    }
}
