import Foundation

/// Абстракція джерела мотиваційних цитат. `HomeViewModel`-сусід —
/// `MotivationViewModel` — залежить лише від цього протоколу (Dependency
/// Inversion), тому джерело можна підмінити стабом для демонстрації порожньої
/// відповіді чи помилки без вимкнення мережі.
protocol QuoteFetching {
    func fetchRandomQuote() async throws -> MotivationalQuote
}
