import SwiftUI

struct HomeView: View {
    @State private var viewModel: HomeViewModel
    /// Окремий стабільний `@State`, а не поле всередині `viewModel`: `content(at:)`
    /// викликається щосекунди через `TimelineView`, тож мотиваційна ViewModel має
    /// створюватися рівно один раз в `init`, інакше кожен тік скидав би її стан.
    @State private var motivationViewModel: MotivationViewModel
    let router: AppRouter

    init(viewModel: HomeViewModel, motivationViewModel: MotivationViewModel, router: AppRouter) {
        _viewModel = State(initialValue: viewModel)
        _motivationViewModel = State(initialValue: motivationViewModel)
        self.router = router
    }

    var body: some View {
        TimelineView(.periodic(from: .now, by: 1)) { context in
            ScrollView {
                content(at: context.date)
                    .padding()
            }
        }
        .navigationTitle("Прогрес")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    router.presentEditProfile()
                } label: {
                    Image(systemName: "person.crop.circle")
                }
                .accessibilityLabel("Редагувати профіль")
            }
        }
    }

    @ViewBuilder
    private func content(at date: Date) -> some View {
        if let snapshot = viewModel.snapshot(at: date) {
            VStack(spacing: 14) {
                TimeCounterCard(progress: snapshot.progress)

                MotivationCardView(viewModel: motivationViewModel)

                LazyVGrid(columns: [GridItem(.adaptive(minimum: 150), spacing: 12)], spacing: 12) {
                    StatCard(
                        title: "Заощаджено",
                        value: Formatters.money(snapshot.progress.moneySaved, currency: snapshot.currency),
                        systemImage: "banknote")
                    StatCard(
                        title: "Не викурено",
                        value: "\(snapshot.progress.cigarettesAvoided)",
                        systemImage: "nosign")
                    Button { router.push(.history) } label: {
                        StatCard(
                            title: "Подолано тяг",
                            value: "\(snapshot.overcomeCravings)",
                            systemImage: "flame")
                    }
                    .buttonStyle(.plain)
                    StatCard(
                        title: "Етапи відновлення",
                        value: "\(snapshot.reachedCount) з \(snapshot.totalMilestones)",
                        systemImage: "checkmark.seal")
                }

                nextMilestoneCard(snapshot)
            }
        } else {
            ContentUnavailableView("Профіль не знайдено", systemImage: "person.crop.circle.badge.questionmark")
        }
    }

    @ViewBuilder
    private func nextMilestoneCard(_ snapshot: HomeSnapshot) -> some View {
        if let next = snapshot.nextMilestone {
            Button {
                router.push(.milestoneDetail(id: next.id))
            } label: {
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Label("Наступний етап · \(next.thresholdLabel)", systemImage: next.symbolName)
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.footnote)
                            .foregroundStyle(.tertiary)
                    }
                    Text(next.title)
                        .font(.headline)
                        .foregroundStyle(.primary)
                    MilestoneProgressBar(fraction: snapshot.fractionToNext)
                    Text("Ще \(Formatters.compactDuration(next.requiredInterval - snapshot.progress.elapsed))")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .cardBackground()
            }
            .buttonStyle(.plain)
        } else {
            Label("Усі етапи відновлення досягнуто", systemImage: "star.circle.fill")
                .frame(maxWidth: .infinity)
                .padding()
                .cardBackground()
        }
    }
}
