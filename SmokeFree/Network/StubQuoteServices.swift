import Foundation

/// Стаби для **керованого** відтворення негативних сценаріїв (порожня
/// відповідь, помилка) без вимкнення мережі — саме те, що допускає завдання
/// для негативних випадків. Реальний успішний запит демонструє `ZenQuotesService`.

/// Завжди повертає порожню відповідь.
struct EmptyQuoteService: QuoteFetching {
    func fetchRandomQuote() async throws -> MotivationalQuote {
        throw NetworkError.empty
    }
}

/// Завжди імітує відмову мережі.
struct FailingQuoteService: QuoteFetching {
    func fetchRandomQuote() async throws -> MotivationalQuote {
        throw NetworkError.transport("Демонстраційна помилка мережі.")
    }
}
