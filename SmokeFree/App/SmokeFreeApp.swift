import SwiftUI

@main
struct SmokeFreeApp: App {
    private let container: AppContainer

    init() {
        let arguments = ProcessInfo.processInfo.arguments

        // Сценарій практичної 1 лишається доступним: аргумент запуску `-console-demo`.
        if arguments.contains("-console-demo") {
            ConsoleScenario(calculator: ProgressCalculator()).run().forEach { print($0) }
        }

        // Керована демонстрація негативних мережевих сценаріїв без вимкнення мережі
        // (практична 4): `-quote-empty` — порожня відповідь, `-quote-error` — помилка.
        let quoteOverride: QuoteFetching? =
            arguments.contains("-quote-empty") ? EmptyQuoteService() :
            arguments.contains("-quote-error") ? FailingQuoteService() : nil

        container = arguments.contains("-demo-data")
            ? .demo(quoteOverride: quoteOverride)
            : .live(quoteOverride: quoteOverride)
    }

    var body: some Scene {
        WindowGroup {
            RootView(container: container)
        }
    }
}
