import SwiftUI

/// Модальний редактор нотатки до епізоду тяги. Демонструє передавання сутності
/// (`CravingEvent`) у модальне вікно, повернення результату (`onSave`) та зміну
/// стану кнопки залежно від уведеного тексту.
struct NoteEditorView: View {
    let event: CravingEvent
    let onSave: (String?) -> Void
    let onDismiss: () -> Void

    @State private var text: String
    @FocusState private var isFocused: Bool

    init(event: CravingEvent, onSave: @escaping (String?) -> Void, onDismiss: @escaping () -> Void) {
        self.event = event
        self.onSave = onSave
        self.onDismiss = onDismiss
        _text = State(initialValue: event.note ?? "")
    }

    private var trimmed: String {
        text.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    LabeledContent("Тригер", value: event.trigger.title)
                    LabeledContent("Коли", value: Formatters.dateTime(event.startedAt))
                    LabeledContent("Результат", value: event.wasCompleted ? "Подолано" : "Перервано")
                }
                Section("Нотатка") {
                    TextEditor(text: $text)
                        .frame(minHeight: 120)
                        .focused($isFocused)
                }
            }
            .navigationTitle("Епізод тяги")
            .navigationBarTitleDisplayMode(.inline)
            .scrollDismissesKeyboard(.interactively)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Скасувати") { onDismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    // Стан кнопки змінюється залежно від наявності тексту.
                    Button("Зберегти") {
                        onSave(trimmed.isEmpty ? nil : trimmed)
                    }
                    .fontWeight(trimmed.isEmpty ? .regular : .bold)
                    .animation(.easeInOut(duration: 0.15), value: trimmed.isEmpty)
                }
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Готово") { isFocused = false }
                }
            }
        }
    }
}
