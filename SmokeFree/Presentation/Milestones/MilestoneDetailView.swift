import SwiftUI

struct MilestoneDetailView: View {
    @State private var viewModel: MilestoneDetailViewModel
    /// Стан розгортання пояснення — саме та анімація, пов'язана з дією користувача,
    /// яку вимагає завдання (не плутати зі стандартним переходом між екранами).
    @State private var isExplanationExpanded = false

    init(viewModel: MilestoneDetailViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        TimelineView(.periodic(from: .now, by: 1)) { context in
            ScrollView {
                if let snapshot = viewModel.snapshot(at: context.date) {
                    content(snapshot)
                        .padding()
                } else {
                    ContentUnavailableView("Етап не знайдено", systemImage: "questionmark.circle")
                        .padding()
                }
            }
        }
        .navigationTitle("Етап")
        .navigationBarTitleDisplayMode(.inline)
    }

    @ViewBuilder
    private func content(_ snapshot: MilestoneDetailViewModel.Snapshot) -> some View {
        let milestone = snapshot.milestone

        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .stroke(Color.secondary.opacity(0.2), lineWidth: 14)
                Circle()
                    .trim(from: 0, to: snapshot.fraction)
                    .stroke(snapshot.isReached ? Color.green : Color.accentColor,
                            style: StrokeStyle(lineWidth: 14, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .animation(.easeOut(duration: 0.6), value: snapshot.fraction)
                Image(systemName: milestone.symbolName)
                    .font(.system(size: 40))
                    .foregroundStyle(snapshot.isReached ? .green : .accentColor)
            }
            .frame(width: 160, height: 160)

            VStack(spacing: 6) {
                Text(milestone.thresholdLabel)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Text(milestone.title)
                    .font(.title2.bold())
                    .multilineTextAlignment(.center)
                Text(snapshot.isReached ? "Етап досягнуто ✔︎" : "Ще \(Formatters.compactDuration(snapshot.remaining))")
                    .font(.subheadline)
                    .foregroundStyle(snapshot.isReached ? .green : .secondary)
            }

            // Розгортання деталей за дією користувача — сама анімація, а не стандартний
            // перехід між екранами.
            VStack(spacing: 10) {
                Button {
                    withAnimation(.snappy) { isExplanationExpanded.toggle() }
                } label: {
                    Label(isExplanationExpanded ? "Згорнути" : "Чому це важливо",
                          systemImage: isExplanationExpanded ? "chevron.up" : "chevron.down")
                }
                .buttonStyle(.bordered)

                if isExplanationExpanded {
                    Text(milestone.detail)
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .cardBackground()
                        .transition(.asymmetric(insertion: .opacity.combined(with: .move(edge: .top)), removal: .opacity))
                }
            }
        }
    }
}
