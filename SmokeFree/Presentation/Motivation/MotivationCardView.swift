import SwiftUI

/// Картка на Home: реальний асинхронний запит до ZenQuotes API, використаний у
/// сценарії застосунку (мотиваційна цитата поруч із прогресом). Показує всі
/// вимагані стани: завантаження, успіх, відсутність даних, помилка з повтором.
struct MotivationCardView: View {
    @State private var viewModel: MotivationViewModel

    init(viewModel: MotivationViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Label("Цитата дня", systemImage: "quote.opening")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                Spacer()
                Button {
                    Task { await viewModel.load() }
                } label: {
                    Image(systemName: "arrow.clockwise")
                }
                .disabled(viewModel.state == .loading)
                .accessibilityLabel("Інша цитата")
            }

            body(for: viewModel.state)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .cardBackground()
        // Стартовий запит — рівно один раз при першій появі картки; повторні
        // періодичні перерендери Home (TimelineView) не перезапускають .task,
        // бо viewModel — стабільний @State, а не створюється щотіку.
        .task {
            if viewModel.state == .idle { await viewModel.load() }
        }
    }

    @ViewBuilder
    private func body(for state: MotivationViewModel.State) -> some View {
        switch state {
        case .idle, .loading:
            HStack {
                ProgressView()
                Text("Завантаження цитати…")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

        case .loaded(let quote):
            VStack(alignment: .leading, spacing: 6) {
                Text("«\(quote.text)»")
                    .font(.subheadline.italic())
                    .fixedSize(horizontal: false, vertical: true)
                Text("— \(quote.author)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                // Обов'язкова атрибуція за умовами безкоштовного рівня ZenQuotes API.
                Link("ZenQuotes API", destination: URL(string: "https://zenquotes.io/")!)
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
            .transition(.opacity)

        case .empty:
            retryRow(message: "Наразі немає жодної цитати.", icon: "tray")

        case .failed(let message):
            retryRow(message: message, icon: "wifi.slash")
        }
    }

    private func retryRow(message: String, icon: String) -> some View {
        HStack {
            Label(message, systemImage: icon)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Spacer()
            Button("Повторити") { Task { await viewModel.load() } }
                .font(.subheadline)
        }
    }
}
