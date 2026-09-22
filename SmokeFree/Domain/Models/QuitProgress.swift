import Foundation

/// Результат розрахунку прогресу на певний момент часу (значення, без поведінки).
struct QuitProgress: Equatable {
    /// Час без нікотину в секундах (ніколи не від'ємний).
    let elapsed: TimeInterval
    let cigarettesAvoided: Int
    let moneySaved: Double

    var days: Int { Int(elapsed) / Int(TimeSpan.day) }
    var hours: Int { (Int(elapsed) % Int(TimeSpan.day)) / Int(TimeSpan.hour) }
    var minutes: Int { (Int(elapsed) % Int(TimeSpan.hour)) / Int(TimeSpan.minute) }
    var seconds: Int { Int(elapsed) % Int(TimeSpan.minute) }
}
