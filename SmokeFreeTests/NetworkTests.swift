import XCTest
@testable import SmokeFree

final class ZenQuotesServiceTests: XCTestCase {
    private func json(_ quotes: [(String, String)]) -> Data {
        let array = quotes.map { ["q": $0.0, "a": $0.1, "h": "<blockquote></blockquote>"] }
        return try! JSONSerialization.data(withJSONObject: array)
    }

    func testSuccessfulRequestMapsFirstQuote() async throws {
        let client = MockHTTPClient()
        client.result = .success(status: 200, body: json([("Тримайся.", "Автор"), ("Друга", "Інший")]))
        let service = ZenQuotesService(client: client)

        let quote = try await service.fetchRandomQuote()
        XCTAssertEqual(quote, MotivationalQuote(text: "Тримайся.", author: "Автор"))
        XCTAssertEqual(client.requestedURLs.first, URL(string: "https://zenquotes.io/api/random"))
    }

    func testTransportErrorIsWrapped() async {
        let client = MockHTTPClient()
        client.result = .failure(TransportFailure())
        let service = ZenQuotesService(client: client)

        await XCTAssertThrowsErrorAsync(try await service.fetchRandomQuote()) { error in
            guard case .transport = error as? NetworkError else {
                return XCTFail("Очікувалась .transport, отримано \(error)")
            }
        }
    }

    /// Статус перевіряється ДО спроби декодування: тіло навмисно некоректне,
    /// але помилка все одно має бути саме `.badStatus`, а не `.decoding`.
    func testBadHTTPStatusIsReportedBeforeDecoding() async {
        let client = MockHTTPClient()
        client.result = .success(status: 500, body: Data("не json".utf8))
        let service = ZenQuotesService(client: client)

        await XCTAssertThrowsErrorAsync(try await service.fetchRandomQuote()) { error in
            XCTAssertEqual(error as? NetworkError, .badStatus(code: 500))
        }
    }

    func testDecodingErrorOnMalformedJSON() async {
        let client = MockHTTPClient()
        client.result = .success(status: 200, body: Data("{ не масив }".utf8))
        let service = ZenQuotesService(client: client)

        await XCTAssertThrowsErrorAsync(try await service.fetchRandomQuote()) { error in
            guard case .decoding = error as? NetworkError else {
                return XCTFail("Очікувалась .decoding, отримано \(error)")
            }
        }
    }

    func testEmptyArrayIsReportedAsEmpty() async {
        let client = MockHTTPClient()
        client.result = .success(status: 200, body: json([]))
        let service = ZenQuotesService(client: client)

        await XCTAssertThrowsErrorAsync(try await service.fetchRandomQuote()) { error in
            XCTAssertEqual(error as? NetworkError, .empty)
        }
    }
}

@MainActor
final class MotivationViewModelTests: XCTestCase {
    private struct StubService: QuoteFetching {
        let result: Swift.Result<MotivationalQuote, Error>
        func fetchRandomQuote() async throws -> MotivationalQuote {
            switch result {
            case .success(let quote): return quote
            case .failure(let error): throw error
            }
        }
    }

    func testLoadSuccessUpdatesStateOnMainActor() async {
        let quote = MotivationalQuote(text: "Q", author: "A")
        let vm = MotivationViewModel(service: StubService(result: .success(quote)))
        XCTAssertEqual(vm.state, .idle)

        await vm.load()
        XCTAssertEqual(vm.state, .loaded(quote))
    }

    func testLoadEmptyMapsToEmptyState() async {
        let vm = MotivationViewModel(service: EmptyQuoteService())
        await vm.load()
        XCTAssertEqual(vm.state, .empty)
    }

    func testLoadFailureMapsToFailedStateWithMessage() async {
        let vm = MotivationViewModel(service: FailingQuoteService())
        await vm.load()
        guard case .failed(let message) = vm.state else {
            return XCTFail("Очікувався .failed, отримано \(vm.state)")
        }
        XCTAssertFalse(message.isEmpty)
    }

    func testGenericErrorIsAlsoReportedAsFailed() async {
        let vm = MotivationViewModel(service: StubService(result: .failure(TransportFailure())))
        await vm.load()
        guard case .failed = vm.state else {
            return XCTFail("Очікувався .failed, отримано \(vm.state)")
        }
    }
}

// MARK: - Допоміжне для async XCTAssertThrowsError

func XCTAssertThrowsErrorAsync<T>(
    _ expression: @autoclosure () async throws -> T,
    _ errorHandler: (Error) -> Void,
    file: StaticString = #filePath, line: UInt = #line
) async {
    do {
        _ = try await expression()
        XCTFail("Очікувалась помилка, але виклик завершився успішно", file: file, line: line)
    } catch {
        errorHandler(error)
    }
}
