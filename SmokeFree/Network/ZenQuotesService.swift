import Foundation

/// Джерело даних практичної 4: **ZenQuotes API** (https://zenquotes.io) —
/// відкрите, без реєстрації й без ключа на безкоштовному рівні.
///
/// - Базова адреса: `https://zenquotes.io/api`
/// - Endpoint: `GET /random` — одна випадкова цитата.
/// - Параметри: немає.
/// - Формат відповіді: JSON-масив з одним об'єктом `{ "q": String, "a": String, "h": String }`
///   (`q` — текст цитати, `a` — автор, `h` — готовий HTML; тут не використовується).
/// - Авторизація: не потрібна (безкоштовний рівень: до 5 запитів/30 с на IP,
///   обов'язкове посилання на zenquotes.io при показі цитати — див. `MotivationCardView`).
///
/// Єдиний мережевий компонент застосунку: HTTP-виклики не розкидані по екранах —
/// лише тут є `URLSession`/`URLRequest`.
final class ZenQuotesService: QuoteFetching {
    private static let endpoint = URL(string: "https://zenquotes.io/api/random")!

    private let client: HTTPClient
    private let decoder = JSONDecoder()

    init(client: HTTPClient = URLSession.shared) {
        self.client = client
    }

    func fetchRandomQuote() async throws -> MotivationalQuote {
        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await client.data(for: URLRequest(url: Self.endpoint))
        } catch {
            throw NetworkError.transport(error.localizedDescription)
        }

        // Спершу перевіряємо HTTP-статус і лише потім обробляємо тіло як успішне.
        guard let http = response as? HTTPURLResponse else {
            throw NetworkError.transport("Некоректна відповідь сервера.")
        }
        guard (200...299).contains(http.statusCode) else {
            throw NetworkError.badStatus(code: http.statusCode)
        }

        let quotes: [ZenQuoteDTO]
        do {
            quotes = try decoder.decode([ZenQuoteDTO].self, from: data)
        } catch {
            throw NetworkError.decoding(error.localizedDescription)
        }

        guard let first = quotes.first, !first.q.isEmpty else {
            throw NetworkError.empty
        }
        return first.toDomain
    }
}
