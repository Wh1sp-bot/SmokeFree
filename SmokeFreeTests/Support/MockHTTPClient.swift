import Foundation
@testable import SmokeFree

/// Фейковий транспорт: підміняє `URLSession` у тестах, щоб перевірити обробку
/// кожного виду відповіді/відмови без реального мережевого виклику.
final class MockHTTPClient: HTTPClient {
    enum Result {
        case success(status: Int, body: Data)
        case failure(Error)
    }

    var result: Result = .success(status: 200, body: Data("[]".utf8))
    private(set) var requestedURLs: [URL] = []

    func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        if let url = request.url { requestedURLs.append(url) }
        switch result {
        case .failure(let error):
            throw error
        case .success(let status, let body):
            let response = HTTPURLResponse(url: request.url!, statusCode: status, httpVersion: nil, headerFields: nil)!
            return (body, response)
        }
    }
}

struct TransportFailure: Error {}
