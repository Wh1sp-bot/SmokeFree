# Навігація — практична робота 3

## Карта переходів

Джерело: [docs/diagrams/navigation.mmd](diagrams/navigation.mmd).

```mermaid
flowchart LR
    Start(["Запуск"]) -->|профіль відсутній| Create["Створення профілю\n(ProfileFormView, mode: create)"]
    Start -->|профіль є| Home

    Create -->|Builder.build() успішний → save()| Home["Прогрес (Home)\nсписок показників"]

    Home -->|push id етапу| Detail["Деталі етапу\n(MilestoneDetailView)"]
    Detail -->|pop / swipe back| Home

    Home -->|push| History["Журнал тяги\n(HistoryView, список)"]
    History -->|pop / swipe back| Home

    Home -->|"modal: presentEditProfile()"| EditProfile["Редагування профілю\n(ProfileFormView, mode: edit)"]
    EditProfile -->|save → dismiss| Home

    History -->|"modal: presentNote(for:)"| Note["Нотатка до епізоду\n(NoteEditorView)"]
    Note -->|save/cancel → dismiss| History

    Home -.вкладка.-> SOS["SOS\n(дихальна вправа)"]
    SOS -.вкладка.-> Home
```

Три змістовні екрани сценарію (за завданням): **список показників** (Home) →
**деталі** (MilestoneDetailView) та **список** (HistoryView) → **редагування**
(ProfileFormView у режимі `.edit`, модально) і **створення нотатки**
(NoteEditorView, модально).

## Відповідальність Coordinator/Router

`AppRouter` (`Presentation/Navigation/AppRouter.swift`) — окремий
`@Observable`-об'єкт, не прив'язаний до конкретного `View`:

- **Стекова навігація**: `push(_:)`, `pop()`, `popToRoot()` керують
  `NavigationPath`, яку `ProgressTabView` віддає в `NavigationStack(path:)`.
- **Модальні вікна**: `presentEditProfile()`, `presentNote(for:)`,
  `dismissSheet()` керують `presentedSheet: AppSheet?`, який `ProgressTabView`
  віддає в `.sheet(item:)`.
- **Міжвкладкові переходи**: `showMilestoneDetail(id:)` перемикає вкладку й
  одночасно готує стек — приклад переходу, що не вкладається в один локальний
  `View`.

Екрани (`HomeView`, `HistoryView`) не створюють `NavigationLink(destination:)`
і не знають одне про одного — вони лише викликають методи роутера. Це і є межа
відповідальності Coordinator/Router: **навігаційні рішення** (куди перейти)
відокремлені від **вмісту екрана** (що показати).

## Передавання даних

- **Деталі етапу**: передається лише `id: String` (`ProgressRoute.milestoneDetail(id:)`),
  а не весь `HealthMilestone`. `MilestoneDetailViewModel` сам читає актуальні
  дані з `MilestoneTimeline` за цим `id` — прогрес завжди свіжий, навіть якщо
  час минув, поки користувач був на екрані деталей.
- **Нотатка до епізоду**: у модальне вікно передається сама сутність
  `CravingEvent` (`AppSheet.addCravingNote(CravingEvent)`), бо там потрібні всі
  її поля одразу. Результат повертається через замикання `onSave`, яке викликає
  `CravingJournal.updateNote(for:note:)` — а не через повторний запит сутності.
- **Оновлення попереднього екрана**: `CravingJournal` і `ProfileRepository` —
  `@Observable`. Коли `updateNote` чи `save` змінює дані, `HistoryView` і
  `HomeView` оновлюються автоматично — без ручного «прокидання» колбеків між
  екранами по всьому стеку.

## Модальна презентація

Дві незалежні модалки, обидві через `AppRouter.presentedSheet`:
редагування профілю (`.editProfile`) і нотатка до епізоду (`.addCravingNote`).
`.sheet(item:)` гарантує коректне відкриття/закриття навіть при швидких тапах.

## Анімація, пов'язана зі станом/дією

- **Розгортання деталей** (`MilestoneDetailView`): тап «Чому це важливо»
  розгортає/згортає пояснювальний текст із `withAnimation(.snappy)` і
  `.transition` — саме приклад, названий у завданні, а не стандартний перехід
  між екранами.
- **Зміна стану кнопки** (`NoteEditorView`): кнопка «Зберегти» стає жирною,
  щойно текст нотатки перестає бути порожнім (`.animation(value: trimmed.isEmpty)`).
- Додатково: кільце прогресу на `MilestoneDetailView` плавно домальовується
  (`.animation(value: snapshot.fraction)`), а `MilestoneProgressBar` на Home
  заповнюється при появі (успадковано з практичної 2).

## Перевірка інтерфейсу (виконати в Xcode)

1. **Два розміри екрана**: запустити на симуляторах iPhone SE (3rd gen) і
   iPhone 16 Pro Max — переконатися, що текст на `HomeView`/`MilestoneDetailView`
   не обрізається і не накладається (адаптивна сітка `LazyVGrid`,
   `minimumScaleFactor` на лічильниках).
2. **Клавіатура не блокує форму**: у `ProfileFormView` і `NoteEditorView`
   відкрити поле вводу — перевірити, що `scrollDismissesKeyboard(.interactively)`
   і кнопка «Готово» на клавіатурній панелі дозволяють завершити введення.
3. **Повторні переходи**: кілька разів відкрити/закрити деталі етапу та
   журнал, переконатися, що стек не накопичує зайві екрани (`pop`/swipe back
   повертає рівно на попередній).
4. **Повернення без втрати стану**: змінити нотатку в `NoteEditorView`,
   закрити — переконатися, що `HistoryView` одразу показує оновлений текст.
