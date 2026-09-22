import Foundation

/// Що спровокувало тягу. `enum` із власною поведінкою (заголовок, іконка).
enum CravingTrigger: String, CaseIterable, Codable, Hashable, Identifiable {
    case stress
    case coffee
    case alcohol
    case afterMeal
    case boredom
    case social
    case other

    var id: String { rawValue }

    var title: String {
        switch self {
        case .stress: return "Стрес"
        case .coffee: return "Кава"
        case .alcohol: return "Алкоголь"
        case .afterMeal: return "Після їжі"
        case .boredom: return "Нудьга"
        case .social: return "Компанія"
        case .other: return "Інше"
        }
    }

    var symbolName: String {
        switch self {
        case .stress: return "bolt.heart"
        case .coffee: return "cup.and.saucer"
        case .alcohol: return "wineglass"
        case .afterMeal: return "fork.knife"
        case .boredom: return "hourglass"
        case .social: return "person.2"
        case .other: return "ellipsis.circle"
        }
    }
}
