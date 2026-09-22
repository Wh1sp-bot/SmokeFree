import Foundation

/// Сутність №2: етап відновлення організму.
///
/// Тексти — загальна публічна інформація (узагальнення рекомендацій ВООЗ, CDC та
/// American Cancer Society), а не медична порада. Значення орієнтовні й
/// індивідуальні.
struct HealthMilestone: Identifiable, Equatable {
    let id: String
    let title: String
    let detail: String
    /// Через скільки часу без нікотину етап вважається досягнутим.
    let requiredInterval: TimeInterval
    /// Людський підпис порога («20 хвилин», «1 рік»).
    let thresholdLabel: String
    /// Назва SF Symbol.
    let symbolName: String

    func isReached(after elapsed: TimeInterval) -> Bool {
        elapsed >= requiredInterval
    }

    /// Частка виконання від 0 до 1 (обмежена, щоб не виходити за межі шкали).
    func fraction(after elapsed: TimeInterval) -> Double {
        guard requiredInterval > 0 else { return 1 }
        return min(1, max(0, elapsed / requiredInterval))
    }
}

extension HealthMilestone {
    /// Каталог етапів, відсортований за зростанням порога.
    static let catalog: [HealthMilestone] = [
        HealthMilestone(
            id: "m20min", title: "Пульс і тиск наближаються до норми",
            detail: "Уже за 20 хвилин без сигарети частота серцевих скорочень і артеріальний тиск починають знижуватися.",
            requiredInterval: 20 * TimeSpan.minute, thresholdLabel: "20 хвилин", symbolName: "heart.fill"),
        HealthMilestone(
            id: "m24h", title: "Чадний газ виводиться з крові",
            detail: "Протягом доби рівень чадного газу в крові нормалізується, тканини отримують більше кисню.",
            requiredInterval: 24 * TimeSpan.hour, thresholdLabel: "24 години", symbolName: "wind"),
        HealthMilestone(
            id: "m48h", title: "Повертаються нюх і смак",
            detail: "Закінчення нервових волокон починають відновлюватися — запахи та смак відчуваються яскравіше.",
            requiredInterval: 48 * TimeSpan.hour, thresholdLabel: "48 годин", symbolName: "nose.fill"),
        HealthMilestone(
            id: "m72h", title: "Нікотин майже виведено",
            detail: "Нікотин переважно залишає організм. Симптоми відмови в цей період найсильніші, далі стає легше.",
            requiredInterval: 72 * TimeSpan.hour, thresholdLabel: "3 доби", symbolName: "drop.fill"),
        HealthMilestone(
            id: "m7d", title: "Перший тиждень позаду",
            detail: "Найгостріша фаза абстиненції минає: тяга приходить рідше й триває коротше.",
            requiredInterval: 7 * TimeSpan.day, thresholdLabel: "1 тиждень", symbolName: "calendar"),
        HealthMilestone(
            id: "m14d", title: "Покращується кровообіг",
            detail: "Кровообіг поступово покращується, фізичні навантаження даються легше.",
            requiredInterval: 14 * TimeSpan.day, thresholdLabel: "2 тижні", symbolName: "figure.walk"),
        HealthMilestone(
            id: "m30d", title: "Менше кашлю та задишки",
            detail: "Війчасті клітини дихальних шляхів відновлюються, кашель і задишка стають слабшими.",
            requiredInterval: 30 * TimeSpan.day, thresholdLabel: "1 місяць", symbolName: "lungs.fill"),
        HealthMilestone(
            id: "m90d", title: "Легені працюють краще",
            detail: "Функція легень помітно покращується порівняно з періодом паління.",
            requiredInterval: 90 * TimeSpan.day, thresholdLabel: "3 місяці", symbolName: "lungs"),
        HealthMilestone(
            id: "m1y", title: "Ризик хвороб серця вдвічі менший",
            detail: "Ризик ішемічної хвороби серця приблизно вдвічі нижчий, ніж у людини, яка продовжує палити.",
            requiredInterval: TimeSpan.year, thresholdLabel: "1 рік", symbolName: "heart.circle.fill"),
        HealthMilestone(
            id: "m5y", title: "Нижчий ризик інсульту та раку",
            detail: "Ризик інсульту й низки видів раку суттєво знижується.",
            requiredInterval: 5 * TimeSpan.year, thresholdLabel: "5 років", symbolName: "shield.fill"),
        HealthMilestone(
            id: "m10y", title: "Ризик раку легень удвічі менший",
            detail: "Ризик смерті від раку легень приблизно вдвічі нижчий, ніж у людини, яка продовжує палити.",
            requiredInterval: 10 * TimeSpan.year, thresholdLabel: "10 років", symbolName: "star.circle.fill")
    ]
}
