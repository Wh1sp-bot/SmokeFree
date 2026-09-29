import Foundation
import Observation

/// ViewModel мотиваційної цитати. Стани екрана — окремі випадки `State`, тому
/// `MotivationCardView` не вгадує стан за комбінацією прапорців.
@MainActor
@Observable
final class MotivationViewModel {
    enum State: Equatable {
        case idle
        case loading
        case loaded(MotivationalQuote)
        case empty
        case failed(String)
    }

    private(set) var state: State = .idle
    private let service: QuoteFetching

    init(service: QuoteFetching) {
        self.service = service
    }

    /// Викликається з `.task` при появі картки та повторно — кнопкою «Оновити».
    /// Не блокує інтерфейс: виконується на фоновому потоці `URLSession`,
    /// а стан оновлюється на головному акторі (клас позначено `@MainActor`).
    func load() async {
        state = .loading
        do {
            let quote = try await service.fetchRandomQuote()
            state = .loaded(quote)
        } catch let error as NetworkError {
            state = (error == .empty) ? .empty : .failed(error.localizedDescription)
        } catch {
            state = .failed(error.localizedDescription)
        }
    }
}
