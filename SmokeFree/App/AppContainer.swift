import Foundation

/// Composition Root: єдине місце, де створюються та зв'язуються конкретні
/// реалізації. Решта коду отримує залежності через `init` (Dependency Injection)
/// і бачить лише протоколи. Глобальних синглтонів у проєкті немає.
final class AppContainer {
    let storage: DataStoring
    let profileRepository: ProfileRepository
    let cravingJournal: CravingJournal
    let calculator: ProgressCalculating
    let timeline: MilestoneTimeline
    let haptics: HapticsProviding
    let quoteService: QuoteFetching

    init(
        storage: DataStoring,
        haptics: HapticsProviding,
        quoteService: QuoteFetching = ZenQuotesService(),
        calculator: ProgressCalculating = ProgressCalculator(),
        timeline: MilestoneTimeline = MilestoneTimeline()
    ) {
        self.storage = storage
        self.haptics = haptics
        self.quoteService = quoteService
        self.calculator = calculator
        self.timeline = timeline
        self.profileRepository = ProfileRepository(storage: storage)
        self.cravingJournal = CravingJournal(storage: storage)
    }

    // MARK: - Конфігурації

    /// Робоча: справжнє сховище, вібрація й мережевий сервіс.
    /// - Parameter quoteOverride: підміна джерела цитат для керованої демонстрації
    ///   порожньої відповіді (`-quote-empty`) чи помилки (`-quote-error`) — див. `SmokeFreeApp`.
    static func live(quoteOverride: QuoteFetching? = nil) -> AppContainer {
        AppContainer(storage: UserDefaultsStorage(), haptics: CoreHapticsAdapter(), quoteService: quoteOverride ?? ZenQuotesService())
    }

    /// Демонстраційна: дані в пам'яті + готовий профіль. Запуск: аргумент `-demo-data`.
    /// Зручно для скриншотів і захисту — нічого не зберігається на пристрої.
    static func demo(now: Date = Date(), quoteOverride: QuoteFetching? = nil) -> AppContainer {
        let container = AppContainer(storage: InMemoryStorage(), haptics: NoOpHaptics(), quoteService: quoteOverride ?? ZenQuotesService())
        let quitDate = now.addingTimeInterval(-(10 * TimeSpan.day + 3 * TimeSpan.hour))
        if let profile = try? QuitProfile(
            quitDate: quitDate, cigarettesPerDay: 15, cigarettesPerPack: 20, packPrice: 95, currency: .uah
        ) {
            _ = try? container.profileRepository.save(profile)
        }
        container.cravingJournal.add(CravingEvent(
            startedAt: now.addingTimeInterval(-3 * TimeSpan.day), duration: 180, wasCompleted: true, trigger: .coffee))
        container.cravingJournal.add(CravingEvent(
            startedAt: now.addingTimeInterval(-1 * TimeSpan.day), duration: 180, wasCompleted: true, trigger: .stress))
        container.cravingJournal.add(CravingEvent(
            startedAt: now.addingTimeInterval(-5 * TimeSpan.hour), duration: 45, wasCompleted: false, trigger: .alcohol))
        return container
    }

    // MARK: - Фабрики View Model

    @MainActor
    func makeHomeViewModel() -> HomeViewModel {
        HomeViewModel(repository: profileRepository, journal: cravingJournal, calculator: calculator, timeline: timeline)
    }

    @MainActor
    func makeProfileFormViewModel(mode: ProfileFormViewModel.Mode) -> ProfileFormViewModel {
        ProfileFormViewModel(mode: mode, repository: profileRepository)
    }

    @MainActor
    func makeBreathingViewModel() -> BreathingViewModel {
        BreathingViewModel(haptics: haptics, journal: cravingJournal)
    }

    @MainActor
    func makeMilestoneDetailViewModel(milestoneID: String) -> MilestoneDetailViewModel {
        MilestoneDetailViewModel(milestoneID: milestoneID, repository: profileRepository, calculator: calculator, timeline: timeline)
    }

    @MainActor
    func makeHistoryViewModel() -> HistoryViewModel {
        HistoryViewModel(journal: cravingJournal)
    }

    @MainActor
    func makeMotivationViewModel() -> MotivationViewModel {
        MotivationViewModel(service: quoteService)
    }
}
