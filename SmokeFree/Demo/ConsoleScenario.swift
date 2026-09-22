import Foundation

/// Завершений сценарій практичної роботи 1.
///
/// Створює профіль → рахує прогрес → визначає етапи відновлення → веде журнал
/// тяги. Результат повертається як рядки: їх виводимо в консоль Xcode та
/// показуємо на екрані.
struct ConsoleScenario {
    /// Залежність передається ззовні (через `init`), а не створюється всередині.
    let calculator: ProgressCalculating

    func run(now: Date = Date()) -> [String] {
        var lines: [String] = ["=== SmokeFree · Практична робота 1 ==="]

        // 1. Створення сутності. `let` — значення не змінюється після створення.
        let quitDate = now.addingTimeInterval(-(3 * TimeSpan.day + 5 * TimeSpan.hour + 20 * TimeSpan.minute))
        let profile: QuitProfile
        do {
            profile = try QuitProfile(
                quitDate: quitDate, cigarettesPerDay: 15, cigarettesPerPack: 20,
                packPrice: 95, currency: .uah
            )
        } catch {
            return lines + ["Профіль не створено: \(error.localizedDescription)"]
        }
        lines.append("Профіль: \(profile.cigarettesPerDay) цигарок/день, пачка \(profile.cigarettesPerPack) шт. за \(money(profile.packPrice, profile.currency))")

        // 2. Валідація: некоректні дані відхиляються (Optional через try?).
        let invalid = try? QuitProfile(
            quitDate: quitDate, cigarettesPerDay: 0, cigarettesPerPack: 20,
            packPrice: 95, currency: .uah
        )
        if invalid == nil {
            lines.append("Профіль із 0 цигарок/день відхилено валідацією ✔︎")
        }

        // 3. Розрахунок прогресу через протокол.
        let progress = calculator.progress(for: profile, at: now)
        lines.append("Без нікотину: \(progress.days) д \(progress.hours) год \(progress.minutes) хв")
        lines.append("Не викурено: \(progress.cigarettesAvoided) цигарок")
        lines.append("Заощаджено: \(money(progress.moneySaved, profile.currency))")

        // 4. Колекція + умова + обробка елементів + безпечне розгортання Optional.
        let reached = HealthMilestone.catalog.filter { $0.isReached(after: progress.elapsed) }
        lines.append("Досягнуто етапів: \(reached.count) з \(HealthMilestone.catalog.count)")
        for (index, milestone) in reached.enumerated() {
            lines.append("  \(index + 1). [\(milestone.thresholdLabel)] \(milestone.title)")
        }
        if let next = HealthMilestone.catalog.first(where: { !$0.isReached(after: progress.elapsed) }) {
            let remaining = next.requiredInterval - progress.elapsed
            lines.append("Наступний етап: «\(next.title)» — ще \(duration(remaining))")
        } else {
            lines.append("Усі етапи досягнуто 🎉")
        }

        // 5. class vs struct: семантика посилання проти семантики значення.
        let journal = CravingJournal()
        let sameJournal = journal // те саме посилання на той самий об'єкт
        journal.add(CravingEvent(startedAt: now.addingTimeInterval(-2 * TimeSpan.day), duration: 180, wasCompleted: true, trigger: .coffee))
        journal.add(CravingEvent(startedAt: now.addingTimeInterval(-1 * TimeSpan.day), duration: 60, wasCompleted: false, trigger: .stress))
        sameJournal.add(CravingEvent(startedAt: now.addingTimeInterval(-3 * TimeSpan.hour), duration: 180, wasCompleted: true, trigger: .coffee))
        lines.append("Журнал (class): journal.events = \(journal.events.count), sameJournal.events = \(sameJournal.events.count) — один об'єкт")

        var profileCopy = profile // struct копіюється
        profileCopy.cigarettesPerDay = 5
        lines.append("Профіль (struct): оригінал \(profile.cigarettesPerDay), копія \(profileCopy.cigarettesPerDay) — незалежні значення")

        // 6. Фільтрація змінної колекції та Optional-результат.
        lines.append("Подолано тяг: \(journal.completedCount) з \(journal.events.count)")
        lines.append("Через каву: \(journal.events(triggeredBy: .coffee).count)")
        if let trigger = journal.mostCommonTrigger() {
            lines.append("Найчастіший тригер: \(trigger.title)")
        }

        return lines
    }

    // MARK: - Форматування

    private func money(_ value: Double, _ currency: Currency) -> String {
        "\(String(format: "%.2f", value)) \(currency.symbol)"
    }

    private func duration(_ interval: TimeInterval) -> String {
        let total = Int(max(0, interval))
        let days = total / Int(TimeSpan.day)
        let hours = (total % Int(TimeSpan.day)) / Int(TimeSpan.hour)
        let minutes = (total % Int(TimeSpan.hour)) / Int(TimeSpan.minute)
        return "\(days) д \(hours) год \(minutes) хв"
    }
}
