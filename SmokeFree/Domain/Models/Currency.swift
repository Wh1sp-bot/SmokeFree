import Foundation

/// Валюта, у якій користувач рахує заощадження.
///
/// `enum` — бо множина значень скінченна й відома наперед; `rawValue` — код ISO 4217.
enum Currency: String, CaseIterable, Codable, Identifiable {
    case uah = "UAH"
    case usd = "USD"
    case eur = "EUR"
    case pln = "PLN"

    var id: String { rawValue }

    var symbol: String {
        switch self {
        case .uah: return "₴"
        case .usd: return "$"
        case .eur: return "€"
        case .pln: return "zł"
        }
    }

    var displayName: String {
        switch self {
        case .uah: return "Гривня"
        case .usd: return "Долар США"
        case .eur: return "Євро"
        case .pln: return "Злотий"
        }
    }
}
