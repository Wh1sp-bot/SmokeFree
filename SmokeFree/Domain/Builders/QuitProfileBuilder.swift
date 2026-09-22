import Foundation

/// **Патерн Builder (породжувальний).**
/// Профіль збирається по крокам (форма вводу), має значення за замовчуванням, а
/// перевірку коректності виконує лише в `build()`. Це відокремлює *збирання*
/// (форма, часткові дані) від *валідного продукту* (`QuitProfile`), який
/// неможливо створити некоректним.
///
/// Учасники: Builder — `QuitProfileBuilder`; Product — `QuitProfile`;
/// Director — `ProfileFormViewModel`.
struct QuitProfileBuilder {
    private var id = UUID()
    private var quitDate = Date()
    private var cigarettesPerDay = 10
    private var cigarettesPerPack = 20
    private var packPrice: Double?
    private var currency: Currency = .uah

    init() {}

    /// Builder для редагування: стартує зі значень наявного профілю (id зберігається).
    init(editing profile: QuitProfile) {
        id = profile.id
        quitDate = profile.quitDate
        cigarettesPerDay = profile.cigarettesPerDay
        cigarettesPerPack = profile.cigarettesPerPack
        packPrice = profile.packPrice
        currency = profile.currency
    }

    func withQuitDate(_ value: Date) -> QuitProfileBuilder {
        var copy = self
        copy.quitDate = value
        return copy
    }

    func withCigarettesPerDay(_ value: Int) -> QuitProfileBuilder {
        var copy = self
        copy.cigarettesPerDay = value
        return copy
    }

    func withCigarettesPerPack(_ value: Int) -> QuitProfileBuilder {
        var copy = self
        copy.cigarettesPerPack = value
        return copy
    }

    /// `nil` означає «ціну ще не введено» — `build()` це відхилить.
    func withPackPrice(_ value: Double?) -> QuitProfileBuilder {
        var copy = self
        copy.packPrice = value
        return copy
    }

    func withCurrency(_ value: Currency) -> QuitProfileBuilder {
        var copy = self
        copy.currency = value
        return copy
    }

    func build() throws -> QuitProfile {
        guard let packPrice else { throw ProfileValidationError.invalidPackPrice }
        return try QuitProfile(
            id: id, quitDate: quitDate, cigarettesPerDay: cigarettesPerDay,
            cigarettesPerPack: cigarettesPerPack, packPrice: packPrice, currency: currency
        )
    }
}
