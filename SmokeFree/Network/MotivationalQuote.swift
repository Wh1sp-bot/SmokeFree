import Foundation

/// Доменна модель — те, чим користується решта застосунку. Не залежить від
/// формату відповіді конкретного API (це відповідальність DTO нижче).
struct MotivationalQuote: Equatable {
    let text: String
    let author: String
}

/// DTO у форматі ZenQuotes API: `[{ "q": "...", "a": "...", "h": "<blockquote>…</blockquote>" }]`.
/// `h` (готовий HTML) застосунку не потрібен, тому в моделі його немає.
struct ZenQuoteDTO: Decodable {
    let q: String
    let a: String

    var toDomain: MotivationalQuote {
        MotivationalQuote(text: q, author: a)
    }
}
