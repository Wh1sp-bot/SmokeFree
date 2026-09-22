import SwiftUI

struct ProfileFormView: View {
    @State private var viewModel: ProfileFormViewModel
    @FocusState private var priceFocused: Bool

    init(viewModel: ProfileFormViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        @Bindable var viewModel = viewModel

        NavigationStack {
            Form {
                Section("Коли ви кинули?") {
                    DatePicker(
                        "Дата й час",
                        selection: $viewModel.quitDate,
                        in: ...Date(),
                        displayedComponents: [.date, .hourAndMinute]
                    )
                }

                Section("Скільки палили") {
                    Stepper(value: $viewModel.cigarettesPerDay, in: QuitProfile.cigarettesPerDayRange) {
                        LabeledContent("Цигарок на день", value: "\(viewModel.cigarettesPerDay)")
                    }
                    Stepper(value: $viewModel.cigarettesPerPack, in: QuitProfile.cigarettesPerPackRange) {
                        LabeledContent("Цигарок у пачці", value: "\(viewModel.cigarettesPerPack)")
                    }
                }

                Section("Вартість пачки") {
                    TextField("Ціна пачки", text: $viewModel.packPriceText)
                        .keyboardType(.decimalPad)
                        .focused($priceFocused)
                    Picker("Валюта", selection: $viewModel.currency) {
                        ForEach(Currency.allCases) { currency in
                            Text("\(currency.displayName) (\(currency.symbol))").tag(currency)
                        }
                    }
                }

                if let message = viewModel.errorMessage {
                    Section {
                        Label(message, systemImage: "exclamationmark.triangle.fill")
                            .foregroundStyle(.red)
                    }
                }

                Section {
                    Button(viewModel.saveButtonTitle) {
                        priceFocused = false
                        viewModel.save()
                    }
                    .frame(maxWidth: .infinity)
                    .fontWeight(.semibold)
                }
            }
            .navigationTitle(viewModel.title)
            .scrollDismissesKeyboard(.interactively)
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Готово") { priceFocused = false }
                }
            }
        }
    }
}
