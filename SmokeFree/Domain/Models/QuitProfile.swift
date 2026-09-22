import Foundation

/// Помилки валідації даних профілю.
enum ProfileValidationError: Error, Equatable, LocalizedError {
    case invalidCigarettesPerDay(Int)
    case invalidCigarettesPerPack(Int)
    case invalidPackPrice

    var errorDescription: String? {
        switch self {
        case .invalidCigarettesPerDay(let value):
            let range = QuitProfile.cigarettesPerDayRange
            return "Кількість цигарок на день має бути від \(range.lowerBound) до \(range.upperBound) (введено \(value))."
        case .invalidCigarettesPerPack(let value):
            let range = QuitProfile.cigarettesPerPackRange
            return "Кількість цигарок у пачці має бути від \(range.lowerBound) до \(range.upperBound) (введено \(value))."
        case .invalidPackPrice:
            return "Ціна пачки має бути додатним числом."
        }
    }
}

/// Сутність №1: профіль відмови від паління.
///
/// Це `struct` (семантика значення): профіль — прості дані без «особистості».
/// Копія профілю незалежна від оригіналу, тому зміни в одному місці не
/// «протікають» в інше. Поля `var` можна змінювати, `id` — `let`, він незмінний.
struct QuitProfile: Codable, Equatable, Identifiable {
    static let cigarettesPerDayRange = 1...200
    static let cigarettesPerPackRange = 1...100

    let id: UUID
    var quitDate: Date
    var cigarettesPerDay: Int
    var cigarettesPerPack: Int
    var packPrice: Double
    var currency: Currency

    /// Валідуючий ініціалізатор: неможливо створити профіль із некоректними даними.
    init(
        id: UUID = UUID(),
        quitDate: Date,
        cigarettesPerDay: Int,
        cigarettesPerPack: Int,
        packPrice: Double,
        currency: Currency
    ) throws {
        guard Self.cigarettesPerDayRange.contains(cigarettesPerDay) else {
            throw ProfileValidationError.invalidCigarettesPerDay(cigarettesPerDay)
        }
        guard Self.cigarettesPerPackRange.contains(cigarettesPerPack) else {
            throw ProfileValidationError.invalidCigarettesPerPack(cigarettesPerPack)
        }
        guard packPrice.isFinite, packPrice > 0 else {
            throw ProfileValidationError.invalidPackPrice
        }
        self.id = id
        self.quitDate = quitDate
        self.cigarettesPerDay = cigarettesPerDay
        self.cigarettesPerPack = cigarettesPerPack
        self.packPrice = packPrice
        self.currency = currency
    }

    // MARK: - Обчислювані властивості

    /// Ціна однієї цигарки.
    var pricePerCigarette: Double {
        packPrice / Double(cigarettesPerPack)
    }

    /// Скільки користувач витрачав би щодня, якби не кинув.
    var dailySavings: Double {
        pricePerCigarette * Double(cigarettesPerDay)
    }
}
