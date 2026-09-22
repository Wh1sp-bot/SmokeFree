# Підготовка Xcode-проєкту

## Варіант A (рекомендований): XcodeGen

`project.yml` — єдине джерело істини про структуру проєкту, target-и, схеми та
налаштування збирання. `SmokeFree.xcodeproj` з нього генерується.

```bash
brew install xcodegen
xcodegen generate
open SmokeFree.xcodeproj
```

Після додавання нових файлів у каталоги `SmokeFree/` чи `SmokeFreeTests/` достатньо
знову виконати `xcodegen generate`.

> Згенерований `SmokeFree.xcodeproj` можна (і зручно для перевіряючого) закомітити:
> `git add SmokeFree.xcodeproj && git commit -m "chore: add generated Xcode project"`.

## Варіант B: створити проєкт вручну

1. Xcode → **File ▸ New ▸ Project ▸ iOS ▸ App**. Product Name: `SmokeFree`,
   Interface: **SwiftUI**, Language: **Swift**, Organization Identifier: ваш (наприклад, `com.yourname`).
2. **Minimum Deployments** → iOS 17.0. Targets → Supported Destinations → лише iPhone.
3. Видаліть згенеровані `SmokeFreeApp.swift`/`ContentView.swift`, перетягніть у
   проєкт каталог `SmokeFree/` з репозиторію (Create groups, target **SmokeFree**),
   замініть `Assets.xcassets` вмістом з репозиторію.
4. **File ▸ New ▸ Target ▸ Unit Testing Bundle** (`SmokeFreeTests`), додайте файли з `SmokeFreeTests/`.
5. Вкажіть Team у *Signing & Capabilities* (для симулятора необов'язково).

## Типові проблеми

| Симптом | Рішення |
|---|---|
| `xcodegen: command not found` | `brew install xcodegen` |
| `@Observable` не знайдено | Мінімальна iOS має бути 17.0, Xcode ≥ 15 |
| «Signing requires a development team» | Оберіть Team або запускайте на симуляторі |
