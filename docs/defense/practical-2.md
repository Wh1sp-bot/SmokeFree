# Практична 2 — підготовка до захисту

## Чому для проєкту обрано саме цю архітектуру? Які її обмеження?

Обрано **MVVM**: екрани переважно показують і реагують на зміну стану, а не
керують складним багатоекранним потоком (де виправдана VIPER) чи великою
командою з чіткими межами модулів. SwiftUI + `@Observable` роблять зв'язок
View ↔ ViewModel по суті безкоштовним. Обмеження: на дуже простих екранах
MVVM додає прошарок, який може виглядати надлишковим; при зростанні кількості
екранів ViewModel-и потребують дисципліни, щоб не перетворитися на «масивні».

## Чим архітектура відрізняється від патерна проєктування?

Архітектура (MVVM) визначає **межі шарів** застосунку загалом: хто за що
відповідає на рівні всього проєкту (View / ViewModel / Domain / Data).
Патерн проєктування (Builder, Adapter, Strategy) розв'язує **локальну задачу**
всередині одного шару чи навіть одного класу. Архітектура — про структуру
проєкту; патерн — про структуру рішення конкретної проблеми.

## Яку проблему розв'язує кожен використаний патерн?

- **Builder** (`QuitProfileBuilder`) — дозволяє збирати профіль покроково
  (форма) без проміжних невалідних об'єктів `QuitProfile`; валідація — лише
  в `build()`.
- **Adapter** (`UserDefaultsStorage`, `CoreHapticsAdapter`) — ховає незручний
  системний API (`UserDefaults`, `CHHapticEngine`) за простим доменним
  протоколом (`DataStoring`, `HapticsProviding`).
- **Strategy** (`BreathingPattern` і реалізації) — дозволяє мати кілька
  взаємозамінних технік дихання з однаковим інтерфейсом; нова техніка не
  вимагає зміни `BreathingSchedule`.

## Як пояснити кожен принцип SOLID на прикладі проєкту?

Див. розділ «SOLID» у [docs/architecture.md](../architecture.md) — там кожен
принцип має конкретний приклад із коду проєкту.

## Чим Dependency Injection відрізняється від Dependency Inversion?

- **Dependency Inversion** (принцип, «D» у SOLID) — верхні шари мають залежати
  від абстракцій, а не від деталей: `HomeViewModel` залежить від протоколу
  `ProfileProviding`, а не від класу `ProfileRepository`.
- **Dependency Injection** (техніка) — *спосіб* передати конкретну реалізацію
  залежному коду: через `init`. У проєкті це робить `AppContainer`:
  `HomeViewModel(repository: profileRepository, …)`.

Інверсія — це *принцип*, ін'єкція — *механізм*, яким цей принцип втілюється в коді.

## Як перевірити бізнес-логіку окремо від UI та реального джерела даних?

Unit-тести підміняють залежності тестовими двійниками
(`SmokeFreeTests/Support/TestDoubles.swift`): `MockProfileRepository`,
`MockJournal`, `SpyHaptics`, `FixedCalculator`, `FailingStorage`. Наприклад,
`HomeViewModelTests.testSnapshotUsesInjectedDependencies` перевіряє
`HomeViewModel` із фіксованим `QuitProgress` — без `UserDefaults`, реального
годинника чи SwiftUI. `BreathingViewModelTests` керує часом вручну через
`tick(now:)`, тому тест не чекає реальні 3 хвилини.

## Демонстрація

1. Показати схему `docs/diagrams/architecture.mmd`.
2. `⌘R` зі стартовим аргументом `-demo-data` → готовий профіль і журнал без
   реєстрації та мережі.
3. Пройти сценарій: створення профілю (Builder) → головний екран (MVVM) →
   SOS-вправа зі зміною техніки (Strategy).
4. `⌘U` → усі тести зелені, включно з `QuitProfileBuilderTests`, `StorageTests`,
   `BreathingTests`.
5. `git log --oneline` і фінальний тег `practical-4`.
