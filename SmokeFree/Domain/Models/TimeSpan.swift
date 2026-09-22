import Foundation

/// Іменовані константи часу (у секундах), щоб у коді не було «магічних чисел».
enum TimeSpan {
    static let minute: TimeInterval = 60
    static let hour: TimeInterval = 60 * minute
    static let day: TimeInterval = 24 * hour
    static let year: TimeInterval = 365 * day
}
