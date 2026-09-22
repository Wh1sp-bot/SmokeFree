import Foundation

/// Абстракція розрахунку прогресу.
///
/// `protocol` описує *що* потрібно (контракт), а не *як* це робиться. Тому
/// реалізацію можна підмінити (наприклад, у тестах — фіксованою).
protocol ProgressCalculating {
    func progress(for profile: QuitProfile, at date: Date) -> QuitProgress
}

/// Стандартна реалізація: лінійний розрахунок від дати відмови.
struct ProgressCalculator: ProgressCalculating {
    func progress(for profile: QuitProfile, at date: Date) -> QuitProgress {
        // Якщо дата відмови ще в майбутньому — прогрес нульовий, а не від'ємний.
        let elapsed = max(0, date.timeIntervalSince(profile.quitDate))
        let elapsedDays = elapsed / TimeSpan.day

        let avoided = Int((elapsedDays * Double(profile.cigarettesPerDay)).rounded(.down))
        let saved = elapsedDays * profile.dailySavings

        return QuitProgress(elapsed: elapsed, cigarettesAvoided: avoided, moneySaved: saved)
    }
}
