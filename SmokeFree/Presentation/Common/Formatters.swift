import Foundation

/// Єдине місце форматування чисел, грошей і часу (щоб не дублювати по екранах).
enum Formatters {
    private static let moneyFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        return formatter
    }()

    static func money(_ value: Double, currency: Currency) -> String {
        let number = moneyFormatter.string(from: NSNumber(value: value)) ?? String(format: "%.2f", value)
        return "\(number) \(currency.symbol)"
    }

    /// Ціна для поля вводу: «95» або «95.50».
    static func priceInput(_ value: Double) -> String {
        value.truncatingRemainder(dividingBy: 1) == 0 ? String(Int(value)) : String(format: "%.2f", value)
    }

    /// Таймер «мм:сс».
    static func clock(_ interval: TimeInterval) -> String {
        let total = max(0, Int(interval.rounded(.up)))
        return String(format: "%02d:%02d", total / 60, total % 60)
    }

    /// Стислий проміжок: «3 д 5 год», «2 год 10 хв», «15 хв».
    static func compactDuration(_ interval: TimeInterval) -> String {
        let total = Int(max(0, interval))
        let days = total / Int(TimeSpan.day)
        let hours = (total % Int(TimeSpan.day)) / Int(TimeSpan.hour)
        let minutes = (total % Int(TimeSpan.hour)) / Int(TimeSpan.minute)
        if days > 0 { return hours > 0 ? "\(days) д \(hours) год" : "\(days) д" }
        if hours > 0 { return minutes > 0 ? "\(hours) год \(minutes) хв" : "\(hours) год" }
        return "\(minutes) хв"
    }

    static func dateTime(_ date: Date) -> String {
        date.formatted(date: .abbreviated, time: .shortened)
    }
}
