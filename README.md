# SmokeFree — застосунок для відмови від паління

Автономний iOS-застосунок (SwiftUI), який допомагає кинути палити: показує час без
нікотину, заощаджені гроші, етапи відновлення організму та підтримує в момент
гострої тяги. Працює **без реєстрації та без обов'язкового інтернету** — дані
лишаються на пристрої.

> Навчальний проєкт курсу «Основи iOS-розробки». Кожна практична робота
> розвиває попередню; актуальну завершену версію позначено Git-тегом `practical-4`.

## Технічні вимоги

| | |
|---|---|
| Xcode | 16.0 або новіший |
| Swift | 5 (режим мови Swift 5) |
| Мінімальна iOS | 17.0 (потрібна для `@Observable`) |
| Пристрої | iPhone (симулятор або реальний) |
| Bundle Identifier | `com.wh1sp.SmokeFree` |

## Як запустити

Xcode-проєкт описано файлом `project.yml` (XcodeGen), тому «чистий checkout»
відтворюється однією командою:

```bash
git clone https://github.com/Wh1sp-bot/SmokeFree.git && cd SmokeFree
brew install xcodegen        # один раз
xcodegen generate            # створює SmokeFree.xcodeproj
open SmokeFree.xcodeproj
```

У Xcode оберіть схему **SmokeFree**, симулятор (наприклад, iPhone 16) і натисніть ⌘R.
Тести — ⌘U. Без XcodeGen: див. [docs/setup-xcode.md](docs/setup-xcode.md).
Секретів у репозиторії немає й не потрібно.

## Предметна область

**Користувач** — доросла людина, яка кинула або хоче кинути палити й хоче бачити
свій прогрес та мати «під рукою» інструмент на випадок тяги.

**Основні сценарії**

1. Вказати дату відмови, скільки цигарок на день і ціну пачки.
2. Бачити, скільки часу без нікотину, скільки цигарок не викурено та грошей заощаджено.
3. Бачити етапи відновлення організму й наступний етап.
4. У момент тяги пройти 3-хвилинну дихальну вправу та зберегти цей епізод.

**Сутності**

| Сутність | Тип | Призначення |
|---|---|---|
| `QuitProfile` | `struct` | Профіль користувача: дата відмови, норма, ціна пачки, валюта |
| `HealthMilestone` | `struct` | Етап відновлення організму (поріг часу, опис, іконка) |
| `CravingEvent` | `struct` | Епізод тяги, який користувач пережив |
| `CravingJournal` | `class` | Спільний журнал епізодів (`Data/Repositories/`) |
| `Currency`, `CravingTrigger` | `enum` | Скінченні множини значень |
| `QuitProgress` | `struct` | Результат розрахунку прогресу на момент часу |
| `BreathingPattern` | `protocol` + `struct` | Техніка дихання (Strategy): `BoxBreathing`, `FourSevenEightBreathing`, `CalmBreathing` |

## Практична робота 1 — Swift-основи та Git

### Де в коді реалізовано потрібні конструкції

| Вимога | Де дивитися |
|---|---|
| `struct` | `Domain/Models/QuitProfile.swift`, `HealthMilestone.swift`, `CravingEvent.swift`, `QuitProgress.swift` |
| `class` | `Data/Repositories/CravingJournal.swift` |
| `protocol` | `Domain/Logic/ProgressCalculating.swift` (`ProgressCalculating`, реалізація `ProgressCalculator`) |
| `enum` | `Domain/Models/Currency.swift`, `CravingTrigger.swift`, `QuitProfile.swift` (`ProfileValidationError`), `TimeSpan.swift` |
| `var` / `let` | `Demo/ConsoleScenario.swift` (`let profile`, `var lines`, `var profileCopy`) |
| Властивості (збережені й обчислювані) | `QuitProfile.pricePerCigarette`, `dailySavings`; `QuitProgress.days/hours/minutes` |
| Методи | `HealthMilestone.isReached(after:)`, `CravingJournal.add(_:)`, `ProgressCalculator.progress(for:at:)` |
| Ініціалізація | `QuitProfile.init(...) throws` (валідація), `CravingEvent.init(...)`, `CravingJournal.init(events:)` |
| Колекції | `HealthMilestone.catalog`, `CravingJournal.events` |
| Optional + безпечне розгортання | `CravingJournal.mostCommonTrigger() -> CravingTrigger?`, `if let next = …first(where:)`, `try?` у `ConsoleScenario` |
| Умовні конструкції | `guard`/`if`/`switch` у `QuitProfile`, `ConsoleScenario`, `Currency` |
| Обробка елементів колекції | `filter`, `map`, `first(where:)`, `for … in … enumerated()` у `ConsoleScenario` |

### Завершений сценарій і як його перевірити

Сценарій `ConsoleScenario` (`Demo/ConsoleScenario.swift`) виконується при запуску:
створює профіль → відхиляє некоректний → рахує прогрес → визначає досягнуті та
наступний етапи → веде журнал тяги (демонструє `class` vs `struct`).

1. Із практичної 2 сценарій живе поруч з повним застосунком. Щоб побачити саме
   його вивід: Product ▸ Scheme ▸ Edit Scheme ▸ Run ▸ Arguments → додати
   `-console-demo` → ⌘R → результат виведеться в консоль Xcode (`All Output`)
   при старті, до появи звичайного інтерфейсу.
2. Запустіть unit-тести (⌘U): `QuitProfileTests`, `ProgressCalculatorTests`,
   `HealthMilestoneTests`, `CravingJournalTests`.

Очікуваний початок виводу:

```
=== SmokeFree · Практична робота 1 ===
Профіль: 15 цигарок/день, пачка 20 шт. за 95.00 ₴
Профіль із 0 цигарок/день відхилено валідацією ✔︎
Без нікотину: 3 д 5 год 20 хв
Не викурено: 48 цигарок
…
```

Відповіді на питання до захисту: [docs/defense/practical-1.md](docs/defense/practical-1.md).

## Практична робота 2 — архітектура та патерни проєктування

Продовжує практичну 1 на тому самому проєкті. Обрана архітектура — **MVVM**;
обґрунтування, схема компонентів, три категорії патернів (Builder, Adapter,
Strategy), пояснення SOLID і перевірка на антипатерни — у
[docs/architecture.md](docs/architecture.md). Відповіді на питання до захисту —
[docs/defense/practical-2.md](docs/defense/practical-2.md).

### Структура проєкту (за відповідальністю)

```
SmokeFree/
├── App/            # SmokeFreeApp (@main), AppContainer — composition root (DI)
├── Domain/         # моделі, чиста бізнес-логіка, Builder, Strategy — не залежить від UIKit/SwiftUI
│   ├── Models/
│   ├── Logic/
│   ├── Builders/
│   └── Breathing/
├── Data/           # доступ до даних: репозиторії + DataStoring (протокол) + адаптери сховища
│   ├── Repositories/
│   └── Storage/
├── Services/       # системні можливості за протоколом (Adapter): вібрація
│   └── Haptics/
├── Network/        # мережевий шар: HTTPClient, NetworkError, DTO/модель, ZenQuotesService, стаби
├── Presentation/    # MVVM: View + ViewModel по одному екрану на каталог
│   ├── Home/  Profile/  SOS/  Milestones/  History/  Root/
│   ├── Navigation/  # AppRouter (Coordinator), AppRoute, AppSheet
│   └── Common/ Components/  # спільне форматування та UI-компоненти
└── Demo/           # ConsoleScenario практичної 1 (запуск: аргумент -console-demo)
```

Демонстраційний режим (без реєстрації, дані в пам'яті): аргумент запуску
`-demo-data` (Product ▸ Scheme ▸ Edit Scheme ▸ Run ▸ Arguments).

### Де в коді відповідність «патерн / принцип — компонент — призначення»

Повна таблиця — у [docs/architecture.md](docs/architecture.md). Коротко:

| Патерн / принцип | Компонент | Призначення |
|---|---|---|
| Builder (породжувальний) | `Domain/Builders/QuitProfileBuilder.swift` | Покрокове збирання профілю з формою; валідний продукт лише в `build()` |
| Adapter (структурний) | `Data/Storage/UserDefaultsStorage.swift`, `Services/Haptics/CoreHapticsAdapter.swift` | Системні API за доменними протоколами `DataStoring` / `HapticsProviding` |
| Strategy (поведінковий) | `Domain/Breathing/BreathingPattern.swift` | Взаємозамінні техніки дихання за одним інтерфейсом |
| SOLID | `docs/architecture.md` → розділ «SOLID» | Кожен принцип із прикладом із коду |

## Практична робота 3 — навігація між екранами

Продовжує практичну 2. Карта переходів, відповідальність Coordinator/Router,
передавання даних та анімації — у [docs/navigation.md](docs/navigation.md).
Відповіді на питання до захисту — [docs/defense/practical-3.md](docs/defense/practical-3.md).
Чекліст для скриншотів/відео проходження сценарію: [docs/screenshots/](docs/screenshots/).
Медіафайли потрібно додати після фінальної перевірки на симуляторі.

### Екрани та навігація

| Екран | Тип переходу | Де в коді |
|---|---|---|
| Прогрес (Home) | стартовий | `Presentation/Home/HomeView.swift` |
| Деталі етапу | push (стек), передається `id` | `Presentation/Milestones/MilestoneDetailView.swift` |
| Журнал тяги | push (стек) | `Presentation/History/HistoryView.swift` |
| Редагування профілю | modal (`.sheet`) | `Presentation/Profile/ProfileFormView.swift` (режим `.edit`) |
| Нотатка до епізоду | modal (`.sheet`), передається сутність `CravingEvent` | `Presentation/History/NoteEditorView.swift` |

Навігацією керує `AppRouter` (`Presentation/Navigation/AppRouter.swift`) —
Coordinator/Router, відокремлений від View: `push`/`pop`/`popToRoot` для стека,
`presentedSheet` для модалок. Екрани викликають лише методи роутера й не
створюють `NavigationLink(destination:)` одне на одного.

Анімації, пов'язані зі станом/дією: розгортання пояснення на екрані деталей
етапу, заповнення кільця прогресу, зміна ваги кнопки «Зберегти» залежно від
уведеного тексту — детально в [docs/navigation.md](docs/navigation.md).

## Практична робота 4 — мережевий шар

Продовжує практичну 3. Джерело даних, мережевий компонент, стани екрана,
обробка відмов і кроки перевірки — у [docs/networking.md](docs/networking.md).
Відповіді на питання до захисту — [docs/defense/practical-4.md](docs/defense/practical-4.md).

**Джерело даних**: [ZenQuotes API](https://zenquotes.io/) — `GET https://zenquotes.io/api/random`,
без реєстрації й без ключа. Мотиваційна цитата показується на екрані
«Прогрес» (картка `MotivationCardView`) поруч із лічильниками.

**Мережевий компонент**: `Network/ZenQuotesService.swift` — єдине місце з
`URLSession`. Абстракція `QuoteFetching` дозволяє `AppContainer` підмінити
реалізацію для демонстрації негативних сценаріїв без вимкнення мережі:

| Аргумент запуску | Ефект |
|---|---|
| (без аргументів) | реальний запит до ZenQuotes API |
| `-quote-empty` | керована порожня відповідь (`EmptyQuoteService`) |
| `-quote-error` | керована помилка мережі (`FailingQuoteService`) |

Додається в Product ▸ Scheme ▸ Edit Scheme ▸ Run ▸ Arguments ▸ Arguments
Passed On Launch (можна поєднувати з `-demo-data`).

Стани екрана — `MotivationViewModel.State`: `.loading` → `.loaded` /
`.empty` / `.failed(повідомлення)` з кнопкою «Повторити». Відмови
розрізнено на транспортну помилку, невдалий HTTP-статус (перевіряється до
декодування) і помилку декодування (`Network/NetworkError.swift`).

## Git

- Віддалений репозиторій: <https://github.com/Wh1sp-bot/SmokeFree>
- `.gitignore` виключає `xcuserdata`, `DerivedData`, `build`, `.DS_Store`, ключі та
  сертифікати. У репозиторії лишаються код, `project.yml`, ресурси, тести й документація.
- Тег фінальної версії: `practical-4`.

> Історія початкової реалізації була імпортована одним комітом. Подальші
> виправлення оформлено окремими змістовними комітами без переписування
> опублікованої історії.
