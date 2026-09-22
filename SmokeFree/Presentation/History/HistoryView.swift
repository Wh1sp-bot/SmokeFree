import SwiftUI

/// Список (третій самостійний екран навігаційної карти практичної 3).
/// Тап по рядку відкриває модальне вікно нотатки (через роутер), а не
/// `NavigationLink` — це і є щонайменше одна модальна презентація сценарію.
struct HistoryView: View {
    @State private var viewModel: HistoryViewModel
    let router: AppRouter

    init(viewModel: HistoryViewModel, router: AppRouter) {
        _viewModel = State(initialValue: viewModel)
        self.router = router
    }

    var body: some View {
        Group {
            if viewModel.events.isEmpty {
                ContentUnavailableView("Поки що порожньо", systemImage: "clock.arrow.circlepath",
                                       description: Text("Епізоди з'являться тут після вправ на екрані SOS."))
            } else {
                List(viewModel.events) { event in
                    Button {
                        router.presentNote(for: event)
                    } label: {
                        row(event)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .navigationTitle("Журнал тяги")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func row(_ event: CravingEvent) -> some View {
        HStack(spacing: 12) {
            Image(systemName: event.trigger.symbolName)
                .frame(width: 28)
                .foregroundStyle(event.wasCompleted ? .green : .orange)
            VStack(alignment: .leading, spacing: 2) {
                Text(event.trigger.title).font(.body)
                Text(Formatters.dateTime(event.startedAt))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                if let note = event.note, !note.isEmpty {
                    Text(note)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }
            Spacer()
            Text(event.wasCompleted ? "Подолано" : "Перервано")
                .font(.caption.weight(.medium))
                .foregroundStyle(event.wasCompleted ? .green : .orange)
        }
        .padding(.vertical, 4)
        .contentShape(Rectangle())
    }
}
