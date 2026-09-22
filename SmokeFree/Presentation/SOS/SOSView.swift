import SwiftUI

/// Екран дихальної вправи (у практичній 2 — базова версія без анімації кола).
struct SOSView: View {
    @State private var viewModel: BreathingViewModel

    init(viewModel: BreathingViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    VStack(spacing: 8) {
                        Text(viewModel.status == .finished ? "Готово!" : viewModel.state.phase.kind.title)
                            .font(.system(size: 44, weight: .bold, design: .rounded))
                            .minimumScaleFactor(0.6)
                            .lineLimit(1)
                        Text(Formatters.clock(viewModel.state.remaining))
                            .font(.title2.monospacedDigit())
                            .foregroundStyle(.secondary)
                    }
                    .padding(.top, 24)

                    if viewModel.status == .finished {
                        Label("Ви подолали тягу. Це записано в журнал.", systemImage: "checkmark.seal.fill")
                            .foregroundStyle(.green)
                            .multilineTextAlignment(.center)
                    }

                    controls
                }
                .padding()
            }
            .navigationTitle("Мені хочеться курити")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    @ViewBuilder
    private var controls: some View {
        @Bindable var viewModel = viewModel

        VStack(spacing: 12) {
            Picker("Техніка", selection: Binding(
                get: { viewModel.selectedPatternID },
                set: { viewModel.select(patternID: $0) }
            )) {
                ForEach(viewModel.patterns.indices, id: \.self) { index in
                    Text(viewModel.patterns[index].title).tag(viewModel.patterns[index].id)
                }
            }
            .pickerStyle(.menu)
            .disabled(viewModel.status == .running)

            Text(viewModel.pattern.summary)
                .font(.footnote)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            Picker("Що викликало тягу?", selection: $viewModel.selectedTrigger) {
                ForEach(CravingTrigger.allCases) { trigger in
                    Label(trigger.title, systemImage: trigger.symbolName).tag(trigger)
                }
            }
            .pickerStyle(.menu)
            .disabled(viewModel.status == .running)

            if viewModel.status == .running {
                Button("Зупинити", role: .destructive) { viewModel.stop() }
                    .buttonStyle(.bordered)
                    .controlSize(.large)
            } else {
                Button(viewModel.status == .finished ? "Ще раз" : "Почати вправу") { viewModel.start() }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
            }
        }
    }
}
