import Foundation

/// Мінімальна абстракція над транспортом HTTP-запиту.
///
/// Тонкий протокол навколо `URLSession.data(for:)` — потрібен лише для того,
/// щоб у тестах підставити фейковий транспорт (`MockHTTPClient`) і перевірити
/// обробку кожного виду відмови без реального мережевого виклику.
protocol HTTPClient {
    func data(for request: URLRequest) async throws -> (Data, URLResponse)
}

extension URLSession: HTTPClient {}
