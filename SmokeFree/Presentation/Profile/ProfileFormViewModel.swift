import Foundation
import Observation

/// View Model форми профілю. Один клас обслуговує і створення, і редагування.
///
/// Виступає «Director» для `QuitProfileBuilder`: збирає введені значення й просить
/// Builder створити валідний профіль.
@MainActor
@Observable
final class ProfileFormViewModel {
    enum Mode: Equatable {
        case create
        case edit(QuitProfile)
    }

    var quitDate: Date
    var cigarettesPerDay: Int
    var cigarettesPerPack: Int
    var packPriceText: String
    var currency: Currency
    private(set) var errorMessage: String?

    let mode: Mode
    private let repository: ProfileProviding

    init(mode: Mode = .create, repository: ProfileProviding, now: Date = Date()) {
        self.mode = mode
        self.repository = repository
        switch mode {
        case .create:
            quitDate = now
            cigarettesPerDay = 10
            cigarettesPerPack = 20
            packPriceText = ""
            currency = .uah
        case .edit(let profile):
            quitDate = profile.quitDate
            cigarettesPerDay = profile.cigarettesPerDay
            cigarettesPerPack = profile.cigarettesPerPack
            packPriceText = Formatters.priceInput(profile.packPrice)
            currency = profile.currency
        }
    }

    var isEditing: Bool {
        if case .edit = mode { return true }
        return false
    }

    var title: String { isEditing ? "Профіль" : "Ласкаво просимо" }
    var saveButtonTitle: String { isEditing ? "Зберегти зміни" : "Почати відлік" }

    /// Зберігає профіль. Повертає `true` при успіху; інакше заповнює `errorMessage`.
    @discardableResult
    func save() -> Bool {
        let base: QuitProfileBuilder
        switch mode {
        case .create: base = QuitProfileBuilder()
        case .edit(let profile): base = QuitProfileBuilder(editing: profile)
        }

        do {
            let profile = try base
                .withQuitDate(quitDate)
                .withCigarettesPerDay(cigarettesPerDay)
                .withCigarettesPerPack(cigarettesPerPack)
                .withPackPrice(Self.parsePrice(packPriceText))
                .withCurrency(currency)
                .build()
            try repository.save(profile)
            errorMessage = nil
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }

    /// Приймає і «95.5», і «95,5»; порожній чи некоректний ввід → `nil`.
    static func parsePrice(_ text: String) -> Double? {
        let normalized = text
            .trimmingCharacters(in: .whitespaces)
            .replacingOccurrences(of: ",", with: ".")
        return Double(normalized)
    }
}
